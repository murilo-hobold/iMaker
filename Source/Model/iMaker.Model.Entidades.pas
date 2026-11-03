unit iMaker.Model.Entidades;

{ Entidades do domínio. Records simples, sem dependência de banco ou de tela. }

interface

uses
  System.SysUtils, System.DateUtils, System.Math;

const
  META_PADRAO      = 2000;
  META_MINIMA      = 100;
  MAX_EQUIPES      = 3;
  QTDS_JOGADORES: array[0..3] of Integer = (2, 3, 4, 6);

type
  TStatusPartida = (spEmAndamento, spFinalizada);

  TJogador = record
    Id: Integer;
    Nome: string;
    Ativo: Boolean;
    Equipe: Integer;              // equipe na partida (0 fora do contexto de uma partida)
    function Iniciais: string;
    function PrimeiroNome: string;
    class function Vazio: TJogador; static;
  end;

  TEquipe = record
    Numero: Integer;              // 1..3
    Nome: string;
    Jogadores: TArray<TJogador>;
    function NomesJogadores(const aSeparador: string = ' & '): string;
  end;

  TRodada = record
    Id: Integer;
    Numero: Integer;
    DealerId: Integer;
    DealerNome: string;
    Data: TDateTime;
    Pontos: TArray<Integer>;      // índice 0 = equipe 1
    function PontosEquipe(aEquipe: Integer): Integer;
  end;

  TPartida = record
    Id: Integer;
    QtJogadores: Integer;
    Meta: Integer;
    Status: TStatusPartida;
    Inicio: TDateTime;
    Fim: TDateTime;
    DealerInicialId: Integer;
    EquipeVencedora: Integer;     // 0 = sem vencedor
    Equipes: TArray<TEquipe>;
    Mesa: TArray<TJogador>;       // ordem dos jogadores na mesa (rodízio de quem embaralha)
    Rodadas: TArray<TRodada>;     // ordenadas pelo número
    function QtEquipes: Integer;
    function LimiteBuraco: Integer;
    function LimiteRodadaDeOuro: Integer;
    function Total(aEquipe: Integer): Integer;
    function Totais: TArray<Integer>;
    function Lider: Integer;      // 0 = empate ou sem pontos
    function EstaNoBuraco(aEquipe: Integer): Boolean;
    function FaltaParaMeta(aEquipe: Integer): Integer;
    function ProximoNumeroRodada: Integer;
    function ProximoDealer: TJogador;
    function DuracaoSegundos: Int64;
    function Finalizada: Boolean;
    function NomeEquipe(aEquipe: Integer): string;
    function IndiceRodada(aRodadaId: Integer): Integer;
    function MelhorRodada(aEquipe: Integer): Integer;
  end;

  { Dados informados na tela de nova partida }
  TNovaPartida = record
    QtJogadores: Integer;
    Meta: Integer;
    DealerInicialId: Integer;              // 0 = primeiro da mesa
    NomesEquipes: TArray<string>;          // um por equipe
    JogadoresEquipes: TArray<TArray<Integer>>; // ids dos jogadores de cada equipe
  end;

  TTipoEvento = (
    teRodadaIniciada,
    teVitoria,
    teEmpateNaMeta,
    teEntrouNoBuraco,
    teVirada,
    teEmpate,
    teNegativo,
    teRodadaDeOuro
  );

  TEvento = record
    Tipo: TTipoEvento;
    Equipe: Integer;              // 0 quando o evento não é de uma equipe
    Titulo: string;
    Mensagem: string;
    class function Criar(aTipo: TTipoEvento; aEquipe: Integer;
      const aTitulo, aMensagem: string): TEvento; static;
  end;

  TResultadoRodada = record
    Partida: TPartida;
    Eventos: TArray<TEvento>;     // em ordem de importância
  end;

  TEstatisticaJogador = record
    Jogador: TJogador;
    Partidas: Integer;
    Vitorias: Integer;
    MediaPontos: Double;          // média do total da equipe por partida
    MelhorRodada: Integer;
    function Aproveitamento: Double; // 0..100
    function Derrotas: Integer;
  end;

  TConfigApp = record
    MetaPadrao: Integer;
    SomAtivo: Boolean;
    TelaSempreAcesa: Boolean;
    class function Padrao: TConfigApp; static;
  end;

  EIMakerValidacao = class(Exception);

function FormatarDuracao(aSegundos: Int64): string;
function FormatarPontos(aPontos: Integer): string;

implementation

function FormatarDuracao(aSegundos: Int64): string;
var
  vH, vM, vS: Int64;
begin
  if aSegundos < 0 then
    aSegundos := 0;
  vH := aSegundos div 3600;
  vM := (aSegundos mod 3600) div 60;
  vS := aSegundos mod 60;
  if vH > 0 then
    Result := Format('%d:%.2d:%.2d', [vH, vM, vS])
  else
    Result := Format('%.2d:%.2d', [vM, vS]);
end;

function FormatarPontos(aPontos: Integer): string;
begin
  Result := FormatFloat('#,##0', aPontos);
end;

{ TJogador }

function TJogador.Iniciais: string;
var
  vPartes: TArray<string>;
begin
  vPartes := Nome.Trim.Split([' '], TStringSplitOptions.ExcludeEmpty);
  case Length(vPartes) of
    0: Result := '?';
    1: Result := vPartes[0].Substring(0, 2);
  else
    Result := vPartes[0].Substring(0, 1) + vPartes[High(vPartes)].Substring(0, 1);
  end;
  Result := Result.ToUpper;
end;

function TJogador.PrimeiroNome: string;
var
  vPartes: TArray<string>;
