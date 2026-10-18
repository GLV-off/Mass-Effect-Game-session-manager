unit MES.Contracts;

{$I 'mes.inc'}

interface

uses
  Generics.Collections;

type
  TStatus = (sNew, sVisited, sPartial, sDone, sUnavailable);

  TElement = class(TInterfacedObject)
  strict private
    FCaption: string;
    FKind: string;
    FStatus: TStatus;
  public
    constructor Create(const InCaption: string);
    destructor Destroy; override;
    property Caption: string read FCaption;
    property Kind: string read FKind write FKind;
    property Status: TStatus read FStatus write FStatus;
  end;

  IDescribeAdapter = interface
    procedure AddColumn(const InCaption: string);
  end;

  IElements = interface
    procedure Describe(const InAdapter: IDescribeAdapter);
  end;

  TElementProc = reference to procedure(const InElement: TElement);

  TElementsList = TObjectList<TElement>;

  TElements = class(TInterfacedObject, IElements)
  strict private
    FItems: TElementsList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const InElement: TElement);
    procedure Describe(const InAdapter: IDescribeAdapter); virtual;
    procedure ForEach(const InProc: TElementProc);
  end;

function StatusAsStr(const InStatus: TStatus): string;

implementation

uses
  SysUtils;

function StatusAsStr(const InStatus: TStatus): string;
begin
  case InStatus of
    sNew: Result := 'new';
    sVisited: Result := 'visited';
    sPartial: Result := 'partial';
    sDone: Result := 'done' ;
    sUnavailable: Result := 'unavailable';
  end;
end;

{ TElement }

constructor TElement.Create(const InCaption: string);
begin
  inherited Create;
  FCaption := InCaption;
  FKind := '';
  FStatus := TStatus.sNew;
end;

destructor TElement.Destroy;
begin
  FKind := '';
  FCaption := '';
  inherited Destroy;
end;

constructor TElements.Create;
begin
  inherited Create;
  FItems := TElementsList.Create(True);
end;

destructor TElements.Destroy;
begin
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TElements.Add(const InElement: TElement);
begin
  FItems.Add(InElement);
end;

procedure TElements.Describe(const InAdapter: IDescribeAdapter);
begin
  InAdapter.AddColumn('Caption');
  InAdapter.AddColumn('Kind');
  InAdapter.AddColumn('Status');
end;

procedure TElements.ForEach(const InProc: TElementProc);
var
  EL: TElement;
begin
  if not Assigned(InProc) then
    Exit;

  for El in FItems do
  begin
    InProc(EL);
  end;
end;

end.
