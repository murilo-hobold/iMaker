# iMaker · Marcador de Canastra

Aplicativo Delphi FMX (Android e iOS) para marcar pontos de partidas de canastra.
Tema preto, dourado e branco.

## Funcionalidades

- Partidas com 2, 3, 4 ou 6 jogadores (individual, duplas ou trios)
- Meta configurável (recomendado 2.000). Ao chegar na metade da meta a equipe **entra no buraco** e o app avisa
- Lançamento do total de cada equipe por rodada, com botão ± para pontos negativos
- Editar e excluir rodadas (os totais e o vencedor são recalculados)
- Rodízio automático de quem embaralha, seguindo a ordem da mesa
- Cronômetro da partida
- Celebrações com emoji e som: vitória, derrota, rodada iniciada, entrou no buraco, virada, empate, rodada de ouro e rodada negativa
- Histórico de partidas: continuar, rever ou excluir
- Ranking por jogador: vitórias, aproveitamento, média de pontos e melhor rodada
- Compartilhar o placar como imagem (WhatsApp etc.)
- Manter a tela acesa durante o jogo; som liga/desliga nas configurações

## Arquitetura

O back-end fica em units `.pas` sem nenhuma dependência de tela. As telas (`.fmx` + `.pas`) só exibem dados e chamam os serviços.

```
Source/
  Model/        Entidades (records) e regras de cálculo: totais, líder, buraco, rodízio
  Infra/        Conexão SQLite (FireDAC) + migração, recursos embutidos, som, plataforma
  Repository/   SQL de jogador, partida/rodadas, estatísticas e configurações
  Service/      Regras da canastra: criar partida, lançar/editar rodada, vencedor, eventos, ranking
  View/         Forms, frames, tema, navegação (Router4D) e componentes visuais
Assets/
  Emojis/ Sons/ Icone/   Arquivos originais
  _fonte/                Scripts Python que geram emojis, sons, ícones e o .res
iMakerAssets.res         Emojis e sons embutidos no executável (RCDATA)
```

Banco: `imaker.db` (SQLite) na pasta de documentos do app. A versão do esquema fica em `PRAGMA user_version`. Para evoluir o banco, crie `CriarVersao2` em `iMaker.Infra.Conexao`.

## Compilar

1. Abra `iMaker.dproj` no RAD Studio 12.
2. O Router4D precisa estar no Library Path (como já estava antes).
3. **Android**: em *Project > Options > Application > Entitlement List*, marque **Secure File Sharing** (necessário para compartilhar a imagem do placar).
4. Os ícones e splashes do Android já apontam para `Assets\Icone`.

Para alterar um emoji ou som, edite o arquivo em `Assets/` (ou os scripts em `Assets/_fonte/`) e gere de novo o `iMakerAssets.res` (`python pacote.py <pasta do projeto>` ou `brcc32 iMakerAssets.rc`).
