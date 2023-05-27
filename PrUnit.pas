unit PrUnit;

interface

uses
  windows, SysUtils, Classes,DB, DBClient, Types, Math,ComCtrls,
  Dialogs, frxClass, frxDesgn, frxDBSet, frxBarcode, frxRich, frxExportXLS,
  frxExportPDF, frxExportODF, frxCross, Controls;

  { Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, ComObj, Mask, ComCtrls,
  ToolWin, ImgList, Buttons, Menus, ShellAPI, Registry, Tabs, TntGrids;
   }

const
  CNFName = 'CNName.txt';
  msgCompareOk = 'Сравнение выполнено!';
  msgFileExists = 'Файл с таким именем уже существует. Дописать данные в имеющийся файл?';
  msgNoTerminal = 'Библиотека Terminal.dll не обнаружена. Часть функций программы будет недоступна!';
  msgNoTable = 'Контейнер не загружен.';
  msgNewScanData = 'В программе уже содержатся данные о кодах. Дописать новые данные к уже существующим?';
  msgDelScanData = 'Все данные в сканере будут удалены!';
  msgScanDataEmpty = 'Сканер или файл пусты!';
  msgSaveOk = 'Выгрузка произведена успешно!';
  msgDelScanDataQst = 'Удалить данные в сканере?';
  msgSaveScanDataQst = 'Сохранить данные из сканера в файле ?';
  msgHelp ='Программа сравнения файла "Октпус" с данными сканера.'+chr(13)+
    'За справкой и технической поддержкой обращайтесь к разработчику:'+chr(13)+
    'Шагинян Сергей Валерьевич'+chr(13)+
    'моб: +7(918)681-59-00'+chr(13)+
    'e-mail: sergey.shaginyan@re-nova.com'+chr(13)+
    'skype: shaginyan.sergey'+chr(13);

