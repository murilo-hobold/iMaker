unit frmConfJogo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  frmModelo1, FMX.Controls.Presentation,
  FMX.Layouts, FMX.Edit, FMX.Objects, FMX.ListBox, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.StorageBin, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Async, FireDAC.DApt,
  System.Actions, FMX.ActnList, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, Router4D, Router4D.Interfaces, Router4D.Props;

type
  TFormConfJogo = class(TFormModelo1, iRouter4DComponent)
    FDMemQtJogador: TFDMemTable;
    FDMemQtJogadorqtJogador: TIntegerField;
    FDMemQtJogadorDescricao: TStringField;
    FDQryPadJogo: TFDQuery;
    FDQryPadJogopjg_qtplayer: TIntegerField;
    FDQryPadJogopjg_player1: TWideMemoField;
    FDQryPadJogopjg_player2: TWideMemoField;
    FDQryPadJogopjg_player3: TWideMemoField;
    FDQryPadJogopjg_player4: TWideMemoField;
    FDQryPadJogopjg_player5: TWideMemoField;
    FDQryPadJogopjg_player6: TWideMemoField;
    FDQryPadJogopjg_Data: TDateField;
    FDQryPadJogopjg_equipe1: TWideMemoField;
    FDQryPadJogopjg_equipe2: TWideMemoField;
    FDQryPadJogopjg_equipe3: TWideMemoField;
    BindSrcDBQtJogador: TBindSourceDB;
    BindList: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    BindSrcDBPadJogo: TBindSourceDB;
    lbPadraoJogo: TListBox;
    lbiPadJogo30: TListBoxItem;
    cbbJogador: TComboBox;
    lbiPadJogo35: TListBoxItem;
    lbSetEquipes: TListBox;
    lbi10Equipe1: TListBoxItem;
    Rectangle10: TRectangle;
    edtEquipe1: TEdit;
    lbi20Equipe2: TListBoxItem;
    Rectangle11: TRectangle;
    edtEquipe2: TEdit;
    lbi30Equipe3: TListBoxItem;
    Rectangle12: TRectangle;
    edtEquipe3: TEdit;
    lbiPadJogo40: TListBoxItem;
    lbSetJogadores: TListBox;
    lbi10Jogador1: TListBoxItem;
    RectangleJogador1: TRectangle;
    lbi20Jogador2: TListBoxItem;
    RectangleJogador2: TRectangle;
    lbi30Jogador3: TListBoxItem;
    RectangleJogador3: TRectangle;
    lbi40Jogador4: TListBoxItem;
    RectangleJogador4: TRectangle;
    lbi50Jogador5: TListBoxItem;
    RectangleJogador5: TRectangle;
    lbi60Jogador6: TListBoxItem;
    RectangleJogador6: TRectangle;
    lbiPadJogo50: TListBoxItem;
    RectJogar: TRectangle;
    btnJogar: TSpeedButton;
    LinkFillControlToField2: TLinkFillControlToField;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField7: TLinkControlToField;
    Rectangle1: TRectangle;
    lbBotoes: TListBox;
    lbiNovJogo: TListBoxItem;
    lbiVoltarAoJogo: TListBoxItem;
    RectVoltarAoJogo: TRectangle;
    btnVoltarAoJogo: TSpeedButton;
    FDQryPadJogojog_id: TIntegerField;
    FDQryJogo: TFDQuery;
    FDQryJogojog_id: TIntegerField;
    FDQryJogojog_qtplayer: TIntegerField;
    FDQryJogojog_equipe1: TWideMemoField;
    FDQryJogojog_equipe2: TWideMemoField;
    FDQryJogojog_equipe3: TWideMemoField;
    FDQryJogojog_player1: TWideMemoField;
    FDQryJogojog_player2: TWideMemoField;
    FDQryJogojog_player3: TWideMemoField;
    FDQryJogojog_player4: TWideMemoField;
    FDQryJogojog_player5: TWideMemoField;
    FDQryJogojog_player6: TWideMemoField;
    FDQryJogojog_data: TDateField;
    actVoltarAoJogo: TAction;
    actSalvar: TAction;
    cbbPlayer1: TComboBox;
    BindSrcDBJogador1: TBindSourceDB;
    LinkFillControlToField3: TLinkFillControlToField;
    cbbJogador2: TComboBox;
    BindSrcDBJogador2: TBindSourceDB;
    cbbPlayer3: TComboBox;
    BindSrcDBJogador3: TBindSourceDB;
    LinkFillControlToField5: TLinkFillControlToField;
    cbbPlayer4: TComboBox;
    BindSrcDBJogador4: TBindSourceDB;
    LinkFillControlToField6: TLinkFillControlToField;
    cbbPlayer5: TComboBox;
    cbbPlayer6: TComboBox;
    BindSrcDBJogador5: TBindSourceDB;
    LinkFillControlToField7: TLinkFillControlToField;
    BindSrcDBJogador6: TBindSourceDB;
    LinkFillControlToField8: TLinkFillControlToField;
    LinkFillControlToField4: TLinkFillControlToField;
    procedure FDMemQtJogadorCalcFields(DataSet: TDataSet);
    procedure FDQryPadJogoNewRecord(DataSet: TDataSet);
    procedure FDQryPadJogopjg_qtplayerValidate(Sender: TField);
    procedure FDQryPadJogoAfterOpen(DataSet: TDataSet);
    procedure actSalvarExecute(Sender: TObject);
    procedure actVoltarAoJogoExecute(Sender: TObject);
  private
    procedure p_EquipPlayers(pQtJogadores: Integer);
    function f_GetIdJogo: Integer;

    { Private declarations }
  public
    function Render: TFMXObject;
    procedure UnRender;
    { Public declarations }
  end;

