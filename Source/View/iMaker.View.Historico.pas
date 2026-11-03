unit iMaker.View.Historico;

{ Histórico de partidas: abrir (continuar/rever) ou excluir. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Objects, FMX.Layouts,
  FMX.StdCtrls, FMX.Controls.Presentation,
  Router4D.Interfaces,
  iMaker.Model.Entidades;

type
  TFormHistorico = class(TForm, iRouter4DComponent)
    LayoutPrincipal: TLayout;
    LayoutTopoLista: TLayout;
    RectBtnNova: TRectangle;
    LabBtnNova: TLabel;
    LabResumo: TLabel;
    LabVazio: TLabel;
    VsbHistorico: TVertScrollBox;
    procedure RectBtnNovaClick(Sender: TObject);
  private
    procedure AtualizarLista;
    procedure PartidaClick(Sender: TObject);
    procedure ExcluirClick(Sender: TObject);
  public
    function Render: TFMXObject;
    procedure UnRender;
  end;

var
  FormHistorico: TFormHistorico;

implementation

{$R *.fmx}

uses
  iMaker.Service.Partida, iMaker.View.Componentes, iMaker.View.Navegacao,
  iMaker.Frame.PartidaItem;

{ Router4D }

function TFormHistorico.Render: TFMXObject;
begin
  AtualizarLista;
  Result := LayoutPrincipal;
end;

procedure TFormHistorico.UnRender;
begin
end;

procedure TFormHistorico.AtualizarLista;
var
  vPartidas: TArray<TPartida>;
  vItem: TFramePartidaItem;
  vFinalizadas, I, vAtual: Integer;
begin
  vPartidas := TPartidaService.Historico;
  vAtual := TPartidaService.PartidaAtualId;
  LimparLista(VsbHistorico);

  vFinalizadas := 0;
  for I := 0 to High(vPartidas) do
    if vPartidas[I].Finalizada then
      Inc(vFinalizadas);

  LabVazio.Visible := Length(vPartidas) = 0;
  LabResumo.Text := Format('%d partida(s) · %d finalizada(s)', [Length(vPartidas), vFinalizadas]);

  VsbHistorico.BeginUpdate;
  try
    for I := 0 to High(vPartidas) do
    begin
      vItem := TFramePartidaItem.Create(nil);
      vItem.Name := '';
      vItem.Parent := VsbHistorico;
      vItem.Align := TAlignLayout.Top;
      vItem.Position.Y := I * 1000;
      vItem.Exibir(vPartidas[I], vPartidas[I].Id = vAtual);
      vItem.RectFundo.OnClick := PartidaClick;
      vItem.RectExcluir.OnClick := ExcluirClick;
    end;
  finally
    VsbHistorico.EndUpdate;
  end;
end;

procedure TFormHistorico.PartidaClick(Sender: TObject);
begin
  TPartidaService.SelecionarPartida(TControl(Sender).Tag);
  TNavegacao.Ir(rtJogo);
end;

procedure TFormHistorico.ExcluirClick(Sender: TObject);
var
  vId: Integer;
begin
  vId := TControl(Sender).Tag;
  TDialogo.Confirmar('Excluir esta partida e todas as suas rodadas? Não dá para desfazer.',
    procedure
    begin
      TPartidaService.ExcluirPartida(vId);
      AtualizarLista;
      TToast.Mostrar(LayoutPrincipal, 'Partida excluída.');
    end);
end;

procedure TFormHistorico.RectBtnNovaClick(Sender: TObject);
begin
  TNavegacao.Ir(rtNovaPartida);
end;

end.
