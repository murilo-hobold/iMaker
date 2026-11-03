unit iMaker.Frame.EquipeConfig;

{ Card de configuração de uma equipe na tela de nova partida:
  nome da equipe + vagas de jogadores (1 a 3). }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation;

type
  TFrameEquipeConfig = class(TFrame)
    RectCard: TRectangle;
    LayoutTopo: TLayout;
    CircleCor: TCircle;
    LabTitulo: TLabel;
    RectNome: TRectangle;
    EdtNome: TEdit;
    RectSlot1: TRectangle;
    PathSeta1: TPath;
    LabSlot1: TLabel;
    RectSlot2: TRectangle;
    PathSeta2: TPath;
    LabSlot2: TLabel;
    RectSlot3: TRectangle;
    PathSeta3: TPath;
    LabSlot3: TLabel;
  private
    FEquipe: Integer;
    FQtVagas: Integer;
    function Slot(aIndice: Integer): TRectangle;
    function LabelSlot(aIndice: Integer): TLabel;
  public
    procedure Configurar(aEquipe, aQtVagas: Integer; aCor: TAlphaColor);
    procedure ExibirJogador(aVaga: Integer; const aNome: string);
    { Liga o clique das vagas a um único evento da tela (Tag = vaga) }
    procedure AoClicarVaga(const aEvento: TNotifyEvent);
    property Equipe: Integer read FEquipe;
    property QtVagas: Integer read FQtVagas;
  end;

implementation

{$R *.fmx}

uses
  iMaker.View.Tema;

{ TFrameEquipeConfig }

function TFrameEquipeConfig.Slot(aIndice: Integer): TRectangle;
begin
  case aIndice of
    1: Result := RectSlot1;
    2: Result := RectSlot2;
  else
    Result := RectSlot3;
  end;
end;

function TFrameEquipeConfig.LabelSlot(aIndice: Integer): TLabel;
begin
  case aIndice of
    1: Result := LabSlot1;
    2: Result := LabSlot2;
  else
    Result := LabSlot3;
  end;
end;

procedure TFrameEquipeConfig.Configurar(aEquipe, aQtVagas: Integer; aCor: TAlphaColor);
var
  I: Integer;
begin
  FEquipe := aEquipe;
  FQtVagas := aQtVagas;
  LabTitulo.Text := Format('EQUIPE %d', [aEquipe]);
  CircleCor.Fill.Color := aCor;

  for I := 1 to 3 do
  begin
    Slot(I).Visible := I <= aQtVagas;
    Slot(I).Tag := I;
  end;

  { padding + topo + nome + vagas + margem inferior }
  Height := 12 + 20 + 8 + 44 + aQtVagas * 52 + 12 + 12;
end;

procedure TFrameEquipeConfig.ExibirJogador(aVaga: Integer; const aNome: string);
begin
  if aNome.IsEmpty then
  begin
    LabelSlot(aVaga).Text := 'Escolher jogador';
    LabelSlot(aVaga).TextSettings.FontColor := COR_TEXTO_SEC;
    Slot(aVaga).Stroke.Color := COR_BORDA;
  end
  else
  begin
    LabelSlot(aVaga).Text := aNome;
    LabelSlot(aVaga).TextSettings.FontColor := COR_TEXTO;
    Slot(aVaga).Stroke.Color := COR_OURO_ESCURO;
  end;
end;

procedure TFrameEquipeConfig.AoClicarVaga(const aEvento: TNotifyEvent);
begin
  RectSlot1.OnClick := aEvento;
  RectSlot2.OnClick := aEvento;
  RectSlot3.OnClick := aEvento;
end;

end.
