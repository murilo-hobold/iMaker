unit iMaker.Repository.Estatistica;

{ Consultas de estatísticas e ranking (somente partidas finalizadas). }

interface

uses
  System.SysUtils, System.Generics.Collections, Data.DB, FireDAC.Comp.Client,
  iMaker.Model.Entidades, iMaker.Infra.Conexao;

type
  TEstatisticaRepository = class
  public
    class function PorJogador: TArray<TEstatisticaJogador>; static;
    class procedure ResumoGeral(out aPartidas, aRodadas: Integer); static;
  end;

implementation

{ TEstatisticaRepository }

class function TEstatisticaRepository.PorJogador: TArray<TEstatisticaJogador>;
var
  vQry: TFDQuery;
  vLista: TList<TEstatisticaJogador>;
  vItem: TEstatisticaJogador;
begin
  vLista := TList<TEstatisticaJogador>.Create;
  vQry := TConexao.NovaQuery(
    'SELECT j.jgd_id, j.jgd_nome, j.jgd_ativo, ' +
    '       COUNT(p.par_id) AS partidas, ' +
    '       COALESCE(SUM(CASE WHEN p.par_equipe_vencedora = pj.equ_numero THEN 1 ELSE 0 END), 0) AS vitorias, ' +
    '       COALESCE(AVG(t.total), 0) AS media, ' +
    '       COALESCE(MAX(t.melhor), 0) AS melhor ' +
    '  FROM jogador j ' +
    '  LEFT JOIN partida_jogador pj ON pj.jgd_id = j.jgd_id ' +
    '  LEFT JOIN partida p ON p.par_id = pj.par_id AND p.par_status = ''F'' ' +
    '  LEFT JOIN (SELECT r.par_id, rp.equ_numero, ' +
    '                    SUM(rp.rp_pontos) AS total, MAX(rp.rp_pontos) AS melhor ' +
    '               FROM rodada r ' +
    '               JOIN rodada_ponto rp ON rp.rod_id = r.rod_id ' +
    '              GROUP BY r.par_id, rp.equ_numero) t ' +
    '         ON t.par_id = p.par_id AND t.equ_numero = pj.equ_numero ' +
    ' WHERE j.jgd_ativo = 1 OR p.par_id IS NOT NULL ' +
    ' GROUP BY j.jgd_id, j.jgd_nome, j.jgd_ativo');
  try
    vQry.Open;
    while not vQry.Eof do
    begin
      vItem := Default(TEstatisticaJogador);
      vItem.Jogador.Id := vQry.FieldByName('jgd_id').AsInteger;
      vItem.Jogador.Nome := vQry.FieldByName('jgd_nome').AsString;
      vItem.Jogador.Ativo := vQry.FieldByName('jgd_ativo').AsInteger = 1;
      vItem.Partidas := vQry.FieldByName('partidas').AsInteger;
      vItem.Vitorias := vQry.FieldByName('vitorias').AsInteger;
      vItem.MediaPontos := vQry.FieldByName('media').AsFloat;
      vItem.MelhorRodada := vQry.FieldByName('melhor').AsInteger;
      vLista.Add(vItem);
      vQry.Next;
    end;
    Result := vLista.ToArray;
  finally
    vQry.Free;
    vLista.Free;
  end;
end;

class procedure TEstatisticaRepository.ResumoGeral(out aPartidas, aRodadas: Integer);
begin
  aPartidas := TConexao.Get.ExecSQLScalar('SELECT COUNT(*) FROM partida WHERE par_status = ''F''');
  aRodadas := TConexao.Get.ExecSQLScalar(
    'SELECT COUNT(*) FROM rodada r JOIN partida p ON p.par_id = r.par_id WHERE p.par_status = ''F''');
end;

end.
