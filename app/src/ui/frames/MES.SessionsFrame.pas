unit MES.SessionsFrame;

{$I 'mes.inc'}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  StdCtrls,
  ComCtrls,
  Buttons, ExtCtrls,
  laz.VirtualTrees,
  GLV.UiRouter.Controller,
  GLV.UiRouter.RouterFrame,
  MES.SessionInputFrame,
  MES.Contracts, Graphics;

type

  {  }
  PSessionView = ^TSessionView;
  TSessionView = record
    Caption: string;
    Level: Integer;
  end;

  PElementWrapper = ^TElementWrapper;
  TElementWrapper = record
    Element: TElement;
  end;

  TVstColumnAdapter = class(TInterfacedObject, IDescribeAdapter)
  strict private
    FVst: TLazVirtualStringTree;
  public
    constructor Create(const InVst: TLazVirtualStringTree);
    destructor Destroy; override;
    procedure AddColumn(const InCaption: string);
  end;

  TSessionsFrame = class(TRouterFrame)
    Images: TImageList;
    Splitter1: TSplitter;
    VST_Elements: TLazVirtualStringTree;
    VST_Sessions: TLazVirtualStringTree;
    btn_New: TSpeedButton;
    btn_Del: TSpeedButton;
    btn_Save: TSpeedButton;
    btn_Load: TSpeedButton;
    ToolBar: TToolBar;
    procedure btn_DelClick(Sender: TObject);
    procedure btn_NewClick(Sender: TObject);
    procedure VST_ElementsBeforeCellPaint(Sender: TBaseVirtualTree;
                                          TargetCanvas: TCanvas;
                                          Node: PVirtualNode;
                                          Column: TColumnIndex;
                                          CellPaintMode: TVTCellPaintMode;
                                          CellRect: TRect;
                                          var ContentRect: TRect);
    procedure VST_ElementsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VST_ElementsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VST_ElementsInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure VST_ElementsPaintBackground(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; const R: TRect; var Handled: Boolean);

    procedure VST_SessionsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
  strict private
    FRootSession: PVirtualNode;
    FRootElements: PVirtualNode;
    FElements: TElements;
    FElementsAdapter: IDescribeAdapter;
    procedure VST_AddElement(const InElement: TElement);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    //
    procedure SetupSessionsTree;
    procedure SetupElementsGrid;
    //
    function ShowNewDialog: Boolean;
    procedure ShowNewDialogOnOk(Sender: TObject);
    //
    procedure AddSession;
    procedure RemSession;
  end;

implementation

{$R *.lfm}

uses
  MES.Backend;

{ TSessionsFrame }

procedure TSessionsFrame.VST_SessionsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  D: PSessionView;
begin
  D := Sender.GetNodeData(Node);
  if Assigned(D) then
  begin
    CellText := D.Caption;
    if D.Level = 0 then
    begin
      //if FSess
      if Node.ChildCount <= 0 then
        CellText := CellText + '(нет сессий)'
      else
        CellText := CellText + '(' + IntTOstr(Node.ChildCount) + ')'
    end;
  end
  else
    CellText := 'unknown_node';

end;

procedure TSessionsFrame.VST_AddElement(const InElement: TElement);
var
  P: PVirtualNode;
  W: PElementWrapper;
begin
  if not Assigned(InElement) then
    Exit;

  P := VST_Elements.AddChild(nil);
  W := VST_Elements.GetNodeData(P);
  W.Element := InElement;
end;

procedure TSessionsFrame.btn_NewClick(Sender: TObject);
begin
  AddSession;
end;

procedure TSessionsFrame.VST_ElementsBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
  W: PElementWrapper;
  El: TElement;
  TmpColor: TColor;
begin
  W := PElementWrapper(Sender.GetNodeData(Node));
  if not Assigned(W) then
    Exit;

  El := W.Element;

  if not Assigned(El) then
    Exit;

  case El.Status of
    sNew: TmpColor := clYellow;
    sVisited: TmpColor := clBlue;
    sPartial: TmpColor := clOlive;
    sDone: TmpColor := clGreen;
    sUnavailable : TmpColor := clRed;
  end;

  if CellPaintMode = cpmPaint then
  begin
    TargetCanvas.Brush.Color:=TmpColor;
    TargetCanvas.FillRect(CellRect);
  end;
end;

procedure TSessionsFrame.VST_ElementsFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  P: PElementWrapper;
begin
  P := Sender.GetNodeData(Node);
  if Assigned(P) then
    P.Element := nil;
end;

