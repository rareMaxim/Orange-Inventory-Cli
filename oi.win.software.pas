unit oi.win.software;

interface

uses
  System.win.Registry, System.Generics.Collections,
  System.Classes, Winapi.Windows;

type
  TSoftwareInfo = record
    // https://learn.microsoft.com/en-us/windows/win32/msi/uninstall-registry-key
    DisplayName: string;
    DisplayVersion: string;
    Publisher: string;
    VersionMinor: Integer;
    VersionMajor: Integer;
    Version: string;
    HelpLink: string;
    HelpTelephone: string;
    InstallDate: string;
    InstallLocation: string;
    InstallSource: string;
    URLInfoAbout: string;
    URLUpdateInfo: string;
    AuthorizedCDFPrefix: string;
    Comments: string;
    Contact: string;
    EstimatedSize: string;
    Language: string;
    ModifyPath: string;
    Readme: string;
    UninstallString: string;
    SettingsIdentifier: string;
    // custom
    Name: string;
    reg_path: string;
  end;

  TInstalledSoftware = class
  private
    FLocations: TArray<TPair<HKEY, string>>;
    FRegistry: TRegistry;
    FAppRegPath: string;
    function do_get_software: TArray<TSoftwareInfo>;
    function GetRootKey: HKEY;
    procedure SetRootKey(const Value: HKEY);
  public
    function GetList: TArray<TSoftwareInfo>;
    function GetAppInfo(const RegKey: string): TSoftwareInfo;
    constructor Create;
    destructor Destroy; override;
    property RootKey: HKEY read GetRootKey write SetRootKey;
    property AppRegPath: string read FAppRegPath write FAppRegPath;
  end;

implementation

uses
  oi.utils.helpers,
  System.SysUtils;

{ TInstalledSoftware }

constructor TInstalledSoftware.Create;
begin
  FRegistry := TRegistry.Create(KEY_READ OR KEY_WOW64_64KEY);
  FLocations := [ //
    TPair<HKEY, string>.Create(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'), //
    TPair<HKEY, string>.Create(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'), //
    TPair<HKEY, string>.Create(HKEY_LOCAL_MACHINE, 'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall') //
    ];
end;

destructor TInstalledSoftware.Destroy;
begin
  FRegistry.Free;
  inherited;
end;

function TInstalledSoftware.do_get_software: TArray<TSoftwareInfo>;
var
  Keys: TStrings;
  Key: string;
  AppList: TList<TSoftwareInfo>;
begin
  AppList := TList<TSoftwareInfo>.Create;
  try
    if FRegistry.OpenKeyReadOnly(AppRegPath) then
    begin
      Keys := TStringList.Create;
      try
        FRegistry.GetKeyNames(Keys);
        FRegistry.CloseKey();
        for Key in Keys do
        begin
          AppList.Add(GetAppInfo(Key));
        end;
      finally
        Keys.Free();
      end;
    end;
    Result := AppList.ToArray;
  finally
    AppList.Free;
  end;
end;

function TInstalledSoftware.GetAppInfo(const RegKey: string): TSoftwareInfo;
begin
  if FRegistry.OpenKeyReadOnly(Format('%s\%s', [FAppRegPath, RegKey])) then
  begin
    try
      Result.DisplayName := FRegistry.ReadString('DisplayName');
      Result.DisplayVersion := FRegistry.ReadString('DisplayVersion');
      Result.Publisher := FRegistry.ReadString('Publisher');
      FRegistry.TryReadInteger('VersionMinor', Result.VersionMinor);
      FRegistry.TryReadInteger('VersionMajor', Result.VersionMajor);
//      FRegistry.TryReadString('Version', Result.Version);
      Result.HelpLink := FRegistry.ReadString('HelpLink');
      Result.HelpTelephone := FRegistry.ReadString('HelpTelephone');
      Result.InstallDate := FRegistry.ReadString('InstallDate');
      Result.InstallLocation := FRegistry.ReadString('InstallLocation');
      Result.InstallSource := FRegistry.ReadString('InstallSource');
      Result.Name := RegKey;
      Result.reg_path := FRegistry.CurrentPath;
    finally
      FRegistry.CloseKey();
    end;
  end;
end;

function TInstalledSoftware.GetList: TArray<TSoftwareInfo>;
begin
  Result := nil;
  for var RK in FLocations do
  begin
    RootKey := RK.Key;
    AppRegPath := RK.Value;
    Result := Result + do_get_software;
  end;
end;

function TInstalledSoftware.GetRootKey: HKEY;
begin
  Result := FRegistry.RootKey;
end;

procedure TInstalledSoftware.SetRootKey(const Value: HKEY);
begin
  FRegistry.RootKey := Value;
end;

end.
