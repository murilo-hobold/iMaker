unit iMaker.View.Principal;

{ Tela principal: cabeçalho, abas inferiores, área de navegação (Router4D)
  e configurações. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  iMaker.View.Navegacao;

type
  TFormPrincipal = class(TForm)
    LayoutTopo: TLayout;
    ImgLogo: TImage;
    RectBtnConfig: TRectangle;
    PathConfig: TPath;
    LayoutTitulos: TLayout;
    LabApp: TLabel;
    LabTitulo: TLabel;
    RectNav: TRectangle;
    LayTabJogo: TLayout;
    PathTabJogo: TPath;
    LabTabJogo: TLabel;
    LayTabHistorico: TLayout;
    PathTabHistorico: TPath;
    LabTabHistorico: TLabel;
    LayTabRanking: TLayout;
    PathTabRanking: TPath;
    LabTabRanking: TLabel;
    LayTabJogadores: TLayout;
    PathTabJogadores: TPath;
    LabTabJogadores: TLabel;
    LayoutTela: TLayout;
    LayoutConfig: TLayout;
    RectConfigFundo: TRectangle;
    RectConfigCard: TRectangle;
    LabConfigTitulo: TLabel;
    LabMetaTitulo: TLabel;
    RectMetaPadrao: TRectangle;
    EdtMetaPadrao: TEdit;
    LabMetaInfo: TLabel;
    LayoutSom: TLayout;
    SwSom: TSwitch;
    LabSom: TLabel;
    LayoutTelaAcesa: TLayout;
    SwTelaAcesa: TSwitch;
    LabTelaAcesa: TLabel;
    RectBtnSalvarConfig: TRectangle;
    LabBtnSalvarConfig: TLabel;
    RectConfigFechar: TRectangle;
    LabConfigFechar: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure TabClick(Sender: TObject);
    procedure RectNavResize(Sender: TObject);
    procedure RectBtnConfigClick(Sender: TObject);
    procedure RectConfigFecharClick(Sender: TObject);
    procedure RectBtnSalvarConfigClick(Sender: TObject);
    procedure EdtMetaPadraoChangeTracking(Sender: TObject);
  private
    procedure RegistrarRotas;
    procedure AoNavegar(aRota: TRota);
    procedure AtualizarAbas(aRota: TRota);
    procedure AplicarConfig;
    procedure TratarExcecao(Sender: TObject; E: Exception);
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.fmx}

uses
  Router4D,
  iMaker.Model.Entidades, iMaker.Service.Config, iMaker.Service.Jogador,
  iMaker.Infra.Recursos, iMaker.Infra.Som, iMaker.Infra.Plataforma,
  iMaker.View.Tema, iMaker.View.Componentes,
  iMaker.View.Jogo, iMaker.View.NovaPartida, iMaker.View.Jogadores,
  iMaker.View.Historico, iMaker.View.Ranking;

{ TFormPrincipal }

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  Application.OnException := TratarExcecao;
  SystemStatusBar.BackgroundColor := COR_FUNDO;
  ImgLogo.Bitmap.Assign(TRecursos.Emoji(emRodada));

  AplicarConfig;

  TNavegacao.OnNavegou := AoNavegar;
  TNavegacao.Container := LayoutTela;
  RegistrarRotas;
  TRouter4D.Render<TFormJogo>.SetElement(LayoutTela, LayoutTela);
  AtualizarAbas(rtJogo);

  { Primeiro uso: sem jogadores cadastrados, começa pelo cadastro }
  if Length(TJogadorService.Listar) = 0 then
    TNavegacao.Ir(rtJogadores);
end;

procedure TFormPrincipal.RegistrarRotas;
begin
  TRouter4D.Switch.Router(TNavegacao.NomeRota(rtJogo), TFormJogo);
  TRouter4D.Switch.Router(TNavegacao.NomeRota(rtNovaPartida), TFormNovaPartida);
  TRouter4D.Switch.Router(TNavegacao.NomeRota(rtHistorico), TFormHistorico);
  TRouter4D.Switch.Router(TNavegacao.NomeRota(rtRanking), TFormRanking);
  TRouter4D.Switch.Router(TNavegacao.NomeRota(rtJogadores), TFormJogadores);
end;

procedure TFormPrincipal.AplicarConfig;
var
  vConfig: TConfigApp;
begin
  vConfig := TConfigService.Atual;
  TSomPlayer.Ativo := vConfig.SomAtivo;
  TPlataforma.ManterTelaAcesa(vConfig.TelaSempreAcesa);
