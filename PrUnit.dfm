object PrDM: TPrDM
  OldCreateOrder = False
  Height = 285
  Width = 667
  object Report: TfrxReport
    Version = '4.15'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 41333.813541412000000000
    ReportOptions.LastChange = 44477.425978506940000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    OnGetValue = ReportGetValue
    Left = 24
    Top = 16
    Datasets = <
      item
        DataSet = DS1
        DataSetName = 'DS1'
      end
      item
        DataSet = DS2
        DataSetName = 'DS2'
      end>
    Variables = <
      item
        Name = ' New Category1'
        Value = Null
      end
      item
        Name = 'ContNum'
        Value = Null
      end
      item
        Name = 'TotBox'
        Value = Null
      end
      item
        Name = 'TotFault'
        Value = Null
      end>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
      object ReportTitle1: TfrxReportTitle
        Height = 79.370130000000000000
        Top = 18.897650000000000000
        Width = 718.110700000000000000
        object Memo13: TfrxMemoView
          Width = 718.110700000000000000
          Height = 41.574830000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1038#1056#1119#1056#152#1056#1038#1056#1115#1056#1113
            #1056#1029#1056#176#1056#8470#1056#1169#1056#181#1056#1029#1057#8249#1057#8230' '#1056#1105' '#1056#1029#1056#181' '#1056#1029#1056#176#1056#8470#1056#1169#1056#181#1056#1029#1057#8249#1057#8230' '#1056#1108#1056#1109#1057#1026#1056#1109#1056#177#1056#1109#1056#1108)
          ParentFont = False
        end
        object Memo14: TfrxMemoView
          Top = 41.574830000000000000
          Width = 718.110700000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          HAlign = haCenter
          Memo.UTF8 = (
            '[ContNum]')
          ParentFont = False
        end
      end
      object MasterData1: TfrxMasterData
        Top = 226.771800000000000000
        Width = 718.110700000000000000
        DataSet = DS1
        DataSetName = 'DS1'
        RowCount = 0
        object Memo12: TfrxMemoView
          Width = 721.890230000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftBottom]
          ParentFont = False
        end
      end
      object PageHeader1: TfrxPageHeader
        Height = 45.354360000000000000
        Top = 120.944960000000000000
        Width = 718.110700000000000000
        object Memo7: TfrxMemoView
          Top = 3.779530000000000000
          Width = 56.692950000000000000
          Height = 41.574830000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1113#1056#1109#1056#1169' '#1056#1108#1056#1109#1057#1026#1056#1109#1056#177#1056#1108#1056#1105)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo8: TfrxMemoView
          Left = 631.181510000000000000
          Top = 3.779530000000000000
          Width = 86.929190000000000000
          Height = 41.574830000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1119#1057#1026#1056#1105#1056#1112#1056#181#1057#8225#1056#176#1056#1029#1056#1105#1056#181)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo9: TfrxMemoView
          Left = 563.149970000000000000
          Top = 3.779530000000000000
          Width = 68.031540000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1113#1056#1109#1056#187'-'#1056#1030#1056#1109)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo10: TfrxMemoView
          Left = 517.795610000000000000
          Top = 22.677180000000000000
          Width = 45.354360000000000000
          Height = 22.677180000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1108#1056#1109#1056#187'-'#1056#1030#1056#1109)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo11: TfrxMemoView
          Left = 491.338900000000000000
          Top = 22.677180000000000000
          Width = 26.456710000000000000
          Height = 22.677180000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#8226#1056#1169)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo2: TfrxMemoView
          Left = 56.692950000000000000
          Top = 3.779530000000000000
          Width = 506.457020000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1038#1056#1109#1056#1169#1056#181#1057#1026#1056#182#1056#1105#1056#1112#1056#1109#1056#181)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo3: TfrxMemoView
          Left = 56.692950000000000000
          Top = 22.677180000000000000
          Width = 336.378170000000000000
          Height = 22.677180000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1116#1056#176#1056#1105#1056#1112#1056#181#1056#1029#1056#1109#1056#1030#1056#176#1056#1029#1056#1105#1056#181' '#1056#1169#1056#181#1057#8218#1056#176#1056#187#1056#1105)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo4: TfrxMemoView
          Left = 563.149970000000000000
          Top = 22.677180000000000000
          Width = 34.015770000000000000
          Height = 22.677180000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1169'.'#1056#177'.')
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo5: TfrxMemoView
          Left = 597.165740000000000000
          Top = 22.677180000000000000
          Width = 34.015770000000000000
          Height = 22.677180000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1109#1057#8218#1057#1027)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo18: TfrxMemoView
          Left = 393.071120000000000000
          Top = 22.677180000000000000
          Width = 98.267780000000000000
          Height = 22.677180000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#8212#1056#176#1056#1108#1056#176#1056#183)
          ParentFont = False
          VAlign = vaCenter
        end
      end
      object DetailData1: TfrxDetailData
        Height = 18.897650000000000000
        Top = 249.448980000000000000
        Width = 718.110700000000000000
        DataSet = DS2
        DataSetName = 'DS2'
        RowCount = 0
        object Memo1: TfrxMemoView
          Width = 56.692950000000000000
          Height = 18.897650000000000000
          ShowHint = False
          StretchMode = smMaxHeight
          DataField = 'Fld1'
          DataSet = DS2
          DataSetName = 'DS2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight]
          GapX = 4.000000000000000000
          Memo.UTF8 = (
            '[DS2."Fld1"]')
          ParentFont = False
        end
        object Memo6: TfrxMemoView
          Left = 597.165740000000000000
          Width = 34.015770000000000000
          Height = 18.897650000000000000
          ShowHint = False
          DataField = 'Fld6'
          DataSet = DS2
          DataSetName = 'DS2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight]
          GapX = 4.000000000000000000
          Memo.UTF8 = (
            '[DS2."Fld6"]')
          ParentFont = False
        end
        object Memo16: TfrxMemoView
          Left = 563.149970000000000000
          Width = 34.015770000000000000
          Height = 18.897650000000000000
          ShowHint = False
          DataField = 'Fld5'
          DataSet = DS2
          DataSetName = 'DS2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight]
          GapX = 4.000000000000000000
          Memo.UTF8 = (
            '[DS2."Fld5"]')
          ParentFont = False
        end
        object Memo17: TfrxMemoView
          Left = 631.181510000000000000
          Width = 86.929190000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight]
          ParentFont = False
        end
        object Memo20: TfrxMemoView
          Left = 79.370130000000000000
          Width = 313.700990000000000000
          Height = 18.897650000000000000
          ShowHint = False
          DataField = 'Fld2'
          DataSet = DS2
          DataSetName = 'DS2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          GapX = 4.000000000000000000
          Memo.UTF8 = (
            '[DS2."Fld2"]')
          ParentFont = False
          WordWrap = False
          VAlign = vaCenter
        end
        object Memo21: TfrxMemoView
          Left = 56.692950000000000000
          Width = 22.677180000000000000
          Height = 18.897650000000000000
          ShowHint = False
          DataSet = DS2
          DataSetName = 'DS2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          GapX = 4.000000000000000000
          Memo.UTF8 = (
            '[Line]')
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo22: TfrxMemoView
          Left = 491.338900000000000000
          Width = 26.456710000000000000
          Height = 18.897650000000000000
          ShowHint = False
          DataField = 'Fld3'
          DataSet = DS2
          DataSetName = 'DS2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            '[DS2."Fld3"]')
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo23: TfrxMemoView
          Left = 517.795610000000000000
          Width = 45.354360000000000000
          Height = 18.897650000000000000
          ShowHint = False
          DataField = 'Fld4'
          DataSet = DS2
          DataSetName = 'DS2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          GapX = 5.000000000000000000
          Memo.UTF8 = (
            '[DS2."Fld4"]')
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo15: TfrxMemoView
          Left = 393.071120000000000000
          Width = 98.267780000000000000
          Height = 18.897650000000000000
          ShowHint = False
          DataField = 'Fld8'
          DataSet = DS2
          DataSetName = 'DS2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          Memo.UTF8 = (
            '[DS2."Fld8"]')
          ParentFont = False
          VAlign = vaCenter
        end
      end
      object ReportSummary1: TfrxReportSummary
        Height = 22.677180000000000000
        Top = 328.819110000000000000
        Width = 718.110700000000000000
        object Memo24: TfrxMemoView
          Width = 563.149970000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haRight
          Memo.UTF8 = (
            #1056#152#1057#8218#1056#1109#1056#1110#1056#1109' :')
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo25: TfrxMemoView
          Left = 563.149970000000000000
          Width = 34.015770000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          GapX = 4.000000000000000000
          Memo.UTF8 = (
            '[TotBox]')
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo26: TfrxMemoView
          Left = 597.165740000000000000
          Width = 34.015770000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          GapX = 4.000000000000000000
          Memo.UTF8 = (
            '[TotFault]')
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo27: TfrxMemoView
          Left = 631.181510000000000000
          Width = 86.929190000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          GapX = 4.000000000000000000
          ParentFont = False
          VAlign = vaCenter
        end
      end
    end
  end
  object DS1: TfrxUserDataSet
    RangeEnd = reCount
    UserName = 'DS1'
    Fields.Strings = (
      'Fld1'
      'Fld2'
      'Fld3'
      'Fld4'
      'Fld5'
      'Fld6'
      'Fld7'
      'Fld8'
      'Fld9'
      'Fld10')
    OnGetValue = DS1GetValue
    Left = 88
    Top = 16
  end
  object DS2: TfrxUserDataSet
    UserName = 'DS2'
    OnCheckEOF = DS2CheckEOF
    Fields.Strings = (
      'Fld1'
      'Fld2'
      'Fld3'
      'Fld4'
      'Fld5'
      'Fld6'
      'Fld7'
      'Fld8'
      'Fld9'
      'Fld10')
    OnGetValue = DS2GetValue
    Left = 144
    Top = 16
  end
  object frxXLSExport1: TfrxXLSExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    ExportEMF = True
    AsText = False
    Background = True
    FastExport = True
    PageBreaks = True
    EmptyLines = True
    SuppressPageHeadersFooters = False
    Left = 248
    Top = 16
  end
  object frxODSExport1: TfrxODSExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    PictureType = gpPNG
    Background = True
    Creator = 'FastReport'
    Language = 'en'
    SuppressPageHeadersFooters = False
    Left = 288
    Top = 16
  end
end
