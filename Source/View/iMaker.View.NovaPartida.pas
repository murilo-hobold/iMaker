unit iMaker.View.NovaPartida;

{ Tela de nova partida: quantidade de jogadores, meta, equipes e
  quem embaralha primeiro. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Objects, FMX.Layouts,
  FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  Router4D.Interfaces,
  iMaker.Model.Entidades, iMaker.Frame.EquipeConfig;

type
  TFormNovaPartida = class(TForm, iRouter4DComponent)
    LayoutPrincipal: TLayout;
    VsbNova: TVertScrollBox;
    LabSecQt: TLabel;
    LayoutQt: TLayout;
    RectQt2: TRectangle;
    LabQt2: TLabel;
    RectQt3: TRectangle;
    LabQt3: TLabel;
    RectQt4: TRectangle;
    LabQt4: TLabel;
    RectQt6: TRectangle;
    LabQt6: TLabel;
    LabQtInfo: TLabel;
    LabSecMeta: TLabel;
    LayoutMeta: TLayout;
    RectMeta: TRectangle;
    EdtMeta: TEdit;
    RectMeta1500: TRectangle;
    LabMeta1500: TLabel;
    RectMeta2000: TRectangle;
    LabMeta2000: TLabel;
    RectMeta3000: TRectangle;
    LabMeta3000: TLabel;
    LabMetaInfo: TLabel;
    LayoutSecEquipes: TLayout;
    RectBtnSortear: TRectangle;
    LabSortear: TLabel;
    LabSecEquipes: TLabel;
    LayoutEquipes: TLayout;
    LabSecDealer: TLabel;
    RectDealerInicial: TRectangle;
    PathDealerSeta: TPath;
    LabDealerInicial: TLabel;
    RectBtnComecar: TRectangle;
    LabBtnComecar: TLabel;
    LayoutEspacoFinal: TLayout;
    procedure LayoutQtResize(Sender: TObject);
    procedure RectQtClick(Sender: TObject);
    procedure RectMetaChipClick(Sender: TObject);
    procedure EdtMetaChangeTracking(Sender: TObject);
    procedure RectBtnSortearClick(Sender: TObject);
    procedure RectDealerInicialClick(Sender: TObject);
    procedure RectBtnComecarClick(Sender: TObject);
  private
    FQtJogadores: Integer;
    FJogadores: TArray<TJogador>;
    FSelecao: TArray<TArray<Integer>>;   // [equipe][vaga] = id do jogador (0 = vazio)
    FNomesEquipes: TArray<string>;
    FDealerId: Integer;                  // 0 = primeiro da mesa
    FCards: TArray<TFrameEquipeConfig>;
    procedure MontarEquipes;
    procedure GuardarNomesEquipes;
    procedure ExibirSelecao;
    procedure ExibirQuantidade;
    procedure ExibirDealer;
    procedure VagaClick(Sender: TObject);
    function NomeJogador(aId: Integer): string;
    function IdsSelecionados: TArray<Integer>;
    function JogadorSelecionado(aId: Integer): Boolean;
  public
    function Render: TFMXObject;
    procedure UnRender;
  end;

var
  FormNovaPartida: TFormNovaPartida;

implementation

{$R *.fmx}

uses
  iMaker.Service.Partida, iMaker.Service.Jogador, iMaker.Service.Config,
  iMaker.Infra.Som, iMaker.Infra.Recursos,
  iMaker.View.Tema, iMaker.View.Componentes, iMaker.View.Navegacao,
  iMaker.Frame.Picker;

const
  NOMES_PADRAO: array[0..2] of string = ('Tigres', 'Lobos', 'Ursos');

{ Router4D }

function TFormNovaPartida.Render: TFMXObject;
var
  I, J: Integer;
begin
  FJogadores := TJogadorService.Listar;
  if FQtJogadores = 0 then
  begin
    FQtJogadores := 4;
    EdtMeta.Text := TConfigService.Atual.MetaPadrao.ToString;
  end;

  { Remove da seleção quem foi excluído/inativado desde a última visita }
  for I := 0 to High(FSelecao) do
    for J := 0 to High(FSelecao[I]) do
      if (FSelecao[I][J] > 0) and (NomeJogador(FSelecao[I][J]) = '') then
        FSelecao[I][J] := 0;
  if (FDealerId > 0) and not JogadorSelecionado(FDealerId) then
    FDealerId := 0;

  MontarEquipes;
  EdtMetaChangeTracking(nil);
  VsbNova.ViewportPosition := TPointF.Zero;

  if Length(FJogadores) < 2 then
    Atrasar(300,
      procedure
      begin
        TToast.Mostrar(LayoutPrincipal,
          'Cadastre pelo menos 2 jogadores na aba Jogadores para começar.',
          TRecursos.Emoji(emEmpate));
      end);

  Result := LayoutPrincipal;
end;

procedure TFormNovaPartida.UnRender;
begin
  GuardarNomesEquipes;
end;

{ Quantidade de jogadores }

procedure TFormNovaPartida.LayoutQtResize(Sender: TObject);
var
  vLargura: Single;
begin
  vLargura := LayoutQt.Width / 4 - 8;
  RectQt2.Width := vLargura;
  RectQt3.Width := vLargura;
  RectQt4.Width := vLargura;
  RectQt6.Width := vLargura;
end;

procedure TFormNovaPartida.RectQtClick(Sender: TObject);
begin
  GuardarNomesEquipes;
  FQtJogadores := TControl(Sender).Tag;
  Pulsar(TControl(Sender));
  MontarEquipes;
end;

procedure TFormNovaPartida.ExibirQuantidade;

  procedure Pintar(aRect: TRectangle; aLabel: TLabel; aAtivo: Boolean);
  begin
    if aAtivo then
    begin
      aRect.Fill.Color := COR_OURO;
      aRect.Stroke.Color := COR_OURO;
      aLabel.TextSettings.FontColor := COR_TEXTO_ESCURO;
    end
    else
    begin
      aRect.Fill.Color := COR_SUPERFICIE;
      aRect.Stroke.Color := COR_BORDA;
      aLabel.TextSettings.FontColor := COR_TEXTO;
    end;
  end;

begin
  Pintar(RectQt2, LabQt2, FQtJogadores = 2);
  Pintar(RectQt3, LabQt3, FQtJogadores = 3);
  Pintar(RectQt4, LabQt4, FQtJogadores = 4);
  Pintar(RectQt6, LabQt6, FQtJogadores = 6);

  case FQtJogadores of
    2: LabQtInfo.Text := 'Mano a mano: 2 jogadores, um contra o outro';
    3: LabQtInfo.Text := 'Cada um por si: 3 jogadores individuais';
    4: LabQtInfo.Text := 'Duplas: 2 equipes com 2 jogadores';
    6: LabQtInfo.Text := 'Trios: 2 equipes com 3 jogadores';
  end;
end;

{ Meta }

procedure TFormNovaPartida.RectMetaChipClick(Sender: TObject);
begin
  EdtMeta.Text := TControl(Sender).Tag.ToString;
  Pulsar(TControl(Sender));
  EdtMetaChangeTracking(nil);
end;

procedure TFormNovaPartida.EdtMetaChangeTracking(Sender: TObject);
var
  vMeta: Integer;

  procedure Pintar(aRect: TRectangle; aLabel: TLabel);
  begin
    if aRect.Tag = vMeta then
    begin
      aRect.Fill.Color := COR_OURO;
      aLabel.TextSettings.FontColor := COR_TEXTO_ESCURO;
    end
    else
    begin
      aRect.Fill.Color := COR_SUPERFICIE;
      aLabel.TextSettings.FontColor := COR_TEXTO;
    end;
  end;

begin
  vMeta := StrToIntDef(EdtMeta.Text, 0);
  Pintar(RectMeta1500, LabMeta1500);
  Pintar(RectMeta2000, LabMeta2000);
  Pintar(RectMeta3000, LabMeta3000);

  if vMeta < META_MINIMA then
    LabMetaInfo.Text := Format('Informe pelo menos %d pontos. Recomendado: %s.',
      [META_MINIMA, FormatarPontos(META_PADRAO)])
  else
    LabMetaInfo.Text := Format('Ao chegar em %s pontos a equipe entra no buraco (metade da meta).',
      [FormatarPontos(vMeta div 2)]);
end;

{ Equipes }

procedure TFormNovaPartida.GuardarNomesEquipes;
var
  vCard: TFrameEquipeConfig;
begin
  for vCard in FCards do
    if vCard.Equipe <= Length(FNomesEquipes) then
      FNomesEquipes[vCard.Equipe - 1] := vCard.EdtNome.Text;
end;

procedure TFormNovaPartida.MontarEquipes;
var
  vEquipes, vVagas, I, J: Integer;
  vCard: TFrameEquipeConfig;
  vAltura: Single;
  vAnterior: TArray<TArray<Integer>>;
begin
  vEquipes := TPartidaService.QtEquipes(FQtJogadores);
  vVagas := TPartidaService.JogadoresPorEquipe(FQtJogadores);

  { Preserva quem já estava escolhido nas vagas que continuam existindo }
  vAnterior := FSelecao;
  SetLength(FSelecao, vEquipes);
  for I := 0 to vEquipes - 1 do
  begin
    SetLength(FSelecao[I], vVagas);
    for J := 0 to vVagas - 1 do
      if (I <= High(vAnterior)) and (J <= High(vAnterior[I])) then
        FSelecao[I][J] := vAnterior[I][J]
      else
        FSelecao[I][J] := 0;
  end;

  I := Length(FNomesEquipes);
  SetLength(FNomesEquipes, MAX_EQUIPES);
  for J := I to MAX_EQUIPES - 1 do
    FNomesEquipes[J] := NOMES_PADRAO[J];

  for vCard in FCards do
    vCard.Free;
  SetLength(FCards, vEquipes);

  vAltura := 0;
  for I := 0 to vEquipes - 1 do
  begin
    vCard := TFrameEquipeConfig.Create(nil);
    vCard.Name := '';
    vCard.Parent := LayoutEquipes;
    vCard.Align := TAlignLayout.Top;
    vCard.Position.Y := I * 1000;
    vCard.Configurar(I + 1, vVagas, CORES_EQUIPE[I + 1]);
    vCard.EdtNome.Text := FNomesEquipes[I];
    vCard.AoClicarVaga(VagaClick);
    vAltura := vAltura + vCard.Height;
    FCards[I] := vCard;
  end;
  LayoutEquipes.Height := vAltura;

  if (FDealerId > 0) and not JogadorSelecionado(FDealerId) then
    FDealerId := 0;

  ExibirQuantidade;
  ExibirSelecao;
end;

procedure TFormNovaPartida.ExibirSelecao;
var
  I, J: Integer;
begin
  for I := 0 to High(FCards) do
    for J := 0 to High(FSelecao[I]) do
      FCards[I].ExibirJogador(J + 1, NomeJogador(FSelecao[I][J]));
  ExibirDealer;
end;

function TFormNovaPartida.NomeJogador(aId: Integer): string;
var
  vJogador: TJogador;
begin
  Result := '';
  for vJogador in FJogadores do
    if vJogador.Id = aId then
      Exit(vJogador.Nome);
end;

function TFormNovaPartida.IdsSelecionados: TArray<Integer>;
var
  vEquipe: TArray<Integer>;
  vId: Integer;
begin
  Result := nil;
  for vEquipe in FSelecao do
    for vId in vEquipe do
      if vId > 0 then
        Result := Result + [vId];
end;

function TFormNovaPartida.JogadorSelecionado(aId: Integer): Boolean;
var
  vId: Integer;
begin
  Result := False;
  for vId in IdsSelecionados do
    if vId = aId then
      Exit(True);
end;

procedure TFormNovaPartida.VagaClick(Sender: TObject);
var
  vCard: TFrameEquipeConfig;
  vEquipe, vVaga, vAtual: Integer;
  vIds: TArray<Integer>;
  vNomes: TArray<string>;
  vJogador: TJogador;
  vSelecionado: Integer;
begin
  GuardarNomesEquipes;
  vCard := TFrameEquipeConfig(TComponent(Sender).Owner);
  vEquipe := vCard.Equipe - 1;
  vVaga := TControl(Sender).Tag - 1;
  vAtual := FSelecao[vEquipe][vVaga];

  { Opções: jogadores livres + o que já ocupa esta vaga }
  vIds := nil;
  vNomes := nil;
  vSelecionado := -1;
  if vAtual > 0 then
  begin
    vIds := vIds + [0];
    vNomes := vNomes + ['(deixar vaga livre)'];
  end;
  for vJogador in FJogadores do
    if (vJogador.Id = vAtual) or not JogadorSelecionado(vJogador.Id) then
    begin
      if vJogador.Id = vAtual then
        vSelecionado := Length(vIds);
      vIds := vIds + [vJogador.Id];
      vNomes := vNomes + [vJogador.Nome];
    end;

  if Length(vIds) = 0 then
  begin
    TToast.Mostrar(LayoutPrincipal, 'Todos os jogadores já estão na mesa. Cadastre mais na aba Jogadores.');
    Exit;
  end;

  TFramePicker.Abrir(LayoutPrincipal, Format('Equipe %d · vaga %d', [vEquipe + 1, vVaga + 1]),
    vNomes, vSelecionado,
    procedure(aIndice: Integer)
    begin
      FSelecao[vEquipe][vVaga] := vIds[aIndice];
      if (FDealerId > 0) and not JogadorSelecionado(FDealerId) then
        FDealerId := 0;
      ExibirSelecao;
    end);
end;

procedure TFormNovaPartida.RectBtnSortearClick(Sender: TObject);
var
  vPool, vOutros: TArray<Integer>;
  vJogador: TJogador;
  I, J, K: Integer;
begin
  GuardarNomesEquipes;
  if Length(FJogadores) < FQtJogadores then
  begin
    TDialogo.Aviso(Format('Para sortear %d jogadores, cadastre pelo menos %d na aba Jogadores.',
      [FQtJogadores, FQtJogadores]));
    Exit;
  end;

  { Usa quem já está na mesa e completa com outros jogadores, se faltar gente }
  vPool := IdsSelecionados;
  vOutros := nil;
  for vJogador in FJogadores do
    if not JogadorSelecionado(vJogador.Id) then
      vOutros := vOutros + [vJogador.Id];
  vOutros := TPartidaService.Embaralhar(vOutros);
  K := 0;
  while (Length(vPool) < FQtJogadores) and (K <= High(vOutros)) do
  begin
    vPool := vPool + [vOutros[K]];
    Inc(K);
  end;

  vPool := TPartidaService.Embaralhar(vPool);
  K := 0;
  for J := 0 to TPartidaService.JogadoresPorEquipe(FQtJogadores) - 1 do
    for I := 0 to High(FSelecao) do
    begin
      FSelecao[I][J] := vPool[K];
      Inc(K);
    end;

  FDealerId := 0;
  ExibirSelecao;
  Pulsar(RectBtnSortear);
  TSomPlayer.Tocar(smRodada);
  TToast.Mostrar(LayoutPrincipal, 'Equipes sorteadas!', TRecursos.Emoji(emRodada));
end;

{ Quem embaralha primeiro }

procedure TFormNovaPartida.ExibirDealer;
begin
  if FDealerId > 0 then
    LabDealerInicial.Text := NomeJogador(FDealerId)
  else
    LabDealerInicial.Text := 'Primeiro jogador da equipe 1';
end;

procedure TFormNovaPartida.RectDealerInicialClick(Sender: TObject);
var
  vIds: TArray<Integer>;
  vNomes: TArray<string>;
  vId, vSelecionado: Integer;
begin
  vIds := [0, -1];
  vNomes := ['Primeiro jogador da equipe 1', 'Sortear agora'];
  vSelecionado := -1;
  if FDealerId = 0 then
    vSelecionado := 0;
  for vId in IdsSelecionados do
  begin
    if vId = FDealerId then
      vSelecionado := Length(vIds);
    vIds := vIds + [vId];
    vNomes := vNomes + [NomeJogador(vId)];
  end;

  TFramePicker.Abrir(LayoutPrincipal, 'Quem embaralha primeiro?', vNomes, vSelecionado,
    procedure(aIndice: Integer)
    var
      vSelecionados: TArray<Integer>;
    begin
      if vIds[aIndice] = -1 then
      begin
        vSelecionados := IdsSelecionados;
        if Length(vSelecionados) = 0 then
        begin
          TToast.Mostrar(LayoutPrincipal, 'Escolha os jogadores antes de sortear.');
          Exit;
        end;
        FDealerId := TPartidaService.Embaralhar(vSelecionados)[0];
        TSomPlayer.Tocar(smRodada);
      end
      else
        FDealerId := vIds[aIndice];
      ExibirDealer;
    end);
end;

{ Começar }

procedure TFormNovaPartida.RectBtnComecarClick(Sender: TObject);
var
  vNova: TNovaPartida;
  I: Integer;
begin
  GuardarNomesEquipes;
  vNova.QtJogadores := FQtJogadores;
  vNova.Meta := StrToIntDef(EdtMeta.Text, 0);
  vNova.DealerInicialId := FDealerId;
  vNova.JogadoresEquipes := Copy(FSelecao);
  SetLength(vNova.NomesEquipes, Length(FSelecao));
  for I := 0 to High(FSelecao) do
    vNova.NomesEquipes[I] := FNomesEquipes[I];

  TPartidaService.Criar(vNova);

  { Mantém equipes e jogadores escolhidos: facilita a revanche }
  FDealerId := 0;

  TNavegacao.MostrarInicioDaPartida := True;
  TNavegacao.Ir(rtJogo);
end;

end.
