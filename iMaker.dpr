program iMaker;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Types,
  iMaker.Model.Entidades in 'Source\Model\iMaker.Model.Entidades.pas',
  iMaker.Infra.Conexao in 'Source\Infra\iMaker.Infra.Conexao.pas',
  iMaker.Infra.Recursos in 'Source\Infra\iMaker.Infra.Recursos.pas',
  iMaker.Infra.Som in 'Source\Infra\iMaker.Infra.Som.pas',
  iMaker.Infra.Plataforma in 'Source\Infra\iMaker.Infra.Plataforma.pas',
  iMaker.Repository.Jogador in 'Source\Repository\iMaker.Repository.Jogador.pas',
  iMaker.Repository.Partida in 'Source\Repository\iMaker.Repository.Partida.pas',
  iMaker.Repository.Estatistica in 'Source\Repository\iMaker.Repository.Estatistica.pas',
  iMaker.Repository.Config in 'Source\Repository\iMaker.Repository.Config.pas',
  iMaker.Service.Partida in 'Source\Service\iMaker.Service.Partida.pas',
  iMaker.Service.Jogador in 'Source\Service\iMaker.Service.Jogador.pas',
  iMaker.Service.Config in 'Source\Service\iMaker.Service.Config.pas',
  iMaker.View.Tema in 'Source\View\iMaker.View.Tema.pas',
  iMaker.View.Navegacao in 'Source\View\iMaker.View.Navegacao.pas',
  iMaker.View.Componentes in 'Source\View\iMaker.View.Componentes.pas',
  iMaker.Frame.Rodada in 'Source\View\Frames\iMaker.Frame.Rodada.pas' {FrameRodada: TFrame},
  iMaker.Frame.EquipePlacar in 'Source\View\Frames\iMaker.Frame.EquipePlacar.pas' {FrameEquipePlacar: TFrame},
  iMaker.Frame.JogadorItem in 'Source\View\Frames\iMaker.Frame.JogadorItem.pas' {FrameJogadorItem: TFrame},
  iMaker.Frame.PartidaItem in 'Source\View\Frames\iMaker.Frame.PartidaItem.pas' {FramePartidaItem: TFrame},
  iMaker.Frame.RankingItem in 'Source\View\Frames\iMaker.Frame.RankingItem.pas' {FrameRankingItem: TFrame},
  iMaker.Frame.EquipeConfig in 'Source\View\Frames\iMaker.Frame.EquipeConfig.pas' {FrameEquipeConfig: TFrame},
  iMaker.Frame.Picker in 'Source\View\Frames\iMaker.Frame.Picker.pas' {FramePicker: TFrame},
  iMaker.View.Principal in 'Source\View\iMaker.View.Principal.pas' {FormPrincipal},
  iMaker.View.Jogo in 'Source\View\iMaker.View.Jogo.pas' {FormJogo},
  iMaker.View.NovaPartida in 'Source\View\iMaker.View.NovaPartida.pas' {FormNovaPartida},
  iMaker.View.Jogadores in 'Source\View\iMaker.View.Jogadores.pas' {FormJogadores},
  iMaker.View.Historico in 'Source\View\iMaker.View.Historico.pas' {FormHistorico},
  iMaker.View.Ranking in 'Source\View\iMaker.View.Ranking.pas' {FormRanking};

{$R *.res}
{$R iMakerAssets.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
