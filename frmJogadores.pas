unit frmJogadores;

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
  TFormJogadores = class(TFormModelo1, iRouter4DComponent)
    lbJogadores: TListBox;
    RoundRectNovo: TRoundRect;
    btnNovoJogador: TSpeedButton;
    lbJogador: TListBox;
    lbiCodigo: TListBoxItem;
    edtCodigo: TEdit;
    edtNome: TEdit;
    FDQryJogador: TFDQuery;
    FDQryJogadorjgd_codigo: TWideMemoField;
    FDQryJogadorjgd_nome: TWideMemoField;
    BindSrcDBJogador: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    lbiSalvarJogador: TListBoxItem;
    RoundRect1: TRoundRect;
    btnSalvarJogador: TSpeedButton;
    actAddJogador: TAction;
    actSalvarJogador: TAction;
    procedure actAddJogadorExecute(Sender: TObject);
    procedure actSalvarJogadorExecute(Sender: TObject);
  private
    procedure p_AtualizarJogadores;
    procedure p_add_lb_Jogadores(pSigla, pJogador: String);
    { Private declarations }
  public
    function Render: TFMXObject;
    procedure UnRender;
    { Public declarations }
  end;

var
  FormJogadores: TFormJogadores;

implementation

{$R *.fmx}

uses udm, frJogadores;

function TFormJogadores.Render: TFMXObject;
begin
    p_AtualizarJogadores;

    Result := LayoutPrincipal;
end;

procedure TFormJogadores.UnRender;
begin
  //
end;

procedure TFormJogadores.p_AtualizarJogadores;
var
    vqr :TFDQuery;
begin
    try
        lbJogadores.BeginUpdate;
        lbJogadores.Clear;
        try
            vqr := dm.queryCtrl('select jogador.jgd_codigo, jogador.jgd_nome '+
                                '  from jogador '+
                                ' order by jogador.jgd_codigo asc ');
            vqr.Open;
            if vqr.RowsAffected > 0 then begin
              vqr.First;
              while not vqr.Eof do begin
                p_add_lb_Jogadores(vqr.FieldByName('jgd_codigo').AsString, vqr.FieldByName('jgd_nome').AsString);

                vqr.Next;
              end;
            end;
        finally
            FreeAndNil(vqr);
        end;
    finally
        lbJogadores.EndUpdate;
    end;
end;

procedure TFormJogadores.p_add_lb_Jogadores(pSigla, pJogador :String);
var
    vItem: TListBoxItem;
    vFrame: TframeJogadores;
begin
    vItem := TListBoxItem.Create(lbJogadores);
    vItem.Parent := lbJogadores;
    vItem.Selectable := False;
    vItem.Text       := '';
    vItem.Height     := 50;

    vFrame := TframeJogadores.Create(vItem);
    vFrame.Align                 := TAlignLayout.Client;
    vFrame.Parent                := vItem;
    vFrame.LabJogador.text       := pSigla +  ' - ' + pJogador;

    vItem.AddObject(vFrame);

    lbJogadores.AddObject(vItem);
end;

procedure TFormJogadores.actAddJogadorExecute(Sender: TObject);
begin
  inherited;
    with FDQryJogador do begin
        Close;
        ParamByName('jgd_codigo').Value := 0;
        Open;

        if IsEmpty then begin
            Insert;
        end else begin
            Edit;
        end;
    end;

    p_PopUpMenuShow('Adicionar Jogador', lbJogador.Items.Count);
end;

procedure TFormJogadores.actSalvarJogadorExecute(Sender: TObject);
begin
  inherited;
    try
        dm.FDConCtrl.StartTransaction;

        if (FDQryJogador.State in [dsEdit, dsInsert]) then begin
            FDQryJogador.Post;
        end;

        FDQryJogador.ApplyUpdates;
        FDQryJogador.CommitUpdates;

        dm.FDConCtrl.Commit;

        try
          p_PopUpMenuHide;
        finally
          p_AtualizarJogadores;
        end;
    except
        on E: Exception do
        begin
            dm.FDConCtrl.Rollback;

            raise Exception.Create('Ocorreu um problema ao salvar o jogador' + #13#10 +
                                   'Erro: ' + E.Message);
        end;
    end;
end;

end.
