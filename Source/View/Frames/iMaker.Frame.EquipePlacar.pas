unit iMaker.Frame.EquipePlacar;

{ Card de placar de uma equipe (total, progresso até a meta, buraco, líder). }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Math,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FMX.Ani, FMX.Controls.Presentation,
  iMaker.Model.Entidades;

type
  TFrameEquipePlacar = class(TFrame)
    RectCard: TRectangle;
    LayoutTopo: TLayout;
    ImgLider: TImage;
    LabNome: TLabel;
    LabJogadores: TLabel;
    LayoutRodape: TLayout;
    RectBarraFundo: TRectangle;
    RectBarra: TRectangle;
    LayoutInfo: TLayout;
    RectBuraco: TRectangle;
    LabBuraco: TLabel;
    LabFalta: TLabel;
    LabTotal: TLabel;
    procedure RectBarraFundoResize(Sender: TObject);
  private
    FTotalExibido: Integer;
    FProgresso: Single;
    procedure AjustarBarra;
  public
    procedure Exibir(const aPartida: TPartida; aEquipe: Integer; aAnimar: Boolean);
  end;

implementation

{$R *.fmx}

uses
  iMaker.View.Tema, iMaker.Infra.Recursos;

{ TFrameEquipePlacar }

procedure TFrameEquipePlacar.Exibir(const aPartida: TPartida; aEquipe: Integer; aAnimar: Boolean);
var
  vTotal: Integer;
  vLider, vVencedora: Boolean;
begin
  vTotal := aPartida.Total(aEquipe);
  vLider := aPartida.Lider = aEquipe;
  vVencedora := aPartida.Finalizada and (aPartida.EquipeVencedora = aEquipe);

  LabNome.Text := aPartida.NomeEquipe(aEquipe);
  LabNome.TextSettings.FontColor := CORES_EQUIPE[aEquipe];
  LabJogadores.Text := aPartida.Equipes[aEquipe - 1].NomesJogadores;
  LabTotal.Text := FormatarPontos(vTotal);
  if vTotal < 0 then
    LabTotal.TextSettings.FontColor := COR_PERIGO
  else
    LabTotal.TextSettings.FontColor := COR_TEXTO;

  if vVencedora then
    LabFalta.Text := 'Campeã!'
  else
    LabFalta.Text := 'faltam ' + FormatarPontos(aPartida.FaltaParaMeta(aEquipe));

  RectBuraco.Visible := aPartida.EstaNoBuraco(aEquipe) and not vVencedora;
  RectBarra.Fill.Color := CORES_EQUIPE[aEquipe];

  ImgLider.Visible := vLider;
  if vVencedora then
    ImgLider.Bitmap.Assign(TRecursos.Emoji(emVitoria))
  else if vLider then
    ImgLider.Bitmap.Assign(TRecursos.Emoji(emLider));

  if vLider or vVencedora then
  begin
    RectCard.Stroke.Color := COR_OURO;
    RectCard.Stroke.Thickness := 2;
  end
  else
  begin
    RectCard.Stroke.Color := COR_BORDA;
    RectCard.Stroke.Thickness := 1.5;
  end;

  FProgresso := EnsureRange(vTotal / Max(aPartida.Meta, 1), 0, 1);
  AjustarBarra;

  if aAnimar and (vTotal <> FTotalExibido) then
  begin
    LabTotal.Scale.Point := TPointF.Create(1.25, 1.25);
    TAnimator.AnimateFloat(LabTotal, 'Scale.X', 1, 0.4, TAnimationType.Out, TInterpolationType.Back);
    TAnimator.AnimateFloat(LabTotal, 'Scale.Y', 1, 0.4, TAnimationType.Out, TInterpolationType.Back);
  end;
  FTotalExibido := vTotal;
end;

procedure TFrameEquipePlacar.AjustarBarra;
begin
  if Assigned(RectBarra) and Assigned(RectBarraFundo) then
    RectBarra.Width := RectBarraFundo.Width * FProgresso;
end;

procedure TFrameEquipePlacar.RectBarraFundoResize(Sender: TObject);
begin
  AjustarBarra;
end;

end.
