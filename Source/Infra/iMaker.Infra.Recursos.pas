unit iMaker.Infra.Recursos;

{ Emojis e sons embutidos no executável (iMakerAssets.res, tipo RCDATA). }

interface

uses
  System.SysUtils, System.Classes, System.Types, System.IOUtils,
  FMX.Graphics, iMaker.Model.Entidades;

type
  TEmoji = (emVitoria, emDerrota, emRodada, emBuraco, emVirada, emEmpate, emNegativo, emOuro, emLider);
  TSom = (smRodada, smPonto, smVitoria, smDerrota, smBuraco, smVirada, smEmpate, smNegativo, smOuro);

  TRecursos = class
  strict private
    class var FEmojis: array[TEmoji] of TBitmap;
  public
    class destructor Destroy;
    { Bitmap em cache. Não liberar: use Assign para copiar. }
    class function Emoji(aEmoji: TEmoji): TBitmap; static;
    { Caminho do arquivo .wav extraído para a pasta de cache do app }
    class function ArquivoSom(aSom: TSom): string; static;
    class function EmojiDoEvento(aTipo: TTipoEvento): TEmoji; static;
    class function SomDoEvento(aTipo: TTipoEvento): TSom; static;
  end;

implementation

const
  NOME_EMOJI: array[TEmoji] of string =
    ('VITORIA', 'DERROTA', 'RODADA', 'BURACO', 'VIRADA', 'EMPATE', 'NEGATIVO', 'OURO', 'LIDER');
  NOME_SOM: array[TSom] of string =
    ('RODADA', 'PONTO', 'VITORIA', 'DERROTA', 'BURACO', 'VIRADA', 'EMPATE', 'NEGATIVO', 'OURO');

{ TRecursos }

class destructor TRecursos.Destroy;
var
  vEmoji: TEmoji;
begin
  for vEmoji := Low(TEmoji) to High(TEmoji) do
    FreeAndNil(FEmojis[vEmoji]);
end;

class function TRecursos.Emoji(aEmoji: TEmoji): TBitmap;
var
  vStream: TResourceStream;
begin
  if not Assigned(FEmojis[aEmoji]) then
  begin
    vStream := TResourceStream.Create(HInstance, 'EMOJI_' + NOME_EMOJI[aEmoji], RT_RCDATA);
    try
      FEmojis[aEmoji] := TBitmap.Create;
      FEmojis[aEmoji].LoadFromStream(vStream);
    finally
      vStream.Free;
    end;
  end;
  Result := FEmojis[aEmoji];
end;

class function TRecursos.ArquivoSom(aSom: TSom): string;
var
  vStream: TResourceStream;
begin
  Result := TPath.Combine(TPath.GetCachePath, 'imaker_' + NOME_SOM[aSom].ToLower + '.wav');
  if TFile.Exists(Result) then
    Exit;

  vStream := TResourceStream.Create(HInstance, 'SOM_' + NOME_SOM[aSom], RT_RCDATA);
  try
    vStream.SaveToFile(Result);
  finally
    vStream.Free;
  end;
end;

class function TRecursos.EmojiDoEvento(aTipo: TTipoEvento): TEmoji;
begin
  case aTipo of
    teVitoria:        Result := emVitoria;
    teEmpateNaMeta:   Result := emEmpate;
    teEntrouNoBuraco: Result := emBuraco;
    teVirada:         Result := emVirada;
    teEmpate:         Result := emEmpate;
    teNegativo:       Result := emNegativo;
    teRodadaDeOuro:   Result := emOuro;
  else
    Result := emRodada;
  end;
end;

class function TRecursos.SomDoEvento(aTipo: TTipoEvento): TSom;
begin
  case aTipo of
    teVitoria:        Result := smVitoria;
    teEmpateNaMeta:   Result := smEmpate;
    teEntrouNoBuraco: Result := smBuraco;
    teVirada:         Result := smVirada;
    teEmpate:         Result := smEmpate;
    teNegativo:       Result := smNegativo;
    teRodadaDeOuro:   Result := smOuro;
  else
    Result := smRodada;
  end;
end;

end.
