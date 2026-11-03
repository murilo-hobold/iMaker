unit iMaker.Service.Partida;

{ Regras da canastra: criação da partida, lançamento de rodadas, meta, buraco,
  vencedor, eventos (vitória, virada, buraco...) e rodízio de quem embaralha. }

interface

uses
  System.SysUtils, System.Math, System.DateUtils, System.Generics.Collections,
  iMaker.Model.Entidades, iMaker.Infra.Conexao,
  iMaker.Repository.Partida, iMaker.Repository.Jogador;

type
  TPartidaService = class
  strict private
    class var FPartidaAtualId: Integer;
    class var FAtualDefinida: Boolean;
    class procedure ValidarNovaPartida(const aNova: TNovaPartida); static;
    class procedure ValidarPontos(const aPartida: TPartida; const aPontos: TArray<Integer>); static;
    class procedure AvaliarFimDePartida(var aPartida: TPartida); static;
    class function Vencedor(const aPartida: TPartida): Integer; static;
    class function EmpateNaMeta(const aPartida: TPartida): Boolean; static;
    class function GerarEventos(const aAntes, aDepois: TPartida;
      const aPontos: TArray<Integer>): TArray<TEvento>; static;
  public
    class function JogadoresPorEquipe(aQtJogadores: Integer): Integer; static;
    class function QtEquipes(aQtJogadores: Integer): Integer; static;

    class function Criar(const aNova: TNovaPartida): TPartida; static;
    class function Carregar(aId: Integer): TPartida; static;
    class function Historico: TArray<TPartida>; static;
    class procedure ExcluirPartida(aId: Integer); static;

    { Partida exibida na tela de jogo }
    class function PartidaAtualId: Integer; static;
    class procedure SelecionarPartida(aId: Integer); static;

    class function LancarRodada(aPartidaId: Integer; const aPontos: TArray<Integer>;
      aDealerId: Integer): TResultadoRodada; static;
    class function EditarRodada(aPartidaId, aRodadaId: Integer; const aPontos: TArray<Integer>;
      aDealerId: Integer): TResultadoRodada; static;
    class function ExcluirRodada(aPartidaId, aRodadaId: Integer): TResultadoRodada; static;

    { Evento de abertura da partida/rodada atual (quem embaralha) }
    class function EventoRodadaAtual(const aPartida: TPartida): TEvento; static;
    { Sorteios auxiliares para a tela de nova partida }
    class function Embaralhar(const aIds: TArray<Integer>): TArray<Integer>; static;
    class function TextoResumo(const aPartida: TPartida): string; static;
  end;

implementation

{ TPartidaService }

class function TPartidaService.QtEquipes(aQtJogadores: Integer): Integer;
begin
  if aQtJogadores = 3 then
    Result := 3
  else
    Result := 2;
end;

class function TPartidaService.JogadoresPorEquipe(aQtJogadores: Integer): Integer;
begin
  Result := aQtJogadores div QtEquipes(aQtJogadores);
end;

class procedure TPartidaService.ValidarNovaPartida(const aNova: TNovaPartida);
var
  vQtValida: Boolean;
  vQt, vEquipes, vPorEquipe, I, J, vId: Integer;
  vUsados: TList<Integer>;
  vNomes: TList<string>;
  vNome: string;
