unit SQLG.Params;

interface

uses
  System.Rtti, System.SysUtils;

type
  TSQLParam = record
    Key: string;
    Value: TValue;
    AsType: string;
    function KeyWithCast: string;
    constructor Create(const Key: string; const Value: TValue);
    function ToString: string;
  end;

  TSQLParams = TArray<TSQLParam>;

  TEmptyGUID = record
    class function Create: TEmptyGUID; static;
  end;

  TParams = class
    class function Params<T>(const Name: string; const Values: TArray<T>; AsType: string = ''): TArray<TSQLParam>;
  end;

function Param(const Name: string; const Value: TValue; AsType: string = ''): TSQLParam; overload;

function Param(const Name: string; const Value: TGUID; AsType: string = ''): TSQLParam; overload;

function Params(const Name: string; const Values: TArray<Integer>; AsType: string = ''): TArray<TSQLParam>; overload;

function Params(const Name: string; const Values: TArray<string>; AsType: string = ''): TArray<TSQLParam>; overload;

function Params(const Name: string; const Values: TArray<TGUID>; AsType: string = ''): TArray<TSQLParam>; overload;

function ToJson: string;

function CreateGUID(const Value: TGUID): TValue; overload;

function CreateGUID(const Value: string): TValue; overload;

implementation

function CreateGUID(const Value: TGUID): TValue;
begin
  Result := TValue.From<TGUID>(Value);
end;

function CreateGUID(const Value: string): TValue;
begin
  if Value = '' then
    Result := TValue.From<TEmptyGUID>(TEmptyGUID.Create)
  else
    Result := TValue.From<TGUID>(TGUID.Create(Value));
end;

function Param(const Name: string; const Value: TValue; AsType: string = ''): TSQLParam;
begin
  Result := TSQLParam.Create(Name, Value);
  Result.AsType := AsType;
end;

function Param(const Name: string; const Value: TGUID; AsType: string = ''): TSQLParam;
begin
  Result := TSQLParam.Create(Name, CreateGUID(Value));
  Result.AsType := AsType;
end;

function Params(const Name: string; const Values: TArray<Integer>; AsType: string = ''): TArray<TSQLParam>;
begin
  for var Value in Values do
  begin
    var Param := TSQLParam.Create(Name, Value);
    Param.AsType := AsType;
    Result := Result + [Param];
  end;
end;

function Params(const Name: string; const Values: TArray<string>; AsType: string = ''): TArray<TSQLParam>;
begin
  for var Value in Values do
  begin
    var Param := TSQLParam.Create(Name, Value);
    Param.AsType := AsType;
    Result := Result + [Param];
  end;
end;

function Params(const Name: string; const Values: TArray<TGUID>; AsType: string = ''): TArray<TSQLParam>;
begin
  for var Value in Values do
  begin
    var Param := TSQLParam.Create(Name, CreateGUID(Value));
    Param.AsType := AsType;
    Result := Result + [Param];
  end;
end;

function ToJson: string;
begin
  Result := 'to_json';
end;

{ TSQLParam }

constructor TSQLParam.Create(const Key: string; const Value: TValue);
begin
  Self.Key := Key;
  Self.Value := Value;
end;

function TSQLParam.KeyWithCast: string;
begin
  if AsType.IsEmpty then
    Result := ':' + Key
  else if AsType = ToJson then
    Result := 'to_json(:' + Key + ')'
  else
    Result := 'CAST(:' + Key + ' as ' + AsType + ')';
end;

function TSQLParam.ToString: string;
begin
  if Value.IsType<TGUID>(False) then
    Exit(Value.AsType<TGUID>.ToString);
  try
    Result := Value.ToString;
  except
    Result := '?';
  end;
end;

{ TEmptyGUID }

class function TEmptyGUID.Create: TEmptyGUID;
begin
  // empty
end;

{ TParams }

class function TParams.Params<T>(const Name: string; const Values: TArray<T>; AsType: string): TArray<TSQLParam>;
begin
  for var Value in Values do
  begin
    var Param := TSQLParam.Create(Name, TValue.From<T>(Value));
    Param.AsType := AsType;
    Result := Result + [Param];
  end;
end;

end.

