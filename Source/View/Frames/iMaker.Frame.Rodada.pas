unit iMaker.Frame.Rodada;

{ Linha de uma rodada no placar. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Math,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation,
  iMaker.Model.Entidades;

type
  TFrameRodada = class(TFrame)
    RectFundo: TRectangle;
    LabNumero: TLabel;
    LabDealer: TLabel;
    PathEditar: TPath;
    LayoutPontos: TLayout;
    LabPontos1: TLabel;
    LabPontos2: TLabel;
    LabPontos3: TLabel;
    procedure LayoutPontosResize(Sender: TObject);
  private
    FQtEquipes: Integer;
  public
    procedure Exibir(const aRodada: TRodada; aQtEquipes: Integer; aEditavel: Boolean);
  end;

implementation

{$R *.fmx}

uses
  iMaker.View.Tema;

{ TFrameRodada }

procedure TFrameRodada.Exibir(const aRodada: TRodada; aQtEquipes: Integer; aEditavel: Boolean);
var
  vLabels: array[1..3] of TLabel;
  vMaior, vEq, vPontos: Integer;
begin
  FQtEquipes := aQtEquipes;
  vLabels[1] := LabPontos1;
  vLabels[2] := LabPontos2;
  vLabels[3] := LabPontos3;

  LabNumero.Text := aRodada.Numero.ToString;
  if aRodada.DealerNome.Trim.IsEmpty then
    LabDealer.Text := '-'
  else
    LabDealer.Text := aRodada.DealerNome.Trim.Split([' '])[0];
  PathEditar.Visible := aEditavel;
  RectFundo.Tag := aRodada.Id;

  vMaior := MaxIntValue(aRodada.Pontos);
  for vEq := 1 to 3 do
  begin
    vLabels[vEq].Visible := vEq <= aQtEquipes;
    if vEq > aQtEquipes then
      Continue;
    vPontos := aRodada.PontosEquipe(vEq);
    vLabels[vEq].Text := FormatarPontos(vPontos);
    if vPontos < 0 then
      vLabels[vEq].TextSettings.FontColor := COR_PERIGO
    else if (vPontos = vMaior) and (vPontos > 0) then
      vLabels[vEq].TextSettings.FontColor := COR_OURO
    else
      vLabels[vEq].TextSettings.FontColor := COR_TEXTO;
  end;
  LayoutPontosResize(nil);
end;

procedure TFrameRodada.LayoutPontosResize(Sender: TObject);
var
  vLargura: Single;
begin
  if FQtEquipes = 0 then
    Exit;
  vLargura := LayoutPontos.Width / FQtEquipes;
  LabPontos1.Width := vLargura;
  LabPontos2.Width := vLargura;
  LabPontos3.Width := vLargura;
end;

end.
