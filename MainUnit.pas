unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, ComObj, Mask, ComCtrls,
  ToolWin, ImgList, Buttons, Menus, ShellAPI, Registry, Tabs, AppEvnts,
  ActnList, CategoryButtons, CheckLst;

type
  TScanMainForm = class(TForm)
    TablPanel: TPanel;
    OpenDlg: TOpenDialog;
    ContTbs: TTabSet;
    StBar: TStatusBar;
    SaveDlg: TSaveDialog;
    Act: TActionList;
    ImageList1: TImageList;
    OpenTable: TAction;
    EditFault: TAction;
    PrintBox: TAction;
    About: TAction;
    Compare: TAction;
    PrintDet: TAction;
    ExportTo1C: TAction;
    SelAll: TAction;
    UnselAll: TAction;
    CngSel: TAction;
    ShowOnlyFault: TAction;
    Panel1: TPanel;
    StaticText2: TStaticText;
    CategoryButtons1: TCategoryButtons;
    OrdSelImg: TImage;
    Panel2: TPanel;
    StaticText1: TStaticText;
    OrderCB: TCheckListBox;
    LoadSG: TStringGrid;
    CheckModLst: TAction;
    ModLstPn: TPanel;
    Panel4: TPanel;
    Label1: TLabel;
    ModLstLb: TLabel;
    BitBtn1: TBitBtn;
    ModLstSG: TStringGrid;
    Panel3: TPanel;
    BitBtn2: TBitBtn;
    CntED: TEdit;
    Label2: TLabel;
    BitBtn3: TBitBtn;
    OnlyChkCB: TCheckBox;
    NoteLB: TLabel;
    DataFromFileNew: TAction;
    TableToScan: TAction;
    ProgressPn: TPanel;
    procedure OrderCBClickCheck(Sender: TObject);
    procedure ShowOnlyFaultExecute(Sender: TObject);
    procedure CngSelExecute(Sender: TObject);
    procedure UnselAllExecute(Sender: TObject);
    procedure SelAllExecute(Sender: TObject);
    procedure ExportTo1CExecute(Sender: TObject);
    procedure PrintDetExecute(Sender: TObject);
    procedure CompareExecute(Sender: TObject);
    procedure AboutExecute(Sender: TObject);
    procedure PrintBoxExecute(Sender: TObject);
    procedure EditFaultExecute(Sender: TObject);
    procedure OpenTableExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ContTbsChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure FormShow(Sender: TObject);
    procedure LoadSGDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure UpdateControl(msg:string);
    procedure LoadSGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure LoadSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure UpdateContList(ContName: string);
    procedure SelectionRow(mode:byte);
    procedure CheckModLstExecute(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure UpdateCheckModLst;
    procedure BitBtn2Click(Sender: TObject);
    procedure ModLstSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure BitBtn3Click(Sender: TObject);
    procedure OnlyChkCBClick(Sender: TObject);
    procedure DataFromFileNewExecute(Sender: TObject);
    procedure TableToScanExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ScanMainForm: TScanMainForm;

implementation

{$R *.dfm}

uses PrUnit,TDataLst,TCont;


var
  lang          : byte=0;
  CurBoxInd     : integer;
  LoadCodeCnt   : integer=0;

procedure TScanMainForm.UpdateControl(msg:string);
begin
  if CurOctFile<>'' then self.Caption:='File "'+PrDm.ExtractFileNameEx(CurOctFile,false)+'"'
    else self.Caption:='Supply analizer. V.1.6';
  //Заголовки панели контейнера
  LoadSG.Cells[0,0]  :='' ;
  LoadSG.Cells[1,0]  :='№ кор' ;
  LoadSG.Cells[2,0]  :='Заказ' ;
  LoadSG.Cells[3,0]  :='Содержимое' ;
  LoadSG.Cells[4,0]  :='Ед' ;
  LoadSG.Cells[5,0]  :='Кол-во' ;
  LoadSG.Cells[6,0]  :='Кол мест' ;
  LoadSG.Cells[7,0]  :='Не найд' ;
  StBar.Panels[0].Text:=msg;
  if LoadCodeCnt>0 then
    StBar.Panels[1].Text:='Коды(строки/коды): '+IntToStr(LoadCodeCnt)+
            '/'+IntToStr(ScanData.GetCodeCnt)
  else StBar.Panels[1].Text:='';
  if CurContName<>'' then StBar.Panels[2].Text:='Кор-ки(всего/найд): '+
    inttostr(ContLst.ByName(CurContName).TotBoxCnt)+'/'+
    inttostr(ContLst.ByName(CurContName).TotBoxCnt-ContLst.ByName(CurContName).FaultBoxCnt)
    else StBar.Panels[2].Text:='';
    //Отключение кнопок при отсутсвии данных в таблице
    if (CurContName='')or((CurContName<>'')and(ContLst.ByName(CurContName).TotBoxCnt=0)) then
      begin
        self.PrintBox.Enabled:=false;
        self.PrintDet.Enabled:=false;
        self.ExportTo1C.Enabled:=false;
        self.EditFault.Enabled:=false;
        self.SelAll.Enabled:=false;
        self.UnselAll.Enabled:=false;
        self.CngSel.Enabled:=false;
      end else
      begin
        self.PrintBox.Enabled:=true;
        self.PrintDet.Enabled:=true;
        self.ExportTo1C.Enabled:=true;
        self.SelAll.Enabled:=true;
        self.UnselAll.Enabled:=true;
        self.CngSel.Enabled:=true;
        self.EditFault.Enabled:=(CurBoxInd>-1)and(ContLst.ByName(CurContName).Box[CurBoxInd].FaultCnt>0);
      end;
    // Настройка активности кнопки сравнения
    if((CurContName='')or((CurContName<>'')and(ContLst.ByName(CurContName).TotBoxCnt=0)))
      or (ScanData.Count=0)then self.Compare.Enabled:=false else self.Compare.Enabled:=true;
end;

procedure TScanMainForm.UnselAllExecute(Sender: TObject);
begin
  self.SelectionRow(2);
end;

procedure TScanMainForm.UpdateContList(ContName: string);
var
  i,j,k : integer;
  Cnt   : TContr;
  onlyfault,showboxnum : boolean;

function ItemInSelOrder(ordername:string):boolean;
var
  l : integer;
begin
  result:=false;
  l:=0;
  while (l<OrderCB.Items.Count)and(OrderCB.Items[l]<>ordername) do inc(l);
  if (l<OrderCB.Items.Count)and(OrderCB.Items[l]=ordername)and(OrderCB.Checked[l]) then result:=true;
end;

begin
  onlyfault:=(self.ShowOnlyFault.Checked)and(ScanData.Count>0);
  //определение количества строк в будующей таблице
  if (ContName<>'')and(ContLst.ByName(ContName).BoxCount>0) then
    begin
      Cnt:=ContLst.ByName(ContName);
      k:=1;
      for I := 0 to Cnt.BoxCount - 1 do
        if (not OnlyFault)or((OnlyFault)and(Cnt.Box[i].FaultCnt>0)) then
          for j := 0 to Cnt.Box[i].ItemCount-1 do
            if ItemInSelOrder(Cnt.Box[i].Items[j].OrdName) then inc(k);
    end;
  //вывод таблицы
  if k>1 then
    begin
      LoadSG.Enabled:=true;
      LoadSG.RowCount:=k;
      k:=1;
      for I := 0 to Cnt.BoxCount - 1 do
      if (not OnlyFault)or((OnlyFault)and(Cnt.Box[i].FaultCnt>0)) then
      begin
       showboxnum:=true;
       for j := 0 to Cnt.Box[i].ItemCount-1 do
        //определение вхождения детали в выбранные заказы
        if ItemInSelOrder(Cnt.Box[i].Items[j].OrdName) then with LoadSG do
        begin
          Cnt.Box[i].Items[j].RowInd:=k;
          if showboxnum then Cells[0,k]:=IntToStr(i+1) else Cells[0,k]:='';
          if showboxnum then Cells[1,k]:=Cnt.Box[i].BoxCode else Cells[1,k]:='';
          Cells[2,k]:=Cnt.Box[i].Items[j].OrdName;
          Cells[3,k]:=ModLst.GetNameByCode(Lang,Cnt.Box[i].Items[j].OrdName,
              Cnt.Box[i].Items[j].PosCode);
          Cells[4,k]:=ModLst.GetEIByCode(Lang,Cnt.Box[i].Items[j].OrdName,
              Cnt.Box[i].Items[j].PosCode);
          Cells[5,k]:=FormatFloat('###0.###',Cnt.Box[i].Items[j].Count);
          if showboxnum then
            begin
              Cells[6,k]:=IntToStr(Cnt.Box[i].BoxCount);
              if Cnt.Box[i].FaultCnt>0 then Cells[7,k]:=FormatFloat('###0',Cnt.Box[i].FaultCnt)
                else Cells[7,k]:='';
            end
            else
            begin
              Cells[6,k]:='';
              Cells[7,k]:='';
            end;
          inc(k);
          if showboxnum then showboxnum:=false;
        end;
      end;
        CurBoxInd:=ContLst.ByName(CurContName).FindByRowInd(LoadSG.Selection.Top).X;
        //self.FormResize(self);
    end
    else
    begin
      LoadSG.RowCount:=2;
      for i := 0 to LoadSG.ColCount - 1 do LoadSG.Cells[i,1]:='';
      LoadSG.Enabled:=false;
      CurBoxInd:=-1;
    end;
end;

procedure TScanMainForm.OnlyChkCBClick(Sender: TObject);
begin
  self.UpdateCheckModLst;
end;

procedure TScanMainForm.OpenTableExecute(Sender: TObject);
var
  i : integer;
begin
  iF DirectoryExists(AppPath+'\Files') then
  OpenDLG.InitialDir:=AppPath+'\Files' else
    OpenDLG.InitialDir:=AppPath;
  if OpenDlg.Execute then
    begin
      //Удаляем все старое
      while ContLst.Count>0 do ContLst.DelCont(ContLst.Cont[0].Name);
      ContLst.LastBoxInd:=0;
      while ModLst.Count>0 do ModLst.Delete(ModLst.Model[0].EngName);
      CurContName:='';
      ContTbs.Tabs.Clear;
      OrderCB.Items.Clear;
      //Загружаем новое
      PrDM.LoadAll(OpenDlg.FileName);
      CurOctFile:=OpenDlg.FileName;
      //Обновляем список нарядов
      for I := 0 to ModLst.Count - 1 do
        begin
          OrderCB.Items.Add(ModLst.Model[i].EngName);
          OrderCB.Checked[i]:=true;
        end;
      //Обновляем элементы управления
      if ContLst.Count>0 then
        begin
          for i:=0 to ContLst.Count-1 do  ContTbs.Tabs.Add(ContLst.Cont[i].Name);
          ContTbs.TabIndex:=0;
          CurContName:=ContTbs.Tabs[0];
        end;
      self.UpdateContList(CurContname);
      self.UpdateControl('');
      self.FormResize(self);
    end;
end;

procedure TScanMainForm.OrderCBClickCheck(Sender: TObject);
begin
  self.UpdateContList(CurContname);
  LoadSG.Repaint;
end;

procedure TScanMainForm.AboutExecute(Sender: TObject);
begin
  MessageDlg(msgHelp,mtInformation,[mbOk],0);
end;

procedure TScanMainForm.PrintDetExecute(Sender: TObject);
var
  i,j : integer;
begin
  j:=0;
  for I := 0 to OrderCB.Items.Count - 1 do
    if OrderCB.Checked[i] then
      begin
        inc(j);
        SetLength(ModIndlst,j);
        ModIndLst[j-1]:=i;
      end;
  PrDm.PrintDet;
end;

procedure TScanMainForm.BitBtn1Click(Sender: TObject);
begin
  ModLstPn.Visible:=false;
end;

procedure TScanMainForm.BitBtn2Click(Sender: TObject);
begin
  CntED.Text:=IntToStr(StrToIntDef(CntED.Text,1));
  self.UpdateCheckModLst;
end;

procedure TScanMainForm.BitBtn3Click(Sender: TObject);
var
  i     : integer;
  note2 : string;
begin
  //записываем информацию в объект данных для печати
  SetLength(PntModList,ModLstSG.RowCount-1);
  for I := 0 to high(PntModList) do begin
    PntModList[i].code:=ModLstSG.Cells[1,i+1];
    PntModList[i].name:=ModLstSG.Cells[2,i+1];
    PntModList[i].ord:=ModLstSG.Cells[3,i+1];
    PntModList[i].qty:=StrToFloatDef(ModLstSG.Cells[4,i+1],0);
    PntModList[i].qty1:=StrToFloatDef(ModLstSG.Cells[5,i+1],0);
    PntModList[i].qty2:=StrToFloatDef(ModLstSG.Cells[6,i+1],0);
  end;
  if OnlyChkCB.Checked then note2:='(только нехватка)' else note2:='';
  PrDm.PrintChkModRes(OnlyChkCb.Checked,CntED.Text,ModLstLb.Caption,
    note2,NoteLB.Caption);
end;

procedure TScanMainForm.UpdateCheckModLst;
var
  StrLst  : TStringList;
  i,j,k,l : integer;
  tcnt    : real;
  ncnt    : real;
  ResRec  : TMyRecLst;
begin
    //записываем наименования в список для сортировки
    StrLst:=TStringList.Create;
    for I := 0 to high(ChkModList) do StrLst.Add(ChkModList[i].name);
    StrLst.Sorted:=true;
    //заполнеяем таблицу
    l:=0;
    ModLstSG.RowCount:=l+2;
    ModLstSG.Rows[1].Clear;
    for I := 0 to StrLst.Count - 1 do begin
      j:=0;
      while(j<=high(ChkModList))and(StrLst[i]<>ChkModList[j].name)do inc(j);
      if(j<=high(ChkModList))and(StrLst[i]=ChkModList[j].name)then begin
        //подсчитываем сколько всего имеется
        if PrDm.GetResultRec(ResRec) then begin
          k:=0;
          tcnt:=0;
          while(k<=high(ResRec))and(ResRec[k].code<>ChkModList[j].code)do inc(k);
          if(k<=high(ResRec))and(ResRec[k].code=ChkModList[j].code)then tcnt:=ResRec[k].qty;
        end else tcnt:=0;
        ChkModList[j].qty1:=tcnt;
        //подсчитывае необходимое количество
        ncnt:=ChkModList[j].qty*StrToIntDef(CntED.Text,1);
        ChkModList[j].qty2:=ncnt;
        //отмечаем недосдачу
        ChkModList[j].chk:=((tcnt-ncnt)<0);
        //выводим в зависимости от флага "только недосдача"
        if (OnlyChkCB.Checked=false)or((OnlyChkCB.Checked)and(ChkModList[j].chk)) then begin
          //определяем единицу измерения по данным из файла загрузки
          k := 0;
          while(k<ModLst.Count)and(Length(ModLst.GetEIByCode(lgRus,ModLst.Model[k].EngName,
            ChkModList[j].code))=0)do inc(k);
          if(k<ModLst.Count)and(Length(ModLst.GetEIByCode(lgRus,ModLst.Model[k].EngName,
            ChkModList[j].code))<>0)then
              ModLstSG.Cells[3,l+1]:=ModLst.GetEIByCode(lgRus,ModLst.Model[k].EngName,
              ChkModList[j].code) else ModLstSG.Cells[3,l+1]:='';
          ChkModList[j].ord:= ModLstSG.Cells[3,l+1];
          ModLstSG.Cells[0,l+1]:=inttostr(l+1);
          ModLstSG.Cells[1,l+1]:=ChkModList[j].code;
          ModLstSG.Cells[2,l+1]:=ChkModList[j].name;
          ModLstSG.Cells[4,l+1]:=FormatFloat('#####0.00',ncnt);
          ModLstSG.Cells[5,l+1]:=FormatFloat('#####0.00',tcnt);
          //подстчитываем разницу
          if (tcnt-ncnt)<>0 then ModLstSG.Cells[6,l+1]:=FormatFloat('#####0.00',tcnt-ncnt) else
            ModLstSG.Cells[6,l+1]:='';
          inc(l);
          if (l+1)>=(ModLstSG.RowCount+1) then ModLstSG.RowCount:=ModLstSG.RowCount+1;
        end;
      end;
    end;
    //установка заголовков и ширины колонок таблицы
    ModLstSG.Cells[1,0]:=' Код';
    ModLstSG.Cells[2,0]:=' Наименование';
    ModLstSG.Cells[3,0]:=' Ед';
    ModLstSG.Cells[4,0]:=' Треб';
    ModLstSG.Cells[5,0]:=' Есть';
    ModLstSG.Cells[6,0]:=' Недост';
    ModLstSG.ColWidths[6]:=70;
    ModLstSG.ColWidths[5]:=60;
    ModLstSG.ColWidths[4]:=60;
    ModLstSG.ColWidths[3]:=30;
    ModLstSG.ColWidths[1]:=80;
    ModLstSG.ColWidths[2]:=ModLstSG.ClientWidth-ModLstSG.ColWidths[6]-
      ModLstSG.ColWidths[5]-ModLstSG.ColWidths[4]-ModLstSG.ColWidths[3]
      -ModLstSG.ColWidths[1]-ModLstSG.ColWidths[0]-10;
end;

procedure TScanMainForm.CheckModLstExecute(Sender: TObject);
begin
  //приосходит сравнение потребности по комплектовочной ведомости с данными сканера
  //если данные не загружены берется вся информация о загрузке всех контейнеров
  //деталями из всех заказов в независимости от наличия отметок в окне выбора заказов
  iF DirectoryExists(AppPath+'\Models') then
    OpenDLG.InitialDir:=AppPath+'\Models' else OpenDLG.InitialDir:=AppPath;
  SetLength(ChkModList,0);
  if (OpenDlg.Execute)and(PrDm.LoadModelList(OpenDlg.FileName,ChkModList))then begin
    //вывод имени файла комплектации
    ModLstLb.Caption:='Файл комплектации: '+
      PrDm.ExtractFileNameEx(OpenDlg.FileName,false);
    //вывод напоминания о наличии/отсутствии данных сканера
    If ScanData.Count=0 then begin
        NoteLB.Font.Color:=clRed;
        NoteLb.Font.Style:=[fsBold];
        NoteLb.Caption:='Внимание! Данные сканера не загружены! Используются данные о полной загрузке  контейнеров!'
      end else begin
        NoteLB.Font.Color:=clBlack;
        NoteLb.Font.Style:=[];
        NoteLb.Caption:='Сравнение с данными сканера:' ;
      end;
    //установка размеров панели
    ModLstPn.Width  :=round(screen.Width *0.6);
    ModLstPn.Height :=round(screen.Height*0.75);
    ModLstPn.Top    :=round((screen.Height-ModLstPn.Height)*0.25);
    ModLstPn.Left   :=round((screen.Width -ModLstPn.Width )/2);
    CntED.Text      :='1';
    self.UpdateCheckModLst;
    //показ панели
    ModLstPn.Visible:=true;
  end;
end;

procedure TScanMainForm.CngSelExecute(Sender: TObject);
begin
  self.SelectionRow(3);
end;

procedure TScanMainForm.CompareExecute(Sender: TObject);
begin
  if (ScanData.Count>0)and(CurContName<>'') then
    begin
      PrDm.CompareCode(CurContName);
      self.UpdateContList(CurContName);
      self.UpdateControl(msgCompareOk);
      LoadSG.Refresh;
    end;
end;

procedure TScanMainForm.ContTbsChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  CurContName:=ContTbs.Tabs[NewTab];
  self.UpdateContList(CurContName);
  self.LoadSG.Repaint;
end;

procedure TScanMainForm.DataFromFileNewExecute(Sender: TObject);
var
  i : integer;
  msg: string;
begin
  if OpenDlg.Execute then
    begin
      //загружаем данные из файла
      if (ScanData.Count>0)and(MessageDlg(msgNewScanData,mtWarning,[mbYes,mbNo],0)=mrYes) then
          i:=LoadCodeCnt+ScanData.LoadFromFileNew(OpenDlg.FileName)
        else
        begin
          ScanData.Clear;
          i:=ScanData.LoadFromFileNew(OpenDlg.FileName);
        end;
      if i>0 then
        begin
          LoadCodeCnt:=i;
          if(CurContName<>'') then
            begin
              PrDm.CompareCode(CurContName);
              self.UpdateContList(CurContName);
              msg:=msgCompareOk;
            end else msg:=msgNoTable;
          self.UpdateControl(msg);
          LoadSG.Refresh;
        end else self.UpdateControl(msgScanDataEmpty);
    end;
end;

procedure TScanMainForm.EditFaultExecute(Sender: TObject);
var
  i   : integer;
  str : string;
begin
  if (CurBoxInd>-1)and(ContLst.ByName(CurContName).Box[CurBoxInd].FaultCnt>0) then
    begin
      str:=IntTostr(ContLst.ByName(CurContName).Box[CurBoxInd].FaultCnt);
      str:=InputBox('Кор №'+ContLst.ByName(CurContName).Box[CurBoxInd].BoxCode,
        'Количество не найденых коробок:',str);
      if Length(str)>0 then
        begin
          i:=StrToInt(str);
          if i>ContLst.ByName(CurContName).Box[CurBoxInd].BoxCount then
            MessageDLG('Слишком большое число !',mtError,[mbOK],0) else
              begin
                i:=ContLst.ByName(CurContName).Box[CurBoxInd].FaultCnt-i;
                ScanData.Add(ContLst.ByName(CurContName).Box[CurBoxInd].BoxCode,i);
                self.CompareExecute(self);
                LoadSG.Refresh;
              end;
        end;
    end;
end;

procedure TScanMainForm.ExportTo1CExecute(Sender: TObject);
begin
  if(CurContName<>'')then
    if (ScanData.Count>0)or((ScanData.Count=0)and(MessageDLG('Данные сканера не загружены!'+
      chr(13)+'Продолжить не смотря на это?',mtWarning,[mbYes,mbNo],0)=mrYes)) then
      if (SaveDlg.Execute)then begin
        if PrDm.SaveTo1CFile(SaveDlg.FileName)then MessageDlg(msgSaveOk,MtInformation,[mbOk],0);
      end;
end;

procedure TScanMainForm.FormCreate(Sender: TObject);
begin
  AppPath:=ExtractFileDir(Application.ExeName);
end;

procedure TScanMainForm.FormResize(Sender: TObject);
var
  i,w : integer;
begin
  //Установка размера столбца "наименования" в таблице контейнра
  w:=0;
  for I := 0 to LoadSG.ColCount-1 do w:=w+LoadSG.ColWidths[i];
  w:=w-LoadSG.ColWidths[3];
  LoadSG.ColWidths[3]:=LoadSG.ClientWidth-w-10;
end;

procedure TScanMainForm.FormShow(Sender: TObject);
begin
  ModLst:=TModList.Create;
  ContLst:=TContLst.Create;
  ScanData:=TScanData.Create;
  self.UpdateControl('');
  self.LoadSG.Enabled:=false;
end;

procedure TScanMainForm.LoadSGDblClick(Sender: TObject);
begin
  if (CurBoxInd>-1)then
    begin
      ContLst.ByName(CurContName).Box[CurBoxInd].Sel:=not ContLst.ByName(CurContName).Box[CurBoxInd].Sel;
      LoadSG.Refresh;
    end;
end;

procedure TScanMainForm.LoadSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  str  : WideString;
  Flag : Cardinal;
  Rct  : TRect;
  BI   : integer;
begin
  if (ACol=0)and(Arow>0)and(CurContName<>'')and(ContLst.ByName(CurContName).BoxCount>0)
     then begin
      BI:=ContLst.ByName(CurContName).FindByRowInd(ARow).X;
      if (BI>-1)and(ContLst.ByName(CurContName).Box[BI].Sel)
         and((Sender as TStringGrid).Cells[Acol,Arow]<>'') then
         (Sender as TStringGrid).Canvas.Draw(Rect.Left,Rect.Top+1,OrdSelImg.Picture.Graphic);
     end;
  if (ARow>0)and(ACol>0)and(CurContName<>'')and(ContLst.ByName(CurContName).BoxCount>0) then
  with (Sender as TStringGrid) do
    begin
      BI:=ContLst.ByName(CurContName).FindByRowInd(ARow).X;
      if(ContLst.ByName(CurContName).Box[BI].FaultCnt>0)and(self.ShowOnlyFault.Checked=false)
        then Canvas.Font.Color:=clRED else Canvas.Font.Color:=clBlack;
      if (BI=CurBoxInd)and(ARow<>Selection.Top) then Canvas.Brush.Color:=clSkyBlue;
      str :=Cells[Acol,Arow];
      Canvas.FillRect(Rect);
      Rct:=Rect;
      Flag := DT_LEFT;
      Inc(Rct.Left,2);
      Inc(Rct.Top,2);
      DrawTextW((Sender as TDrawGrid).Canvas.Handle,PWideChar(str),length(str),Rct,Flag);
    end;
end;

procedure TScanMainForm.LoadSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if CurContName<>'' then
    begin
      CurBoxInd:=ContLst.ByName(CurContName).FindByRowInd(Arow).X;
      if (CurBoxInd>-1) then
        begin
          LoadSG.Repaint;
          self.EditFault.Enabled:=(ContLst.ByName(CurContName).Box[CurBoxInd].FaultCnt>0);
        end;
    end;
end;

procedure TScanMainForm.ModLstSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  str : string;
  Rct : TRect;
begin
  str:=(sender as TStringGrid).Cells[ACol,ARow];
  if StrToFloatDef((sender as TStringGrid).Cells[6,ARow],0)<0 then begin
    (sender as TStringGrid).Canvas.Font.Color:=clRed;
    (sender as TStringGrid).Canvas.FillRect(Rect);
    Rct:=Rect;
    Inc(Rct.Left,2);
    Inc(Rct.Top,2);
    DrawText((Sender as TStringGrid).Canvas.Handle,pchar(str),length(str),Rct,DT_LEFT);
  end else (sender as TStringGrid).Canvas.Font.Color:=clBlack;
end;

procedure TScanMainForm.PrintBoxExecute(Sender: TObject);
var
  i,j : integer;
begin
  j:=0;
  for I := 0 to OrderCB.Items.Count - 1 do
    if OrderCB.Checked[i] then
      begin
        inc(j);
        SetLength(ModIndlst,j);
        ModIndLst[j-1]:=i;
      end;
  PrDm.PrintBox;
end;

procedure TScanMainForm.SelAllExecute(Sender: TObject);
begin
  self.SelectionRow(1);
end;

procedure TScanMainForm.SelectionRow(mode: Byte);
var
  i    : integer;

function CanSelect(box:TBox):boolean;
var
  j,k:integer;
begin
  result:=false;
  j:=0;
  while(j<box.ItemCount)and(not result)do
    begin
      k:=0;
      while(k<OrderCB.Items.Count)and(box.Items[j].OrdName<>OrderCB.Items[k])do inc(k);
      if(k<OrderCB.Items.Count)and(box.Items[j].OrdName=OrderCB.Items[k])and(OrderCB.Checked[k])then result:=true;
      inc(j);
    end;
end;

begin
  if self.LoadSG.Enabled then
    begin
      for I := 0 to ContLst.ByName(CurContName).BoxCount - 1 do
        //определение входит ли хотябы одна деталь из коробоки в выбранные заказы
        if CanSelect(ContLst.ByName(CurContName).Box[i]) then
          begin
            case mode of
              1 : ContLst.ByName(CurContName).Box[i].Sel:=true;
              2 : ContLst.ByName(CurContName).Box[i].Sel:=false;
              3 : ContLst.ByName(CurContName).Box[i].Sel:=not ContLst.ByName(CurContName).Box[i].Sel;
            end;
          end else ContLst.ByName(CurContName).Box[i].Sel:=false;
      LoadSG.Refresh;
    end;
end;

procedure TScanMainForm.ShowOnlyFaultExecute(Sender: TObject);
begin
  if Self.LoadSG.Enabled then
    begin
      self.ShowOnlyFault.Checked:=not self.ShowOnlyFault.Checked;
      if self.ShowOnlyFault.Checked then self.ShowOnlyFault.Caption:='Вся таблица'
        else self.ShowOnlyFault.Caption:='Только ошибки';
      self.UpdateContList(CurContName);
      self.UpdateControl('');
      self.LoadSG.Refresh;
    end;
end;

procedure TScanMainForm.TableToScanExecute(Sender: TObject);
var
  cnt, bx,i,k,totbox  : integer;
  code,descr,str : string;
  strs       : TStringList;
begin
  strs:=TStringList.Create;
  strs.Add('Код;Артикул;Наименование;Packing.Barcode;ПоСН;Product.BasePackingId;Packing.Id;Packing.Name;Packing.ИдХарактеристики');
  k:=0;
  ProgressPN.Visible:=true;
  ProgressPN.Left:=round((self.Width-ProgressPn.Width)/2);
  ProgressPN.Top:=round(self.Height*0.4);
  for cnt := 0 to ContLst.Count-1 do begin
    ProgressPn.Caption:='0%';
    application.ProcessMessages;
    totbox:=ContLst.Cont[cnt].TotBoxCnt;
    for bx := 0 to ContLst.Cont[cnt].BoxCount-1 do begin
      descr:='';
      for i := 0 to ContLst.Cont[cnt].Box[bx].ItemCount-1 do
        descr:=descr+ModLst.GetNameByCode(0,ContLst.Cont[cnt].Box[bx].Items[i].OrdName,
            ContLst.Cont[cnt].Box[bx].Items[i].PosCode)+'-'+
            FormatFloat('######0.##',ContLst.Cont[cnt].Box[bx].Items[i].Count/
            ContLst.Cont[cnt].Box[bx].BoxCount)+ ', ';
      delete(descr,length(descr)-1,2);
      descr:=copy(descr,1,250);
      for i := 0 to ContLst.Cont[cnt].Box[bx].BoxCount-1 do begin
        code:=copy(PrDm.ExtractFileNameEx(CurOctFile,false),1,7)+ContLst.Cont[cnt].Box[bx].BoxCode
          +FormatFloat('000',(i+1))+FormatFloat('000',(ContLst.Cont[cnt].Box[bx].BoxCount));
        //ShowMessage(code+'  '+descr);
        inc(k);
        str:='T'+FormatFloat('0000000',k);
        strs.Add(str+';'+str+';'+descr+';'+code+';true;шт;шт;шт;');
        ProgressPn.Caption:='Подготовка данных : '+FormatFloat('##0.00%',k/totbox*100);
        ProgressPN.Refresh;
        if (k mod 20)=0 then sleep(1);
      end;
    end;
  end;
  ProgressPN.Visible:=false;
  //ShowMessage(strs.Text);
  iF DirectoryExists('C:\ТСД\На терминал') then
    SaveDLG.InitialDir:='C:\ТСД\На терминал' else SaveDLG.InitialDir:='C:\';
  SaveDLG.FileName:='Номенклатура';
  if SaveDlg.Execute then strs.SaveToFile(SaveDLG.FileName);
  strs.Free;
end;

end.
