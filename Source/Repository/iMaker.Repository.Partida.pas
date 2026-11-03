unit iMaker.Repository.Partida;

{ Acesso a dados de partida, equipes, jogadores da partida e rodadas. }

interface

uses
  System.SysUtils, System.Generics.Collections, System.Variants, Data.DB,
  FireDAC.Comp.Client,
  iMaker.Model.Entidades, iMaker.Infra.Conexao;

type
  TPartidaRepository = class
  strict private
    class procedure CarregarEquipesEMesa(var aPartida: TPartida); static;
    class procedure CarregarRodadas(var aPartida: TPartida); static;
    class procedure GravarPontos(aRodadaId: Integer; const aPontos: TArray<Integer>); static;
  public
    { Grava partida, equipes e jogadores da mesa. Preenche aPartida.Id. }
    class procedure Inserir(var aPartida: TPartida); static;
    class function Carregar(aId: Integer): TPartida; static;
    class function Existe(aId: Integer): Boolean; static;
    class function ListarIds: TArray<Integer>; static;
    class function IdEmAndamento: Integer; static;
    class procedure AtualizarStatus(const aPartida: TPartida); static;
    class procedure Excluir(aId: Integer); static;

    class function InserirRodada(aPartidaId, aNumero, aDealerId: Integer;
      const aPontos: TArray<Integer>): Integer; static;
    class procedure AtualizarRodada(aRodadaId, aDealerId: Integer;
      const aPontos: TArray<Integer>); static;
    class procedure ExcluirRodada(aPartidaId, aRodadaId: Integer); static;
  end;

implementation

const
  STATUS_BANCO: array[TStatusPartida] of string = ('A', 'F');

function DataOuNulo(aData: TDateTime): Variant;
begin
  if aData = 0 then
    Result := Null
  else
    Result := aData;
end;

{ TPartidaRepository }

class procedure TPartidaRepository.Inserir(var aPartida: TPartida);
var
  vConexao: TFDConnection;
  vEquipe: TEquipe;
  I: Integer;
begin
  vConexao := TConexao.Get;
  vConexao.ExecSQL(
    'INSERT INTO partida (par_qt_jogadores, par_meta, par_status, par_inicio, ' +
    '                     par_dealer_inicial, par_equipe_vencedora) ' +
    'VALUES (:qt, :meta, :status, :inicio, :dealer, 0)',
    [aPartida.QtJogadores, aPartida.Meta, STATUS_BANCO[aPartida.Status],
     aPartida.Inicio, aPartida.DealerInicialId]);
  aPartida.Id := vConexao.GetLastAutoGenValue('');

  for vEquipe in aPartida.Equipes do
    vConexao.ExecSQL(
      'INSERT INTO equipe (par_id, equ_numero, equ_nome) VALUES (:par, :num, :nome)',
      [aPartida.Id, vEquipe.Numero, vEquipe.Nome]);

  for I := 0 to High(aPartida.Mesa) do
    vConexao.ExecSQL(
      'INSERT INTO partida_jogador (par_id, jgd_id, equ_numero, pj_posicao) ' +
      'VALUES (:par, :jgd, :equ, :pos)',
      [aPartida.Id, aPartida.Mesa[I].Id, aPartida.Mesa[I].Equipe, I + 1]);
end;

class function TPartidaRepository.Carregar(aId: Integer): TPartida;
var
  vQry: TFDQuery;
begin
  Result := Default(TPartida);
  vQry := TConexao.NovaQuery(
    'SELECT par_id, par_qt_jogadores, par_meta, par_status, par_inicio, par_fim, ' +
    '       par_dealer_inicial, par_equipe_vencedora ' +
    '  FROM partida WHERE par_id = :id');
  try
    vQry.ParamByName('id').AsInteger := aId;
    vQry.Open;
    if vQry.IsEmpty then
      raise EIMakerValidacao.Create('Partida não encontrada.');

    Result.Id := vQry.FieldByName('par_id').AsInteger;
    Result.QtJogadores := vQry.FieldByName('par_qt_jogadores').AsInteger;
    Result.Meta := vQry.FieldByName('par_meta').AsInteger;
    if vQry.FieldByName('par_status').AsString = STATUS_BANCO[spFinalizada] then
      Result.Status := spFinalizada
    else
      Result.Status := spEmAndamento;
    Result.Inicio := vQry.FieldByName('par_inicio').AsDateTime;
    Result.Fim := vQry.FieldByName('par_fim').AsDateTime;
    Result.DealerInicialId := vQry.FieldByName('par_dealer_inicial').AsInteger;
    Result.EquipeVencedora := vQry.FieldByName('par_equipe_vencedora').AsInteger;
  finally
    vQry.Free;
  end;

  CarregarEquipesEMesa(Result);
  CarregarRodadas(Result);
end;

class procedure TPartidaRepository.CarregarEquipesEMesa(var aPartida: TPartida);
var
  vQry: TFDQuery;
  vEquipes: TList<TEquipe>;
  vMesa: TList<TJogador>;
  vEquipe: TEquipe;
  vJogador: TJogador;
  I: Integer;