begin
  vQtValida := False;
  for vQt in QTDS_JOGADORES do
    vQtValida := vQtValida or (vQt = aNova.QtJogadores);
  if not vQtValida then
    raise EIMakerValidacao.Create('Quantidade de jogadores inválida. Use 2, 3, 4 ou 6.');

  if aNova.Meta < META_MINIMA then
    raise EIMakerValidacao.CreateFmt('A meta deve ser de pelo menos %d pontos.', [META_MINIMA]);

  vEquipes := QtEquipes(aNova.QtJogadores);
  vPorEquipe := JogadoresPorEquipe(aNova.QtJogadores);

  if (Length(aNova.NomesEquipes) <> vEquipes) or (Length(aNova.JogadoresEquipes) <> vEquipes) then
    raise EIMakerValidacao.Create('Informe todas as equipes.');

  vUsados := TList<Integer>.Create;
  vNomes := TList<string>.Create;
  try
    for I := 0 to vEquipes - 1 do
    begin
      vNome := aNova.NomesEquipes[I].Trim;
      if vNome.IsEmpty then
        raise EIMakerValidacao.CreateFmt('Informe o nome da equipe %d.', [I + 1]);
      if vNomes.Contains(vNome.ToUpper) then
        raise EIMakerValidacao.CreateFmt('Já existe uma equipe chamada "%s".', [vNome]);
      vNomes.Add(vNome.ToUpper);

      if Length(aNova.JogadoresEquipes[I]) <> vPorEquipe then
        raise EIMakerValidacao.CreateFmt('A equipe "%s" precisa de %d jogador(es).', [vNome, vPorEquipe]);

      for J := 0 to High(aNova.JogadoresEquipes[I]) do
      begin
        vId := aNova.JogadoresEquipes[I][J];
        if vId <= 0 then
          raise EIMakerValidacao.CreateFmt('Escolha todos os jogadores da equipe "%s".', [vNome]);
        if vUsados.Contains(vId) then
          raise EIMakerValidacao.Create('Um jogador não pode estar em duas posições na mesa.');
        vUsados.Add(vId);
      end;
    end;
  finally
    vNomes.Free;
    vUsados.Free;
  end;
end;

class function TPartidaService.Criar(const aNova: TNovaPartida): TPartida;
var
  vPartida: TPartida;
  vEquipes, vPorEquipe, vPos, vEq: Integer;
  vJogador: TJogador;
  vDealerValido: Boolean;
begin
  ValidarNovaPartida(aNova);

  vEquipes := QtEquipes(aNova.QtJogadores);
  vPorEquipe := JogadoresPorEquipe(aNova.QtJogadores);

  vPartida := Default(TPartida);
  vPartida.QtJogadores := aNova.QtJogadores;
  vPartida.Meta := aNova.Meta;
  vPartida.Status := spEmAndamento;
  vPartida.Inicio := Now;

  SetLength(vPartida.Equipes, vEquipes);
  for vEq := 0 to vEquipes - 1 do
  begin
    vPartida.Equipes[vEq].Numero := vEq + 1;
    vPartida.Equipes[vEq].Nome := aNova.NomesEquipes[vEq].Trim;
  end;

  { Monta a mesa alternando as equipes: E1, E2, (E3), E1, E2... }
  for vPos := 0 to vPorEquipe - 1 do
    for vEq := 0 to vEquipes - 1 do
    begin
      vJogador := TJogadorRepository.Buscar(aNova.JogadoresEquipes[vEq][vPos]);
      if vJogador.Id = 0 then
        raise EIMakerValidacao.Create('Jogador não encontrado. Atualize a lista de jogadores.');
      vJogador.Equipe := vEq + 1;
      vPartida.Mesa := vPartida.Mesa + [vJogador];
    end;

  vDealerValido := False;
  for vJogador in vPartida.Mesa do
    vDealerValido := vDealerValido or (vJogador.Id = aNova.DealerInicialId);
  if vDealerValido then
    vPartida.DealerInicialId := aNova.DealerInicialId
  else
    vPartida.DealerInicialId := vPartida.Mesa[0].Id;

  TConexao.EmTransacao(
    procedure
    begin
      TPartidaRepository.Inserir(vPartida);
    end);

  SelecionarPartida(vPartida.Id);
  Result := TPartidaRepository.Carregar(vPartida.Id);
end;

class function TPartidaService.Carregar(aId: Integer): TPartida;
begin
  Result := TPartidaRepository.Carregar(aId);
end;

class function TPartidaService.Historico: TArray<TPartida>;
var
  vId: Integer;
