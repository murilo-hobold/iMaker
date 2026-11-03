unit iMaker.Infra.Som;

{ Reprodução dos efeitos sonoros (TMediaPlayer nativo do FMX). }

interface

uses
  System.SysUtils, FMX.Media, iMaker.Infra.Recursos;

type
  TSomPlayer = class
  strict private
    class var FPlayer: TMediaPlayer;
    class var FAtivo: Boolean;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure Tocar(aSom: TSom); static;
    class property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

{ TSomPlayer }

class constructor TSomPlayer.Create;
begin
  FAtivo := True;
end;

class destructor TSomPlayer.Destroy;
begin
  FreeAndNil(FPlayer);
end;

class procedure TSomPlayer.Tocar(aSom: TSom);
begin
  if not FAtivo then
    Exit;
  try
    if not Assigned(FPlayer) then
      FPlayer := TMediaPlayer.Create(nil);
    if FPlayer.State = TMediaState.Playing then
      FPlayer.Stop;
    FPlayer.FileName := TRecursos.ArquivoSom(aSom);
    FPlayer.CurrentTime := 0;
    FPlayer.Play;
  except
    { Som é acessório: uma falha no player nunca deve interromper o jogo }
  end;
end;

end.