begin
  vPartes := Nome.Trim.Split([' '], TStringSplitOptions.ExcludeEmpty);
  if Length(vPartes) = 0 then
    Result := ''
  else
    Result := vPartes[0];
end;

class function TJogador.Vazio: TJogador;
begin
  Result := Default(TJogador);
end;

{ TEquipe }

function TEquipe.NomesJogadores(const aSeparador: string): string;
var
  vJogador: TJogador;
begin
  Result := '';
  for vJogador in Jogadores do
  begin
    if not Result.IsEmpty then
      Result := Result + aSeparador;
    Result := Result + vJogador.PrimeiroNome;
  end;
end;

{ TRodada }

function TRodada.PontosEquipe(aEquipe: Integer): Integer;
begin
  if (aEquipe >= 1) and (aEquipe <= Length(Pontos)) then
    Result := Pontos[aEquipe - 1]
  else
    Result := 0;
end;

{ TPartida }

function TPartida.QtEquipes: Integer;
begin
  if QtJogadores = 3 then
    Result := 3
  else
    Result := 2;
end;

function TPartida.LimiteBuraco: Integer;
begin
  Result := Meta div 2;
end;

function TPartida.LimiteRodadaDeOuro: Integer;
begin
  Result := Max(Meta div 4, 100);
end;

function TPartida.Total(aEquipe: Integer): Integer;
var
  vRodada: TRodada;
begin
  Result := 0;
  for vRodada in Rodadas do
    Inc(Result, vRodada.PontosEquipe(aEquipe));
end;

function TPartida.Totais: TArray<Integer>;
var
  I: Integer;
begin
  SetLength(Result, QtEquipes);
  for I := 1 to QtEquipes do
    Result[I - 1] := Total(I);
end;

function TPartida.Lider: Integer;
var
  I, vMaior, vQtMaior: Integer;
  vTotais: TArray<Integer>;
begin
  Result := 0;
  if Length(Rodadas) = 0 then
    Exit;

  vTotais := Totais;
  vMaior := MaxInt * -1;
  vQtMaior := 0;
  for I := 0 to High(vTotais) do
  begin
    if vTotais[I] > vMaior then
    begin
      vMaior := vTotais[I];
      vQtMaior := 1;
      Result := I + 1;
    end
    else if vTotais[I] = vMaior then
      Inc(vQtMaior);
  end;

  if vQtMaior > 1 then
    Result := 0;
end;

function TPartida.EstaNoBuraco(aEquipe: Integer): Boolean;
begin
  Result := Total(aEquipe) >= LimiteBuraco;
end;

function TPartida.FaltaParaMeta(aEquipe: Integer): Integer;
begin
  Result := Max(Meta - Total(aEquipe), 0);
end;

function TPartida.ProximoNumeroRodada: Integer;
begin
  if Length(Rodadas) = 0 then
    Result := 1
  else
    Result := Rodadas[High(Rodadas)].Numero + 1;
end;

function TPartida.ProximoDealer: TJogador;
var
  I, vUltimoDealer: Integer;
begin
  Result := TJogador.Vazio;
  if Length(Mesa) = 0 then
    Exit;

  if Length(Rodadas) = 0 then
  begin
    for I := 0 to High(Mesa) do
      if Mesa[I].Id = DealerInicialId then
        Exit(Mesa[I]);
    Exit(Mesa[0]);
  end;

  vUltimoDealer := Rodadas[High(Rodadas)].DealerId;
  for I := 0 to High(Mesa) do
    if Mesa[I].Id = vUltimoDealer then
      Exit(Mesa[(I + 1) mod Length(Mesa)]);

  Result := Mesa[0];
end;

function TPartida.DuracaoSegundos: Int64;
begin
  if Inicio = 0 then
    Exit(0);
  if Finalizada and (Fim > 0) then
    Result := SecondsBetween(Fim, Inicio)
  else
    Result := SecondsBetween(Now, Inicio);
end;

function TPartida.Finalizada: Boolean;
begin
  Result := Status = spFinalizada;
end;

function TPartida.NomeEquipe(aEquipe: Integer): string;
begin
  if (aEquipe >= 1) and (aEquipe <= Length(Equipes)) then
    Result := Equipes[aEquipe - 1].Nome
  else
    Result := '';
end;

function TPartida.IndiceRodada(aRodadaId: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to High(Rodadas) do
    if Rodadas[I].Id = aRodadaId then
      Exit(I);
  Result := -1;
end;

function TPartida.MelhorRodada(aEquipe: Integer): Integer;
var
  vRodada: TRodada;
begin
  Result := 0;
  for vRodada in Rodadas do
    Result := Max(Result, vRodada.PontosEquipe(aEquipe));
end;

{ TEvento }

class function TEvento.Criar(aTipo: TTipoEvento; aEquipe: Integer;
  const aTitulo, aMensagem: string): TEvento;
begin
  Result.Tipo := aTipo;
  Result.Equipe := aEquipe;
  Result.Titulo := aTitulo;
  Result.Mensagem := aMensagem;
end;

{ TEstatisticaJogador }

function TEstatisticaJogador.Aproveitamento: Double;
begin
  if Partidas = 0 then
    Result := 0
  else
    Result := Vitorias / Partidas * 100;
end;

function TEstatisticaJogador.Derrotas: Integer;
begin
  Result := Partidas - Vitorias;
end;

{ TConfigApp }

class function TConfigApp.Padrao: TConfigApp;
begin
  Result.MetaPadrao := META_PADRAO;
  Result.SomAtivo := True;
  Result.TelaSempreAcesa := True;
end;

end.
