unit iMaker.View.Componentes;

{ Utilitários visuais reaproveitados pelas telas: modal animado, toast,
  confete, diálogos e helpers de lista. }

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  FMX.Types, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.Graphics, FMX.Ani,
  FMX.StdCtrls, FMX.DialogService;

type
  TModal = class
  public
    { aCamada: layout Align=Contents com fundo escuro + card.
      O card entra deslizando de cima, para não ficar atrás do teclado. }
    class procedure Mostrar(aCamada: TControl; aCard: TControl); static;
    class procedure Esconder(aCamada: TControl; aCard: TControl; const aDepois: TProc = nil); static;
  end;

  TToast = class
  public
    class procedure Mostrar(aParent: TControl; const aTexto: string;
      aIcone: TBitmap = nil); static;
  end;

  TConfete = class
  public
    class procedure Disparar(aParent: TControl; aQuantidade: Integer = 60); static;
  end;

  TDialogo = class
  public
    class procedure Aviso(const aMensagem: string); static;
    class procedure Confirmar(const aMensagem: string; const aAoConfirmar: TProc); static;
  end;

  { Executa aProc na thread principal depois de aMs milissegundos }
  procedure Atrasar(aMs: Integer; const aProc: TProc);
  procedure LimparLista(aBox: TVertScrollBox);
  { Converte texto digitado em inteiro ('' ou '-' viram 0; ignora pontos de milhar) }
  function TextoParaInteiro(const aTexto: string): Integer;
  procedure Pulsar(aControle: TControl);

implementation

uses
  iMaker.View.Tema;

procedure Atrasar(aMs: Integer; const aProc: TProc);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(aMs);
      TThread.Queue(nil,
        procedure
        begin
          aProc();
        end);
    end).Start;
end;

procedure LimparLista(aBox: TVertScrollBox);
var
  I: Integer;
begin
  aBox.BeginUpdate;
  try
    for I := aBox.Content.ChildrenCount - 1 downto 0 do
      aBox.Content.Children[I].Free;
  finally
    aBox.EndUpdate;
  end;
  aBox.ViewportPosition := TPointF.Zero;
end;

function TextoParaInteiro(const aTexto: string): Integer;
var
  vTexto: string;
begin
  vTexto := aTexto.Trim.Replace('.', '').Replace(',', '').Replace(' ', '');
  if (vTexto = '') or (vTexto = '-') then
    Exit(0);
  if not TryStrToInt(vTexto, Result) then
    raise EConvertError.CreateFmt('"%s" não é um número válido.', [aTexto]);
end;

procedure Pulsar(aControle: TControl);
begin
  TAnimator.AnimateFloat(aControle, 'Scale.X', 1.08, 0.12, TAnimationType.Out, TInterpolationType.Quadratic);
  TAnimator.AnimateFloat(aControle, 'Scale.Y', 1.08, 0.12, TAnimationType.Out, TInterpolationType.Quadratic);
  Atrasar(130,
    procedure
    begin
      TAnimator.AnimateFloat(aControle, 'Scale.X', 1, 0.2, TAnimationType.Out, TInterpolationType.Back);
      TAnimator.AnimateFloat(aControle, 'Scale.Y', 1, 0.2, TAnimationType.Out, TInterpolationType.Back);
    end);
end;

{ TModal }

class procedure TModal.Mostrar(aCamada: TControl; aCard: TControl);
var
  vDestinoY: Single;
begin
  aCamada.Opacity := 0;
  aCamada.Visible := True;
  aCamada.BringToFront;

  aCard.Align := TAlignLayout.None;
  aCard.Width := Min(aCamada.Width - 32, 480);
  aCard.Position.X := (aCamada.Width - aCard.Width) / 2;
  vDestinoY := Max(16, Min(48, (aCamada.Height - aCard.Height) / 2));
  aCard.Position.Y := vDestinoY - 40;

  TAnimator.AnimateFloat(aCamada, 'Opacity', 1, 0.2);
  TAnimator.AnimateFloat(aCard, 'Position.Y', vDestinoY, 0.35, TAnimationType.Out, TInterpolationType.Back);
end;

class procedure TModal.Esconder(aCamada: TControl; aCard: TControl; const aDepois: TProc);
begin
  TAnimator.AnimateFloat(aCamada, 'Opacity', 0, 0.18);
  TAnimator.AnimateFloat(aCard, 'Position.Y', aCard.Position.Y - 30, 0.18);
  Atrasar(200,
    procedure
    begin
      aCamada.Visible := False;
      if Assigned(aDepois) then
        aDepois();
    end);
