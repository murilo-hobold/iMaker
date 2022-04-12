unit frmModelo1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Router4D, Router4D.Interfaces,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  System.Actions, FMX.ActnList;

type
  TFormModelo1 = class(TForm, iRouter4DComponent)
    LayoutPrincipal: TLayout;
    rectFundoPreto: TRectangle;
    rectPopupMenu: TRectangle;
    LayPopUpMenu: TLayout;
    RectPopUpTitulo: TRectangle;
    LabPopUpTitulo: TLabel;
    RectPopUpHide: TRectangle;
    LabPopUpMenuHide: TLabel;
    LayoutModelo: TLayout;
    actList: TActionList;
    procedure FormCreate(Sender: TObject);
    procedure RectPopUpHideClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Render :TFMXObject;
    procedure UnRender;
    procedure p_PopUpMenuHide;
    procedure p_PopUpMenuShow(vTitulo: String; vLbItens: Integer);
    procedure p_PopUpMenuVisible(vVisible: Boolean);
  end;

var
  FormModelo1: TFormModelo1;

implementation

{$R *.fmx}

{ TFormModelo1 }

procedure TFormModelo1.RectPopUpHideClick(Sender: TObject);
begin
    p_PopUpMenuHide;
end;

function TFormModelo1.Render: TFMXObject;
begin
  Result := LayoutPrincipal;
end;

procedure TFormModelo1.UnRender;
begin

end;

procedure TFormModelo1.p_PopUpMenuVisible(vVisible: Boolean);
begin
    rectPopupMenu.Visible  := vVisible;
    rectFundoPreto.Visible := vVisible;
end;

procedure TFormModelo1.p_PopUpMenuShow(vTitulo: String; vLbItens :Integer);
const
    cHeightItem = 48;
var
    vHeight :Integer;
begin
    LabPopUpTitulo.Text := vTitulo;

    vHeight := (vLbItens * cHeightItem) + StrToInt(RectPopUpTitulo.Height.ToString) + 8;
    if vHeight > (LayoutPrincipal.Height - 75) then begin
        vHeight := StrToInt(LayoutPrincipal.Height.ToString) - 75;
    end;


    rectPopupMenu.Width      := LayoutPrincipal.Width  - 60;
    rectPopupMenu.Height     := vHeight;
    rectPopupMenu.Position.X := LayoutPrincipal.Position.X + 30;
    rectPopupMenu.Position.Y := LayoutPrincipal.Position.Y + 470;

    p_PopUpMenuVisible(True);

    rectPopupMenu.AnimateFloat('Position.Y', LayoutPrincipal.Position.Y + 25 - 8, 0.5,
      TAnimationType.InOut, TInterpolationType.Circular);
end;

procedure TFormModelo1.FormCreate(Sender: TObject);
begin
    p_PopUpMenuVisible(False);
end;

procedure TFormModelo1.p_PopUpMenuHide;
begin
    rectPopupMenu.AnimateFloat('Position.Y', LayoutPrincipal.Position.Y + 500, 0.3,
      TAnimationType.InOut, TInterpolationType.Circular);

    TThread.CreateAnonymousThread(
        procedure
        begin
            try
                sleep(300);
            finally
                TThread.Synchronize(nil, procedure
                begin
                    p_PopUpMenuVisible(False);
                end);
            end;
        end).Start;
end;

end.