begin
  Result := nil;
  for vId in TPartidaRepository.ListarIds do
    Result := Result + [TPartidaRepository.Carregar(vId)];
end;

class procedure TPartidaService.ExcluirPartida(aId: Integer);
begin
  TPartidaRepository.Excluir(aId);
  if PartidaAtualId = aId then
    SelecionarPartida(TPartidaRepository.IdEmAndamento);
end;

class function TPartidaService.PartidaAtualId: Integer;
begin
  if not FAtualDefinida then
  begin
    FPartidaAtualId := TPartidaRepository.IdEmAndamento;
    FAtualDefinida := True;
  end
  else if (FPartidaAtualId > 0) and not TPartidaRepository.Existe(FPartidaAtualId) then
    FPartidaAtualId := TPartidaRepository.IdEmAndamento;
  Result := FPartidaAtualId;
end;

class procedure TPartidaService.SelecionarPartida(aId: Integer);
begin
  FPartidaAtualId := aId;
  FAtualDefinida := True;
end;

class procedure TPartidaService.ValidarPontos(const aPartida: TPartida; const aPontos: TArray<Integer>);
var
  vPonto: Integer;
  vAlgumDiferenteDeZero: Boolean;
begin
  if Length(aPontos) <> aPartida.QtEquipes then
    raise EIMakerValidacao.Create('Informe os pontos de todas as equipes.');

  vAlgumDiferenteDeZero := False;
  for vPonto in aPontos do
  begin
    if Abs(vPonto) > 20000 then
      raise EIMakerValidacao.Create('Pontuação fora do limite (máximo 20.000 por rodada).');
    vAlgumDiferenteDeZero := vAlgumDiferenteDeZero or (vPonto <> 0);
  end;

  if not vAlgumDiferenteDeZero then
    raise EIMakerValidacao.Create('Informe a pontuação de pelo menos uma equipe.');
end;

class function TPartidaService.Vencedor(const aPartida: TPartida): Integer;
var
  vLider: Integer;
begin
  Result := 0;
  vLider := aPartida.Lider;
  if (vLider > 0) and (aPartida.Total(vLider) >= aPartida.Meta) then
    Result := vLider;
end;

class function TPartidaService.EmpateNaMeta(const aPartida: TPartida): Boolean;
var
  vMaior: Integer;
begin
  vMaior := MaxIntValue(aPartida.Totais);
  Result := (aPartida.Lider = 0) and (vMaior >= aPartida.Meta) and (Length(aPartida.Rodadas) > 0);
end;

class procedure TPartidaService.AvaliarFimDePartida(var aPartida: TPartida);
var
  vVencedor: Integer;
  vMudou: Boolean;
begin
  vVencedor := Vencedor(aPartida);
  vMudou := False;

  if vVencedor > 0 then
  begin
    if (not aPartida.Finalizada) or (aPartida.EquipeVencedora <> vVencedor) then
    begin
      aPartida.Status := spFinalizada;
      aPartida.EquipeVencedora := vVencedor;
      if aPartida.Fim = 0 then
        aPartida.Fim := Now;
      vMudou := True;
    end;
  end
  else if aPartida.Finalizada or (aPartida.EquipeVencedora <> 0) then
  begin
    { Uma edição/exclusão de rodada pode "reabrir" a partida }
    aPartida.Status := spEmAndamento;
    aPartida.EquipeVencedora := 0;
    aPartida.Fim := 0;
    vMudou := True;
  end;

  if vMudou then
    TPartidaRepository.AtualizarStatus(aPartida);
end;

class function TPartidaService.EventoRodadaAtual(const aPartida: TPartida): TEvento;
var
  vDealer: TJogador;
begin
  vDealer := aPartida.ProximoDealer;
  Result := TEvento.Criar(teRodadaIniciada, 0,
    Format('Rodada %d', [aPartida.ProximoNumeroRodada]),
    Format('%s embaralha as cartas. Boa sorte!', [vDealer.PrimeiroNome]));
