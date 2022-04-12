unit frmJogo;

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
  TFormJogo = class(TFormModelo1, iRouter4DComponent)
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
    BindSrcDBJogo: TBindSourceDB;
    BindingsList1: TBindingsList;
    lbPlacar: TListBox;
    LayoutRodada: TLayout;
    lbSetEquipes: TListBox;
    lbi10Equipe1: TListBoxItem;
    RectangleEquipe1: TRectangle;
    lbi20Equipe2: TListBoxItem;
    RectangleEquipe2: TRectangle;
    lbi30Equipe3: TListBoxItem;
    RectangleEquipe3: TRectangle;
    edtPlacar1: TEdit;
    edtPlacar2: TEdit;
    edtPlacar3: TEdit;
    FDQryRodada: TFDQuery;
    FDQryRodadajog_id: TIntegerField;
    FDQryRodadarod_id: TIntegerField;
    FDQryRodadarod_ponteq1: TFloatField;
    FDQryRodadarod_ponteq2: TFloatField;
    FDQryRodadarod_ponteq3: TFloatField;
    labProxRodada: TLabel;
    RectangleProxRodada: TRectangle;
    RectangleAdd: TRectangle;
    btnAddRodada: TSpeedButton;
    BindSrcDBRodada: TBindSourceDB;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkPropertyToFieldText: TLinkPropertyToField;
    procedure btnAddRodadaClick(Sender: TObject);
  private

    procedure p_AtualizarJogo(pJogoId: Integer);
    procedure p_add_lb_Placar(pQtPlayer: Integer; pEquipe1, pEquipe2,
      pEquipe3: String);
    procedure p_setEqRodada(pQtPlayer: Integer);
    procedure p_add_lb_Placar2(pQtPlayer, pRodada: Integer; pEquipe1, pEquipe2,
      pEquipe3: String);
    procedure p_add_lb_PlacarTotal(pQtPlayer: Integer; pEquipe1, pEquipe2,
      pEquipe3: String);
    { Private declarations }
  public
    function Render: TFMXObject;
    procedure UnRender;
    { Public declarations }
  end;

var
  FormJogo: TFormJogo;

implementation

{$R *.fmx}

uses udm, uFuncoes, frPlacar, frPlacar2;

function TFormJogo.Render: TFMXObject;
var
    vqr: TFDQuery;
    vJogoId :Integer;
begin
    try
        vqr := dm.queryCtrl('select padjogo.jog_id from padjogo ');
        vqr.open;
        if (vqr.RowsAffected > 0) then begin
            vJogoId := vqr.FieldByName('jog_id').Value;
        end;
    finally
        vqr.free;
    end;

    p_AtualizarJogo(vJogoId);

    //-->>
    Result := LayoutPrincipal;
end;

procedure TFormJogo.UnRender;
begin
  //
end;

procedure TFormJogo.p_AtualizarJogo(pJogoId :Integer);
var
    vRodada :Integer;
    vPont1, vPont2, vPont3 :Double;
begin
    try
        lbPlacar.BeginUpdate;
        lbPlacar.Clear;

        with FDQryJogo do begin
            Close;
            ParamByName('jog_id').Value := pJogoId;
            Open;
        end;

        if FDQryJogo.IsEmpty then begin
            raise Exception.Create('Jogo não encontrado!');
        end;

        with FDQryRodada do begin
            Close;
            ParamByName('jog_id').Value := pJogoId;
            Open;
        end;

        p_setEqRodada(FDQryJogojog_qtplayer.Value);

        p_add_lb_Placar(FDQryJogojog_qtplayer.Value,
                        FDQryJogojog_equipe1.Value,
                        FDQryJogojog_equipe2.Value,
                        FDQryJogojog_equipe3.Value);

        vPont1  := 0;
        vPont2  := 0;
        vPont3  := 0;
        vRodada := 0;

        FDQryRodada.First;
        while not(FDQryRodada.Eof) do begin

            vPont1  := vPont1 + FDQryRodadarod_ponteq1.Value;
            vPont2  := vPont2 + FDQryRodadarod_ponteq2.Value;
            vPont3  := vPont3 + FDQryRodadarod_ponteq3.Value;

            FDQryRodada.Next;
        end;

        p_add_lb_PlacarTotal(FDQryJogojog_qtplayer.Value,
                             FloatToStr(vPont1),
                             FloatToStr(vPont2),
                             FloatToStr(vPont3));

        FDQryRodada.First;

        vRodada := FDQryRodadarod_id.Value;

        while not(FDQryRodada.Eof) do begin

            p_add_lb_Placar2(FDQryJogojog_qtplayer.Value,
                             FDQryRodadarod_id.Value,
                             FDQryRodadarod_ponteq1.AsString,
                             FDQryRodadarod_ponteq2.AsString,
                             FDQryRodadarod_ponteq3.AsString);

            FDQryRodada.Next;
        end;

        FDQryRodada.Insert;
        FDQryRodadajog_id.Value := pJogoId;
        FDQryRodadarod_id.Value := vRodada + 1;
    finally
        lbPlacar.EndUpdate;
    end;