var
  FormConfJogo: TFormConfJogo;

implementation

{$R *.fmx}

uses udm, uFuncoes;

function TFormConfJogo.Render: TFMXObject;
begin
  with dm.FDQryJogador1 do begin
      Close;
      Open;
  end;
  with dm.FDQryJogador2 do begin
      Close;
      Open;
  end;
  with dm.FDQryJogador3 do begin
      Close;
      Open;
  end;
  with dm.FDQryJogador4 do begin
      Close;
      Open;
  end;
  with dm.FDQryJogador5 do begin
      Close;
      Open;
  end;
  with dm.FDQryJogador6 do begin
      Close;
      Open;
  end;


  with FDQryPadJogo do begin
      Close;
      Open;

      if isEmpty then begin
          Insert;
      end else begin
          Edit;
      end;
  end;
  Result := LayoutPrincipal;
end;

procedure TFormConfJogo.UnRender;
begin
  //
end;

procedure TFormConfJogo.actSalvarExecute(Sender: TObject);
begin
  inherited;
    try
        dm.FDConCtrl.StartTransaction;

        if (FDQryPadJogo.State in [dsEdit, dsInsert]) then begin
            FDQryPadJogo.Post;
        end;

        FDQryJogo.Close;
        FDQryJogo.Open;

        //-->>
        FDQryJogo.Insert;
        FDQryJogojog_id.Value       := f_GetIdJogo;
        FDQryJogojog_qtplayer.Value := FDQryPadJogopjg_qtplayer.Value;
        FDQryJogojog_equipe1.Value  := FDQryPadJogopjg_equipe1.Value;
        FDQryJogojog_equipe2.Value  := FDQryPadJogopjg_equipe2.Value;
        FDQryJogojog_equipe3.Value  := FDQryPadJogopjg_equipe3.Value;
        FDQryJogojog_player1.Value  := FDQryPadJogopjg_player1.Value;
        FDQryJogojog_player2.Value  := FDQryPadJogopjg_player2.Value;
        FDQryJogojog_player3.Value  := FDQryPadJogopjg_player3.Value;
        FDQryJogojog_player4.Value  := FDQryPadJogopjg_player4.Value;
        FDQryJogojog_player5.Value  := FDQryPadJogopjg_player5.Value;
        FDQryJogojog_player6.Value  := FDQryPadJogopjg_player6.Value;
        FDQryJogo.Post;

        FDQryPadJogo.Edit;
        FDQryPadJogojog_id.Value := FDQryJogojog_id.Value;
        FDQryPadJogo.Post;

        FDQryPadJogo.ApplyUpdates;
        FDQryJogo.ApplyUpdates;

        FDQryPadJogo.CommitUpdates;
        FDQryJogo.CommitUpdates;

        dm.FDConCtrl.Commit;

        //-->> Abre Tela Jogo
        TRouter4D.Link.&To('Jogo');
    except
        on E: Exception do
        begin
            dm.FDConCtrl.Rollback;

            raise Exception.Create('Ocorreu um problema ao salvar o jogo' + #13#10 +
                                   'Erro: ' + E.Message);
        end;
    end;
end;

procedure TFormConfJogo.actVoltarAoJogoExecute(Sender: TObject);
begin
  inherited;
  //-->> Abre Tela Jogo
  TRouter4D.Link.&To('Jogo');
end;

procedure TFormConfJogo.FDMemQtJogadorCalcFields(DataSet: TDataSet);
begin
  inherited;
    DataSet.FieldByName('Descricao').AsString := DataSet.FieldByName('qtJogador').AsString + ' Jogadores';
