program OrangeInventoryCli;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.JSON.Serializers,
  oi.win.software in 'oi.win.software.pas',
  System.JSON.Types,
  oi.utils.helpers in 'oi.utils.helpers.pas';

procedure Test;
var
  AppInstalled: TInstalledSoftware;
  JS: TJsonSerializer;
begin
  JS := TJsonSerializer.Create;
  JS.Formatting := TJsonFormatting.Indented;
  AppInstalled := TInstalledSoftware.Create;
  try
    var
    SI_List := AppInstalled.GetList;
    var
    data := JS.Serialize < TArray < TSoftwareInfo >> (SI_List);
    Write(data);
    // for var SI in SI_List do
    // begin
    // Writeln(SI.Name);
    // end;
  finally
    AppInstalled.Free;
  end;
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;

end.
