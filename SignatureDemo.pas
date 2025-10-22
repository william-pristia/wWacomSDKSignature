unit SignatureDemo;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    btnSign: TButton;
    procedure btnSignClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  wylib.Thirdparts.Classes.WacomSignature;

{$R *.dfm}

procedure TForm1.btnSignClick(Sender: TObject);
var
  LStream: TMemoryStream;
  LResult: TWACOMTableResultRecord;
begin
  LStream := TMemoryStream.Create;
  try
    LResult := TWACOMSignature.Run('', 'my company', 'reason', LStream);
    if LResult.ResultCode = 0 then
    begin
      Caption := LResult.SignHash;
    end;
  finally
    LStream.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Image1.Canvas.Create;
end;

end.