procedure TSessionsFrame.VST_ElementsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  P: PElementWrapper;
begin
  if not Assigned(Node) then
    Exit;

  P := Sender.GetNodeData(Node);
  if Assigned(P) then
  begin
    if Assigned(P.Element) then
    begin
      case Column of
        00: CellText := P.Element.Caption;
        01: CellText := P.Element.Kind;
        02: CellText := StatusAsStr(P.Element.Status);
      end;
    end
    else
      CellText := 'element not assigned';
  end
  else
    CellText := 'wrapper element not initialized';
end;

procedure TSessionsFrame.VST_ElementsInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  //
end;

procedure TSessionsFrame.VST_ElementsPaintBackground(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; const R: TRect; var Handled: Boolean);
begin
  //
//
//  Canvas.Brush.Color:=clGreen;
//  Canvas.Rectangle(R);
end;

procedure TSessionsFrame.btn_DelClick(Sender: TObject);
begin
  RemSession;
end;

procedure TSessionsFrame.AfterConstruction;
begin
  inherited AfterConstruction;
  SetupSessionsTree;
  SetupElementsGrid;
end;

procedure TSessionsFrame.BeforeDestruction;
begin
  FreeAndNil(FElements);
  FElementsAdapter := nil;
  inherited BeforeDestruction;
end;

procedure TSessionsFrame.SetupSessionsTree;
var
  D: PSessionView;
begin
  VST_Sessions.TreeOptions.SelectionOptions := VST_Sessions.TreeOptions.SelectionOptions + [toFullRowSelect];
  VST_Sessions.TreeOptions.SelectionOptions := VST_Sessions.TreeOptions.SelectionOptions - [toMultiSelect];

  FRootSession := nil;
  VST_Sessions.NodeDataSize:= Sizeof(TSessionView);

  FRootSession := VST_Sessions.AddChild(nil);
  D := PSessionView(VST_Sessions.GetNodeData(FRootSession));
  if Assigned(D) then
  begin
    D.Level := 0;
    D.Caption:= 'Сеанс';
  end;
  AddSession();
end;

procedure TSessionsFrame.SetupElementsGrid;
begin
  VST_ELements.NodeDataSize:= Sizeof(TElementWrapper);

  FElementsAdapter := TVstColumnAdapter.Create(VST_Elements);
  FElements:= CreateElements();
  FElements.Describe(FElementsAdapter);

  FRootElements := nil;

  VST_Elements.TreeOptions.PaintOptions :=
    VST_Elements.TreeOptions.PaintOptions
    - [toShowRoot, toShowTreeLines, toShowButtons];
  VST_Elements.NodeDataSize := Sizeof(TSessionView);
  VST_Elements.Header.Options := [hoVisible, hoColumnResize];
  VST_Elements.TreeOptions.SelectionOptions := VST_Elements.TreeOptions.SelectionOptions + [toFullRowSelect];
  VST_Elements.BeginUpdate;
  try
    FElements.ForEach(VST_AddElement);
  finally
    VST_Elements.EndUpdate;
  end;
end;

function TSessionsFrame.ShowNewDialog: Boolean;
var
  Form: TForm;
  MR: Integer;
  Frame: TSessionInputFrame;
begin
  Form := TForm.Create(nil);
  Form.Name := 'form_SessionNewDialog';
  Form.Width := 600;
  Form.Height := 300;

  Frame := TSessionInputFrame.Create(Form);
  Frame.Align := alClient;
  Frame.Parent := Form;
  Frame.OnOk:= nil;

  MR := Form.ShowModal;

  FreeAndNil(Form);
  Result := MR <> mrCancel;
end;

procedure TSessionsFrame.ShowNewDialogOnOk(Sender: TObject);
begin
  //Form.
end;

procedure TSessionsFrame.AddSession;
var
  P: PVirtualNode;
  D: PSessionView;
begin
  P := VST_Sessions.AddChild(FRootSession);
  D := PSessionView(VST_Sessions.GetNodeData(P));
  if Assigned(D) then
  begin
    D.Caption := 'Temp Session';
    D.Level := 1;
  end;
end;

procedure TSessionsFrame.RemSession;
var
  P: PVirtualNode;
begin
  P := VST_Sessions.GetFirstSelected();
  if P = nil then
    Exit;

  if P = VST_Sessions.RootNode then
    Exit;

  VST_Sessions.DeleteNode(P);
end;

constructor TVstColumnAdapter.Create(const InVst: TLazVirtualStringTree);
begin
  inherited Create;
  FVst := InVst;
end;

destructor TVstColumnAdapter.Destroy;
begin
  FVst := nil;
  inherited Destroy;
end;

procedure TVstColumnAdapter.AddColumn(const InCaption: string);
var
  Col: TVirtualTreeColumn;
begin
  Col := FVst.Header.Columns.Add;
  Col.Text:= InCaption;
  Col.Options := Col.Options + [coVisible];
end;

end.

