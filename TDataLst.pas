unit TDataLst;

interface

Uses classes, Sysutils, Math;

const
  lgRUS=0;
  lgENG=1;
  lgCN =2;

type
  // Запись. Информация о единице комплектующих
  TOnePos = record
    Num      : integer;
    Code     : string[20];
    BOM      : string[20];
    RName    : string[255];
    LRName   : string[255];
    EName    : string[255];
    CName    : String[255];
    TNCode   : string[255];
    BoxType  : string[64];
    CntInOne : real;
    EI       : string[3];
    Net      : real;
    Vol      : real;
    CntInBox : integer;
    BarCode  : string[50];
    TotCount : real;
    GNet     : real;
    Price    : real;
    PriceN   : real;
    PriceA   : real;
    //Доп поля
    sel      : boolean;
    NetEI    : boolean;
    CIBOld   : integer;
  end;
  //Массив записей о комплектующих
  TItemLst = array of TOnePos;
  //Класс. Информация о комплекте изделия
  TDataList=Class(TObject)
    private {здесь описываются только внутренние переменные и процедуры - "для служебного пользования"}
      FEngName  : string;
      FItems    : TItemLst;
      FCount    : integer;
    public {Описанное здесь доступно для пользователя класса}
      Constructor Create;
      Destructor Destroy; override;
      property Count:integer read FCount write FCount;
      property Item:TitemLst read FItems;
      property EngName:string read FEngName write FEngName;
      function LoadFrom1CTXT(FName:string):string;
      function IndByNum(num:integer):integer;
      function Add(NewItem : TOnePos):integer;
      procedure Delete(Itm : TonePos);
    end;
  //Массив классов "Комплект изделия"
  TModelList = array of TDataList;
  //Класс. Информация о группе комплеков
  TModList=Class(TObject)
    private {здесь описываются только внутренние переменные и процедуры - "для служебного пользования"}
      FModels   : TModelList;
      FCount    : integer;
    public {Описанное здесь доступно для пользователя класса}
      Constructor Create;
      Destructor Destroy; override;
      property Count:integer read FCount write FCount;
      property Model:TModelList read FModels;
      function Add(NewItem : TDataList):integer;
      procedure Delete (EngName:string);
      function IndByName(EngName:string):integer;
      function GetNameByCode(lng : integer; ordname,code:string):String;
      function GetLongRusName(ordname,code:string):string;
      function GetEIByCode(lng : integer; ordname,code:string):string;
      function GetBOMByCode(ordname,code:string):string;
      function GetNetByCode(ordname,code:string):real;
      function GetVolByCode(ordname,code:string):real;
      function GetCIBByCode(ordname,code:string):integer;
      function GetPriceByCode(PInd : integer; ordname,code:string):real;
      function GetTNCodeByCode(ordname,code:string):string;
      function GetBoxTypeByCode(ordname,code:string):string;
    end;

var
  ModLst: TModList;

function NilOnePos:TOnePos;

implementation

//uses LangUnit;

//-------------------------- TDataList -----------------------------------------

function NilOnePos:TOnePos;
var
  res : TOnePos;
begin
  with res do
    begin
    Num      :=0;
    Code     :='';
    BOM      :='';
    RName    :='';
    LRName   :='';
    EName    :='';
    CName    :='';
    CntInOne :=0;
    EI       :='';
    Net      :=0;
    Vol      :=0;
    CntInBox :=0;
    BarCode  :='';
    TotCount :=0;
    end;
  result:=res;
end;

constructor TDataList.Create;
begin
  inherited;
  FCount:=0;
  SetLength(FItems,FCount);
end;

destructor TDataList.Destroy;
begin
  //
  inherited;
end;

procedure TDataList.Delete(Itm: TOnePos);
var
  i,j:integer;
begin
  i:=0;
  while Self.FItems[i].Code<>Itm.Code do inc(i);
  for j := i to self.FCount-2 do self.FItems[j]:=self.FItems[j+1];
  self.FCount:=self.FCount-1;
  //setLength(FItems,FCount);
end;

