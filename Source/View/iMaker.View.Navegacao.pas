unit iMaker.View.Navegacao;

{ Navegação entre telas (Router4D).
  As rotas usam o nome da classe do form: assim o Render<T> inicial e o
  Link.&To compartilham a mesma instância da tela. }

interface

uses
  System.SysUtils, FMX.Types;

type
  TRota = (rtJogo, rtNovaPartida, rtHistorico, rtRanking, rtJogadores);

  TNavegacao = class
  strict private
    class var FOnNavegou: TProc<TRota>;
    class var FRotaAtual: TRota;
    class var FContainer: TFmxObject;
  public
    { Área onde as telas são exibidas (LayoutTela da tela principal) }
    class property Container: TFmxObject read FContainer write FContainer;
    class procedure Ir(aRota: TRota); static;
    class function NomeRota(aRota: TRota): string; static;
    class function Titulo(aRota: TRota): string; static;
    class property OnNavegou: TProc<TRota> read FOnNavegou write FOnNavegou;
    class property RotaAtual: TRota read FRotaAtual;
    { Quando True, a tela de jogo mostra a animação de "rodada iniciada" ao abrir }
    class var MostrarInicioDaPartida: Boolean;
  end;

implementation

uses
  Router4D;

const
  NOMES_ROTA: array[TRota] of string =
    ('TFormJogo', 'TFormNovaPartida', 'TFormHistorico', 'TFormRanking', 'TFormJogadores');
  TITULOS_ROTA: array[TRota] of string =
    ('Partida', 'Nova partida', 'Histórico', 'Ranking', 'Jogadores');

{ TNavegacao }

class procedure TNavegacao.Ir(aRota: TRota);
begin
  FRotaAtual := aRota;
  { O Router4D remove só o primeiro filho do container. Tiramos todos antes,
    para nunca sobrar uma tela antiga desenhada por baixo da nova. }
  if Assigned(FContainer) then
    while FContainer.ChildrenCount > 0 do
      FContainer.RemoveObject(FContainer.Children[0]);
  TRouter4D.Link.&To(NomeRota(aRota));
  if Assigned(FOnNavegou) then
    FOnNavegou(aRota);
end;

class function TNavegacao.NomeRota(aRota: TRota): string;
begin
  Result := NOMES_ROTA[aRota];
end;

class function TNavegacao.Titulo(aRota: TRota): string;
begin
  Result := TITULOS_ROTA[aRota];
end;

end.
