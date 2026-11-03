unit iMaker.View.Jogo;

{ Tela da partida: placar, cronômetro, rodadas, lançamento/edição de
  rodada, celebrações (emoji + som) e compartilhamento. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Objects, FMX.Layouts,
  FMX.StdCtrls, FMX.Edit, FMX.Ani, FMX.Controls.Presentation,
  Router4D.Interfaces,
  iMaker.Model.Entidades, iMaker.Frame.EquipePlacar;

type
  TFormJogo = class(TForm, iRouter4DComponent)
    LayoutPrincipal: TLayout;
    LayoutVazio: TLayout;
    ImgVazio: TImage;
    LabVazioTitulo: TLabel;
    LabVazioMsg: TLabel;
    RectBtnNovaVazio: TRectangle;
    LabBtnNovaVazio: TLabel;
    LayoutPartida: TLayout;
    RectCaptura: TRectangle;
    LayoutInfo: TLayout;
    RectBtnCompartilhar: TRectangle;
    PathCompartilhar: TPath;
    RectChipMeta: TRectangle;
    LabMeta: TLabel;
    RectChipTempo: TRectangle;
    PathTempo: TPath;
    LabTempo: TLabel;
    LayoutPlacar: TLayout;
    RectVencedor: TRectangle;
    ImgVencedor: TImage;
    LayoutVencedorTextos: TLayout;
    LabVencedorTitulo: TLabel;
    LabVencedorMsg: TLabel;
    LayoutAcoes: TLayout;
    RectProxima: TRectangle;
    PathDealer: TPath;
    LabProxima: TLabel;
    RectBtnLancar: TRectangle;
    LabBtnLancar: TLabel;
    RectBtnNovaFim: TRectangle;
    LabBtnNovaFim: TLabel;
    LayoutCabecalho: TLayout;
    LabCabNumero: TLabel;
    LabCabDealer: TLabel;
    LayoutCabEspaco: TLayout;
    LayoutCabPontos: TLayout;
    LabCab1: TLabel;
    LabCab2: TLabel;
    LabCab3: TLabel;
    LabSemRodadas: TLabel;
    VsbRodadas: TVertScrollBox;
    LayoutModalRodada: TLayout;
    RectModalFundo: TRectangle;
    RectModalCard: TRectangle;
    LabModalTitulo: TLabel;
    LabModalSub: TLabel;
    LayoutCampo1: TLayout;
    LabCampo1: TLabel;
    RectSinal1: TRectangle;
    LabSinal1: TLabel;
    RectEdit1: TRectangle;
    EdtPontos1: TEdit;
    LayoutCampo2: TLayout;
    LabCampo2: TLabel;
    RectSinal2: TRectangle;
    LabSinal2: TLabel;
    RectEdit2: TRectangle;
    EdtPontos2: TEdit;
    LayoutCampo3: TLayout;
    LabCampo3: TLabel;
    RectSinal3: TRectangle;
    LabSinal3: TLabel;
    RectEdit3: TRectangle;
    EdtPontos3: TEdit;
    LabDealerTitulo: TLabel;
    RectDealer: TRectangle;
    PathDealerSeta: TPath;
    LabDealerNome: TLabel;
    RectBtnSalvar: TRectangle;
    LabBtnSalvar: TLabel;
    LayoutBotoesSec: TLayout;
    RectBtnExcluir: TRectangle;
    LabBtnExcluir: TLabel;
    RectBtnCancelar: TRectangle;
    LabBtnCancelar: TLabel;
    LayoutCelebracao: TLayout;
    RectCelebFundo: TRectangle;
    LayoutCelebConteudo: TLayout;
    ImgCeleb: TImage;
    LabCelebTitulo: TLabel;
    LabCelebMsg: TLabel;
    LayoutCelebPerdedores: TLayout;
    ImgDerrota: TImage;
    LabPerdedores: TLabel;
    RectBtnCeleb: TRectangle;
    LabBtnCeleb: TLabel;
    TimerRelogio: TTimer;
    procedure BtnNovaPartidaClick(Sender: TObject);
    procedure RectBtnLancarClick(Sender: TObject);
    procedure RectBtnSalvarClick(Sender: TObject);
    procedure RectBtnCancelarClick(Sender: TObject);
    procedure RectBtnExcluirClick(Sender: TObject);
    procedure RectSinalClick(Sender: TObject);
    procedure RectDealerClick(Sender: TObject);
    procedure RectBtnCelebClick(Sender: TObject);
    procedure RectBtnCompartilharClick(Sender: TObject);
    procedure LayoutPlacarResize(Sender: TObject);
    procedure LayoutCabPontosResize(Sender: TObject);
    procedure TimerRelogioTimer(Sender: TObject);
  private
    FPartida: TPartida;
    FTemPartida: Boolean;
    FCards: TArray<TFrameEquipePlacar>;
    FRodadaEditando: Integer;     // 0 = nova rodada
    FDealerSelecionado: Integer;  // id do jogador
    procedure Recarregar(aAnimar: Boolean);
    procedure Exibir(aAnimar: Boolean);
    procedure ExibirCards(aAnimar: Boolean);
    procedure ExibirRodadas;
    procedure ExibirVencedor;
    procedure RodadaClick(Sender: TObject);
    procedure AbrirModalRodada(aRodadaId: Integer);
    procedure FecharModalRodada;
    procedure ExibirDealerSelecionado;
    function EditPontos(aEquipe: Integer): TEdit;
    procedure ProcessarResultado(const aResultado: TResultadoRodada);
    procedure Celebrar(const aEvento: TEvento);
    procedure AgendarAviso(aAtrasoMs: Integer; const aEvento: TEvento);
  public
    function Render: TFMXObject;
    procedure UnRender;
  end;

var
  FormJogo: TFormJogo;

implementation

{$R *.fmx}

uses
  iMaker.Service.Partida, iMaker.Infra.Recursos, iMaker.Infra.Som,
  iMaker.Infra.Plataforma, iMaker.View.Tema, iMaker.View.Componentes,
  iMaker.View.Navegacao, iMaker.Frame.Rodada, iMaker.Frame.Picker;

const
  EVENTOS_GRANDES = [teVitoria, teEmpateNaMeta, teEntrouNoBuraco, teVirada, teRodadaDeOuro];

{ Router4D }

function TFormJogo.Render: TFMXObject;
begin
  LayoutModalRodada.Visible := False;
  LayoutCelebracao.Visible := False;
  Recarregar(False);

  if FTemPartida and TNavegacao.MostrarInicioDaPartida then
  begin
    TNavegacao.MostrarInicioDaPartida := False;
    Atrasar(350,
      procedure
      begin
        Celebrar(TPartidaService.EventoRodadaAtual(FPartida));
      end);
  end;

  Result := LayoutPrincipal;
end;

procedure TFormJogo.UnRender;
begin
  TimerRelogio.Enabled := False;
end;

{ Carga e exibição }

procedure TFormJogo.Recarregar(aAnimar: Boolean);
var
  vId: Integer;
begin
  vId := TPartidaService.PartidaAtualId;
  FTemPartida := vId > 0;
  if FTemPartida then
    FPartida := TPartidaService.Carregar(vId);
  Exibir(aAnimar);
end;

procedure TFormJogo.Exibir(aAnimar: Boolean);
var
  vDealer: TJogador;
begin
  LayoutVazio.Visible := not FTemPartida;
  LayoutPartida.Visible := FTemPartida;
  TimerRelogio.Enabled := FTemPartida and not FPartida.Finalizada;

  if not FTemPartida then
  begin
    ImgVazio.Bitmap.Assign(TRecursos.Emoji(emRodada));
    Exit;
  end;

  LabMeta.Text := Format('Meta %s  ·  Buraco %s',
    [FormatarPontos(FPartida.Meta), FormatarPontos(FPartida.LimiteBuraco)]);
  LabTempo.Text := FormatarDuracao(FPartida.DuracaoSegundos);

  ExibirCards(aAnimar);
  ExibirVencedor;

  if FPartida.Finalizada then
  begin
    LabProxima.Text := Format('Partida encerrada em %d rodada(s)', [Length(FPartida.Rodadas)]);
    RectBtnLancar.Visible := False;
    RectBtnNovaFim.Visible := True;
  end
  else
  begin
    vDealer := FPartida.ProximoDealer;
    LabProxima.Text := Format('Rodada %d  ·  %s embaralha',
      [FPartida.ProximoNumeroRodada, vDealer.PrimeiroNome]);
    RectBtnLancar.Visible := True;
    RectBtnNovaFim.Visible := False;
  end;

  ExibirRodadas;
end;

procedure TFormJogo.ExibirCards(aAnimar: Boolean);
var
  I: Integer;
  vCard: TFrameEquipePlacar;
begin
  { Recria os cards só quando muda a quantidade de equipes }
  if Length(FCards) <> FPartida.QtEquipes then
  begin
    for vCard in FCards do
      vCard.Free;
    SetLength(FCards, FPartida.QtEquipes);
    for I := 0 to High(FCards) do
    begin
      FCards[I] := TFrameEquipePlacar.Create(nil);
      FCards[I].Name := '';
      FCards[I].Parent := LayoutPlacar;
      FCards[I].Align := TAlignLayout.Left;
    end;
    aAnimar := False;
  end;

  for I := 0 to High(FCards) do
  begin
    FCards[I].Exibir(FPartida, I + 1, aAnimar);
    if FPartida.QtEquipes = 3 then
      FCards[I].LabTotal.TextSettings.Font.Size := 28
    else
      FCards[I].LabTotal.TextSettings.Font.Size := 36;
  end;
  LayoutPlacarResize(nil);
end;

procedure TFormJogo.ExibirVencedor;
var
  vAltura: Single;
begin
  RectVencedor.Visible := FPartida.Finalizada;
  vAltura := 4 + 36 + 8 + 150 + 4;
  if FPartida.Finalizada then
  begin
    ImgVencedor.Bitmap.Assign(TRecursos.Emoji(emVitoria));
    LabVencedorTitulo.Text := FPartida.NomeEquipe(FPartida.EquipeVencedora) + ' venceu!';
    LabVencedorMsg.Text := Format('%s  ·  %s pontos  ·  %s',
      [FPartida.Equipes[FPartida.EquipeVencedora - 1].NomesJogadores,
       FormatarPontos(FPartida.Total(FPartida.EquipeVencedora)),
       FormatarDuracao(FPartida.DuracaoSegundos)]);
    vAltura := vAltura + 10 + 64;
  end;
  RectCaptura.Height := vAltura;
end;

procedure TFormJogo.ExibirRodadas;
var
  I: Integer;
  vLinha: TFrameRodada;
  vLabels: array[1..3] of TLabel;
  vEq: Integer;
begin
  vLabels[1] := LabCab1;
  vLabels[2] := LabCab2;
  vLabels[3] := LabCab3;
  for vEq := 1 to 3 do
  begin
    vLabels[vEq].Visible := vEq <= FPartida.QtEquipes;
    if vEq <= FPartida.QtEquipes then
      vLabels[vEq].Text := FPartida.NomeEquipe(vEq).ToUpper;
  end;
  LayoutCabPontosResize(nil);

  LimparLista(VsbRodadas);
  LabSemRodadas.Visible := Length(FPartida.Rodadas) = 0;
  LayoutCabecalho.Visible := not LabSemRodadas.Visible;

  VsbRodadas.BeginUpdate;
  try
    { Mais recente primeiro }
    for I := High(FPartida.Rodadas) downto 0 do
    begin
      vLinha := TFrameRodada.Create(nil);
      vLinha.Name := '';
      vLinha.Parent := VsbRodadas;
      vLinha.Align := TAlignLayout.Top;
      vLinha.Position.Y := (High(FPartida.Rodadas) - I) * 100;
      vLinha.Exibir(FPartida.Rodadas[I], FPartida.QtEquipes, True);
      vLinha.RectFundo.OnClick := RodadaClick;
    end;
  finally
    VsbRodadas.EndUpdate;
  end;
end;

procedure TFormJogo.LayoutPlacarResize(Sender: TObject);
var
  I: Integer;
  vLargura: Single;
begin
  if Length(FCards) = 0 then
    Exit;
  vLargura := LayoutPlacar.Width / Length(FCards);
  for I := 0 to High(FCards) do
  begin
    FCards[I].Width := vLargura;
    FCards[I].Position.X := I * vLargura;
  end;
end;

procedure TFormJogo.LayoutCabPontosResize(Sender: TObject);
var
  vLargura: Single;
begin
  if not FTemPartida then
    Exit;
  vLargura := LayoutCabPontos.Width / FPartida.QtEquipes;
  LabCab1.Width := vLargura;
  LabCab2.Width := vLargura;
  LabCab3.Width := vLargura;
end;

procedure TFormJogo.TimerRelogioTimer(Sender: TObject);
begin
  if FTemPartida then
    LabTempo.Text := FormatarDuracao(FPartida.DuracaoSegundos);
end;

{ Ações }

procedure TFormJogo.BtnNovaPartidaClick(Sender: TObject);
begin
  TNavegacao.Ir(rtNovaPartida);
end;

procedure TFormJogo.RectBtnLancarClick(Sender: TObject);
begin
  Pulsar(RectBtnLancar);
  AbrirModalRodada(0);
end;

procedure TFormJogo.RodadaClick(Sender: TObject);
begin
  AbrirModalRodada(TControl(Sender).Tag);
end;

function TFormJogo.EditPontos(aEquipe: Integer): TEdit;
begin
  case aEquipe of
    1: Result := EdtPontos1;
    2: Result := EdtPontos2;
  else
    Result := EdtPontos3;
  end;
end;

procedure TFormJogo.AbrirModalRodada(aRodadaId: Integer);
var
  vIndice, vEq: Integer;
  vRodada: TRodada;
  vCampos: array[1..3] of TLayout;
  vTitulos: array[1..3] of TLabel;
begin
  if not FTemPartida then
    Exit;

  vCampos[1] := LayoutCampo1;  vCampos[2] := LayoutCampo2;  vCampos[3] := LayoutCampo3;
  vTitulos[1] := LabCampo1;    vTitulos[2] := LabCampo2;    vTitulos[3] := LabCampo3;

  FRodadaEditando := aRodadaId;
  vIndice := FPartida.IndiceRodada(aRodadaId);

  if vIndice >= 0 then
  begin
    vRodada := FPartida.Rodadas[vIndice];
    LabModalTitulo.Text := Format('Editar rodada %d', [vRodada.Numero]);
    LabBtnSalvar.Text := 'Salvar alterações';
    FDealerSelecionado := vRodada.DealerId;
  end
  else
  begin
    FRodadaEditando := 0;
    vRodada := Default(TRodada);
    LabModalTitulo.Text := Format('Rodada %d', [FPartida.ProximoNumeroRodada]);
    LabBtnSalvar.Text := 'Salvar rodada';
    FDealerSelecionado := FPartida.ProximoDealer.Id;
  end;
  RectBtnExcluir.Visible := FRodadaEditando > 0;

  for vEq := 1 to 3 do
  begin
    vCampos[vEq].Visible := vEq <= FPartida.QtEquipes;
    if vEq > FPartida.QtEquipes then
      Continue;
    vTitulos[vEq].Text := FPartida.NomeEquipe(vEq) + '  ·  ' +
      FPartida.Equipes[vEq - 1].NomesJogadores;
    vTitulos[vEq].TextSettings.FontColor := CORES_EQUIPE[vEq];
    if FRodadaEditando > 0 then
      EditPontos(vEq).Text := vRodada.PontosEquipe(vEq).ToString
    else
      EditPontos(vEq).Text := '';
  end;
  ExibirDealerSelecionado;

  { título + subtítulo + campos + embaralhador + botões + paddings }
  RectModalCard.Height := 16 + 30 + 18 + FPartida.QtEquipes * 82 + 32 + 50 + 68 + 54 + 16 + 4;
  TModal.Mostrar(LayoutModalRodada, RectModalCard);
end;

procedure TFormJogo.ExibirDealerSelecionado;
var
  vJogador: TJogador;
begin
  LabDealerNome.Text := 'Escolher';
  for vJogador in FPartida.Mesa do
    if vJogador.Id = FDealerSelecionado then
      LabDealerNome.Text := vJogador.Nome;
end;

procedure TFormJogo.RectDealerClick(Sender: TObject);
var
  vNomes: TArray<string>;
  vSelecionado, I: Integer;
begin
  vSelecionado := -1;
  SetLength(vNomes, Length(FPartida.Mesa));
  for I := 0 to High(FPartida.Mesa) do
  begin
    vNomes[I] := FPartida.Mesa[I].Nome + '  (' + FPartida.NomeEquipe(FPartida.Mesa[I].Equipe) + ')';
    if FPartida.Mesa[I].Id = FDealerSelecionado then
      vSelecionado := I;
  end;

  TFramePicker.Abrir(LayoutPrincipal, 'Quem embaralhou?', vNomes, vSelecionado,
    procedure(aIndice: Integer)
    begin
      FDealerSelecionado := FPartida.Mesa[aIndice].Id;
      ExibirDealerSelecionado;
    end);
end;

procedure TFormJogo.RectSinalClick(Sender: TObject);
var
  vEdit: TEdit;
  vValor: Integer;
begin
  vEdit := EditPontos(TControl(Sender).Tag);
  vValor := TextoParaInteiro(vEdit.Text);
  if vValor = 0 then
    vEdit.Text := '-'
  else
    vEdit.Text := IntToStr(-vValor);
  Pulsar(TControl(Sender));
end;

procedure TFormJogo.RectBtnCancelarClick(Sender: TObject);
begin
  FecharModalRodada;
end;

procedure TFormJogo.FecharModalRodada;
begin
  EdtPontos1.ResetFocus;
  EdtPontos2.ResetFocus;
  EdtPontos3.ResetFocus;
  TModal.Esconder(LayoutModalRodada, RectModalCard);
end;

procedure TFormJogo.RectBtnSalvarClick(Sender: TObject);
var
  vPontos: TArray<Integer>;
  vEq: Integer;
  vResultado: TResultadoRodada;
begin
  SetLength(vPontos, FPartida.QtEquipes);
  for vEq := 1 to FPartida.QtEquipes do
    vPontos[vEq - 1] := TextoParaInteiro(EditPontos(vEq).Text);

  if FRodadaEditando > 0 then
    vResultado := TPartidaService.EditarRodada(FPartida.Id, FRodadaEditando, vPontos, FDealerSelecionado)
  else
    vResultado := TPartidaService.LancarRodada(FPartida.Id, vPontos, FDealerSelecionado);

  FecharModalRodada;
  ProcessarResultado(vResultado);
end;

procedure TFormJogo.RectBtnExcluirClick(Sender: TObject);
var
  vRodadaId: Integer;
begin
  vRodadaId := FRodadaEditando;
  TDialogo.Confirmar('Excluir esta rodada? Os totais serão recalculados.',
    procedure
    var
      vResultado: TResultadoRodada;
    begin
      vResultado := TPartidaService.ExcluirRodada(FPartida.Id, vRodadaId);
      FecharModalRodada;
      ProcessarResultado(vResultado);
      TToast.Mostrar(LayoutPrincipal, 'Rodada excluída.');
    end);
end;

procedure TFormJogo.ProcessarResultado(const aResultado: TResultadoRodada);
var
  vGrande: Integer;
  I, vAtraso: Integer;
begin
  FPartida := aResultado.Partida;
  Exibir(True);

  vGrande := -1;
  for I := 0 to High(aResultado.Eventos) do
    if aResultado.Eventos[I].Tipo in EVENTOS_GRANDES then
    begin
      vGrande := I;
      Break;
    end;

  if vGrande >= 0 then
    Celebrar(aResultado.Eventos[vGrande])
  else if Length(aResultado.Eventos) > 0 then
    TSomPlayer.Tocar(TRecursos.SomDoEvento(aResultado.Eventos[0].Tipo))
  else
    TSomPlayer.Tocar(smPonto);

  { Os demais eventos aparecem como avisos, um depois do outro }
  vAtraso := 0;
  if vGrande >= 0 then
    vAtraso := 2500;
  for I := 0 to High(aResultado.Eventos) do
  begin
    if I = vGrande then
      Continue;
    AgendarAviso(vAtraso, aResultado.Eventos[I]);
    Inc(vAtraso, 3000);
  end;
end;

procedure TFormJogo.AgendarAviso(aAtrasoMs: Integer; const aEvento: TEvento);
var
  vEvento: TEvento;
begin
  { Cópia local: cada aviso agendado captura o seu próprio evento }
  vEvento := aEvento;
  Atrasar(aAtrasoMs,
    procedure
    begin
      TToast.Mostrar(LayoutPrincipal, vEvento.Titulo + ' ' + vEvento.Mensagem,
        TRecursos.Emoji(TRecursos.EmojiDoEvento(vEvento.Tipo)));
    end);
end;

{ Celebração (emoji grande + som + animação) }

procedure TFormJogo.Celebrar(const aEvento: TEvento);
var
  vEq: Integer;
  vPerdedores: string;
begin
  ImgCeleb.Bitmap.Assign(TRecursos.Emoji(TRecursos.EmojiDoEvento(aEvento.Tipo)));
  LabCelebTitulo.Text := aEvento.Titulo;
  LabCelebMsg.Text := aEvento.Mensagem;

  LayoutCelebPerdedores.Visible := aEvento.Tipo = teVitoria;
  if aEvento.Tipo = teVitoria then
  begin
    ImgDerrota.Bitmap.Assign(TRecursos.Emoji(emDerrota));
    vPerdedores := '';
    for vEq := 1 to FPartida.QtEquipes do
      if vEq <> aEvento.Equipe then
      begin
        if not vPerdedores.IsEmpty then
          vPerdedores := vPerdedores + sLineBreak;
        vPerdedores := vPerdedores + Format('%s: %s pontos',
          [FPartida.NomeEquipe(vEq), FormatarPontos(FPartida.Total(vEq))]);
      end;
    LabPerdedores.Text := 'Não foi dessa vez' + sLineBreak + vPerdedores;
    LabBtnCeleb.Text := 'Ver placar final';
  end
  else
    LabBtnCeleb.Text := 'Continuar';

  LayoutCelebracao.Opacity := 0;
  LayoutCelebracao.Visible := True;
  LayoutCelebracao.BringToFront;
  TAnimator.AnimateFloat(LayoutCelebracao, 'Opacity', 1, 0.25);

  ImgCeleb.Scale.Point := TPointF.Create(0.2, 0.2);
  ImgCeleb.RotationAngle := -20;
  TAnimator.AnimateFloat(ImgCeleb, 'Scale.X', 1, 0.8, TAnimationType.Out, TInterpolationType.Elastic);
  TAnimator.AnimateFloat(ImgCeleb, 'Scale.Y', 1, 0.8, TAnimationType.Out, TInterpolationType.Elastic);
  TAnimator.AnimateFloat(ImgCeleb, 'RotationAngle', 0, 0.6, TAnimationType.Out, TInterpolationType.Back);

  LabCelebTitulo.Opacity := 0;
  TAnimator.AnimateFloatDelay(LabCelebTitulo, 'Opacity', 1, 0.3, 0.25);

  TSomPlayer.Tocar(TRecursos.SomDoEvento(aEvento.Tipo));

  if aEvento.Tipo in [teVitoria, teRodadaDeOuro] then
    TConfete.Disparar(LayoutCelebracao, IfThen(aEvento.Tipo = teVitoria, 80, 40));
end;

procedure TFormJogo.RectBtnCelebClick(Sender: TObject);
begin
  TAnimator.AnimateFloat(LayoutCelebracao, 'Opacity', 0, 0.2);
  Atrasar(220,
    procedure
    begin
      LayoutCelebracao.Visible := False;
    end);
end;

{ Compartilhar }

procedure TFormJogo.RectBtnCompartilharClick(Sender: TObject);
var
  vImagem: TBitmap;
  vArquivo: string;
begin
  if not FTemPartida then
    Exit;
  vImagem := RectCaptura.MakeScreenshot;
  try
    vArquivo := TPlataforma.Compartilhar(RectBtnCompartilhar,
      TPartidaService.TextoResumo(FPartida), vImagem);
  finally
    vImagem.Free;
  end;
  if not vArquivo.IsEmpty then
    TToast.Mostrar(LayoutPrincipal, 'Imagem salva em: ' + vArquivo);
end;

end.
