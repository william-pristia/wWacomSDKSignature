object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'TestSigCapt'
  ClientHeight = 474
  ClientWidth = 957
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 13
  object Image1: TImage
    Left = 16
    Top = 16
    Width = 473
    Height = 257
  end
  object btnSign: TButton
    Left = 707
    Top = 12
    Width = 113
    Height = 57
    Caption = 'Firma'
    TabOrder = 0
    OnClick = btnSignClick
  end
end
