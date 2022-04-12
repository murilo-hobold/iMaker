unit udm;

interface

uses
  System.SysUtils, System.IOUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  System.StrUtils, System.Types, Fmx.Dialogs,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.UI;

type
  Tdm = class(TDataModule)
    FDConCtrl: TFDConnection;
    FDQryJogador1: TFDQuery;
    FDQryJogador1jgd_codigo: TWideMemoField;
    FDQryJogador1jgd_nome: TWideMemoField;
    FDQryJogador2: TFDQuery;
    FDQryJogador3: TFDQuery;
    FDQryJogador4: TFDQuery;
    FDQryJogador5: TFDQuery;
    FDQryJogador6: TFDQuery;
    FDQryJogador2jgd_codigo: TWideMemoField;
    FDQryJogador2jgd_nome: TWideMemoField;
    FDQryJogador3jgd_codigo: TWideMemoField;
    FDQryJogador3jgd_nome: TWideMemoField;
    FDQryJogador4jgd_codigo: TWideMemoField;
    FDQryJogador4jgd_nome: TWideMemoField;
    FDQryJogador5jgd_codigo: TWideMemoField;
    FDQryJogador5jgd_nome: TWideMemoField;
    FDQryJogador6jgd_codigo: TWideMemoField;
    FDQryJogador6jgd_nome: TWideMemoField;
    procedure FDConCtrlAfterConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure addfields(vtb, vcampo, vtipo: string);
    { Private declarations }
  public
    function queryCtrl(vsql: string): TFDQuery;
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

function Tdm.queryCtrl (vsql: string): TFDQuery;
begin
  result := TFDQuery.Create(nil);
  result.Connection := FDConCtrl;
  result.SQL.Add(vsql);
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
    if FDConCtrl.Connected = true
    then FDConCtrl.Connected := false;

{$IF DEFINED(iOS) or DEFINED(android)}
    FDConCtrl.Params.Values['DataBase'] := TPath.Combine(TPath.GetDocumentsPath,'basectrl.db');
{$ENDIF}

{$IF DEFINED (MSWINDOWS)}
    FDConCtrl.Params.Values['DataBase'] := 'basectrl.db';
{$ENDIF}

    FDConCtrl.Connected := true;
end;

procedure Tdm.FDConCtrlAfterConnect(Sender: TObject);
begin
    //=== Aqui cria as tabelas ===
    FDConCtrl.ExecSQL('CREATE TABLE IF NOT EXISTS padjogo ('  +
                      'pjg_id       INTEGER PRIMARY KEY AUTOINCREMENT, '+
                      'pjg_qtplayer INTEGER,' +
                      'pjg_equipe1  TEXT,' +
                      'pjg_equipe2  TEXT,' +
                      'pjg_equipe3  TEXT,' +
                      'pjg_player1  TEXT,' +
                      'pjg_player2  TEXT,' +
                      'pjg_player3  TEXT,' +
                      'pjg_player4  TEXT,' +
                      'pjg_player5  TEXT,' +
                      'pjg_player6  TEXT,' +
                      'jog_id       INTEGER,' +
                      'pjg_data     DATE DEFAULT (datetime('+QuotedStr('now') + ',' + QuotedStr('localtime') + ')))');

    FDConCtrl.ExecSQL('CREATE TABLE IF NOT EXISTS jogo ('  +
                      'jog_id       INTEGER PRIMARY KEY,' +
                      'jog_qtplayer INTEGER,' +
                      'jog_equipe1  TEXT,' +
                      'jog_equipe2  TEXT,' +
                      'jog_equipe3  TEXT,' +
                      'jog_player1  TEXT,' +
                      'jog_player2  TEXT,' +
                      'jog_player3  TEXT,' +
                      'jog_player4  TEXT,' +
                      'jog_player5  TEXT,' +
                      'jog_player6  TEXT,' +
                      'jog_data     DATE DEFAULT (datetime('+QuotedStr('now') + ',' + QuotedStr('localtime') + ')))');

    FDConCtrl.ExecSQL('CREATE TABLE IF NOT EXISTS jogador ('  +
                      'jgd_codigo TEXT PRIMARY KEY,' +
                      'jgd_nome   TEXT,' +
                      'jog_data   DATE DEFAULT (datetime('+QuotedStr('now') + ',' + QuotedStr('localtime') + ')))');

    FDConCtrl.ExecSQL('CREATE TABLE IF NOT EXISTS rodada ('  +
                      'jog_id       INTEGER,' +
                      'rod_id       INTEGER,' +
                      'rod_ponteq1  FLOAT,' +
                      'rod_ponteq2  FLOAT,' +
                      'rod_ponteq3  FLOAT,' +
                      'rod_data     DATE DEFAULT (datetime('+QuotedStr('now') + ',' + QuotedStr('localtime') + ')), ' +
                      'primary key ( jog_id, rod_id))');
end;

procedure Tdm.addfields(vtb, vcampo, vtipo: string);
var vq: TFDQuery;
begin
    try
        vq := queryCtrl('select ' + vcampo + ' from ' + vtb);
        vq.Open;
        vq.Close;
    except
        vq := queryCtrl('alter table ' + vtb + ' add column ' + vcampo + ' ' + vtipo + ';');
        vq.execsql;
        vq.Close;
    end;
    FreeAndNil(vq);
end;

end.
