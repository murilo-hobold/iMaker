unit iMaker.Repository.Config;

{ Configurações chave/valor do aplicativo. }

interface

uses
  System.SysUtils, System.Variants, iMaker.Infra.Conexao;

type
  TConfigRepository = class
  public
    class function Ler(const aChave, aPadrao: string): string; static;
    class procedure Gravar(const aChave, aValor: string); static;
  end;

implementation

{ TConfigRepository }

class function TConfigRepository.Ler(const aChave, aPadrao: string): string;
var
  vValor: Variant;
begin
  vValor := TConexao.Get.ExecSQLScalar('SELECT cfg_valor FROM config WHERE cfg_chave = :c', [aChave]);
  if VarIsNull(vValor) or VarIsEmpty(vValor) then
    Result := aPadrao
  else
    Result := VarToStr(vValor);
end;

class procedure TConfigRepository.Gravar(const aChave, aValor: string);
begin
  TConexao.Get.ExecSQL('INSERT OR REPLACE INTO config (cfg_chave, cfg_valor) VALUES (:c, :v)', [aChave, aValor]);
end;

end.
