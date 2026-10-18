unit MES.Contract.Test;

{$I 'mes_test.inc'}

interface

uses
  Classes,
  SysUtils,
  GLV.Testing.Cross,
  MES.Contracts;

type
  TElementTest = class(TCrossTestCase)
  protected
    FElement: TElement;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSimple;
  end;

implementation

procedure TElementTest.SetUp;
begin
end;

procedure TElementTest.TearDown;
begin
end;

procedure TElementTest.TestSimple;
begin
  //Fail('Write your own test');
end;

initialization

CrossRegTest(TElementTest, 'Unit');

end.

