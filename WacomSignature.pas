unit WacomSignature;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.ExtCtrls,
  FLSIGCTLLib_TLB;

// REQUIRE DRIVER "Wacom-STU-Driver-5.4.5.exe"
// REQUIRE SDK "sdk-for-signature-windows-4.8.2.zip"

type
  TWACOMTabletResultCode = (wcNone, wcUnexpected, wcOk, wcCancel, wcNoService, wcNoDevice);

  TWACOMTableResultRecord = record
  public
    ResultClass: TWACOMTabletResultCode;
    ResultCode: Integer;
    SignHash: string;
    Graphometrics: string;
    GraphoHash: string;
    DigitizerModel: string;
    DigitizerDriver: string;
    procedure Clear;
  end;

  TWACOMSignature = class(TObject)
  private const
    cFreeLicense =
      'eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI3YmM5Y2IxYWIxMGE0NmUxODI2N2E5MTJkYTA2ZTI3NiIsImV4cCI6MjE0NzQ4MzY0NywiaWF0IjoxNTYwOTUwMjcyLCJyaWdodHMiOlsiU0lHX1NES19DT1JFIiwiU0lHQ0FQVFhfQUNDRVNTIl0sImRldmljZXMiOlsiV0FDT01fQU5ZIl0sInR5cGUiOiJwcm9kIiwibGljX25hbWUiOiJTaWduYXR1cmUgU0RLIiwid2Fjb21faWQiOiI3YmM5Y2IxYWIxMGE0NmUxODI2N2E5MTJkYTA2ZTI3NiIsImxpY191aWQiOiJiODUyM2ViYi0xOGI3LTQ3OGEtYTlkZS04NDlmZTIyNmIwMDIiLCJhcHBzX3dpbmRvd3MiOltdLCJhcHBzX2lvcyI6W10sImFwcHNfYW5kcm9pZCI6W10sIm1hY2hpbmVfaWRzIjpbXX0.ONy3iYQ7lC6rQhou7rz4iJT_OJ20087gWz7GtCgYX3uNtKjmnEaNuP3QkjgxOK_vgOrTdwzD-nm-ysiTDs2GcPlOdUPErSp_bcX8kFBZVmGLyJtmeInAW6HuSp2-57ngoGFivTH_l1kkQ1KMvzDKHJbRglsPpd4nVHhx9WkvqczXyogldygvl0LRidyPOsS5H2GYmaPiyIp9In6meqeNQ1n9zkxSHo7B11mp_WXJXl0k1pek7py8XYCedCNW5qnLi4UCNlfTd6Mk9qz31arsiWsesPeR9PN121LBJtiPi023yQU8mgb9piw_a-ccciviJuNsEuRDN3sGnqONG3dMSA';
  private
    FProvider: string;
    FLicense: string;
    FInkWidth: Real;
    procedure SetProvider(const Value: string);
    procedure SetInkWidth(const Value: Real);
  public
    class function Run(const ALicense: string; const AWho, AWhy: string; AImage: TImage): TWACOMTableResultRecord; overload;
    class function Run(const ALicense: string; const AWho, AWhy: string; AStream: TMemoryStream; const AWidth: Integer = 480; const AHeight: Integer = 150): TWACOMTableResultRecord; overload;
  public
    constructor Create(const ALicense: string); reintroduce; virtual;

    function CaptureSignature(const AWho, AWhy: string; AImage: TImage): TWACOMTableResultRecord; overload;
    function CaptureSignature(const AWho, AWhy: string; const AWidth, AHeight: Integer; AStream: TMemoryStream): TWACOMTableResultRecord; overload;

    property License: string read FLicense;
    property Provider: string read FProvider write SetProvider;
    property InkWidth: Real read FInkWidth write SetInkWidth;
  end;

implementation

uses
  System.Hash,
  Vcl.Imaging.pngimage;

const
  cSECRET_KEY = '8972C394369832B07076484D19D4ABEC96613A8C8788948DA908D5AB09B640A0'; //change this

  TWACOMTabletAdditionalDataDigitizer = 26;
  TWACOMTabletAdditionalDataDriver = 27;
  TWACOMTabletAdditionalDataMachineOS = 28;
  TWACOMTabletAdditionalDataNetworkCard = 29;

  { TWACOMSignature }

class function TWACOMSignature.Run(const ALicense, AWho, AWhy: string; AStream: TMemoryStream; const AWidth: Integer = 480; const AHeight: Integer = 150): TWACOMTableResultRecord;
var
  LWacomDevice: TWACOMSignature;
begin
  LWacomDevice := TWACOMSignature.Create(ALicense);
  Result := LWacomDevice.CaptureSignature(AWho, AWhy, AWidth, AHeight, AStream);
  LWacomDevice.Free;
