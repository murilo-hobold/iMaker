unit iMaker.View.Jogadores;

{ Cadastro de jogadores. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Objects, FMX.Layouts,
  FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  Router4D.Interfaces,
  iMaker.Model.Entidades;

type
  TFormJogadores = class(TForm, iRouter4DComponent)
    LayoutPrincipal: TLayout;
    LayoutTopoLista: TLayout;
    RectBtnNovo: TRectangle;
    LabBtnNovo: TLabel;
    LabContagem: TLabel;
    LabVazio: TLabel;
    VsbJogadores: TVertScrollBox;
    LayoutModal: TLayout;
    RectModalFundo: TRectangle;
    RectModalCard: TRectangle;
    LabModalTitulo: TLabel;
    LabNomeTitulo: TLabel;
    RectNome: TRectangle;
    EdtNome: TEdit;
    RectBtnSalvar: TRectangle;
    LabBtnSalvar: TLabel;
    LayoutBotoes: TLayout;
    RectBtnExcluir: TRectangle;
    LabBtnExcluir: TLabel;
    RectBtnCancelar: TRectangle;
    LabBtnCancelar: TLabel;
    procedure RectBtnNovoClick(Sender: TObject);
    procedure RectBtnSalvarClick(Sender: TObject);
    procedure RectBtnCancelarClick(Sender: TObject);
    procedure RectBtnExcluirClick(Sender: TObject);
  private
    FJogadores: TArray<TJogador>;
    FEditandoId: Integer;
    procedure AtualizarLista;
    procedure ItemClick(Sender: TObject);
    procedure AbrirModal(aId: Integer);
    procedure FecharModal;
  public
    function Render: TFMXObject;
    procedure UnRender;
  end;

var
  FormJogadores: TFormJogadores;

implementation

{$R *.fmx}

uses
  iMaker.Service.Jogador,
  iMaker.View.Componentes, iMaker.Frame.JogadorItem;

{ Router4D }

function TFormJogadores.Render: TFMXObject;
begin
  LayoutModal.Visible := False;
  AtualizarLista;
  Result := LayoutPrincipal;
end;

procedure TFormJogadores.UnRender;
begin
  EdtNome.ResetFocus;
end;

procedure TFormJogadores.AtualizarLista;
var
  I: Integer;
  vItem: TFrameJogadorItem;
  vEstatisticas: TDictionary<Integer, TEstatisticaJogador>;
  vEstatistica: TEstatisticaJogador;
begin
  FJogadores := TJogadorService.Listar;
  LimparLista(VsbJogadores);

  LabVazio.Visible := Length(FJogadores) = 0;
  if Length(FJogadores) = 1 then
    LabContagem.Text := '1 jogador'
  else
    LabContagem.Text := Format('%d jogadores', [Length(FJogadores)]);

  vEstatisticas := TEstatisticaService.PorJogador;
  VsbJogadores.BeginUpdate;
  try
    for I := 0 to High(FJogadores) do
    begin
      if not vEstatisticas.TryGetValue(FJogadores[I].Id, vEstatistica) then
        vEstatistica := Default(TEstatisticaJogador);

      vItem := TFrameJogadorItem.Create(nil);
      vItem.Name := '';
      vItem.Parent := VsbJogadores;
      vItem.Align := TAlignLayout.Top;
      vItem.Position.Y := I * 100;
      vItem.Exibir(FJogadores[I], vEstatistica);
      vItem.RectFundo.OnClick := ItemClick;
    end;
  finally
    VsbJogadores.EndUpdate;
    vEstatisticas.Free;
  end;
end;

procedure TFormJogadores.ItemClick(Sender: TObject);
begin
  AbrirModal(TControl(Sender).Tag);
end;

procedure TFormJogadores.RectBtnNovoClick(Sender: TObject);
begin
  Pulsar(RectBtnNovo);
  AbrirModal(0);
end;

procedure TFormJogadores.AbrirModal(aId: Integer);
var
  vJogador: TJogador;
begin
  FEditandoId := aId;
  EdtNome.Text := '';
  for vJogador in FJogadores do
    if vJogador.Id = aId then
      EdtNome.Text := vJogador.Nome;

  if aId > 0 then
    LabModalTitulo.Text := 'Editar jogador'
  else
    LabModalTitulo.Text := 'Novo jogador';
  RectBtnExcluir.Visible := aId > 0;

  TModal.Mostrar(LayoutModal, RectModalCard);
  EdtNome.SetFocus;
end;

procedure TFormJogadores.FecharModal;
begin
  EdtNome.ResetFocus;
  TModal.Esconder(LayoutModal, RectModalCard);
end;

procedure TFormJogadores.RectBtnCancelarClick(Sender: TObject);
begin
  FecharModal;
end;

procedure TFormJogadores.RectBtnSalvarClick(Sender: TObject);
var
  vNovo: Boolean;
begin
  vNovo := FEditandoId = 0;
  TJogadorService.Salvar(FEditandoId, EdtNome.Text);
  FecharModal;
  AtualizarLista;
  if vNovo then
    TToast.Mostrar(LayoutPrincipal, 'Jogador cadastrado!')
  else
    TToast.Mostrar(LayoutPrincipal, 'Jogador atualizado.');
end;

procedure TFormJogadores.RectBtnExcluirClick(Sender: TObject);
var
  vId: Integer;
begin
  vId := FEditandoId;
  TDialogo.Confirmar('Excluir este jogador?',
    procedure
    begin
      if TJogadorService.Excluir(vId) = reInativado then
        TToast.Mostrar(LayoutPrincipal, 'Jogador removido da lista. O histórico das partidas foi mantido.')
      else
        TToast.Mostrar(LayoutPrincipal, 'Jogador excluído.');
      FecharModal;
      AtualizarLista;
    end);
end;

end.