end;

{ TToast }

class procedure TToast.Mostrar(aParent: TControl; const aTexto: string; aIcone: TBitmap);
var
  vCaixa: TRectangle;
  vTexto: TLabel;
  vImagem: TImage;
begin
  vCaixa := TRectangle.Create(nil);
  vCaixa.Parent := aParent;
  vCaixa.Align := TAlignLayout.None;
  vCaixa.SetBounds(16, aParent.Height - 56 - 16, aParent.Width - 32, 56);
  vCaixa.Padding.Rect := TRectF.Create(10, 6, 14, 6);
  vCaixa.XRadius := 14;
  vCaixa.YRadius := 14;
  vCaixa.Fill.Color := COR_SUPERFICIE_2;
  vCaixa.Stroke.Color := COR_OURO;
  vCaixa.Stroke.Thickness := 1.5;
  vCaixa.HitTest := False;
  vCaixa.Opacity := 0;

  if Assigned(aIcone) then
  begin
    vImagem := TImage.Create(vCaixa);
    vImagem.Parent := vCaixa;
    vImagem.Align := TAlignLayout.Left;
    vImagem.Width := 44;
    vImagem.Margins.Right := 8;
    vImagem.WrapMode := TImageWrapMode.Fit;
    vImagem.Bitmap.Assign(aIcone);
    vImagem.HitTest := False;
  end;

  vTexto := TLabel.Create(vCaixa);
  vTexto.Parent := vCaixa;
  vTexto.Align := TAlignLayout.Client;
  vTexto.StyledSettings := [TStyledSetting.Family];
  vTexto.TextSettings.Font.Size := 14;
  vTexto.TextSettings.FontColor := COR_TEXTO;
  vTexto.TextSettings.WordWrap := True;
  vTexto.Text := aTexto;
  vTexto.HitTest := False;

  vCaixa.BringToFront;
  TAnimator.AnimateFloat(vCaixa, 'Opacity', 1, 0.25);
  Atrasar(2600,
    procedure
    begin
      TAnimator.AnimateFloat(vCaixa, 'Opacity', 0, 0.3);
      Atrasar(350,
        procedure
        begin
          vCaixa.Free;
        end);
    end);
end;

{ TConfete }

class procedure TConfete.Disparar(aParent: TControl; aQuantidade: Integer);
const
  CORES: array[0..3] of TAlphaColor = (COR_OURO, COR_TEXTO, COR_OURO_ESCURO, $FFFFE27A);
var
  I: Integer;
  vPeca: TRectangle;
  vPecas: TArray<TRectangle>;
  vDuracao: Single;
begin
  Randomize;
  SetLength(vPecas, aQuantidade);
  for I := 0 to aQuantidade - 1 do
  begin
    vPeca := TRectangle.Create(nil);
    vPeca.Parent := aParent;
    vPeca.HitTest := False;
    vPeca.Stroke.Kind := TBrushKind.None;
    vPeca.Fill.Color := CORES[Random(Length(CORES))];
    vPeca.Width := 6 + Random(6);
    vPeca.Height := 10 + Random(8);
    vPeca.XRadius := 2;
    vPeca.YRadius := 2;
    vPeca.Position.X := Random(Max(1, Round(aParent.Width)));
    vPeca.Position.Y := -20 - Random(200);
    vPeca.RotationAngle := Random(360);
    vDuracao := 1.4 + Random * 1.4;
    TAnimator.AnimateFloat(vPeca, 'Position.Y', aParent.Height + 30, vDuracao, TAnimationType.In, TInterpolationType.Quadratic);
    TAnimator.AnimateFloat(vPeca, 'RotationAngle', vPeca.RotationAngle + 360 + Random(360), vDuracao);
    vPecas[I] := vPeca;
  end;

  Atrasar(3200,
    procedure
    var
      vItem: TRectangle;
    begin
      for vItem in vPecas do
        vItem.Free;
    end);
end;

{ TDialogo }

class procedure TDialogo.Aviso(const aMensagem: string);
begin
  TDialogService.ShowMessage(aMensagem);
end;

class procedure TDialogo.Confirmar(const aMensagem: string; const aAoConfirmar: TProc);
begin
  TDialogService.MessageDialog(aMensagem, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
    procedure(const aResultado: TModalResult)
    begin
      if aResultado = mrYes then
        aAoConfirmar();
    end);
end;

end.
