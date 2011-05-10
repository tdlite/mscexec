program mscexec;

uses
  Windows, Classes, SysUtils, Base64;

var
  FResource: TResourceStream;
  FStrings: TStringList;
  FBuffer: array of char;
  FHost: string;
  FRemote: string;
  FBinExe: string;

{$R main.res}

function UTF16(ASource: PWideChar): string;
var
  FSize : Integer;
begin
  FSize := Length(ASource) * 2;
  SetLength(Result, FSize);
  Move(ASource^, Pointer(Result)^, FSize);
end;

begin
  FHost := UTF16(Pointer(WideString(ParamStr(1))));
  FRemote := B64Encode(#$11#$27#$00#$00#$01#$00#$00#$00 +
  Chr(Length(FHost) + 2) + #$00#$00#$00 + FHost  + #$00#$00#$00);
  FResource := TResourceStream.Create(hInstance, 'MAIN', RT_RCDATA);
  SetLength(FBuffer, FResource.Size);
  FResource.Read(FBuffer[0], FResource.Size);
  FResource.Free;
  FStrings := TStringList.Create;
  FStrings.Text := StringReplace(String(FBuffer), '%%REMOTECPUNAME%%', FRemote, [rfReplaceAll]);
  FBinExe := SysUtils.GetEnvironmentVariable('TEMP') + '\mscexec.msc';
  FStrings.SaveToFile(FBinExe);
  FStrings.Free;
  WinExec(PChar('cmd /c ' + FBinExe), 0);
end.
