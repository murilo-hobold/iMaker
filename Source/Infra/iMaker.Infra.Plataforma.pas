unit iMaker.Infra.Plataforma;

{ Recursos específicos de cada sistema: manter a tela acesa e compartilhar imagem. }

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.Platform, FMX.MediaLibrary
{$IFDEF ANDROID}
  , Androidapi.Helpers, Androidapi.JNIBridge, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.App, Androidapi.JNI.GraphicsContentViewText
{$ENDIF}
{$IFDEF IOS}
  , iOSapi.Helpers
{$ENDIF}
  ;

type
  TPlataforma = class
  public
    class procedure ManterTelaAcesa(aAtivo: Boolean); static;
    { Abre o compartilhamento nativo (WhatsApp, etc.).
      Retorna '' se compartilhou, ou o caminho do PNG salvo quando a
      plataforma não tem compartilhamento (Windows). }
    class function Compartilhar(aControle: TControl; const aTexto: string;
      aImagem: TBitmap): string; static;
  end;

implementation

{$IFDEF ANDROID}
type
  { Executa código na thread de interface do Android (funciona em qualquer
    versão do Delphi, sem depender de helpers do FMX) }
  TRunnableAndroid = class(TJavaLocal, JRunnable)
  private
    FProc: TProc;
  public
    constructor Create(const aProc: TProc);
    procedure run; cdecl;
  end;

var
  GRunnable: JRunnable;

constructor TRunnableAndroid.Create(const aProc: TProc);
begin
  inherited Create;
  FProc := aProc;
end;

procedure TRunnableAndroid.run;
begin
  FProc();
end;
{$ENDIF}

{ TPlataforma }

class procedure TPlataforma.ManterTelaAcesa(aAtivo: Boolean);
begin
{$IFDEF ANDROID}
  GRunnable := TRunnableAndroid.Create(
    procedure
    begin
      if aAtivo then
        TAndroidHelper.Activity.getWindow.addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON)
      else
        TAndroidHelper.Activity.getWindow.clearFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON);
    end);
  TAndroidHelper.Activity.runOnUiThread(GRunnable);
{$ENDIF}
{$IFDEF IOS}
  TiOSHelper.SharedApplication.setIdleTimerDisabled(aAtivo);
{$ENDIF}
end;

class function TPlataforma.Compartilhar(aControle: TControl; const aTexto: string;
  aImagem: TBitmap): string;
var
  vServico: IFMXShareSheetActionsService;
begin
  Result := '';
  if TPlatformServices.Current.SupportsPlatformService(IFMXShareSheetActionsService, vServico) then
    vServico.Share(aControle, aTexto, aImagem)
  else
  begin
    Result := TPath.Combine(TPath.GetDocumentsPath,
      'iMaker_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.png');
    aImagem.SaveToFile(Result);
  end;
end;

end.