end;

procedure TFormConfJogo.FDQryPadJogoAfterOpen(DataSet: TDataSet);
begin
  inherited;
    if not(DataSet.FieldByName('pjg_qtplayer').isNull) then begin
        p_EquipPlayers(DataSet.FieldByName('pjg_qtplayer').Value);
    end;

    lbiVoltarAoJogo.Enabled := DataSet.FieldByName('jog_id').Value > 0;
end;

procedure TFormConfJogo.FDQryPadJogoNewRecord(DataSet: TDataSet);
begin
  inherited;
    DataSet.FieldByName('pjg_qtplayer').Value := 4;
    DataSet.FieldByName('pjg_equipe1').Value  := 'Lobos';
    DataSet.FieldByName('pjg_equipe2').Value  := 'Ursos';
    DataSet.FieldByName('pjg_equipe3').Value  := 'Leões';
    DataSet.FieldByName('jog_id').Value       := 0;
end;

procedure TFormConfJogo.FDQryPadJogopjg_qtplayerValidate(Sender: TField);
begin
  inherited;
    if not(TField(Sender).IsNull) then begin
        p_EquipPlayers(TField(Sender).Value);
    end;
end;

function TFormConfJogo.f_GetIdJogo :Integer;
const
    cSeqIni = 1;
var
    vq: TFDQuery;
begin
    try
        vq := dm.queryCtrl('select max(jogo.jog_id) as SEQ '+
                           '  from jogo ');
        vq.open;
        if (vq.RowsAffected > 0) and (vq.FieldByName('SEQ').AsString <> NullAsStringValue) then begin
            Result := vq.FieldByName('SEQ').Value + 1;
        end else begin
            Result := cSeqIni;
        end;
    finally
        vq.free;
    end;
end;

procedure TFormConfJogo.p_EquipPlayers(pQtJogadores :Integer);
begin
    lbi10Equipe1.Visible  := False;
    lbi20Equipe2.Visible  := False;
    lbi30Equipe3.Visible  := False;

    lbi10Jogador1.Visible := False;
    lbi20Jogador2.Visible := False;
    lbi30Jogador3.Visible := False;
    lbi40Jogador4.Visible := False;
    lbi50Jogador5.Visible := False;
    lbi60Jogador6.Visible := False;

    Case pQtJogadores of
        2 : //-->> 2 Jogadores
        begin
            lbiPadJogo40.Height    := 46;

            lbSetEquipes.Columns   := f_GetQtdEquipes(pQtJogadores);
            lbSetJogadores.Columns := f_GetQtdEquipes(pQtJogadores);

            lbi10Equipe1.Visible   := True;
            lbi20Equipe2.Visible   := True;
            lbi10Jogador1.Visible  := True;
            lbi20Jogador2.Visible  := True;
        end;
        3 : //-->> 3 Jogadores
        begin
            lbiPadJogo40.Height    := 46;

            lbSetEquipes.Columns   := f_GetQtdEquipes(pQtJogadores);
            lbSetJogadores.Columns := f_GetQtdEquipes(pQtJogadores);

            lbi10Equipe1.Visible   := True;
            lbi20Equipe2.Visible   := True;
            lbi30Equipe3.Visible   := True;

            lbi10Jogador1.Visible  := True;
            lbi20Jogador2.Visible  := True;
            lbi30Jogador3.Visible  := True;
        end;
        4 : //-->> 4 Jogadores
        begin
            lbiPadJogo40.Height    := 88;

            lbSetEquipes.Columns   := f_GetQtdEquipes(pQtJogadores);
            lbSetJogadores.Columns := f_GetQtdEquipes(pQtJogadores);

            lbi10Equipe1.Visible   := True;
            lbi20Equipe2.Visible   := True;

            lbi10Jogador1.Visible  := True;
            lbi20Jogador2.Visible  := True;
            lbi40Jogador4.Visible  := True;
            lbi50Jogador5.Visible  := True;
        end;
        6 : //-->> 6 Jogadores
        begin
            lbiPadJogo40.Height    := 132;

            lbSetEquipes.Columns   := f_GetQtdEquipes(pQtJogadores);
            lbSetJogadores.Columns := f_GetQtdEquipes(pQtJogadores);

            lbi10Equipe1.Visible   := True;
            lbi20Equipe2.Visible   := True;

            lbi10Jogador1.Visible  := True;
            lbi20Jogador2.Visible  := True;
            lbi30Jogador3.Visible  := True;
            lbi40Jogador4.Visible  := True;
            lbi50Jogador5.Visible  := True;
            lbi60Jogador6.Visible  := True;
         end;
    end;
end;

end.
