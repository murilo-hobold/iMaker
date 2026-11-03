unit iMaker.Repository.Jogador;

{ Acesso a dados da tabela jogador. }

interface

uses
  System.SysUtils, System.Generics.Collections, Data.DB, FireDAC.Comp.Client,
  iMaker.Model.Entidades, iMaker.Infra.Conexao;

type
  TJogadorRepository = class
  strict private
    class function LerJogador(aDataSet: TDataSet): TJogador; static;
  public
    class function Listar(aSomenteAtivos: Boolean = True): TArray<TJogador>; static;
    class function Buscar(aId: Integer): TJogador; static;
    class function ExisteNome(const aNome: string; aIgnorarId: Integer): Boolean; static;
    class function Inserir(const aNome: string): Integer; static;
    class procedure Atualizar(aId: Integer; const aNome: string); static;
    class function PossuiPartidas(aId: Integer): Boolean; static;
    class procedure Inativar(aId: Integer); static;
    class procedure Excluir(aId: Integer); static;
  end;

implementation

{ TJogadorRepository }

class function TJogadorRepository.LerJogador(aDataSet: TDataSet): TJogador;
begin
  Result.Id := aDataSet.FieldByName('jgd_id').AsInteger;
  Result.Nome := aDataSet.FieldByName('jgd_nome').AsString;
  Result.Ativo := aDataSet.FieldByName('jgd_ativo').AsInteger = 1;
end;

class function TJogadorRepository.Listar(aSomenteAtivos: Boolean): TArray<TJogador>;
var
  vQry: TFDQuery;
  vLista: TList<TJogador>;
begin
  vLista := TList<TJogador>.Create;
  vQry := TConexao.NovaQuery(
    'SELECT jgd_id, jgd_nome, jgd_ativo FROM jogador ' +
    ' WHERE (:todos = 1) OR (jgd_ativo = 1) ' +
    ' ORDER BY jgd_nome COLLATE NOCASE');
  try
    vQry.ParamByName('todos').AsInteger := Ord(not aSomenteAtivos);
    vQry.Open;
    while not vQry.Eof do
    begin
      vLista.Add(LerJogador(vQry));
      vQry.Next;
    end;
    Result := vLista.ToArray;
  finally
    vQry.Free;
    vLista.Free;
  end;
end;

class function TJogadorRepository.Buscar(aId: Integer): TJogador;
var
  vQry: TFDQuery;
begin
  Result := TJogador.Vazio;
  vQry := TConexao.NovaQuery('SELECT jgd_id, jgd_nome, jgd_ativo FROM jogador WHERE jgd_id = :id');
  try
    vQry.ParamByName('id').AsInteger := aId;
    vQry.Open;
    if not vQry.IsEmpty then
      Result := LerJogador(vQry);
  finally
    vQry.Free;
  end;
end;

class function TJogadorRepository.ExisteNome(const aNome: string; aIgnorarId: Integer): Boolean;
begin
  Result := TConexao.Get.ExecSQLScalar(
    'SELECT COUNT(*) FROM jogador ' +
    ' WHERE jgd_ativo = 1 AND UPPER(jgd_nome) = UPPER(:nome) AND jgd_id <> :id',
    [aNome, aIgnorarId]) > 0;
end;

class function TJogadorRepository.Inserir(const aNome: string): Integer;
begin
  TConexao.Get.ExecSQL(
    'INSERT INTO jogador (jgd_nome, jgd_ativo, jgd_criado) VALUES (:nome, 1, :criado)',
    [aNome, Now]);
  Result := TConexao.Get.GetLastAutoGenValue('');
end;

class procedure TJogadorRepository.Atualizar(aId: Integer; const aNome: string);
begin
  TConexao.Get.ExecSQL('UPDATE jogador SET jgd_nome = :nome WHERE jgd_id = :id', [aNome, aId]);
end;

class function TJogadorRepository.PossuiPartidas(aId: Integer): Boolean;
begin
  Result := TConexao.Get.ExecSQLScalar(
    'SELECT COUNT(*) FROM partida_jogador WHERE jgd_id = :id', [aId]) > 0;
end;

class procedure TJogadorRepository.Inativar(aId: Integer);
begin
  TConexao.Get.ExecSQL('UPDATE jogador SET jgd_ativo = 0 WHERE jgd_id = :id', [aId]);
end;

class procedure TJogadorRepository.Excluir(aId: Integer);
begin
  TConexao.Get.ExecSQL('DELETE FROM jogador WHERE jgd_id = :id', [aId]);
end;

end.
