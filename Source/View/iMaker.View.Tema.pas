unit iMaker.View.Tema;

{ Paleta do iMaker: preto, dourado e branco. }

interface

uses
  System.UITypes;

const
  COR_FUNDO        = TAlphaColor($FF0B0B0B);
  COR_SUPERFICIE   = TAlphaColor($FF171717);
  COR_SUPERFICIE_2 = TAlphaColor($FF222222);
  COR_BORDA        = TAlphaColor($FF2E2E2E);
  COR_OURO         = TAlphaColor($FFF2C230);
  COR_OURO_ESCURO  = TAlphaColor($FFB8860B);
  COR_TEXTO        = TAlphaColor($FFFFFFFF);
  COR_TEXTO_SEC    = TAlphaColor($FFA3A3A3);
  COR_TEXTO_ESCURO = TAlphaColor($FF111111);
  COR_PERIGO       = TAlphaColor($FFE5484D);
  COR_PRATA        = TAlphaColor($FFC9C9C9);
  COR_BRONZE       = TAlphaColor($FFCD7F32);

  { Cor de destaque de cada equipe }
  CORES_EQUIPE: array[1..3] of TAlphaColor = (COR_OURO, COR_TEXTO, COR_PRATA);

  { Ícones (traço) usados em TPath criados em tempo de execução }
  ICONE_LAPIS = 'M4 20 L8 19 L19 8 L16 5 L5 16 Z M14 7 L17 10';
  ICONE_SETA  = 'M9 6 L15 12 L9 18';

implementation

end.
