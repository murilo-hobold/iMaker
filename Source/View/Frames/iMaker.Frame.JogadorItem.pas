unit iMaker.Frame.JogadorItem;

{ Item da lista de jogadores. }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation,
  iMaker.Model.Entidades;

type
  TFrameJogadorItem = class(TFrame)
    RectFundo: TRectangle;
    CircleAvatar: TCircle;
    LabIniciais: TLabel;
    PathEditar: TPath;
    LayoutTextos: TLayout;
    LabNome: TLabel;
    LabDetalhe: TLabel;
  public
    procedure Exibir(const aJogador: TJogador; const aEstatistica: TEstatisticaJogador);
  end;

implementation

{$R *.fmx}

{ TFrameJogadorItem }

procedure TFrameJogadorItem.Exibir(const aJogador: TJogador; const aEstatistica: TEstatisticaJogador);
begin
  RectFundo.Tag := aJogador.Id;
  LabIniciais.Text := aJogador.Iniciais;
  LabNome.Text := aJogador.Nome;

  if aEstatistica.Partidas = 0 then
    LabDetalhe.Text := 'Nenhuma partida finalizada ainda'
  else
    LabDetalhe.Text := Format('%d partida(s) · %d vitória(s) · %.0f%%',
      [aEstatistica.Partidas, aEstatistica.Vitorias, aEstatistica.Aproveitamento]);
end;

end.