begin
  vEquipes := TList<TEquipe>.Create;
  vMesa := TList<TJogador>.Create;
  vQry := TConexao.NovaQuery('');
  try
    vQry.SQL.Text := 'SELECT equ_numero, equ_nome FROM equipe WHERE par_id = :id ORDER BY equ_numero';
    vQry.ParamByName('id').AsInteger := aPartida.Id;
    vQry.Open;
    while not vQry.Eof do
    begin
      vEquipe := Default(TEquipe);
      vEquipe.Numero := vQry.FieldByName('equ_numero').AsInteger;
      vEquipe.Nome := vQry.FieldByName('equ_nome').AsString;
      vEquipes.Add(vEquipe);
      vQry.Next;
    end;
    vQry.Close;

    vQry.SQL.Text :=
      'SELECT j.jgd_id, j.jgd_nome, j.jgd_ativo, pj.equ_numero ' +
      '  FROM partida_jogador pj ' +
      '  JOIN jogador j ON j.jgd_id = pj.jgd_id ' +
      ' WHERE pj.par_id = :id ' +
      ' ORDER BY pj.pj_posicao';
    vQry.ParamByName('id').AsInteger := aPartida.Id;
    vQry.Open;
    while not vQry.Eof do
    begin
      vJogador.Id := vQry.FieldByName('jgd_id').AsInteger;
      vJogador.Nome := vQry.FieldByName('jgd_nome').AsString;
      vJogador.Ativo := vQry.FieldByName('jgd_ativo').AsInteger = 1;
      vJogador.Equipe := vQry.FieldByName('equ_numero').AsInteger;
      vMesa.Add(vJogador);
      vQry.Next;
    end;

    aPartida.Equipes := vEquipes.ToArray;
    aPartida.Mesa := vMesa.ToArray;

    { Jogadores de cada equipe, na ordem da mesa }
    for I := 0 to High(aPartida.Equipes) do
      for vJogador in aPartida.Mesa do
        if vJogador.Equipe = aPartida.Equipes[I].Numero then
          aPartida.Equipes[I].Jogadores := aPartida.Equipes[I].Jogadores + [vJogador];
  finally
    vQry.Free;
    vMesa.Free;
    vEquipes.Free;
  end;
end;

class procedure TPartidaRepository.CarregarRodadas(var aPartida: TPartida);
var
  vQry: TFDQuery;
  vRodadas: TList<TRodada>;
  vRodada: TRodada;
  vIdAtual, vEquipe: Integer;