end;

class function TPartidaService.GerarEventos(const aAntes, aDepois: TPartida;
  const aPontos: TArray<Integer>): TArray<TEvento>;
var
  vEventos: TList<TEvento>;
  vEq, vAntes, vDepois, vLiderAntes, vLiderDepois: Integer;
  vNaMeta: Boolean;
  vNome: string;
begin
  vEventos := TList<TEvento>.Create;
  try
    vNaMeta := EmpateNaMeta(aDepois);
    vLiderAntes := aAntes.Lider;
    vLiderDepois := aDepois.Lider;

    if aDepois.Finalizada then
      vEventos.Add(TEvento.Criar(teVitoria, aDepois.EquipeVencedora, 'Vitória!',
        Format('%s venceu com %s pontos!',
          [aDepois.NomeEquipe(aDepois.EquipeVencedora),
           FormatarPontos(aDepois.Total(aDepois.EquipeVencedora))])))
    else if vNaMeta then
      vEventos.Add(TEvento.Criar(teEmpateNaMeta, 0, 'Empate na meta!',
        Format('Empate em %s pontos. Joguem mais uma rodada para desempatar!',
          [FormatarPontos(MaxIntValue(aDepois.Totais))])));

    if not aDepois.Finalizada then
    begin
      for vEq := 1 to aDepois.QtEquipes do
      begin
        vAntes := aAntes.Total(vEq);
        vDepois := aDepois.Total(vEq);
        if (vAntes < aDepois.LimiteBuraco) and (vDepois >= aDepois.LimiteBuraco) then
          vEventos.Add(TEvento.Criar(teEntrouNoBuraco, vEq, 'Entrou no buraco!',
            Format('%s passou de %s pontos e está no buraco. Atenção ao baixar o jogo!',
              [aDepois.NomeEquipe(vEq), FormatarPontos(aDepois.LimiteBuraco)])));
      end;

      if (vLiderAntes > 0) and (vLiderDepois > 0) and (vLiderAntes <> vLiderDepois) then
        vEventos.Add(TEvento.Criar(teVirada, vLiderDepois, 'Virada!',
          Format('%s passou à frente e assumiu a liderança.', [aDepois.NomeEquipe(vLiderDepois)])));
    end;

    for vEq := 1 to Min(Length(aPontos), aDepois.QtEquipes) do
    begin
      vNome := aDepois.NomeEquipe(vEq);
      if aPontos[vEq - 1] >= aDepois.LimiteRodadaDeOuro then
        vEventos.Add(TEvento.Criar(teRodadaDeOuro, vEq, 'Rodada de ouro!',
          Format('%s fez %s pontos numa só rodada!', [vNome, FormatarPontos(aPontos[vEq - 1])])))
      else if aPontos[vEq - 1] < 0 then
        vEventos.Add(TEvento.Criar(teNegativo, vEq, 'Rodada negativa',
          Format('%s perdeu %s pontos nesta rodada.', [vNome, FormatarPontos(Abs(aPontos[vEq - 1]))])));
    end;

    if (not aDepois.Finalizada) and (not vNaMeta) and (vLiderDepois = 0) and
       (MaxIntValue(aDepois.Totais) <> 0) then
      vEventos.Add(TEvento.Criar(teEmpate, 0, 'Empate!',
        Format('Placar empatado em %s pontos.', [FormatarPontos(MaxIntValue(aDepois.Totais))])));

    if not aDepois.Finalizada then
      vEventos.Add(EventoRodadaAtual(aDepois));

    Result := vEventos.ToArray;
  finally
    vEventos.Free;
  end;
end;

class function TPartidaService.LancarRodada(aPartidaId: Integer; const aPontos: TArray<Integer>;
  aDealerId: Integer): TResultadoRodada;
var
  vAntes, vDepois: TPartida;