type

  MyRec = record
    ord  : string;
    code : string;
    name : string;
    qty  : real;
    qty1 : real;
    qty2 : real;
    chk  : boolean;
   end;

  TMyRecLst = array of MyRec;

  TOneScanData = record
    code : string[13];
    qty  : integer;
  end;

  TSDitems = array of TOneScanData;

  TScanData = class (TObject)
  private
    { Private declarations }
    FItem     : TSDItems;
    FCount    : integer;
  public
    { Public declarations }
    property Items: TSDItems read FItem write FItem;
    property Count: integer read FCount write FCount;
    constructor Create;
    destructor  Destroy;  override;
    procedure Add(code:string; qty:integer);
    function PrepCode(code:string):string;
    function LoadFromFileNew(fname:string):integer;
    function LoadFromFile(fname:string):integer;
    function LoadFromTerminal(var Terminal:OleVariant):integer;
    function FindCode(code:string): integer;
    function SaveToFile(Fname:string):boolean;
    function GetCodeCnt:integer;
    procedure Clear;
  end;

  TPrDM = class(TDataModule)
    Report: TfrxReport;
    DS1: TfrxUserDataSet;
    DS2: TfrxUserDataSet;
    frxXLSExport1: TfrxXLSExport;
    frxODSExport1: TfrxODSExport;
    procedure ReportGetValue(const VarName: string; var Value: Variant);
    procedure DS2CheckEOF(Sender: TObject; var Eof: Boolean);
    procedure DS2GetValue(const VarName: string; var Value: Variant);
    procedure DS1GetValue(const VarName: string; var Value: Variant);
    procedure LoadAll(Fname:string);
    procedure CompareCode(contname:string);
    function  ExtractFileNameEx(FileName: string; ShowExtension: Boolean): string;
    procedure PrintDet;
    procedure PrintBox;
    function  SaveTo1CFile(fname:string):boolean;
    function  LoadModelList(fname:string;var ModLst:TMyRecLst):boolean;
    function  GetResultRec(var Rec: TMyRecLst):boolean;
    procedure PrintChkModRes(onlychk:boolean;cnt,fname,note1,note2:string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



var
  PrDM        : TPrDM;
  ScanData    : TScanData;
  CurOctFile  : string;
  CurContName : string;
  AppPath     : string;
  ModIndLst   : array of integer;
  ChkModList  : TMyRecLst;
  PntModList  : TMyRecLst;

implementation

{$R *.dfm}

uses TCont,TDataLst;

var
  PrintModeSel : boolean;
  PrintMode    : byte;
  PrintBoxCount: integer;
  PrintBoxInd  : array of integer;


function TPrDm.GetResultRec(var Rec: TMyRecLst):boolean ;
var
  i,j,k  : integer;
  RecCnt : integer;
  qty    : real;
begin
  //Заполняем список код-количество
  reccnt:=0;
  SetLength(rec,reccnt);
  if CurContName<>'' then
  for i := 0 to ContLst.ByName(CurContName).BoxCount-1 do
    for j := 0 to ContLst.ByName(CurContName).Box[i].ItemCount - 1 do
      begin
        k:=0;
        while(k<RecCnt)and(Rec[k].code<>ContLst.ByName(CurContName).Box[i].Items[j].PosCode)do inc(k);
        if ContLst.ByName(CurContName).Box[i].Sel then
          qty:=(ContLst.ByName(CurContName).Box[i].Items[j].Count/ContLst.ByName(CurContName).Box[i].BoxCount)*
                (ContLst.ByName(CurContName).Box[i].BoxCount-ContLst.ByName(CurContName).Box[i].FaultCnt)
          else qty:=ContLst.ByName(CurContName).Box[i].Items[j].Count;
        if(qty>0)then if(k=RecCnt)then
          begin
            inc(RecCnt);
            SetLength(rec,reccnt);
            Rec[recCnt-1].ord:=ContLst.ByName(CurContName).Box[i].Items[j].OrdName;
            Rec[recCnt-1].code:=ContLst.ByName(CurContName).Box[i].Items[j].PosCode;
            Rec[recCnt-1].qty:=qty;
          end else Rec[k].qty:=Rec[k].qty+qty;
      end;
  result:=(high(Rec)>=0);
end;

function TPrDm.SaveTo1CFile(fname:string):boolean ;
var
  MyFile : TextFile;
  i      : integer;
  Rec    : TMyRecLst;
  str    : string;
begin
  //Заполняем список код-количество
  if self.GetResultRec(Rec) then begin
  assignfile(MyFile,fname);
  rewrite(MyFile);
  self.ExtractFileNameEx(CurOctFile,false);
  str:='Файл: '+ self.ExtractFileNameEx(CurOctFile,false)+' Контейнер: '+CurContName+
    ' Дата создания: '+DateToStr(now)+' Врем: '+TimeToStr(now);
  writeln(MyFile,str);
  for I := 0 to high(Rec) do
    begin
      str:='"'+Rec[i].code+'","';
      str:=str+ModLst.GetNameByCode(0,Rec[i].ord,Rec[i].code)+'","';
      str:=str+FormatFloat('######0',Rec[i].qty)+'"';
      if (i<=high(Rec))then writeln(MyFile,str) else write(MyFile,str);
    end;
  CloseFile(MyFile);
  result:=true;
  end else result:=false;
end;

procedure TPrDm.PrintDet;
begin
  //Подготовка элементов данных
  DS1.RangeEnd:=reCount;
  DS1.RangeEndCount:=high(ModIndLst)+1;
  DS2.RangeEnd:=reLast;
  PrintModeSel:=ContLst.ByName(CurContName).Selection;
  PrintMode:=1;
  Report.LoadFromFile(AppPath+'\DetReport.fr3',true);
  Report.ShowReport(true);
  Report.Clear;
end;

procedure TPrDm.PrintBox;
var
  i : integer;

function CanPrint(box:TBox):boolean;
var
  j,k:integer;
begin
  result:=false;
  j:=0;
  while(j<box.ItemCount)and(not result)do
    begin
      k:=0;
      while(k<=high(ModIndLst))and(box.Items[j].OrdName<>ModLst.Model[ModIndLst[k]].EngName)do inc(k);
      if(k<=high(ModIndLst))and(box.Items[j].OrdName=ModLst.Model[ModIndLst[k]].EngName)then result:=true;
      inc(j);
    end;
end;


begin
  //Подготовка элементов данных
  PrintModeSel:=ContLst.ByName(CurContName).Selection;
  PrintMode:=0;
  //создаем список печатаемых коробок
  PrintBoxCount:=0;
  for i := 0 to ContLst.ByName(CurContName).BoxCount - 1 do
    if (not PrintModeSel)or((PrintModeSel)and(ContLst.ByName(CurContName).Box[i].Sel)) then
    if CanPrint(ContLst.ByName(CurContName).Box[i]) then
      begin
        inc(PrintBoxCount);
        SetLength(PrintBoxInd,PrintBoxCount);
        PrintBoxInd[PrintBoxCount-1]:=i;
      end;
  DS1.RangeEnd:=reCount;
  DS1.RangeEndCount:=PrintBoxCount;
  DS2.RangeEnd:=reLast;
  Report.LoadFromFile(AppPath+'\BoxReport.fr3',true);
  Report.ShowReport(true);
  Report.Clear;
end;

procedure TPrDm.PrintChkModRes(onlychk:boolean;cnt,fname,note1,note2:string);
begin
  //Подготовка элементов данных
  DS1.RangeEnd:=reCount;
  DS1.RangeEndCount:=high(PntModList)+1;
  PrintMode:=3;
  Report.LoadFromFile(AppPath+'\ChkModReport.fr3',true);
  Report.Variables['Cnt']:=''''+cnt+'''';
  Report.Variables['filename']:=''''+fname+'''';
  Report.Variables['note1']:=''''+note1+'''';
  Report.Variables['note2']:=''''+note2+'''';
  Report.ShowReport(true);
  Report.Clear;
end;

procedure TPrDM.ReportGetValue(const VarName: string; var Value: Variant);
var
  i,j : integer;
begin
  if CompareText(VarName,'ContNum')=0 then Value:=CurContName;
  if CompareText(VarName,'TotBox')=0 then
    begin
      j:=0;
      for i := 0 to PrintBoxCount - 1 do
        j:=j+ContLst.ByName(CurContName).Box[PrintBoxInd[i]].BoxCount;
      Value:=j;
    end;
  if CompareText(VarName,'TotFault')=0 then
    begin
      j:=0;
      for i := 0 to PrintBoxCount - 1 do
        j:=j+ContLst.ByName(CurContName).Box[PrintBoxInd[i]].FaultCnt;
      Value:=j;
    end;
end;

procedure TPrDM.DS1GetValue(const VarName: string; var Value: Variant);
begin
  case PrintMode of
    0 : ;
    //Печать списка деталей
    1 : if CompareText(VarName,'Fld1')=0 then Value:=ModLst.Model[ModIndLst[DS1.RecNo]].EngName;
    //Печать рез сравнения с комплектацией
    3 : begin
        if CompareText(VarName,'Fld1')=0 then Value:=PntModList[DS1.RecNo].code;
        if CompareText(VarName,'Fld2')=0 then Value:=PntModList[DS1.RecNo].name;
        if CompareText(VarName,'Fld3')=0 then Value:=PntModList[DS1.RecNo].ord;
        if CompareText(VarName,'Fld4')=0 then Value:=PntModList[DS1.RecNo].qty;
        if CompareText(VarName,'Fld5')=0 then Value:=PntModList[DS1.RecNo].qty1;
        if CompareText(VarName,'Fld6')=0 then Value:=PntModList[DS1.RecNo].qty2;
        end;
  end;
end;

procedure TPrDM.DS2CheckEOF(Sender: TObject; var Eof: Boolean);
begin
  case PrintMode of
    //Печать списка коробок
    0 : if DS2.RecNo=ContLst.ByName(CurContName).Box[PrintBoxInd[DS1.RecNo]].ItemCount then EoF:=true;
    //Печать списка деталей
    1 : if DS2.RecNo=ModLst.Model[ModIndLst[DS1.RecNo]].Count then EoF:=true;
    //Печать рез сравнения с комплектацией
    3 : ;
  end;
end;

procedure TPrDM.DS2GetValue(const VarName: string; var Value: Variant);
var
  i : real;
  ind : integer;
begin
  case PrintMode of
    0 : begin
        ind:=PrintBoxInd[DS1.RecNo];
        if CompareText(VarName,'Fld1')=0 then
          if(DS2.RecNo>0)then Value:='' else Value:=ContLst.ByName(CurContName).Box[ind].BoxCode;
        if CompareText(VarName,'Fld2')=0 then Value:=ModLst.GetNameByCode(0,
          ContLst.ByName(CurContName).Box[ind].Items[DS2.RecNo].OrdName,
          ContLst.ByName(CurContName).Box[ind].Items[DS2.RecNo].PosCode);
        if CompareText(VarName,'Fld3')=0 then Value:=ModLst.GetEIByCode(0,
          ContLst.ByName(CurContName).Box[ind].Items[DS2.RecNo].OrdName,
          ContLst.ByName(CurContName).Box[ind].Items[DS2.RecNo].PosCode);
        if CompareText(VarName,'Fld4')=0 then Value:=
          ContLst.ByName(CurContName).Box[ind].Items[DS2.RecNo].Count;
        if CompareText(VarName,'Fld5')=0 then
          if(DS2.RecNo>0)then Value:='' else Value:=ContLst.ByName(CurContName).Box[ind].BoxCount;
        if CompareText(VarName,'Fld6')=0 then
          if (ContLst.ByName(CurContName).Box[ind].FaultCnt=0)or(DS2.RecNo>0) then Value:='' else
            Value:=ContLst.ByName(CurContName).Box[ind].FaultCnt;
        if CompareText(VarName,'Fld8')=0 then Value:=ContLst.ByName(CurContName).Box[ind].Items[DS2.RecNo].OrdName;
        end;
    //Печать списка деталей
    1 : begin
        if CompareText(VarName,'Fld1')=0 then Value:=ModLst.Model[ModIndLst[DS1.RecNo]].Item[DS2.RecNo].RName;
        if CompareText(VarName,'Fld2')=0 then Value:=ModLst.Model[ModIndLst[DS1.RecNo]].Item[DS2.RecNo].EI;
        if CompareText(VarName,'Fld3')=0 then Value:=ContLst.ByName(CurContName).PosCount(ModLst.Model[ModIndLst[DS1.RecNo]].EngName,ModLst.Model[ModIndLst[DS1.RecNo]].Item[DS2.RecNo].Code,false,false);
        i:=ContLst.ByName(CurContName).PosCount(ModLst.Model[ModIndLst[DS1.RecNo]].EngName,ModLst.Model[ModIndLst[DS1.RecNo]].Item[DS2.RecNo].Code,true,PrintModeSel);
        if CompareText(VarName,'Fld4')=0 then if i>0 then Value:=i else Value:='';
        end;
    //Печать рез сравнения с комплектацией
    3 : ;
  end;
end;

//------------------------------------------------------------------------------

function TPrDm.ExtractFileNameEx(FileName: string; ShowExtension: Boolean): string;
//Функция возвращает имя файла, без или с его расширением.
//ВХОДНЫЕ ПАРАМЕТРЫ
//FileName - имя файла, которое надо обработать
//ShowExtension - если TRUE, то функция возвратит короткое имя файла
// (без полного пути доступа к нему), с расширением этого файла, иначе, возвратит
  // короткое имя файла, без расширения этого файла.
var
  I: Integer;
  S, S1: string;
begin
  //Определяем длину полного имени файла
  I := Length(FileName);
  //Если длина FileName <> 0, то
  if I <> 0 then
  begin
    //С конца имени параметра FileName ищем символ "\"
    while (FileName[i] <> '\') and (i > 0) do
      i := i - 1;
    // Копируем в переменную S параметр FileName начиная после последнего
    // "\", таким образом переменная S содержит имя файла с расширением, но без
    // полного пути доступа к нему
    S := Copy(FileName, i + 1, Length(FileName) - i);
    i := Length(S);
    //Если полученная S = '' то фукция возвращает ''
    if i = 0 then
    begin
      Result := '';
      Exit;
    end;
    //Иначе, получаем имя файла без расширения
    while (S[i] <> '.') and (i > 0) do
      i := i - 1;
    //... и сохраням это имя файла в переменную s1
    S1 := Copy(S, 1, i - 1);
    //если s1='' то , возвращаем s1=s
    if s1 = '' then
      s1 := s;
    //Если было передано указание функции возвращать имя файла с его
    // расширением, то Result = s,
    //если без расширения, то Result = s1
    if ShowExtension = TRUE then
      Result := s
    else
      Result := s1;
  end
    //Иначе функция возвращает ''
  else
    Result := '';
end;

procedure TPrDM.CompareCode(contname:string);
var
  Cont     : TContr;
  i,qty  : integer;
begin
  //Cont:=TContr.Create;
  Cont:=ContLst.ByName(contname);
  Cont.ClearFault;
  for I := 0 to Cont.BoxCount - 1 do
    begin
      qty:=ScanData.FindCode(Cont.Box[i].BoxCode);
      if qty<Cont.Box[i].BoxCount then
        begin
          Cont.Box[i].Sel:=true;
          if(Cont.Box[i].BoxCount-qty)>0 then Cont.Box[i].FaultCnt:=Cont.Box[i].BoxCount-qty
            else Cont.Box[i].FaultCnt:=0;
        end;
    end;
end;

constructor TScanData.Create;
begin
  inherited;
  FCount:=0;
  SetLength(FItem,FCount);
end;

destructor TScanData.Destroy;
begin
  //
  inherited;
end;

function TScanData.GetCodeCnt:integer;
var
  i,j : integer;
begin
  i:=0;
  for j := 0 to self.FCount - 1 do i:=i+self.fItem[j].qty;
  result:=i;
end;

procedure TScanData.Clear;
var
  i:integer;
begin
  for I := 0 to self.FCount - 1 do
    begin
      self.FItem[i].code:='';
      self.FItem[i].qty:=0;
    end;
  self.FCount:=0;
  SetLength(self.FItem,self.FCount);
end;

procedure TScanData.Add(code: string; qty:integer);
var
  i : integer;
begin
  if code='' then exit;
  //Если элемент с таким кодом не содержится в спике
  //добавляем элемент, если содержится складывае количество
  i:=0;
  while (i<FCount)and(Fitem[i].code<>code) do inc(i);
  if i=FCount then
    begin
      inc(FCount);
      SetLength(FItem,FCount);
      FItem[Fcount-1].code:=code;
      FItem[Fcount-1].qty:=qty;
    end else Fitem[i].qty:=Fitem[i].qty+qty;
end;

function TscanData.PrepCode(code: string):string;
begin
  if (Length(code)=13) then
    begin
      if (code[1]='1')then code:=copy(code,2,5) else code:='';
    end
    else
    begin
      if (Length(code)>5) then
        begin
          while Length(code)<11 do code:='0'+code;
          code:=copy(code,1,5);
        end;
      while Length(code)<5 do code:='0'+code;
    end;
  result:=code;
end;

function TScanData.LoadFromTerminal(var Terminal:OleVariant):integer;
var
  j        : integer;
  code,qty : string;
  mode     : integer;
  CodeList : TstringList;
begin
  if Terminal.DownFieldCol=1 then Mode:=0;
  if Terminal.DownFieldCol=2 then Mode:=1;
  CodeList:=TStringList.Create;
  while  Terminal.GetRecord>=0 do     //...., заполнение таблицы
    begin
      if Mode=0 then begin
          code:=Terminal.GetField(1);
          qty:='1';
        end;
      if Mode=1 then begin
          code:=Terminal.GetField(1);
          qty:=Terminal.GetField(2);
        end;
      //обеспечиваем уникальность кода
      j:=0;
      while(j<CodeList.Count)and(CodeList.Names[j]<>code)do inc(j);
      if(j>=CodeList.Count)then CodeList.Add(code+'='+qty);
    end;
  Terminal.EndReport;
  for j := 0 to CodeList.Count - 1 do begin
    code:=self.PrepCode(CodeList.Names[j]);
    qty:=CodeList.Values[CodeList.Names[j]];
    if code<>'' then self.Add(code,strtointdef(qty,1));
  end;
  result:=CodeList.Count;
end;

function TScanData.LoadFromFile(fname: string):integer;
var
  MyFile       : TextFile;
  str,code,qty : string;
  i            : integer;
begin
  i:=0;
  if FileExists(FName) then
    begin
      assign(MyFile,FName);
      reset(MyFile);
      while not EoF(MyFile) do
        begin
          readln(MyFile,str);
          inc(i);
          if pos(',',str)=0 then
            begin
              code:=copy(str,2,Length(str)-2);
              qty:='1';
            end else
            begin
              code:=copy(str,2,pos(',',str)-3);
              qty:=copy(str,pos(',',str)+2,MaxInt);
              qty:=copy(qty,1,Length(qty)-1);
            end;
          code:=self.PrepCode(code);
          if code<>'' then self.Add(code,strtoint(qty));
        end;
      closefile(MyFile);
    end;
  result:=i;
end;

function TScanData.FindCode(code: string):integer;
var
  i : integer;
begin
  result:=0;
  i:=0;
  while (i<self.FCount)and(self.FItem[i].code<>code) do
    begin
    //showmessage(code+' '+self.FItem[i].code);
    inc(i);
    end;
  if (i<self.FCount) then result:=self.fitem[i].qty;
end;

procedure TPrDM.LoadAll(Fname: string);
var
  i,j,s,k,l,MC,MIC,CC,BC,IC : integer;
  str    : string;
  Strs   : TStringList;
  Model  : TDataList;
  Cont   : TContr;
  ModItm : TOnePos;
  Box    : TBox;
  BoxItm : TOneBoxItem;

function GetSubStr(ind:integer; str:string):string;
var
  j,k,s,e  : integer;
  open     : boolean;
  res      : string;
begin
  k:=0;
  j:=1;
  open:=false;
  while ((j<=Length(str))and(k<(Ind-1))) do
    begin
      if (str[j]='"')then
        if open then open:=false else open:=true;
      if (str[j]=',')and(open=false)then inc(k);
      inc(j);
    end;
  s:=j;
  j:=s;
  open:=false ;
  while ((j<=Length(str))and(k<Ind)) do
    begin
      if (str[j]='"')then
        if open then open:=false else open:=true;
      if (str[j]=',')and(open=false)then inc(k);
      inc(j);
    end;
  e:=j;
  res:=copy(str,s,(e-s));
  if Length(res)<1 then res:='0';
  if res[1]='"' then res:=copy(res,2,MaxInt);
  if res[Length(res)]=',' then res:=copy(res,1,Length(res)-1);
  if res[Length(res)]='"' then res:=copy(res,1,Length(res)-1);
  result:=res;
end;

function StrToReal(str:string):real;
var
  s       : string;
  ind,l,r : integer;
begin
  ind:=0;
  if (pos(',',str)<>0)or(pos('.',str)<>0) then
    begin
      if pos(',',str)<>0 then ind:=pos(',',str);
      if pos('.',str)<>0 then ind:=pos('.',str);
      s:=copy(str,1,ind-1);
      l:=StrToInt(s);
      s:=copy(str,ind+1,maxint);
      r:=StrToInt(s);
      result:=l+r/power(10,Length(str)-ind);
    end
    else result:=StrToFloat(str);
end;

begin
  Strs:=TStringList.Create;
  Strs.LoadFromFile(fname);
  //работаем со списком строк
  s:=0; MC:=StrToInt(Strs[s]);
  for I := 0 to MC - 1 do
    begin
      Model:=TDataList.Create;
      inc(s); Model.EngName:=Strs[s];
      inc(s); MIC:=StrToInt(Strs[s]);
      for j := 0 to MIC - 1 do
        begin
          inc(s); str:=Strs[s];
          ModItm.Num:=StrToInt(GetSubStr(1,str));
          ModItm.Code:=GetSubStr(2,str);
          ModItm.BOM:=GetSubStr(3,str);
          ModItm.RName:=GetSubStr(4,str);
          ModItm.LRName:=GetSubStr(5,str);
          if GetSubStr(6,str)<>'0' then ModItm.EName:=GetSubStr(6,str)
            else ModItm.EName:='no english name';
          ModItm.CntInOne:=StrToReal(GetSubStr(7,str));
          ModItm.EI:=GetSubStr(8,str);
          ModItm.Net:=StrToReal(GetSubStr(9,str));
          ModItm.Vol:=StrToReal(GetSubStr(10,str));
          ModItm.CntInBox:=StrToInt(GetSubStr(11,str));
          ModItm.BarCode:=GetSubStr(12,str);
          ModItm.TotCount:=StrToReal(GetSubStr(13,str));
          ModItm.GNet:=StrToReal(GetSubStr(14,str));
          ModItm.Price:=StrToReal(GetSubStr(15,str));
          ModItm.PriceN:=StrToReal(GetSubStr(16,str));
          ModItm.PriceA:=StrToReal(GetSubStr(17,str));
          if GetSubStr(18,str)='true' then ModItm.sel:=true else ModItm.sel:=false;
          if GetSubStr(19,str)='true' then ModItm.NetEI:=true else ModItm.NetEI:=false;
          ModItm.CIBOld:=StrToInt(GetSubStr(20,str));
          if GetSubStr(21,str)<>'0' then ModItm.CName:=(GetSubStr(21,str))
            else ModItm.CName:='';
          if GetSubStr(22,str)<>'0' then ModItm.TNCode:=GetSubStr(22,str)
            else ModItm.CName:='';
          if GetSubStr(23,str)<>'0' then ModItm.BoxType:=GetSubStr(23,str)
            else ModItm.CName:='';
          //для устранения бага с признаком весовой единицы
          if ((ModItm.EI='Г')or(ModItm.EI='г')or(ModItm.EI='кг')or(ModItm.EI='КГ'))
            and(ModItm.NetEI=false) then ModItm.NetEI:=true;
          Model.Add(ModItm);
        end;
        ModLst.Add(Model);
    end;
  inc(s); CC:=StrToInt(Strs[s]);
  inc(s); ContLst.LastBoxInd:=StrToInt(strs[s]);
  for I := 0 to CC - 1 do
    begin
      inc(s); str:=Strs[s];
      Cont:=TContr.Create;
      Cont.Name:=GetSubStr(1,str);
      Cont.MaxVol:= StrToReal(GetSubStr(2,str));
      Cont.MaxNet:= StrToReal(GetSubStr(3,str));
      inc(s); BC:=StrToInt(Strs[s]);
      for j := 0 to BC - 1 do
        begin
          inc(s); str:=strs[s];
          Box:=TBox.Create;
          Box.BoxCount:=StrToInt(GetSubStr(1,str));
          if GetSubStr(2,str)='true' then Box.Group:=true else Box.Group:=false;
          //Box.BNet:=StrToReal(GetSubStr(3,str));
          Box.BoxCode:=(GetSubStr(4,str));
          if GetSubStr(5,str)='true' then Box.Sel:=true else Box.Sel:=false;
          inc(s); IC:=StrToInt(Strs[s]);
          for k := 0 to IC - 1 do
            begin
              inc(s); str:=strs[s];
              BoxItm.OrdName:=GetSubStr(1,str);
              BoxItm.PosCode:=GetSubStr(2,str);
              if GetSubStr(3,str)='true' then BoxItm.NetEI:=true else BoxItm.NetEI:=false;
              BoxItm.Count:=StrToReal(GetSubStr(4,str));
              BoxItm.RowInd:=StrToInt(GetSubStr(7,str));
              //для устранения бага с признаком весовой единицы
              for l := 0 to ModLst.Model[ModLst.IndByName(BoxItm.OrdName)].Count - 1 do
                  if (ModLst.Model[ModLst.IndByName(BoxItm.OrdName)].Item[l].Code=BoxItm.PosCode)
                      and(ModLst.Model[ModLst.IndByName(BoxItm.OrdName)].Item[l].NetEI) then
                      BoxItm.NetEI:=ModLst.Model[ModLst.IndByName(BoxItm.OrdName)].Item[l].NetEI;
              Box.AddInBox(BoxItm);
            end;
          Box.Sel:=false;
          Box.FaultCnt:=0;
          Cont.AddBox(Box);
        end;
      ContLst.AddCont(Cont);
    end;
end;

function TScanData.SaveToFile(Fname: string):boolean;
var
  MyFile : TextFile;
  str    : string;
  i      : integer;
begin
  //
  try
  assignfile(MyFile,FName);
  if (FileExists(FName))and(MessageDlg(msgFileExists,mtWarning,[mbYes,mbNo],0)=mrYes) then
      begin
        append(MyFile);
        writeln(MyFile,'');
      end
    else  rewrite(MyFile);
  //Запиь данных
  for I := 0 to self.FCount - 1 do
    begin
      str:=self.FItem[i].code;
      {case self.FScanMode of
          0 : str:='"1'+str+'9"'; //режим код-коробка
          1 : str:='"'+str+'","'+inttostr(self.FItem[i].qty)+'"';  //режим код-количество
      end; }
        str:='"'+str+'","'+inttostr(self.FItem[i].qty)+'"';  //режим код-количество
       if i=(self.FCount - 1)then write(MyFile,str)else writeln(MyFile,str);
    end;
  CloseFile(MyFile);
  result:=true;
  except
  result:=false
  end;
end;

function TScanData.LoadFromFileNew(fname: string):integer;

function  GetSubstrings(str : string; var strs :TstringList):boolean;
const
  ch =';';
var
  i   : integer;
  sub : string;
begin
  strs.Clear;
  i:=1;
  while pos(ch,str)>0 do begin
    sub:=inttostr(i)+'='+copy(str,1,pos(ch,str)-1);
    while (length(str)>0)and(pos(' ',str)>0) do system.delete(str,pos(' ',str),1);
    strs.Add(copy(str,1,pos(ch,str)-1));
    system.delete(str,1,pos(ch,str));
    inc(i);
  end;
  strs.Add(str);
  result:=(strs.Count>0);
end;

var
  code,qty : string;
  i            : integer;
  strs,substrs : TStringList;
begin
  result:=0;
  Strs:=TStringList.Create;
  if (FileExists(FName)) then begin
    strs.LoadFromFile(FName);
    substrs:=TStringList.Create;
    for I := 3 to strs.Count - 1 do
      if GetSubStrings(strs[i],substrs)and(Length(substrs[0])>0)then begin
        code:=copy(substrs[0],Length(substrs[0])-10,5);
        qty:=substrs[4];
        if code<>'' then begin
          inc(result);
          self.Add(code,strtointdef(qty,1));
        end;
    end;
    substrs.Free;
  end;
  strs.Free;
end;

function TPrDM.LoadModelList(fname:string;var ModLst:TMyRecLst):boolean;
var
  Strs     : TStringList;
  str,str1 : string;
  i        : integer;
  newrec   : MyRec;
begin
  if FileExists(fname) then begin
    Strs:=TStringList.Create;
    Strs.LoadFromFile(fname);
    for I := 1 to Strs.Count - 1 do begin
      str:=copy(Strs[i],2,MaxInt);
      newrec.code:='Ц'+copy(str,1,pos('","',str)-1);
      str:=copy(str,pos('","',str)+3,MaxInt);
      newrec.name:=copy(str,1,pos('",',str)-1);
      str:=copy(str,pos('",',str)+2,MaxInt);
      str1:=copy(str,1,pos(',"',str)-1);
      if (DecimalSeparator<>'.')and(pos('.',str1)<>0) then str1[pos('.',str1)]:=DecimalSeparator;
      if (DecimalSeparator<>',')and(pos(',',str1)<>0) then str1[pos(',',str1)]:=DecimalSeparator;
      newrec.qty:=StrToFloat(str1);
      str:=copy(str,pos(',"',str)+2,MaxInt);
      newrec.ord:=copy(str,1,Length(str)-1);
      SetLength(ModLst,high(ModLst)+2);
      ModLst[high(ModLst)]:=newrec;
    end;
    result:=true;
  end else result:=false;
end;


end.