end;

class function TWACOMSignature.Run(const ALicense: string; const AWho, AWhy: string; AImage: TImage): TWACOMTableResultRecord;
var
  LWacomDevice: TWACOMSignature;
begin
  LWacomDevice := TWACOMSignature.Create(ALicense);
  Result := LWacomDevice.CaptureSignature(AWho, AWhy, AImage);
  LWacomDevice.Free;
end;

constructor TWACOMSignature.Create(const ALicense: string);
begin
  inherited Create;
  FInkWidth := 0.5;
  FLicense := ALicense;
  FProvider := '';
end;

procedure TWACOMSignature.SetInkWidth(const Value: Real);
begin
  FInkWidth := Value;
end;

procedure TWACOMSignature.SetProvider(const Value: string);
begin
  FProvider := Value;
end;

function TWACOMSignature.CaptureSignature(const AWho, AWhy: string; const AWidth, AHeight: Integer; AStream: TMemoryStream): TWACOMTableResultRecord;
var
  LSignatureControl: TSigCtl;
  LComunicationResult: CaptureResult;
  LSignatureContainer: SigObj;
  LString: string;
  LData: OleVariant;
  DataPtr: Pointer;
  DataSize: Integer;
begin
  Result.Clear;
  AStream.Clear;
  LSignatureControl := TSigCtl.Create(nil);
  try
    if FLicense <> '' then
    begin
      LSignatureControl.SetProperty('Licence', FLicense);
    end
    else
    begin
      LSignatureControl.SetProperty('Licence', cFreeLicense);
    end;
    LComunicationResult := LSignatureControl.Capture(AWho, AWhy);
    if LComunicationResult = CaptureOK then
    begin
      Result.ResultClass := wcOk;
      Result.ResultCode := 0;
      LSignatureContainer := SigObj(LSignatureControl.Signature);
      if FProvider <> '' then
      begin
        LSignatureContainer.ExtraData['AdditionalData'] := FProvider;
      end;
      LData := LSignatureContainer.RenderBitmap('', AWidth, AHeight, 'image/png', FInkWidth, $FF0000, $FFFFFF, -1.0, -1.0, RenderOutputBinary or RenderColor24BPP);
      DataSize := VarArrayHighBound(LData, 1) - VarArrayLowBound(LData, 1) + 1;
      if DataSize > 0 then
      begin
        DataPtr := VarArrayLock(LData);
        try
          AStream.Write(DataPtr^, DataSize);
          AStream.Position := 0;
          if AStream.Size > 0 then
          begin
            LString := VarToStr(LSignatureContainer.SigText);
            Result.Graphometrics := LString;
            Result.SignHash := ''; // implement what you like
            Result.GraphoHash := ''; // implement what you like
            Result.DigitizerModel := VarToStr(LSignatureContainer.AdditionalData[TWACOMTabletAdditionalDataDigitizer]);
            Result.DigitizerDriver := VarToStr(LSignatureContainer.AdditionalData[TWACOMTabletAdditionalDataDriver]);
            AStream.Position := 0;
          end;
        finally
          VarArrayUnlock(LData);
        end;
      end;
    end
    else
    begin
      Result.ResultCode := LComunicationResult;
      case LComunicationResult of
        CaptureCancel:
          begin
            Result.ResultClass := wcCancel;
          end;
        CaptureError:
          begin
            Result.ResultClass := wcNoService;
          end;
        CapturePadError:
          begin
            Result.ResultClass := wcNoDevice;
          end;
      else
        begin
          Result.ResultClass := wcUnexpected;
        end;
      end;
    end;
  finally
    LSignatureControl.Free;
  end;
end;

function TWACOMSignature.CaptureSignature(const AWho, AWhy: string; AImage: TImage): TWACOMTableResultRecord;
var
  LPng: TPngImage;
  LStream: TMemoryStream;
begin
  LStream := TMemoryStream.Create;
  LPng := TPngImage.Create;
  try
    Result := CaptureSignature(AWho, AWhy, AImage.Width, AImage.Height, LStream);
    if Result.ResultClass = wcOk then
    begin
      LPng.LoadFromStream(LStream);
      AImage.Picture.Assign(LPng);
    end
    else
    begin
      AImage.Picture.Assign(nil);
    end;
  finally
    LPng.Free;
    LStream.Free;
  end;
end;

{ TWACOMTableResultRecord }

procedure TWACOMTableResultRecord.Clear;
begin
  ResultClass := wcNone;
  ResultCode := -1;
  Graphometrics := '';
  SignHash := '';
  GraphoHash := '';
  DigitizerModel := '';
  DigitizerDriver := '';
end;

end.
