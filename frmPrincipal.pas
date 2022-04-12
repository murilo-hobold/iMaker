unit frmPrincipal;

// https://www.youtube.com/watch?v=fT-Xvblg0P4&t=0s

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  FMX.ListBox, FMX.MultiView, Router4D, Router4D.Interfaces, Router4D.Props,
  System.Actions, FMX.ActnList;

type
  TFormPrincipal = class(TForm)
    rectopo: TRectangle;
    LayTopo: TLayout;
    LayIconMenu: TLayout;
    Layout3: TLayout;
    Image1: TImage;
    Label1: TLabel;
    LayoutTela: TLayout;
    mviewMenu: TMultiView;
    LayMenu: TLayout;
    RectangleSpeedButtons: TRectangle;
    lbxMenu: TListBox;
    lbi10ConfJogo: TListBoxItem;
    RectConfJogo: TRectangle;
    btnConfJogo: TSpeedButton;
    imgConfJogo: TImage;
    lbi20Jogo: TListBoxItem;
    RectJogo: TRectangle;
    btnJogo: TSpeedButton;
    ImgJogo: TImage;
    actList: TActionList;
    actConfJogo: TAction;
    actJogo: TAction;
    imgPlanoDeFundo: TImage;
    lbi30Jogadores: TListBoxItem;
    RectJogadores: TRectangle;
    btnJogadores: TSpeedButton;
    ImgJogadores: TImage;
    actJogadores: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actJogoExecute(Sender: TObject);
    procedure actConfJogoExecute(Sender: TObject);
    procedure ImgJogoClick(Sender: TObject);
    procedure imgConfJogoClick(Sender: TObject);
    procedure actJogadoresExecute(Sender: TObject);
    procedure ImgJogadoresClick(Sender: TObject);
  private
    procedure RegisterRouters;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

uses
  frmConfJogo, frmJogo, frmJogadores;

{$R *.fmx}
{
  procedure TViewPrincipal.Animation(aLayout: TFMXObject);
  begin
  TLayout(aLayout).Opacity := 0;
  TLayout(aLayout).AnimateFloat('Opacity', 1, 0.9);
  end;
  procedure TViewPrincipal.FormCreate(Sender: TObject);
  begin
  TRouter4D.Render<TMainLayout>.SetElement(Layout1, Layout1);
  TRouter4D.Link.Animation(Animation);
  end;

}

procedure TFormPrincipal.actConfJogoExecute(Sender: TObject);
begin
  TRouter4D.Render<TFormConfJogo>.SetElement(LayoutTela, LayoutTela);
end;

procedure TFormPrincipal.actJogadoresExecute(Sender: TObject);
begin
  TRouter4D.Render<TFormJogadores>.SetElement(LayoutTela, LayoutTela);
end;

procedure TFormPrincipal.actJogoExecute(Sender: TObject);
begin
  TRouter4D.Render<TFormJogo>.SetElement(LayoutTela, LayoutTela);
end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  mviewMenu.Width := 0;
  mviewMenu.NavigationPaneOptions.CollapsedWidth := 0;

  RegisterRouters;

  actConfJogoExecute(Sender);
end;

procedure TFormPrincipal.ImgJogadoresClick(Sender: TObject);
begin
  actJogadoresExecute(Sender);
end;

procedure TFormPrincipal.ImgJogoClick(Sender: TObject);
begin
  actJogoExecute(Sender);
end;

procedure TFormPrincipal.imgConfJogoClick(Sender: TObject);
begin
  actConfJogoExecute(Sender);
end;

procedure TFormPrincipal.RegisterRouters;
begin
  TRouter4D.Switch.Router('ConfJogo', TFormConfJogo);
  TRouter4D.Switch.Router('Jogo', TFormJogo);
  TRouter4D.Switch.Router('Jogadores', TFormJogadores);
end;

end.
