unit MES.SessionInputFrame;

{$I 'mes.inc'}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  StdCtrls;

type

  {
   TSessionInputFrame
  }
  TSessionInputFrame = class(TFrame)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    lbl_SessionName: TLabel;
    procedure Button1Click(Sender: TObject);
  strict private
    FOnOk: TNotifyEvent;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    property OnOk: TNotifyEvent read FOnOK write FOnOk;
  end;

implementation

{$R *.lfm}

{ ==== TSessionInputFrame =================================================== }

procedure TSessionInputFrame.Button1Click(Sender: TObject);
begin
  if Assigned(FOnOk) then
    FOnOk(Sender);
end;

procedure TSessionInputFrame.AfterConstruction;
begin
  inherited AfterConstruction;
  FOnOk := nil;
end;

procedure TSessionInputFrame.BeforeDestruction;
begin
  FOnOk := nil;
  inherited BeforeDestruction;
end;

{ =========================================================================== }

end.