function TDataList.Add(NewItem: TOnePos): integer;
begin
  Inc(FCount);
  SetLength(FItems,FCount);
  FItems[FCount-1]:=NewItem;
  result:=FCount;
end;

function TDataList.LoadFrom1CTXT(FName:string):string;
var
  StrLst : TStringList;
  i      : Integer;
  OnePos : TOnePos;

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
  result:='';
  StrLst:=TStringList.Create;
  StrLst.LoadFromFile(FName);
  FEngName:=GetSubStr(1,StrLst[0]);
  for I := 1 to StrLst.Count - 1 do
    begin
      OnePos.Num      :=StrToInt(GetSubStr(1,StrLst[i]));
      OnePos.Code     :=GetSubStr(2,StrLst[i]);
      OnePos.BOM      :=GetSubStr(3,StrLst[i]);
      OnePos.TNCode   :=GetSubStr(4,StrLst[i]);
      OnePos.RName    :=GetSubStr(5,StrLst[i]);
      while pos('=',OnePos.RName)<>0 do OnePos.RName[pos('=',OnePos.RName)]:='-';
      OnePos.LRName   :=GetSubStr(6,StrLst[i]);
      OnePos.EName    :=GetSubStr(7,StrLst[i]);
      OnePos.CName    :=GetSubStr(8,StrLst[i]);
      OnePos.CntInOne :=StrToReal(GetSubStr(9,StrLst[i]));
      OnePos.EI       :=GetSubStr(10,StrLst[i]);
      OnePos.Net      :=StrToReal(GetSubStr(11,StrLst[i]));
      OnePos.Vol      :=StrToReal(GetSubStr(12,StrLst[i]));
      OnePos.CntInBox :=StrToInt(GetSubStr(13,StrLst[i]));
      OnePos.BarCode  :=GetSubStr(14,StrLst[i]);
      OnePos.GNet     :=StrToReal(GetSubStr(15,StrLst[i]));
      OnePos.BoxType  :=GetSubStr(16,StrLst[i]);
      OnePos.Price    :=StrToReal(GetSubStr(17,StrLst[i]));
      OnePos.PriceN   :=StrToReal(GetSubStr(18,StrLst[i]));
      OnePos.PriceA   :=StrToReal(GetSubStr(19,StrLst[i]));
      OnePos.TotCount :=StrToReal(GetSubStr(20,StrLst[i]));
      //-------------------------------
      OnePos.sel      := false;
      if ((OnePos.EI='г')or(OnePos.EI='Г')or(OnePos.EI='кг')or(OnePos.EI='КГ'))
        then OnePos.NetEI:=true else OnePos.NetEI:=false;
      OnePos.CIBOld   :=OnePos.CntInBox;
      self.Add(OnePos);
    end;
  result:=FEngName;
end;

function TDataList.IndByNum(num: Integer):integer;
var
  i : integer;
begin
  i:=0;
  while self.FItems[i].Num<>num do inc(i);
  result:=i;
end;

//-------------------------- TModList ------------------------------------------

constructor TModList.Create;
begin
  inherited;
  FCount:=0;
  SetLength(FModels,FCount);
end;

destructor TModList.Destroy;
begin
  //
  inherited;
end;

function TModList.Add(NewItem: TDataList): integer;
var
  i   : integer;
  Exs : boolean;
begin
  Exs:=false;
  for I := 0 to FCount - 1 do
    if self.FModels[i].FEngName=NewItem.FEngName then Exs:=true;
  if not Exs then
    begin
      Inc(FCount);
      SetLength(FModels,FCount);
      FModels[FCount-1]:=NewItem;
      result:=FCount;
    end else result:=0;
end;

procedure TModList.Delete (EngName:string);
var
  i : integer;
begin
  i:=0;
  while self.FModels[i].FEngName<>EngName do inc(i);
  FCount:=FCount-1;
  while i<FCount do
    begin
      self.FModels[i]:=self.FModels[i+1];
      inc(i);
    end;
end;

function TModList.IndByName(EngName:string): integer;
var
  i : integer;
