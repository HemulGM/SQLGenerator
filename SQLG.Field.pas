unit SQLG.Field;

interface

uses
  System.SysUtils, System.Rtti, SQLG.Condition, SQLG.Select, SQLG.Params,
  System.TypInfo;

type
  TTableField<T> = record
  public
    FieldName: string;
    TableName: string;
    Attributes: TArray<TCustomAttribute>;
    Alias: string;
    class operator Equal(Left, Right: TTableField<T>): TSQLCondition;
    class operator Equal(Left: TTableField<T>; Right: T): TSQLCondition;
    class operator NotEqual(Left: TTableField<T>; Right: TTableField<T>): TSQLCondition;
    //
    class operator in(Left: TTableField<T>; Right: TArray<T>): TSQLCondition;
    class operator in(Left: TTableField<T>; Right: TSQLSelect): TSQLCondition;
    //
    class operator Implicit(Left: TTableField<T>): TValue;
    //
    class operator Add(Left, Right: TTableField<T>): TSQLCondition;
    //
    class operator LogicalAnd(Left: TTableField<T>; Right: Integer): TTableField<T>;
    class operator LogicalOr(Left: TTableField<T>; Right: Integer): TTableField<T>;
    class operator LogicalXOr(Left, Right: TTableField<T>): TSQLCondition;
    class operator LogicalNot(Left: TTableField<T>): TTableField<T>;
    //
    class operator LeftShift(Left: TTableField<T>; Right: Integer): TTableField<T>;
    class operator RightShift(Left: TTableField<T>; Right: Integer): TTableField<T>;
    //
    class operator BitwiseXOr(Left: TTableField<T>; Right: Integer): TTableField<T>;
    //
    constructor Create(ATableName, AFieldName: string);
    function FullFieldName: string;
    function Table(const TableName: string): TTableField<T>;
    function &As(const Value: string): TTableField<T>;
  end;

  Field = record
    type
      TypeReal = TTableField<Double>;


      TFInteger = TTableField<Integer>;


      TFString = TTableField<string>;


      TFVARCHAR = TTableField<string>;


      TFGUID = TTableField<TGUID>;
  end;
  {
  bigint,
  bit,
  bit varying,
  boolean,
  char,
  character varying,
  character,
  varchar,
  date,
  double precision,
  integer,
  interval,
  numeric,
  decimal,
  real,
  smallint,
  time (with or without time zone),
  timestamp (with or without time zone),
  xml    }

  TFFloat = TTableField<Double>;

  TFInteger = TTableField<Integer>;

  TFString = TTableField<string>;

  TFVARCHAR = TTableField<string>;

  TFGUID = TTableField<TGUID>;


function IsSQLField(const Value: TValue): Boolean;

function GetFieldName(const Value: TValue): string; overload;

function GetFieldName(const TableAlias: string; const Value: TValue): string; overload;

implementation

uses
  System.StrUtils;

procedure ForEachFieldType(Proc: TProc<TTypeInfo>);
begin
  Proc(TTypeInfo(PTypeInfo(TypeInfo(TFInteger))^));
  Proc(TTypeInfo(PTypeInfo(TypeInfo(TFFloat))^));
  Proc(TTypeInfo(PTypeInfo(TypeInfo(TFString))^));
  Proc(TTypeInfo(PTypeInfo(TypeInfo(TFVARCHAR))^));
  Proc(TTypeInfo(PTypeInfo(TypeInfo(TFGUID))^));
end;

function IsSQLField(const Value: TValue): Boolean;
begin
  if Value.IsType<TFInteger>(False) then
    Exit(True)
  else if Value.IsType<TFGUID>(False) then
    Exit(True)
  else if Value.IsType<TFString>(False) then
    Exit(True);
  Result := False;
end;

function GetFieldName(const Value: TValue): string;
begin
  if Value.IsType<TFInteger>(False) then
    Exit(Value.AsType<TFInteger>(False).FullFieldName)
  else if Value.IsType<TFGUID>(False) then
    Exit(Value.AsType<TFGUID>(False).FullFieldName)
  else if Value.IsType<TFString>(False) then
    Exit(Value.AsType<TFString>(False).FullFieldName);
  Result := '';
end;

