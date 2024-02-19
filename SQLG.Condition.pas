unit SQLG.Condition;

interface

uses
  System.SysUtils, System.Rtti, SQLG.Params;

type
  TSQLConditionOperation = (
    // AND
    coAnd,
    // OR
    coOr,
    // NOT
    coNot,
    // XOR
    coXOr,
    // =
    coEqual,
    // <>
    coNotEqual,
    // <
    coLessThan,
    // <=
    coLessThanOrEqual,
    // >
    coGreaterThan,
    // >=
    coGreaterThanOrEqual, 
    // IN
    coIn,
    // +
    coAdd);

  TSQLConditionOperationHelper = record helper for TSQLConditionOperation
    function ToString: string;
  end;

  TSQLCondition = record
    Op: TSQLConditionOperation;
    Left, Right: TValue;
    class operator LogicalAnd(Left, Right: TSQLCondition): TSQLCondition;
    class operator LogicalOr(Left, Right: TSQLCondition): TSQLCondition;
    class operator LogicalNot(Right: TSQLCondition): TSQLCondition;
    function Build(var Params: TSQLParams; const Level: Integer = -1): string;
  end;

implementation

uses
  SQLG.Select;

function TSQLCondition.Build(var Params: TSQLParams; const Level: Integer): string;
begin
  Result := '';
  if Left.IsType<TSQLParam>(False) then
  begin
    var Param := Left.AsType<TSQLParam>;
    Param.Key := 'p' + Length(Params).ToString;
    Params := Params + [Param];
    Result := Result + ':' + Param.Key;
  end
  else if Left.IsType<TArray<TSQLParam>>(False) then
  begin
    var AParam := Left.AsType<TArray<TSQLParam>>;
    var InVal: TArray<string> := [];
    for var LParam in AParam do
    begin
      var Param := LParam;
      Param.Key := 'p' + Length(Params).ToString;
      Params := Params + [Param];
      InVal := InVal + [':' + Param.Key];
    end;
    if Length(InVal) > 0 then
      Result := Result + '(' + string.Join(', ', InVal) + ')';
  end
  else if Left.IsType<TSQLCondition>(False) then
  begin
    var Cond := Left.AsType<TSQLCondition>;
    Result := Result + '(' + Cond.Build(Params, Level + 1) + ')';
  end
  else if Left.IsType<TSQLSelect>(False) then
  begin
    var Select := Left.AsType<TSQLSelect>;
    Result := Result + '(' + Select.Build(Params, '', Level + 1) + ')';
  end
  else if Left.IsType<string>(False) then
    Result := Result + Left.AsString;

  if Result.IsEmpty then
    Result := Op.ToString + ' '
  else
    Result := Result + ' ' + Op.ToString + ' ';

  if Right.IsType<TSQLParam>(False) then
  begin
    var Param := Right.AsType<TSQLParam>;
    Param.Key := 'p' + Length(Params).ToString;
    Params := Params + [Param];
    Result := Result + ':' + Param.Key;
  end
  else if Right.IsType<TArray<TSQLParam>>(False) then
  begin
    var AParam := Right.AsType<TArray<TSQLParam>>;
    var InVal: TArray<string> := [];
    for var LParam in AParam do
    begin
      var Param := LParam;
      Param.Key := 'p' + Length(Params).ToString;
      Params := Params + [Param];
      InVal := InVal + [':' + Param.Key];
    end;
    if Length(InVal) > 0 then
      Result := Result + '(' + string.Join(', ', InVal) + ')';
  end
  else if Right.IsType<TSQLCondition>(False) then
  begin
    var Cond := Right.AsType<TSQLCondition>;
    Result := Result + '(' + Cond.Build(Params, Level + 1) + ')';
  end
  else if Right.IsType<TSQLSelect>(False) then
  begin
    var Select := Right.AsType<TSQLSelect>;
    Result := Result + '(' + Select.Build(Params, '', Level + 1) + ')';
  end
  else if Right.IsType<string>(False) then
    Result := Result + Right.AsString;
end;

class operator TSQLCondition.LogicalAnd(Left, Right: TSQLCondition): TSQLCondition;
begin
  Result.Op := coAnd;
  Result.Left := TValue.From(Left);
  Result.Right := TValue.From(Right);
end;

class operator TSQLCondition.LogicalNot(Right: TSQLCondition): TSQLCondition;
begin
  Result.Op := coNot;
  Result.Left := TValue.Empty;
  Result.Right := TValue.From(Right);
end;

class operator TSQLCondition.LogicalOr(Left, Right: TSQLCondition): TSQLCondition;
begin
  Result.Op := coOr;
  Result.Left := TValue.From(Left);
  Result.Right := TValue.From(Right);
end;

{ TSQLConditionOperationHelper }

function TSQLConditionOperationHelper.ToString: string;
begin
  case Self of
    coAnd:
      Exit('AND');
    coOr:
      Exit('OR');
    coNot:
      Exit('NOT');
    coEqual:
      Exit('=');
    coNotEqual:
      Exit('<>');
    coLessThan:
      Exit('<');
    coLessThanOrEqual:
      Exit('<=');
    coGreaterThan:
      Exit('>');
    coGreaterThanOrEqual:
      Exit('>=');
    coIn:
      Exit('in');
  end;
end;

end.