begin
  if EngName<>'' then
    begin
      i:=0;
      while self.FModels[i].FEngName<>EngName do inc(i);
      result:=i;
    end else result:=0;
end;

function TModList.GetNameByCode(lng : integer; ordname,code:string):String;
var
  i,MI : integer;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.FModels[MI].FItems[i].Code<>code) do inc(i);
    if Lng=lgRUS then result:=self.FModels[MI].FItems[i].RName;
    if Lng=lgENG then
      if self.FModels[MI].FItems[i].EName<>'' then result:=self.FModels[MI].FItems[i].EName
      else result:=self.FModels[MI].FItems[i].CName;
    if Lng=lgCn  then
      if self.FModels[MI].FItems[i].CName<>'' then result:=self.FModels[MI].FItems[i].CName
      else result:=self.FModels[MI].FItems[i].EName;
  except
    result:='';
  end;
end;

function TModList.GetLongRusName(ordname,code:string):string;
var
  i,MI : integer;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.FModels[MI].FItems[i].Code<>code) do inc(i);
    result:=self.FModels[MI].FItems[i].LRName;
  except
    result:='';
  end;
end;

function TModList.GetEIByCode(lng : integer; ordname,code:string):string;
var
  i,MI : integer;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (i<self.FModels[MI].FCount)and(self.FModels[MI].FItems[i].Code<>code) do inc(i);
    if(i<self.FModels[MI].FCount)and(self.FModels[MI].FItems[i].Code=code)then begin
      //if (lng=lgEng) or (Lng=lgCn) then result:=TranslateEI(self.FModels[MI].FItems[i].EI);
      if lng=lgRUS then result:=(self.FModels[MI].FItems[i].EI);
    end else result:='';
  except
    result:='';
  end;
end;

function TModList.GetVolByCode(ordname,code:string):real;
var
  i,MI : integer;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.FModels[MI].FItems[i].code<>code) do inc(i);
    result:=(self.FModels[MI].FItems[i].vol);
  except
    result:=0;
  end;
end;

function TModList.GetPriceByCode(PInd:integer; ordname,code:string):real;
var
  i,MI : integer;
begin
  try
    result:=0;
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.FModels[MI].FItems[i].code<>code) do inc(i);
    if Pind=0 then result:=(self.FModels[MI].FItems[i].Price);
    if Pind=1 then result:=(self.FModels[MI].FItems[i].PriceN);
    if Pind=2 then result:=(self.FModels[MI].FItems[i].PriceA);
  except
    result:=0;
  end;
end;

function TModList.GetBOMByCode(ordname,code:string):string;
var
  i,MI : integer;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.FModels[MI].FItems[i].code<>code) do inc(i);
    result:=(self.FModels[MI].FItems[i].BOM);
  except
    result:='';
  end;
end;

function TModList.GetNetByCode(ordname,code:string):real;
var
  i,MI : integer;
  res  : real;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.Model[MI].Item[i].code<>code) do inc(i);
    res:=(self.Model[MI].Item[i].Net);
    result:=res;
  except
    result:=0;
  end;
end;

function TModList.GetCIBByCode(ordname,code:string):integer;
var
  i,MI : integer;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.FModels[MI].FItems[i].code<>code) do inc(i);
    result:=(self.FModels[MI].FItems[i].CntInBox);
  except
    result:=0;
  end;
end;

function TModList.GetTnCodeByCode(ordname,code:string):string;
var
  i,MI : integer;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.FModels[MI].FItems[i].code<>code) do inc(i);
    result:=(self.FModels[MI].FItems[i].TNCode);
  except
    result:='';
  end;
end;

function TModList.GetBoxTypeByCode(ordname,code:string):string;
var
  i,MI : integer;
begin
  try
    i:=0;
    while (self.FModels[i].FEngName<>ordname) do inc(i);
    MI:=i;
    i:=0;
    while (self.FModels[MI].FItems[i].code<>code) do inc(i);
    result:=(self.FModels[MI].FItems[i].BoxType);
  except
    result:='';
  end;
end;


end.
