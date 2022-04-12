unit frPlacar2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Layouts, FMX.Objects;

type
  TFramePlacar2 = class(TFrame)
    ImgCarta2: TImage;
    lbSetEquipes: TListBox;
    lbi10Equipe1: TListBoxItem;
    RectangleEquipe1: TRectangle;
    LabEquipe1: TLabel;
    lbi20Equipe2: TListBoxItem;
    RectangleEquipe2: TRectangle;
    LabEquipe2: TLabel;
    lbi30Equipe3: TListBoxItem;
    RectangleEquipe3: TRectangle;
    LabEquipe3: TLabel;
    RectangleRodada: TRectangle;
    labRodada: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
