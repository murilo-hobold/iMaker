unit uFuncoes;

interface

uses
    System.SysUtils, System.Types, System.UITypes, System.Classes,
    System.Variants, System.StrUtils, FireDAC.Comp.Client;

procedure ExecutaQueryBaseCtrl(vQuery :string);
function f_GetStrSQLBase(vTabela, vCampo, vWhere :String) :String;
function f_GetHrAtualInt : Integer;
function f_SecondToTime(pSegundos :Cardinal; pHora, pMin, pSeg :Boolean) : String;
function f_GetQtdEquipes(pQtJogadores :Integer):Integer;

implementation

uses udm;

procedure ExecutaQueryBaseCtrl(vQuery :string);
var
  vqr :TFDQuery;
begin
  try
    vqr := dm.queryCtrl(vQuery);
    vqr.execsql;
  finally
    FreeAndNil(vqr);
  end;
end;

function f_GetStrSQLBase(vTabela, vCampo, vWhere :String) :String;
var
    vqr :TFDQuery;
begin
    try
        vqr := dm.queryCtrl('SELECT '+ vCampo + ' AS '+ QuotedStr('CAMPO') + ' ' +
                            '  FROM '+ vTabela + ' ' +
                            ' WHERE '+ vWhere);
        vqr.Open;
        if vqr.RowsAffected > 0 then begin
            Result := vqr.FieldByName('CAMPO').AsString;
        end;
    finally
        FreeAndNil(vqr);
    end;
end;

function f_GetHrAtualInt : Integer;
var
   vhora : String;
   vhh : Integer;
   vmm : Integer;
   vss : Integer;
begin
     vhora := TimeToStr(now);

     //copy(origem,a partir, qtd de caracteres)
     vhh := StrToInt(Copy(vhora,length(vhora)-7,2));
     vmm := StrToInt(Copy(vhora,length(vhora)-4,2));
     vss := StrToInt(Copy(vhora,length(vhora)-1,2));

     vhh := vhh * 3600;
     vmm := vmm * 60;

     Result := vhh + vmm + vss;
end;

function f_SecondToTime(pSegundos :Cardinal; pHora, pMin, pSeg :Boolean) : String;
var
  vSeg, vMin, vHora: Cardinal;
begin
  vHora := pSegundos div 3600;
  vSeg  := pSegundos mod 3600;
  vMin  := vSeg div 60;
  vSeg  := vSeg mod 60;

  Result := IfThen(pHora, FormatFloat(',00', vHora), '') +
            IfThen(pMin,  ':' + FormatFloat('00',  vMin), '') +
            IfThen(pSeg,  ':' + FormatFloat('00',  vSeg), '');
end;

function f_GetIdJogo :Integer;
var
    vqr :TFDQuery;
begin
    try
      vqr := dm.queryCtrl('select ');
      vqr.execsql;
    finally
      FreeAndNil(vqr);
    end;
end;

function f_GetQtdEquipes(pQtJogadores :Integer):Integer;
begin
    if pQtJogadores = 3 then begin
        Result := 3;
    end else begin
        Result := 2;
    end;
end;

end.
