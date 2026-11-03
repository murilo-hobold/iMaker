unit iMaker.Service.Jogador;

{ Regras de cadastro de jogadores e estatísticas/ranking. }

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults, System.Math,
  iMaker.Model.Entidades, iMaker.Repository.Jogador, iMaker.Repository.Estatistica;

type
  TResultadoExclusao = (reExcluido, reInativado);

  TJogadorService = class
  public
    class function Listar: TArray<TJogador>; static;
    class function Salvar(aId: Integer; const aNome: string): Integer; static;
    class function Excluir(aId: Integer): TResultadoExclusao; static;
  end;

  TEstatisticaService = class
  public
    { Ranking: mais vitórias, depois melhor aproveitamento, depois maior média }
    class function Ranking: TArray<TEstatisticaJogador>; static;
    class function PorJogador: TDictionary<Integer, TEstatisticaJogador>; static;
    class procedure ResumoGeral(out aPartidas, aRodadas: Integer); static;
  end;

implementation

{ TJogadorService }

class function TJogadorService.Listar: TArray<TJogador>;
begin
  Result := TJogadorRepository.Listar(True);
end;

class function TJogadorService.Salvar(aId: Integer; const aNome: string): Integer;
var
  vNome: string;
begin
  vNome := aNome.Trim;
  while vNome.Contains('  ') do
    vNome := vNome.Replace('  ', ' ');

  if vNome.IsEmpty then
    raise EIMakerValidacao.Create('Informe o nome do jogador.');
  if vNome.Length > 60 then
    raise EIMakerValidacao.Create('O nome pode ter no máximo 60 caracteres.');
  if TJogadorRepository.ExisteNome(vNome, aId) then
    raise EIMakerValidacao.CreateFmt('Já existe um jogador chamado "%s".', [vNome]);

  if aId > 0 then
  begin
    TJogadorRepository.Atualizar(aId, vNome);
    Result := aId;
  end
  else
    Result := TJogadorRepository.Inserir(vNome);
end;

class function TJogadorService.Excluir(aId: Integer): TResultadoExclusao;
begin
  { Quem já jogou fica inativo, para não perder o histórico das partidas }
  if TJogadorRepository.PossuiPartidas(aId) then
  begin
    TJogadorRepository.Inativar(aId);
    Result := reInativado;
  end
  else
  begin
    TJogadorRepository.Excluir(aId);
    Result := reExcluido;
  end;
end;

{ TEstatisticaService }

class function TEstatisticaService.Ranking: TArray<TEstatisticaJogador>;
begin
  Result := TEstatisticaRepository.PorJogador;
  TArray.Sort<TEstatisticaJogador>(Result, TComparer<TEstatisticaJogador>.Construct(
    function(const A, B: TEstatisticaJogador): Integer
    begin
      Result := CompareValue(B.Vitorias, A.Vitorias);
      if Result = 0 then
        Result := CompareValue(B.Aproveitamento, A.Aproveitamento);
      if Result = 0 then
        Result := CompareValue(B.MediaPontos, A.MediaPontos);
      if Result = 0 then
        Result := CompareValue(B.Partidas, A.Partidas);
      if Result = 0 then
        Result := CompareText(A.Jogador.Nome, B.Jogador.Nome);
    end));
end;

class function TEstatisticaService.PorJogador: TDictionary<Integer, TEstatisticaJogador>;
var
  vItem: TEstatisticaJogador;
begin
  Result := TDictionary<Integer, TEstatisticaJogador>.Create;
  for vItem in TEstatisticaRepository.PorJogador do
    Result.AddOrSetValue(vItem.Jogador.Id, vItem);
end;

class procedure TEstatisticaService.ResumoGeral(out aPartidas, aRodadas: Integer);
begin
  TEstatisticaRepository.ResumoGeral(aPartidas, aRodadas);
end;

end.