function GetFieldName(const TableAlias: string; const Value: TValue): string;
begin
  if TableAlias.IsEmpty then
    Exit(GetFieldName(Value));
  if Value.IsType<TFInteger>(False) then
  begin
    var FField := Value.AsType<TFInteger>(False);
    Exit(TableAlias + '.' + FField.FieldName + IfThen(not FField.Alias.IsEmpty, ' ' + FField.Alias));
  end
  else if Value.IsType<TFGUID>(False) then
  begin
    var FField := Value.AsType<TFGUID>(False);
    Exit(TableAlias + '.' + FField.FieldName + IfThen(not FField.Alias.IsEmpty, ' ' + FField.Alias));
  end
  else if Value.IsType<TFString>(False) then
  begin
    var FField := Value.AsType<TFString>(False);
    Exit(TableAlias + '.' + FField.FieldName + IfThen(not FField.Alias.IsEmpty, ' ' + FField.Alias));
  end;
  Result := '';
end;

{ TTableField<T> }

class operator TTableField<T>.Add(Left, Right: TTableField<T>): TSQLCondition;
begin
  Result.Left := Left.FullFieldName;
  Result.Right := Right.FullFieldName;
  Result.Op := TSQLConditionOperation.coAdd;
end;

function TTableField<T>. &As(const Value: string): TTableField<T>;
begin
  Result := Self;
  Result.Alias := Value;
end;

constructor TTableField<T>.Create(ATableName, AFieldName: string);
begin
  FieldName := AFieldName;
  TableName := ATableName;
end;

class operator TTableField<T>.Equal(Left, Right: TTableField<T>): TSQLCondition;
begin
  Result.Left := Left.FullFieldName;
  Result.Right := Right.FullFieldName;
  Result.Op := TSQLConditionOperation.coEqual;
end;

class operator TTableField<T>.Equal(Left: TTableField<T>; Right: T): TSQLCondition;
begin
  Result.Left := Left.FullFieldName;
  Result.Right := TValue.From(Param('', TValue.From<T>(Right)));
  Result.Op := TSQLConditionOperation.coEqual;
end;

function TTableField<T>.FullFieldName: string;
begin
  Result := TableName + '.' + FieldName + IfThen(not Alias.IsEmpty, ' ' + Alias);
end;

class operator TTableField<T>.Implicit(Left: TTableField<T>): TValue;
begin
  Result := TValue.From(Left);
end;

class operator TTableField<T>.in(Left: TTableField<T>; Right: TSQLSelect): TSQLCondition;
begin
  Result.Left := Left.FullFieldName;
  Result.Right := TValue.From(Right);
  Result.Op := TSQLConditionOperation.coIn;
end;

class operator TTableField<T>.in(Left: TTableField<T>; Right: TArray<T>): TSQLCondition;
begin
  Result.Left := Left.FullFieldName;
  Result.Right := TValue.From(TParams.Params<T>('', Right));
  Result.Op := TSQLConditionOperation.coIn;
end;

class operator TTableField<T>.LeftShift(Left: TTableField<T>; Right: Integer): TTableField<T>;
begin
  Result := Left;
  Result.FieldName := Left.FieldName + ' << ' + Right.ToString;
end;

class operator TTableField<T>.LogicalAnd(Left: TTableField<T>; Right: Integer): TTableField<T>;
begin
  Result := Left;
  Result.FieldName := Left.FieldName + ' & ' + Right.ToString;
end;

class operator TTableField<T>.LogicalNot(Left: TTableField<T>): TTableField<T>;
begin
  Result := Left;
  Result.FieldName := ' ~ ' + Left.FieldName;
end;

class operator TTableField<T>.LogicalOr(Left: TTableField<T>; Right: Integer): TTableField<T>;
begin
  Result := Left;
  Result.FieldName := Left.FieldName + ' | ' + Right.ToString;
end;

class operator TTableField<T>.LogicalXOr(Left, Right: TTableField<T>): TSQLCondition;
begin

end;

class operator TTableField<T>.BitwiseXOr(Left: TTableField<T>; Right: Integer): TTableField<T>;
begin
  Result := Left;
  Result.FieldName := Left.FieldName + ' # ' + Right.ToString;
end;

class operator TTableField<T>.NotEqual(Left, Right: TTableField<T>): TSQLCondition;
begin
  Result.Left := Left.FullFieldName;
  Result.Right := Right.FullFieldName;
  Result.Op := TSQLConditionOperation.coNotEqual;
end;

class operator TTableField<T>.RightShift(Left: TTableField<T>; Right: Integer): TTableField<T>;
begin
  Result := Left;
  Result.FieldName := Left.FieldName + ' >> ' + Right.ToString;
end;

function TTableField<T>.Table(const TableName: string): TTableField<T>;
begin
  Result := Self;
  Result.TableName := TableName;
end;

end.

