unit iMaker.Infra.Conexao;

{ Conexão SQLite (FireDAC) e criação/migração da estrutura do banco. }

interface

uses
  System.SysUtils, System.IOUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Comp.UI, Data.DB;

type
  TConexao = class
  strict private
    class var FConexao: TFDConnection;
    class function CaminhoBanco: string; static;
    class procedure Migrar; static;
    class procedure CriarVersao1; static;
  public
    class destructor Destroy;
    class function Get: TFDConnection; static;
    class function NovaQuery(const aSQL: string): TFDQuery; static;
    { Executa aProc dentro de uma transação (commit/rollback automático). }
    class procedure EmTransacao(const aProc: TProc); static;
  end;

implementation

const
  VERSAO_BANCO = 1;

{ TConexao }

class function TConexao.CaminhoBanco: string;
begin
{$IF DEFINED(ANDROID) or DEFINED(IOS)}
  Result := TPath.Combine(TPath.GetDocumentsPath, 'imaker.db');
{$ELSE}
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'imaker.db');
{$ENDIF}
end;

class function TConexao.Get: TFDConnection;
begin
  if not Assigned(FConexao) then
  begin
    FConexao := TFDConnection.Create(nil);
    FConexao.LoginPrompt := False;
    FConexao.DriverName := 'SQLite';
    FConexao.Params.Values['Database'] := CaminhoBanco;
    FConexao.Params.Values['OpenMode'] := 'CreateUTF8';
    FConexao.Params.Values['LockingMode'] := 'Normal';
    FConexao.Params.Values['StringFormat'] := 'Unicode';
    FConexao.FormatOptions.StrsTrim2Len := True;
    FConexao.Connected := True;
    FConexao.ExecSQL('PRAGMA foreign_keys = ON');
    Migrar;
  end;
  Result := FConexao;
end;

class destructor TConexao.Destroy;
begin
  FreeAndNil(FConexao);
end;

class function TConexao.NovaQuery(const aSQL: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Get;
  Result.SQL.Text := aSQL;
end;

class procedure TConexao.EmTransacao(const aProc: TProc);
var
  vConexao: TFDConnection;
begin
  vConexao := Get;
  vConexao.StartTransaction;
  try
    aProc();
    vConexao.Commit;
  except
    vConexao.Rollback;
    raise;
  end;
end;

class procedure TConexao.Migrar;
var
  vVersao: Integer;
begin
  vVersao := FConexao.ExecSQLScalar('PRAGMA user_version');
  if vVersao < 1 then
    CriarVersao1;
  { Próximas versões: if vVersao < 2 then CriarVersao2; ... }
  if vVersao < VERSAO_BANCO then
    FConexao.ExecSQL('PRAGMA user_version = ' + IntToStr(VERSAO_BANCO));
end;

class procedure TConexao.CriarVersao1;
begin
  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS config (' +
    '  cfg_chave VARCHAR(40) PRIMARY KEY,' +
    '  cfg_valor VARCHAR(200))');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS jogador (' +
    '  jgd_id     INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  jgd_nome   VARCHAR(60) NOT NULL,' +
    '  jgd_ativo  INTEGER NOT NULL DEFAULT 1,' +
    '  jgd_criado DATETIME)');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS partida (' +
    '  par_id               INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  par_qt_jogadores     INTEGER NOT NULL,' +
    '  par_meta             INTEGER NOT NULL,' +
    '  par_status           VARCHAR(1) NOT NULL DEFAULT ''A'',' +
    '  par_inicio           DATETIME,' +
    '  par_fim              DATETIME,' +
    '  par_dealer_inicial   INTEGER,' +
    '  par_equipe_vencedora INTEGER NOT NULL DEFAULT 0)');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS equipe (' +
    '  par_id     INTEGER NOT NULL REFERENCES partida(par_id) ON DELETE CASCADE,' +
    '  equ_numero INTEGER NOT NULL,' +
    '  equ_nome   VARCHAR(40) NOT NULL,' +
    '  PRIMARY KEY (par_id, equ_numero))');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS partida_jogador (' +
    '  par_id     INTEGER NOT NULL REFERENCES partida(par_id) ON DELETE CASCADE,' +
    '  jgd_id     INTEGER NOT NULL REFERENCES jogador(jgd_id),' +
    '  equ_numero INTEGER NOT NULL,' +
    '  pj_posicao INTEGER NOT NULL,' +
    '  PRIMARY KEY (par_id, jgd_id))');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS rodada (' +
    '  rod_id     INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  par_id     INTEGER NOT NULL REFERENCES partida(par_id) ON DELETE CASCADE,' +
    '  rod_numero INTEGER NOT NULL,' +
    '  rod_dealer INTEGER,' +
    '  rod_data   DATETIME)');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS rodada_ponto (' +
    '  rod_id     INTEGER NOT NULL REFERENCES rodada(rod_id) ON DELETE CASCADE,' +
    '  equ_numero INTEGER NOT NULL,' +
    '  rp_pontos  INTEGER NOT NULL DEFAULT 0,' +
    '  PRIMARY KEY (rod_id, equ_numero))');

  FConexao.ExecSQL('CREATE INDEX IF NOT EXISTS idx_rodada_partida ON rodada (par_id, rod_numero)');
  FConexao.ExecSQL('CREATE INDEX IF NOT EXISTS idx_pj_jogador ON partida_jogador (jgd_id)');
end;

end.
