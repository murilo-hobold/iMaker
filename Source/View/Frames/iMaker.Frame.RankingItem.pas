unit iMaker.Frame.RankingItem;

{ Linha do ranking de jogadores. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation,
  iMaker.Model.Entidades;

type
  TFrameRankingItem = class(TFrame)
    RectFundo: TRectangle;
    CirclePosicao: TCircle;
    LabPosicao: TLabel;
    LayoutMedia: TLayout;
    LabMedia: TLabel;
    LabMediaLegenda: TLabel;
    LayoutTextos: TLayout;
    LabNome: TLabel;
    LabDetalhe: TLabel;
  public
    procedure Exibir(aPosicao: Integer; const aItem: TEstatisticaJogador);
  end;

implementation

{$R *.fmx}

uses
  iMaker.View.Tema;

{ TFrameRankingItem }

procedure TFrameRankingItem.Exibir(aPosicao: Integer; const aItem: TEstatisticaJogador);
begin
  LabPosicao.Text := aPosicao.ToString;
  LabNome.Text := aItem.Jogador.Nome;
  LabDetalhe.Text := Format('%d vitória(s) em %d · %.0f%% · melhor rodada %s',
    [aItem.Vitorias, aItem.Partidas, aItem.Aproveitamento, FormatarPontos(aItem.MelhorRodada)]);
  LabMedia.Text := FormatarPontos(Round(aItem.MediaPontos));

  case aPosicao of
    1: CirclePosicao.Fill.Color := COR_OURO;
    2: CirclePosicao.Fill.Color := COR_PRATA;
    3: CirclePosicao.Fill.Color := COR_BRONZE;
  else
    CirclePosicao.Fill.Color := COR_SUPERFICIE_2;
  end;
  if aPosicao <= 3 then
    LabPosicao.TextSettings.FontColor := COR_TEXTO_ESCURO
  else
    LabPosicao.TextSettings.FontColor := COR_TEXTO;

  if aPosicao = 1 then
    RectFundo.Stroke.Color := COR_OURO
  else
    RectFundo.Stroke.Color := COR_BORDA;
end;

end.
