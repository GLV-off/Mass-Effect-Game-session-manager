unit MES.Backend;

{$I 'mes.inc'}

interface

uses
  MES.Contracts;

function CreateElements: TElements;

implementation

function CreateElements: TElements;
var
  E: TElement;
begin
  Result := TElements.Create();

  E := TElement.Create('first');
  E.Kind:='planet';
  E.Status := sNew;
  Result.Add(E);

  E := TElement.Create('second');
  E.Kind:='station';
  E.Status := sPartial;
  Result.Add(E);

  E := TElement.Create('third');
  E.Kind:='ship';
  E.Status := sVisited;
  Result.Add(E);

  E := TElement.Create('forth');
  E.Kind:='planet';
  E.Status := sDone;
  Result.Add(E);

  E := TElement.Create('fifth');
  E.Kind:='plannet';
  E.Status := sUnavailable;
  Result.Add(E);
end;

end.

