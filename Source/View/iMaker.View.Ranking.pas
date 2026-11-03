unit iMaker.View.Ranking;

{ Ranking e estatísticas por jogador (partidas finalizadas). }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Objects, FMX.Layouts,
  FMX.StdCtrls, FMX.Controls.Presentation,
  Router4D.Interfaces,
  iMaker.Model.Entidades;

type
  TFormRanking = class(TForm, iRouter4DComponent)
    LayoutPrincipal: TLayout;
    LayoutResumo: TLayout;
    RectStatPartidas: TRectangle;
    LabStatPartidas: TLabel;
    LabStatPartidasLegenda: TLabel;
    RectStatRodadas: TRectangle;
    LabStatRodadas: TLabel;
    LabStatRodadasLegenda: TLabel;
    RectStatLider: TRectangle;
    LabStatLider: TLabel;
    LabStatLiderLegenda: TLabel;
    LabSecRanking: TLabel;
    LabVazio: TLabel;
    VsbRanking: TVertScrollBox;
    procedure LayoutResumoResize(Sender: TObject);
  private
    procedure AtualizarLista;
  public
    function Render: TFMXObject;
    procedure UnRender;
  end;

var
  FormRanking: TFormRanking;

implementation

{$R *.fmx}

uses
  iMaker.Service.Jogador, iMaker.View.Componentes, iMaker.Frame.RankingItem;

{ Router4D }

function TFormRanking.Render: TFMXObject;
begin
  AtualizarLista;
  Result := LayoutPrincipal;
end;

procedure TFormRanking.UnRender;
begin
end;

procedure TFormRanking.AtualizarLista;
var
  vRanking: TArray<TEstatisticaJogador>;
  vItem: TFrameRankingItem;
  vPartidas, vRodadas, I, vPosicao: Integer;
begin
  TEstatisticaService.ResumoGeral(vPartidas, vRodadas);
  LabStatPartidas.Text := vPartidas.ToString;
  LabStatRodadas.Text := vRodadas.ToString;

  vRanking := TEstatisticaService.Ranking;
  LimparLista(VsbRanking);

  if (Length(vRanking) > 0) and (vRanking[0].Vitorias > 0) then
    LabStatLider.Text := vRanking[0].Jogador.PrimeiroNome
  else
    LabStatLider.Text := '-';

  LabVazio.Visible := vPartidas = 0;
  VsbRanking.Visible := vPartidas > 0;
  if vPartidas = 0 then
    Exit;

  VsbRanking.BeginUpdate;
  try
    vPosicao := 0;
    for I := 0 to High(vRanking) do
    begin
      if vRanking[I].Partidas = 0 then
        Continue;
      Inc(vPosicao);
      vItem := TFrameRankingItem.Create(nil);
      vItem.Name := '';
      vItem.Parent := VsbRanking;
      vItem.Align := TAlignLayout.Top;
      vItem.Position.Y := vPosicao * 100;
      vItem.Exibir(vPosicao, vRanking[I]);
    end;
  finally
    VsbRanking.EndUpdate;
  end;
end;

procedure TFormRanking.LayoutResumoResize(Sender: TObject);
var
  vLargura: Single;
begin
  vLargura := LayoutResumo.Width / 3 - 8;
  RectStatPartidas.Width := vLargura;
  RectStatRodadas.Width := vLargura;
  RectStatLider.Width := vLargura;
end;

end.