begin
  vAntes := TPartidaRepository.Carregar(aPartidaId);
  if vAntes.Finalizada then
    raise EIMakerValidacao.Create('Esta partida já terminou. Edite uma rodada ou comece uma nova partida.');
  ValidarPontos(vAntes, aPontos);

  if aDealerId <= 0 then
    aDealerId := vAntes.ProximoDealer.Id;

  TPartidaRepository.InserirRodada(aPartidaId, vAntes.ProximoNumeroRodada, aDealerId, aPontos);

  vDepois := TPartidaRepository.Carregar(aPartidaId);
  AvaliarFimDePartida(vDepois);

  Result.Partida := vDepois;
  Result.Eventos := GerarEventos(vAntes, vDepois, aPontos);
end;

class function TPartidaService.EditarRodada(aPartidaId, aRodadaId: Integer;
  const aPontos: TArray<Integer>; aDealerId: Integer): TResultadoRodada;
var
  vAntes, vDepois: TPartida;
begin
  vAntes := TPartidaRepository.Carregar(aPartidaId);
  if vAntes.IndiceRodada(aRodadaId) < 0 then
    raise EIMakerValidacao.Create('Rodada não encontrada.');
  ValidarPontos(vAntes, aPontos);

  TPartidaRepository.AtualizarRodada(aRodadaId, aDealerId, aPontos);

  vDepois := TPartidaRepository.Carregar(aPartidaId);
  AvaliarFimDePartida(vDepois);

  Result.Partida := vDepois;
  Result.Eventos := nil;
  if vDepois.Finalizada and not vAntes.Finalizada then
    Result.Eventos := GerarEventos(vAntes, vDepois, []);
end;

class function TPartidaService.ExcluirRodada(aPartidaId, aRodadaId: Integer): TResultadoRodada;
var
  vPartida: TPartida;
begin
  vPartida := TPartidaRepository.Carregar(aPartidaId);
  if vPartida.IndiceRodada(aRodadaId) < 0 then
    raise EIMakerValidacao.Create('Rodada não encontrada.');

  TPartidaRepository.ExcluirRodada(aPartidaId, aRodadaId);

  vPartida := TPartidaRepository.Carregar(aPartidaId);
  AvaliarFimDePartida(vPartida);
  Result.Partida := vPartida;
  Result.Eventos := nil;
end;

class function TPartidaService.Embaralhar(const aIds: TArray<Integer>): TArray<Integer>;
var
  I, J, vTmp: Integer;
begin
  Result := Copy(aIds);
  Randomize;
  for I := High(Result) downto 1 do
  begin
    J := Random(I + 1);
    vTmp := Result[I];
    Result[I] := Result[J];
    Result[J] := vTmp;
  end;
end;

class function TPartidaService.TextoResumo(const aPartida: TPartida): string;
var
  vSb: TStringBuilder;
  vEquipe: TEquipe;
begin
  vSb := TStringBuilder.Create;
  try
    vSb.AppendLine('🃏 iMaker · Canastra');
    vSb.AppendLine(Format('%s · %s · %d rodada(s)',
      [FormatDateTime('dd/mm/yyyy', aPartida.Inicio),
       FormatarDuracao(aPartida.DuracaoSegundos), Length(aPartida.Rodadas)]));
    vSb.AppendLine('');
    for vEquipe in aPartida.Equipes do
    begin
      vSb.Append(Format('%s (%s): %s', [vEquipe.Nome, vEquipe.NomesJogadores,
        FormatarPontos(aPartida.Total(vEquipe.Numero))]));
      if aPartida.EquipeVencedora = vEquipe.Numero then
        vSb.Append(' 🏆');
      vSb.AppendLine;
    end;
    vSb.AppendLine('');
    vSb.Append(Format('Meta: %s pontos', [FormatarPontos(aPartida.Meta)]));
    Result := vSb.ToString;
  finally
    vSb.Free;
  end;
end;

end.
