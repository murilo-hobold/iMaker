unit iMaker.View.Navegacao;

{ Navegação entre telas (Router4D).
  As rotas usam o nome da classe do form: assim o Render<T> inicial e o
  Link.&To compartilham a mesma instância da tela. }

interface

uses
  System.SysUtils;

type
  TRota = (rtJogo, rtNovaPartida, rtHistorico, rtRanking, rtJogadores);

  TNavegacao = class
  strict private
    class var FOnNavegou: TProc<TRota>;
    class var FRotaAtual: TRota;
  public
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
