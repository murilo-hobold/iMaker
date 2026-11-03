unit iMaker.Frame.Picker;

{ Seletor em lista no tema do app (substitui o TComboBox nativo). }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Math,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation;

type
  TFramePicker = class(TFrame)
    RectFundo: TRectangle;
    RectCard: TRectangle;
    LabTitulo: TLabel;
    RectCancelar: TRectangle;
    LabCancelar: TLabel;
    VsbOpcoes: TVertScrollBox;
    procedure RectCancelarClick(Sender: TObject);
  private
    FAoEscolher: TProc<Integer>;
    procedure OpcaoClick(Sender: TObject);
    procedure AdicionarOpcao(aIndice: Integer; const aTexto: string; aSelecionada: Boolean);
    procedure Fechar(aIndiceEscolhido: Integer);
  public
    { Abre o seletor sobre aParent. aAoEscolher recebe o índice escolhido. }
    class procedure Abrir(aParent: TControl; const aTitulo: string;
      const aOpcoes: TArray<string>; aSelecionada: Integer;
      const aAoEscolher: TProc<Integer>); static;
  end;

implementation

{$R *.fmx}

uses
  iMaker.View.Tema, iMaker.View.Componentes;

const
  ALTURA_OPCAO = 50;

{ TFramePicker }

class procedure TFramePicker.Abrir(aParent: TControl; const aTitulo: string;
  const aOpcoes: TArray<string>; aSelecionada: Integer; const aAoEscolher: TProc<Integer>);
var
  vPicker: TFramePicker;
  I: Integer;
begin
  vPicker := TFramePicker.Create(nil);
  vPicker.Name := '';
  vPicker.Parent := aParent;
  vPicker.SetBounds(0, 0, aParent.Width, aParent.Height);
  vPicker.Align := TAlignLayout.Contents;
  vPicker.FAoEscolher := aAoEscolher;
  vPicker.LabTitulo.Text := aTitulo;

  for I := 0 to High(aOpcoes) do
    vPicker.AdicionarOpcao(I, aOpcoes[I], I = aSelecionada);

  vPicker.RectCard.Height := Min(14 + 36 + Length(aOpcoes) * ALTURA_OPCAO + 54 + 14 + 4,
    aParent.Height - 64);
  TModal.Mostrar(vPicker, vPicker.RectCard);
end;

procedure TFramePicker.AdicionarOpcao(aIndice: Integer; const aTexto: string; aSelecionada: Boolean);
var
  vItem: TRectangle;
  vTexto: TLabel;
begin
  vItem := TRectangle.Create(Self);
  vItem.Parent := VsbOpcoes;
  vItem.Align := TAlignLayout.Top;
  vItem.Position.Y := aIndice * ALTURA_OPCAO;
  vItem.Height := ALTURA_OPCAO - 6;
  vItem.Margins.Bottom := 6;
  vItem.XRadius := 10;
  vItem.YRadius := 10;
  vItem.Stroke.Kind := TBrushKind.None;
  vItem.Tag := aIndice;
  vItem.OnClick := OpcaoClick;
  if aSelecionada then
    vItem.Fill.Color := COR_OURO
  else
    vItem.Fill.Color := COR_SUPERFICIE_2;

  vTexto := TLabel.Create(vItem);
  vTexto.Parent := vItem;
  vTexto.Align := TAlignLayout.Client;
  vTexto.Margins.Left := 14;
  vTexto.HitTest := False;
  vTexto.StyledSettings := [TStyledSetting.Family];
  vTexto.TextSettings.Font.Size := 16;
  vTexto.Text := aTexto;
  if aSelecionada then
    vTexto.TextSettings.FontColor := COR_TEXTO_ESCURO
  else
    vTexto.TextSettings.FontColor := COR_TEXTO;
end;

procedure TFramePicker.OpcaoClick(Sender: TObject);
begin
  Fechar(TControl(Sender).Tag);
end;

procedure TFramePicker.RectCancelarClick(Sender: TObject);
begin
  Fechar(-1);
end;

procedure TFramePicker.Fechar(aIndiceEscolhido: Integer);
var
  vAoEscolher: TProc<Integer>;
begin
  vAoEscolher := FAoEscolher;
  HitTest := False;
  TModal.Esconder(Self, RectCard,
    procedure
    begin
      if (aIndiceEscolhido >= 0) and Assigned(vAoEscolher) then
        vAoEscolher(aIndiceEscolhido);
      Self.Free;
    end);
end;

end.
