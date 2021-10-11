object Form2: TForm2
  Left = 364
  Top = 519
  BorderStyle = bsDialog
  Caption = ' Prise de pions'
  ClientHeight = 35
  ClientWidth = 197
  Color = clSkyBlue
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object BtAv: TButton
    Left = 5
    Top = 5
    Width = 91
    Height = 25
    Caption = 'Avant'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    OnClick = BtAvClick
  end
  object BtAr: TButton
    Left = 100
    Top = 5
    Width = 91
    Height = 25
    Caption = 'Arri'#232're'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 6
    ParentFont = False
    TabOrder = 1
    OnClick = BtArClick
  end
end
