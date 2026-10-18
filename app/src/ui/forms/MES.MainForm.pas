unit MES.MainForm;

{$I 'mes.inc'}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs, Menus,
  GLV.UiRouter.Controller;

type

  { TMainForm }

  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    mi_Main: TMenuItem;
    mi_Load: TMenuItem;
    mi_Exit: TMenuItem;
    MenuItem4: TMenuItem;
    mi_About: TMenuItem;
    mi_Sep: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mi_ExitClick(Sender: TObject);
  strict private
    FController: TFrameController;
  end;

  TMesFrameController = class(TFrameController)
  public
    function CreateRoutesDict: TRouteDict; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  MES.SessionsFrame;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  { todo: glv_off: Separate version managment in separate module }
  Caption := 'Mass effect session manager v 0.1.0';
  FController := TMesFrameController.Create(Self);
  FController.Push('sessions');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FController);
end;

procedure TMainForm.mi_ExitClick(Sender: TObject);
begin
  Close;
end;

{ TMesFrameController }

function TMesFrameController.CreateRoutesDict: TRouteDict;
begin
  Result := inherited CreateRoutesDict();
  Result.AddOrSetValue('sessions', TSessionsFrame);
end;

end.