end;

procedure TFormJogo.p_add_lb_Placar(pQtPlayer :Integer; pEquipe1, pEquipe2, pEquipe3 :String);
var
    vItem: TListBoxItem;
    vFrame: TFramePLacar;
begin
    vItem := TListBoxItem.Create(lbPlacar);
    vItem.Parent := lbPlacar;
    vItem.Selectable := False;
    vItem.Text       := '';
    vItem.Height     := 42;

    vFrame := TFramePLacar.Create(vItem);
    vFrame.Align                 := TAlignLayout.Client;
    vFrame.Parent                := vItem;
    vFrame.lbi10Equipe1.Visible  := False;
    vFrame.lbi20Equipe2.Visible  := False;
    vFrame.lbi30Equipe3.Visible  := False;
    vFrame.lbSetEquipes.Columns  := f_GetQtdEquipes(pQtPlayer);

    Case f_GetQtdEquipes(pQtPlayer) of
        2 : //-->> 2 Jogadores
        begin
            vFrame.lbi10Equipe1.Visible   := True;
            vFrame.LabEquipe1.text        := pEquipe1;

            vFrame.lbi20Equipe2.Visible   := True;
            vFrame.LabEquipe2.text        := pEquipe2;
        end;
        3 : //-->> 3 Jogadores
        begin
            vFrame.lbi10Equipe1.Visible   := True;
            vFrame.LabEquipe1.text        := pEquipe1;

            vFrame.lbi20Equipe2.Visible   := True;
            vFrame.LabEquipe2.text        := pEquipe2;

            vFrame.lbi30Equipe3.Visible   := True;
            vFrame.LabEquipe3.text        := pEquipe3;
        end;
    end;

    vItem.AddObject(vFrame);

    lbPlacar.AddObject(vItem);
end;

procedure TFormJogo.p_add_lb_PlacarTotal(pQtPlayer :Integer; pEquipe1, pEquipe2, pEquipe3 :String);
var
    vItem: TListBoxItem;
    vFrame: TFramePLacar;
begin
    vItem := TListBoxItem.Create(lbPlacar);
    vItem.Parent := lbPlacar;
    vItem.Selectable := False;
    vItem.Text       := '';
    vItem.Height     := 42;

    vFrame := TFramePLacar.Create(vItem);
    vFrame.Align                 := TAlignLayout.Client;
    vFrame.Parent                := vItem;
    vFrame.lbi10Equipe1.Visible  := False;
    vFrame.lbi20Equipe2.Visible  := False;
    vFrame.lbi30Equipe3.Visible  := False;
    vFrame.lbSetEquipes.Columns  := f_GetQtdEquipes(pQtPlayer);

    Case f_GetQtdEquipes(pQtPlayer) of
        2 : //-->> 2 Jogadores
        begin
            vFrame.lbi10Equipe1.Visible   := True;
            vFrame.LabEquipe1.text        := pEquipe1;

            vFrame.lbi20Equipe2.Visible   := True;
            vFrame.LabEquipe2.text        := pEquipe2;
        end;
        3 : //-->> 3 Jogadores
        begin
            vFrame.lbi10Equipe1.Visible   := True;
            vFrame.LabEquipe1.text        := pEquipe1;

            vFrame.lbi20Equipe2.Visible   := True;
            vFrame.LabEquipe2.text        := pEquipe2;

            vFrame.lbi30Equipe3.Visible   := True;
            vFrame.LabEquipe3.text        := pEquipe3;
        end;
    end;

    vItem.AddObject(vFrame);

    lbPlacar.AddObject(vItem);
