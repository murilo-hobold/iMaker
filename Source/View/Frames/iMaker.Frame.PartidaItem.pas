unit iMaker.Frame.PartidaItem;

{ Card de uma partida no histórico. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation,
  iMaker.Model.Entidades;

type
  TFramePartidaItem = class(TFrame)
    RectFundo: TRectangle;
    LayoutCabecalho: TLayout;
    RectStatus: TRectangle;
    LabStatus: TLabel;
    LabData: TLabel;
    LayoutEq1: TLayout;
    ImgEq1: TImage;
    LabTotalEq1: TLabel;
    LabEq1: TLabel;
    LayoutEq2: TLayout;
    ImgEq2: TImage;
    LabTotalEq2: TLabel;
    LabEq2: TLabel;
    LayoutEq3: TLayout;
    ImgEq3: TImage;
    LabTotalEq3: TLabel;
    LabEq3: TLabel;
    LayoutRodape: TLayout;
    RectExcluir: TRectangle;
    PathExcluir: TPath;
    LabInfo: TLabel;
  public
    procedure Exibir(const aPartida: TPartida; aAtual: Boolean);
  end;

implementation

{$R *.fmx}

uses
  iMaker.View.Tema, iMaker.Infra.Recursos;

{ TFramePartidaItem }

procedure TFramePartidaItem.Exibir(const aPartida: TPartida; aAtual: Boolean);
var
  vLayouts: array[1..3] of TLayout;
  vImagens: array[1..3] of TImage;
  vNomes, vTotais: array[1..3] of TLabel;
  vEq: Integer;
  vDestaque: Boolean;
begin
  vLayouts[1] := LayoutEq1; vLayouts[2] := LayoutEq2; vLayouts[3] := LayoutEq3;
  vImagens[1] := ImgEq1;    vImagens[2] := ImgEq2;    vImagens[3] := ImgEq3;
  vNomes[1] := LabEq1;      vNomes[2] := LabEq2;      vNomes[3] := LabEq3;
  vTotais[1] := LabTotalEq1; vTotais[2] := LabTotalEq2; vTotais[3] := LabTotalEq3;

  RectFundo.Tag := aPartida.Id;
  RectExcluir.Tag := aPartida.Id;
  LabData.Text := FormatDateTime('dd/mm/yyyy "às" hh:nn', aPartida.Inicio);

  if aPartida.Finalizada then
  begin
    LabStatus.Text := 'FINALIZADA';
    RectStatus.Fill.Color := COR_SUPERFICIE_2;
    LabStatus.TextSettings.FontColor := COR_TEXTO_SEC;
  end
  else
  begin
    LabStatus.Text := 'EM ANDAMENTO';
    RectStatus.Fill.Color := COR_OURO;
    LabStatus.TextSettings.FontColor := COR_TEXTO_ESCURO;
  end;

  if aAtual then
    RectFundo.Stroke.Color := COR_OURO
  else
    RectFundo.Stroke.Color := COR_BORDA;

  for vEq := 1 to 3 do
  begin
    vLayouts[vEq].Visible := vEq <= aPartida.QtEquipes;
    if vEq > aPartida.QtEquipes then
      Continue;

    vDestaque := aPartida.Finalizada and (aPartida.EquipeVencedora = vEq);
    vNomes[vEq].Text := Format('%s  ·  %s',
      [aPartida.NomeEquipe(vEq), aPartida.Equipes[vEq - 1].NomesJogadores]);
    vTotais[vEq].Text := FormatarPontos(aPartida.Total(vEq));

    if vDestaque then
    begin
      vImagens[vEq].Bitmap.Assign(TRecursos.Emoji(emVitoria));
      vNomes[vEq].TextSettings.FontColor := COR_OURO;
      vTotais[vEq].TextSettings.FontColor := COR_OURO;
    end
    else
    begin
      vImagens[vEq].Bitmap.SetSize(0, 0);
      vNomes[vEq].TextSettings.FontColor := COR_TEXTO;
      vTotais[vEq].TextSettings.FontColor := COR_TEXTO;
    end;
  end;

  LabInfo.Text := Format('%d rodada(s)  ·  %s  ·  meta %s',
    [Length(aPartida.Rodadas), FormatarDuracao(aPartida.DuracaoSegundos),
     FormatarPontos(aPartida.Meta)]);

  { padding + cabeçalho + linhas das equipes + rodapé + margem }
  Height := 12 + 22 + 6 + 24 * aPartida.QtEquipes + 32 + 8 + 10 + 4;
end;

end.
