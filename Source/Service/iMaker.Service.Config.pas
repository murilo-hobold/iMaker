unit iMaker.Service.Config;

{ Configurações do aplicativo (meta padrão, som, tela acesa). }

interface

uses
  System.SysUtils, iMaker.Model.Entidades, iMaker.Repository.Config;

type
  TConfigService = class
  strict private
    class var FConfig: TConfigApp;
    class var FCarregada: Boolean;
  public
    class function Atual: TConfigApp; static;
    class procedure Salvar(const aConfig: TConfigApp); static;
  end;

implementation

const
  CHAVE_META = 'meta_padrao';
  CHAVE_SOM  = 'som_ativo';
  CHAVE_TELA = 'tela_acesa';

{ TConfigService }

class function TConfigService.Atual: TConfigApp;
var
  vPadrao: TConfigApp;
begin
  if not FCarregada then
  begin
    vPadrao := TConfigApp.Padrao;
    FConfig.MetaPadrao := StrToIntDef(TConfigRepository.Ler(CHAVE_META, vPadrao.MetaPadrao.ToString), META_PADRAO);
    FConfig.SomAtivo := TConfigRepository.Ler(CHAVE_SOM, BoolToStr(vPadrao.SomAtivo, True)) = BoolToStr(True, True);
    FConfig.TelaSempreAcesa := TConfigRepository.Ler(CHAVE_TELA, BoolToStr(vPadrao.TelaSempreAcesa, True)) = BoolToStr(True, True);
    FCarregada := True;
  end;
  Result := FConfig;
end;

class procedure TConfigService.Salvar(const aConfig: TConfigApp);
begin
  if aConfig.MetaPadrao < META_MINIMA then
    raise EIMakerValidacao.CreateFmt('A meta padrão deve ser de pelo menos %d pontos.', [META_MINIMA]);

  TConfigRepository.Gravar(CHAVE_META, aConfig.MetaPadrao.ToString);
  TConfigRepository.Gravar(CHAVE_SOM, BoolToStr(aConfig.SomAtivo, True));
  TConfigRepository.Gravar(CHAVE_TELA, BoolToStr(aConfig.TelaSempreAcesa, True));
  FConfig := aConfig;
  FCarregada := True;
end;

end.