end;

procedure TFormJogo.p_add_lb_Placar2(pQtPlayer, pRodada :Integer; pEquipe1, pEquipe2, pEquipe3 :String);
var
    vItem: TListBoxItem;
    vFrame: TFramePLacar2;
begin
    vItem := TListBoxItem.Create(lbPlacar);
    vItem.Parent := lbPlacar;
    vItem.Selectable := False;
    vItem.Text       := '';
    vItem.Height     := 42;

    vFrame := TFramePLacar2.Create(vItem);
    vFrame.Align                 := TAlignLayout.Client;
    vFrame.Parent                := vItem;
    vFrame.labRodada.text        := IntToStr(pRodada);
    vFrame.lbi10Equipe1.Visible  := False;
    vFrame.lbi20Equipe2.Visible  := False;
    vFrame.lbi30Equipe3.Visible  := False;
    vFrame.lbSetEquipes.Columns  := f_GetQtdEquipes(pQtPlayer);

    Case f_GetQtdEquipes(pQtPlayer) of
        2 : //-->> 2 Jogadores
        begin
            vFrame.lbi10Equipe1.Visible   := True;
            vFrame.LabEquipe1.text        := pEquipe1;

            vFrame.lbi20Equipe2.Visible   := True;
            vFrame.LabEquipe2.text        := pEquipe2;
        end;
        3 : //-->> 3 Jogadores
        begin
            vFrame.lbi10Equipe1.Visible   := True;
            vFrame.LabEquipe1.text        := pEquipe1;

            vFrame.lbi20Equipe2.Visible   := True;
            vFrame.LabEquipe2.text        := pEquipe2;

            vFrame.lbi30Equipe3.Visible   := True;
            vFrame.LabEquipe3.text        := pEquipe3;
        end;
    end;

    vItem.AddObject(vFrame);

    lbPlacar.AddObject(vItem);
end;

procedure TFormJogo.p_setEqRodada(pQtPlayer :Integer);
begin
    lbi10Equipe1.Visible  := False;
    lbi20Equipe2.Visible  := False;
    lbi30Equipe3.Visible  := False;

    lbSetEquipes.Columns  := f_GetQtdEquipes(pQtPlayer);

    Case f_GetQtdEquipes(pQtPlayer) of
        2 : //-->> 2 Jogadores
        begin
            lbi10Equipe1.Visible   := True;
            lbi20Equipe2.Visible   := True;
        end;
        3 : //-->> 3 Jogadores
        begin
            lbi10Equipe1.Visible   := True;
            lbi20Equipe2.Visible   := True;
            lbi30Equipe3.Visible   := True;
        end;
    end;
end;

procedure TFormJogo.btnAddRodadaClick(Sender: TObject);
begin
    inherited;
    if trim(edtPlacar1.Text) = NullAsStringValue then begin
        raise Exception.Create('Informe a pontuação da equipe 1!');
    end;

    if trim(edtPlacar2.Text) = NullAsStringValue then begin
        raise Exception.Create('Informe a pontuação da equipe 2!');
    end;

    if f_GetQtdEquipes(FDQryJogojog_qtplayer.Value) = 3 then begin
        if trim(edtPlacar3.Text) = NullAsStringValue then begin
            raise Exception.Create('Informe a pontuação da equipe 3!');
        end;
    end;

    try
        dm.FDConCtrl.StartTransaction;

        if (FDQryRodada.State in [dsEdit, dsInsert]) then begin
            FDQryRodada.Post;
        end;

        FDQryRodada.ApplyUpdates;
        FDQryRodada.CommitUpdates;

        dm.FDConCtrl.Commit;

        p_AtualizarJogo(FDQryRodadajog_id.Value);
    except
        on E: Exception do
        begin
            dm.FDConCtrl.Rollback;

            raise Exception.Create('Ocorreu um problema ao salvar a rodada' + #13#10 +
                                   'Erro: ' + E.Message);
        end;
    end;
end;

end.
