program iMarker;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmPrincipal in 'frmPrincipal.pas' {FormPrincipal},
  frmModelo1 in 'Modelos\frmModelo1.pas' {FormModelo1},
  frmConfJogo in 'frmConfJogo.pas' {FormConfJogo},
  udm in 'udm.pas' {dm: TDataModule},
  uFuncoes in 'uFuncoes.pas',
  frPlacar in 'Frames\frPlacar.pas' {FramePlacar: TFrame},
  frPlacar2 in 'Frames\frPlacar2.pas' {FramePlacar2: TFrame},
  frmJogadores in 'frmJogadores.pas' {FormJogadores},
  frJogadores in 'Frames\frJogadores.pas' {FrameJogadores: TFrame},
  frmJogo in 'frmJogo.pas' {FormJogo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.CreateForm(TFormModelo1, FormModelo1);
  Application.Run;
end.
