object dm: Tdm
  OnCreate = DataModuleCreate
  Height = 427
  Width = 713
  PixelsPerInch = 96
  object FDConCtrl: TFDConnection
    Params.Strings = (
      'Database=C:\Projetos\iMarker\Win32\Debug\basectrl.db'
      'DriverID=SQLite')
    LoginPrompt = False
    AfterConnect = FDConCtrlAfterConnect
    Left = 32
    Top = 16
  end
  object FDQryJogador1: TFDQuery
    CachedUpdates = True
    Connection = FDConCtrl
    SQL.Strings = (
      'select   jogador.jgd_codigo, jogador.jgd_nome'
      '    from jogador'
      'order by jogador.jgd_codigo asc')
    Left = 288
    Top = 16
    object FDQryJogador1jgd_codigo: TWideMemoField
      FieldName = 'jgd_codigo'
      Origin = 'jgd_codigo'
      BlobType = ftWideMemo
      Size = 2
    end
    object FDQryJogador1jgd_nome: TWideMemoField
      FieldName = 'jgd_nome'
      Origin = 'jgd_nome'
      BlobType = ftWideMemo
    end
  end
  object FDQryJogador2: TFDQuery
    CachedUpdates = True
    Connection = FDConCtrl
    SQL.Strings = (
      'select   jogador.jgd_codigo, jogador.jgd_nome'
      '    from jogador'
      'order by jogador.jgd_codigo asc')
    Left = 288
    Top = 72
    object FDQryJogador2jgd_codigo: TWideMemoField
      FieldName = 'jgd_codigo'
      Origin = 'jgd_codigo'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      BlobType = ftWideMemo
    end
    object FDQryJogador2jgd_nome: TWideMemoField
      FieldName = 'jgd_nome'
      Origin = 'jgd_nome'
      BlobType = ftWideMemo
    end
  end
  object FDQryJogador3: TFDQuery
    CachedUpdates = True
    Connection = FDConCtrl
    SQL.Strings = (
      'select   jogador.jgd_codigo, jogador.jgd_nome'
      '    from jogador'
      'order by jogador.jgd_codigo asc')
    Left = 288
    Top = 128
    object FDQryJogador3jgd_codigo: TWideMemoField
      FieldName = 'jgd_codigo'
      Origin = 'jgd_codigo'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      BlobType = ftWideMemo
    end
    object FDQryJogador3jgd_nome: TWideMemoField
      FieldName = 'jgd_nome'
      Origin = 'jgd_nome'
      BlobType = ftWideMemo
    end
  end
  object FDQryJogador4: TFDQuery
    CachedUpdates = True
    Connection = FDConCtrl
    SQL.Strings = (
      'select   jogador.jgd_codigo, jogador.jgd_nome'
      '    from jogador'
      'order by jogador.jgd_codigo asc')
    Left = 288
    Top = 192
    object FDQryJogador4jgd_codigo: TWideMemoField
      FieldName = 'jgd_codigo'
      Origin = 'jgd_codigo'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      BlobType = ftWideMemo
    end
    object FDQryJogador4jgd_nome: TWideMemoField
      FieldName = 'jgd_nome'
      Origin = 'jgd_nome'
      BlobType = ftWideMemo
    end
  end
  object FDQryJogador5: TFDQuery
    CachedUpdates = True
    Connection = FDConCtrl
    SQL.Strings = (
      'select   jogador.jgd_codigo, jogador.jgd_nome'
      '    from jogador'
      'order by jogador.jgd_codigo asc')
    Left = 288
    Top = 248
    object FDQryJogador5jgd_codigo: TWideMemoField
      FieldName = 'jgd_codigo'
      Origin = 'jgd_codigo'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      BlobType = ftWideMemo
    end
    object FDQryJogador5jgd_nome: TWideMemoField
      FieldName = 'jgd_nome'
      Origin = 'jgd_nome'
      BlobType = ftWideMemo
    end
  end
  object FDQryJogador6: TFDQuery
    CachedUpdates = True
    Connection = FDConCtrl
    SQL.Strings = (
      'select   jogador.jgd_codigo, jogador.jgd_nome'
      '    from jogador'
      'order by jogador.jgd_codigo asc')
    Left = 288
    Top = 304
    object FDQryJogador6jgd_codigo: TWideMemoField
      FieldName = 'jgd_codigo'
      Origin = 'jgd_codigo'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      BlobType = ftWideMemo
    end
    object FDQryJogador6jgd_nome: TWideMemoField
      FieldName = 'jgd_nome'
      Origin = 'jgd_nome'
      BlobType = ftWideMemo
    end
  end
end