begin
  vRodadas := TList<TRodada>.Create;
  vQry := TConexao.NovaQuery(
    'SELECT r.rod_id, r.rod_numero, r.rod_dealer, r.rod_data, ' +
    '       COALESCE(j.jgd_nome, '''') AS dealer_nome, ' +
    '       rp.equ_numero, COALESCE(rp.rp_pontos, 0) AS rp_pontos ' +
    '  FROM rodada r ' +
    '  LEFT JOIN jogador j ON j.jgd_id = r.rod_dealer ' +
    '  LEFT JOIN rodada_ponto rp ON rp.rod_id = r.rod_id ' +
    ' WHERE r.par_id = :id ' +
    ' ORDER BY r.rod_numero, rp.equ_numero');
  try
    vQry.ParamByName('id').AsInteger := aPartida.Id;
    vQry.Open;

    vIdAtual := -1;
    vRodada := Default(TRodada);
    while not vQry.Eof do
    begin
      if vQry.FieldByName('rod_id').AsInteger <> vIdAtual then
      begin
        if vIdAtual <> -1 then
          vRodadas.Add(vRodada);
        vIdAtual := vQry.FieldByName('rod_id').AsInteger;
        vRodada := Default(TRodada);
        vRodada.Id := vIdAtual;
        vRodada.Numero := vQry.FieldByName('rod_numero').AsInteger;
        vRodada.DealerId := vQry.FieldByName('rod_dealer').AsInteger;
        vRodada.DealerNome := vQry.FieldByName('dealer_nome').AsString;
        vRodada.Data := vQry.FieldByName('rod_data').AsDateTime;
        SetLength(vRodada.Pontos, aPartida.QtEquipes);
      end;

      vEquipe := vQry.FieldByName('equ_numero').AsInteger;
      if (vEquipe >= 1) and (vEquipe <= Length(vRodada.Pontos)) then
        vRodada.Pontos[vEquipe - 1] := vQry.FieldByName('rp_pontos').AsInteger;

      vQry.Next;
    end;
    if vIdAtual <> -1 then
      vRodadas.Add(vRodada);

    aPartida.Rodadas := vRodadas.ToArray;
  finally
    vQry.Free;
    vRodadas.Free;
  end;
end;

class function TPartidaRepository.Existe(aId: Integer): Boolean;
begin
  Result := TConexao.Get.ExecSQLScalar('SELECT COUNT(*) FROM partida WHERE par_id = :id', [aId]) > 0;
end;

class function TPartidaRepository.ListarIds: TArray<Integer>;
var
  vQry: TFDQuery;
  vLista: TList<Integer>;
begin
  vLista := TList<Integer>.Create;
  vQry := TConexao.NovaQuery('SELECT par_id FROM partida ORDER BY par_inicio DESC, par_id DESC');
  try
    vQry.Open;
    while not vQry.Eof do
    begin
      vLista.Add(vQry.Fields[0].AsInteger);
      vQry.Next;
    end;
    Result := vLista.ToArray;
  finally
    vQry.Free;
    vLista.Free;
  end;
end;

class function TPartidaRepository.IdEmAndamento: Integer;
var
  vValor: Variant;
begin
  vValor := TConexao.Get.ExecSQLScalar(
    'SELECT par_id FROM partida WHERE par_status = :st ORDER BY par_inicio DESC, par_id DESC LIMIT 1',
    [STATUS_BANCO[spEmAndamento]]);
  if VarIsNull(vValor) or VarIsEmpty(vValor) then
    Result := 0
  else
    Result := vValor;
end;

class procedure TPartidaRepository.AtualizarStatus(const aPartida: TPartida);
begin
  TConexao.Get.ExecSQL(
    'UPDATE partida SET par_status = :st, par_fim = :fim, par_equipe_vencedora = :venc ' +
    ' WHERE par_id = :id',
    [STATUS_BANCO[aPartida.Status], DataOuNulo(aPartida.Fim), aPartida.EquipeVencedora, aPartida.Id],
    [ftString, ftDateTime, ftInteger, ftInteger]);
end;

class procedure TPartidaRepository.Excluir(aId: Integer);
begin
  TConexao.EmTransacao(
    procedure
    var
      vConexao: TFDConnection;
    begin
      vConexao := TConexao.Get;
      vConexao.ExecSQL('DELETE FROM rodada_ponto WHERE rod_id IN (SELECT rod_id FROM rodada WHERE par_id = :id)', [aId]);
      vConexao.ExecSQL('DELETE FROM rodada WHERE par_id = :id', [aId]);
      vConexao.ExecSQL('DELETE FROM partida_jogador WHERE par_id = :id', [aId]);
      vConexao.ExecSQL('DELETE FROM equipe WHERE par_id = :id', [aId]);
      vConexao.ExecSQL('DELETE FROM partida WHERE par_id = :id', [aId]);
    end);
end;

class procedure TPartidaRepository.GravarPontos(aRodadaId: Integer; const aPontos: TArray<Integer>);
var
  I: Integer;
begin
  TConexao.Get.ExecSQL('DELETE FROM rodada_ponto WHERE rod_id = :id', [aRodadaId]);
  for I := 0 to High(aPontos) do
    TConexao.Get.ExecSQL(
      'INSERT INTO rodada_ponto (rod_id, equ_numero, rp_pontos) VALUES (:rod, :equ, :pts)',
      [aRodadaId, I + 1, aPontos[I]]);
end;

class function TPartidaRepository.InserirRodada(aPartidaId, aNumero, aDealerId: Integer;
  const aPontos: TArray<Integer>): Integer;
var
  vId: Integer;
begin
  vId := 0;
  TConexao.EmTransacao(
    procedure
    begin
      TConexao.Get.ExecSQL(
        'INSERT INTO rodada (par_id, rod_numero, rod_dealer, rod_data) VALUES (:par, :num, :dealer, :data)',
        [aPartidaId, aNumero, aDealerId, Now]);
      vId := TConexao.Get.GetLastAutoGenValue('');
      GravarPontos(vId, aPontos);
    end);
  Result := vId;
end;

class procedure TPartidaRepository.AtualizarRodada(aRodadaId, aDealerId: Integer;
  const aPontos: TArray<Integer>);
begin
  TConexao.EmTransacao(
    procedure
    begin
      TConexao.Get.ExecSQL('UPDATE rodada SET rod_dealer = :dealer WHERE rod_id = :id', [aDealerId, aRodadaId]);
      GravarPontos(aRodadaId, aPontos);
    end);
end;

class procedure TPartidaRepository.ExcluirRodada(aPartidaId, aRodadaId: Integer);
begin
  TConexao.EmTransacao(
    procedure
    var
      vNumero: Integer;
    begin
      vNumero := TConexao.Get.ExecSQLScalar('SELECT rod_numero FROM rodada WHERE rod_id = :id', [aRodadaId]);
      TConexao.Get.ExecSQL('DELETE FROM rodada_ponto WHERE rod_id = :id', [aRodadaId]);
      TConexao.Get.ExecSQL('DELETE FROM rodada WHERE rod_id = :id', [aRodadaId]);
      { Renumera as rodadas seguintes para não deixar buraco na sequência }
      TConexao.Get.ExecSQL(
        'UPDATE rodada SET rod_numero = rod_numero - 1 WHERE par_id = :par AND rod_numero > :num',
        [aPartidaId, vNumero]);
    end);
end;

end.
