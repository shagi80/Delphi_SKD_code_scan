program Project1;

uses
  Windows, Forms,
  MainUnit in 'MainUnit.pas' {ScanMainForm},
  PrUnit in 'PrUnit.pas' {PrDM: TDataModule},
  TDataLst in 'TDataLst.pas',
  TCont in 'TCont.pas';

var
  Handle1 : LongInt;
  Handle2 : LongInt;

{$R *.res}


begin
  Application.Initialize;
  Handle1 := FindWindow('TScanMainForm',nil);
  if handle1 = 0 then
  begin
    Application.CreateForm(TScanMainForm, ScanMainForm);
    Application.CreateForm(TPrDM, PrDM);
    Application.Run;
  end
  else
  begin
    Handle2 := GetWindow(Handle1,GW_OWNER);
    //Чтоб заметили :)
    ShowWindow(Handle2,SW_HIDE);
    ShowWindow(Handle2,SW_RESTORE);
    SetForegroundWindow(Handle1); // Активизируем
  end;

end.