end;

procedure TFormPrincipal.TratarExcecao(Sender: TObject; E: Exception);
begin
  if E is EIMakerValidacao then
    TDialogo.Aviso(E.Message)
  else
    TDialogo.Aviso('Ops! Algo deu errado:' + sLineBreak + E.Message);
end;

procedure TFormPrincipal.AoNavegar(aRota: TRota);
begin
  LabTitulo.Text := TNavegacao.Titulo(aRota);
  AtualizarAbas(aRota);
end;

procedure TFormPrincipal.AtualizarAbas(aRota: TRota);

  procedure Pintar(aPath: TPath; aLabel: TLabel; aAtiva: Boolean);
  var
    vCor: TAlphaColor;
  begin
    if aAtiva then
      vCor := COR_OURO
    else
      vCor := TAlphaColor($FF7A7A7A);
    aPath.Stroke.Color := vCor;
    aLabel.TextSettings.FontColor := vCor;
  end;

begin
  { "Nova partida" fica sob a aba Partida }
  Pintar(PathTabJogo, LabTabJogo, aRota in [rtJogo, rtNovaPartida]);
  Pintar(PathTabHistorico, LabTabHistorico, aRota = rtHistorico);
  Pintar(PathTabRanking, LabTabRanking, aRota = rtRanking);
  Pintar(PathTabJogadores, LabTabJogadores, aRota = rtJogadores);
end;

procedure TFormPrincipal.TabClick(Sender: TObject);
var
  vRota: TRota;
begin
  vRota := TRota(TControl(Sender).Tag);
  Pulsar(TControl(Sender));
  TNavegacao.Ir(vRota);
end;

procedure TFormPrincipal.RectNavResize(Sender: TObject);
var
  vLargura: Single;
begin
  vLargura := RectNav.Width / 4;
  LayTabJogo.Width := vLargura;
  LayTabHistorico.Width := vLargura;
  LayTabRanking.Width := vLargura;
  LayTabJogadores.Width := vLargura;
end;

procedure TFormPrincipal.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar;
  Shift: TShiftState);
begin
  if Key <> vkHardwareBack then
    Exit;

  if LayoutConfig.Visible then
  begin
    RectConfigFecharClick(nil);
    Key := 0;
  end
  else if TNavegacao.RotaAtual <> rtJogo then
  begin
    TNavegacao.Ir(rtJogo);
    Key := 0;
  end;
end;

{ Configurações }

procedure TFormPrincipal.RectBtnConfigClick(Sender: TObject);
var
  vConfig: TConfigApp;
begin
  vConfig := TConfigService.Atual;
  EdtMetaPadrao.Text := vConfig.MetaPadrao.ToString;
  SwSom.IsChecked := vConfig.SomAtivo;
  SwTelaAcesa.IsChecked := vConfig.TelaSempreAcesa;
  EdtMetaPadraoChangeTracking(nil);
  TModal.Mostrar(LayoutConfig, RectConfigCard);
end;

procedure TFormPrincipal.EdtMetaPadraoChangeTracking(Sender: TObject);
var
  vMeta: Integer;
begin
  vMeta := StrToIntDef(EdtMetaPadrao.Text, 0);
  if vMeta >= META_MINIMA then
    LabMetaInfo.Text := Format('A equipe entra no buraco ao chegar em %s pontos (metade da meta).',
      [FormatarPontos(vMeta div 2)])
  else
    LabMetaInfo.Text := Format('A meta deve ter pelo menos %d pontos. Recomendado: %s.',
      [META_MINIMA, FormatarPontos(META_PADRAO)]);
end;

procedure TFormPrincipal.RectBtnSalvarConfigClick(Sender: TObject);
var
  vConfig: TConfigApp;
begin
  vConfig.MetaPadrao := StrToIntDef(EdtMetaPadrao.Text, 0);
  vConfig.SomAtivo := SwSom.IsChecked;
  vConfig.TelaSempreAcesa := SwTelaAcesa.IsChecked;
  TConfigService.Salvar(vConfig);
  AplicarConfig;
  RectConfigFecharClick(nil);
  TToast.Mostrar(LayoutTela, 'Configurações salvas.');
end;

procedure TFormPrincipal.RectConfigFecharClick(Sender: TObject);
begin
  TModal.Esconder(LayoutConfig, RectConfigCard);
end;

end.
