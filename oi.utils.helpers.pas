unit oi.utils.helpers;

interface

uses
  System.Win.Registry;

type
  TRegistryHelper = class helper for TRegistry
    function TryReadInteger(const Name: string; out Return: Integer): Boolean;
    function TryReadString(const Name: string; out Return: string): Boolean;
  end;

implementation

{ TRegistryHelper }

function TRegistryHelper.TryReadInteger(const Name: string; out Return: Integer): Boolean;
begin
  Result := Self.ValueExists(Name);
  if Result then
    Return := Self.ReadInteger(Name);
end;

function TRegistryHelper.TryReadString(const Name: string; out Return: string): Boolean;
begin
  Result := Self.ValueExists(Name);
  if Result then
    Return := Self.ReadString(Name);
end;

end.
