object MainForm: TMainForm
  Left = 246
  Top = 132
  BorderStyle = bsSingle
  Caption = 'Twixt'
  ClientHeight = 550
  ClientWidth = 728
  Color = clAppWorkSpace
  Constraints.MinHeight = 454
  Constraints.MinWidth = 606
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    728
    550)
  PixelsPerInch = 96
  TextHeight = 13
  object PanelOptions: TPanel
    Left = 529
    Top = -2
    Width = 216
    Height = 555
    Anchors = [akTop, akRight, akBottom]
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    DesignSize = (
      216
      555)
    object GroupCurPlayer: TGroupBox
      Left = 8
      Top = 5
      Width = 185
      Height = 48
      Caption = ' Current Player '
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
      object LabelCurPlayer: TLabel
        Left = 37
        Top = 21
        Width = 25
        Height = 13
        Caption = 'Blue'
      end
      object PanelCurPlayer: TPanel
        Left = 9
        Top = 20
        Width = 16
        Height = 16
        BevelInner = bvLowered
        BevelOuter = bvLowered
        Color = clBlue
        TabOrder = 0
      end
      object ButtonSwapPlayer: TButton
        Left = 102
        Top = 16
        Width = 75
        Height = 22
        Caption = 'Swap'
        TabOrder = 1
        OnClick = ButtonSwapPlayerClick
      end
    end
    object GroupMoves: TGroupBox
      Left = 8
      Top = 56
      Width = 185
      Height = 389
      Anchors = [akLeft, akTop, akBottom]
      Caption = ' Moves '
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 1
      DesignSize = (
        185
        389)
      object ListBoxHistory: TListBox
        Left = 7
        Top = 46
        Width = 170
        Height = 305
        Anchors = [akLeft, akTop, akBottom]
        Ctl3D = False
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = []
        ItemHeight = 16
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
      end
      object ButtonUndo: TButton
        Left = 103
        Top = 357
        Width = 74
        Height = 22
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Undo'
        TabOrder = 1
        OnClick = ButtonUndoClick
      end
      object ButtonClear: TButton
        Left = 7
        Top = 357
        Width = 75
        Height = 22
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Clear'
        TabOrder = 2
        OnClick = ButtonClearClick
      end
      object ButtonAdd: TButton
        Left = 102
        Top = 17
        Width = 75
        Height = 22
        Caption = 'Add'
        TabOrder = 3
        OnClick = ButtonAddClick
      end
      object EditInput: TMaskEdit
        Left = 8
        Top = 19
        Width = 89
        Height = 19
        AutoSize = False
        EditMask = '>L-99;1; '
        MaxLength = 4
        TabOrder = 4
        Text = ' -  '
        OnKeyDown = EditInputKeyDown
      end
    end
    object GroupAI: TGroupBox
      Left = 8
      Top = 449
      Width = 185
      Height = 77
      Anchors = [akLeft, akBottom]
      Caption = ' Artificial Intelligence '
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 2
      object LabelMaxTime: TLabel
        Left = 11
        Top = 22
        Width = 86
        Height = 13
        Caption = 'Max Time (ms)'
      end
      object ButtonHint: TButton
        Left = 103
        Top = 44
        Width = 75
        Height = 22
        Caption = 'Hint'
        TabOrder = 0
        OnClick = ButtonHintClick
      end
      object MaxTimeEdit: TMaskEdit
        Left = 103
        Top = 19
        Width = 74
        Height = 19
        AutoSize = False
        EditMask = '99999;1; '
        MaxLength = 5
        TabOrder = 1
        Text = '1000 '
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 531
    Width = 728
    Height = 19
    Panels = <
      item
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Width = 530
      end
      item
        Width = 104
      end
      item
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Width = 100
      end>
  end
end
