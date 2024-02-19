unit SQLG.Select;

interface

uses
  System.SysUtils, System.Rtti, SQLG.Params, SQLG.Table, SQLG.Condition;

type
  TOrderField = record
    Field: TValue;
    OrderType: string;
    class operator Implicit(Left: TOrderField): TValue;
  end;

  TSQLSelect = record
    type
      TSQLJoin = record
      private
        FParent: TValue;
        FSelect: TValue;
        FSelectName: string;
        FOn: TSQLCondition;
        FPredict: string;
        FTable: TSQLTable;
      public
        function &On(const Condition: TSQLCondition): TSQLSelect;
        function Build(var Params: TSQLParams; const Level: Integer = -1): string;
      end;
  private
    FFields: TArray<TValue>;
    FFroms: TArray<TValue>;
    FWheres: TArray<TSQLCondition>;
    FJoins: TArray<TSQLJoin>;
    FOrderBy: TArray<TValue>;
    FGroupBy: TArray<TValue>;
  public
    function Build(var Params: TSQLParams; const Alias: string = ''; const Level: Integer = -1): string;
    function From(const Items: TArray<TValue>): TSQLSelect; overload;
    function From(const Item: TValue): TSQLSelect; overload;
    function Where(const Condition: TSQLCondition): TSQLSelect;
    function Join(const Table: TSQLTable): TSQLJoin; overload;
    function Join(const Select: TSQLSelect; const Alias: string): TSQLJoin; overload;
    function LeftJoin(const Table: TSQLTable): TSQLJoin; overload;
    function LeftJoin(const Select: TSQLSelect; const Alias: string): TSQLJoin; overload;
    function RightJoin(const Table: TSQLTable): TSQLJoin; overload;
    function RightJoin(const Select: TSQLSelect; const Alias: string): TSQLJoin; overload;
    function OrderBy(const Fields: TArray<TValue>): TSQLSelect; overload;
    function OrderBy(const Field: TValue): TSQLSelect; overload;
    function GroupBy(const Fields: TArray<TValue>): TSQLSelect; overload;
    function GroupBy(const Field: TValue): TSQLSelect; overload;
  end;

function Select(Fields: TArray<TValue>): TSQLSelect; overload;

function Select(Fields: TValue): TSQLSelect; overload;

function ASC(Field: TValue): TOrderField;

function DESC(Field: TValue): TOrderField;

implementation

uses
  SQLG.Field;

function Select(Fields: TArray<TValue>): TSQLSelect;
begin
  Result.FFields := Fields;
end;

function Select(Fields: TValue): TSQLSelect;
begin
  Result.FFields := [Fields];
end;

function ASC(Field: TValue): TOrderField;
begin
  Result.Field := Field;
  Result.OrderType := 'ASC';
end;

function DESC(Field: TValue): TOrderField;
begin
  Result.Field := Field;
  Result.OrderType := 'DESC';
end;

{ TSQLSelect }

function TSQLSelect.Build(var Params: TSQLParams; const Alias: string; const Level: Integer): string;
begin
  // SELECT
  var FieldList: TArray<string>;
  for var Field in FFields do
  begin
    if Field.IsType<TSQLTable>(False) then
      FieldList := FieldList + [Field.AsType<TSQLTable>(False).TableName + '.*']
    else if IsSQLField(Field) then
      FieldList := FieldList + [GetFieldName(Alias, Field)]
    else if Field.IsType<string>(False) then
      FieldList := FieldList + [Field.AsString];
  end;
  if Level >= 0 then
    Result := Result + #13#10;
  for var i := 0 to Level do
    Result := Result + '  ';
  Result := Result + 'SELECT ' + string.Join(', ', FieldList);

  // FROM
  if Length(FFroms) > 0 then
  begin
    Result := Result + #13#10;
    for var i := 0 to Level do
      Result := Result + '  ';
    var FromList: TArray<string>;
    for var From in FFroms do
    begin
      if From.IsType<TSQLTable>(False) then
      begin
        FromList := FromList + [From.AsType<TSQLTable>(False).TableName];
      end;
    end;
    Result := Result + ' FROM ' + string.Join(', ', FromList);
  end;

  // JOIN
  if Length(FJoins) > 0 then
  begin
    Result := Result + #13#10;
    for var i := 0 to Level do
      Result := Result + '  ';
    var JoinList: TArray<string>;
    for var Join in FJoins do
      JoinList := JoinList + [Join.Build(Params, Level + 1)];
    Result := Result + string.Join(#13#10, JoinList);
  end;

  // WHERE
  if Length(FWheres) > 0 then
  begin
    Result := Result + #13#10;
    for var i := 0 to Level do
      Result := Result + '  ';
    var WhereList: TArray<string>;
    for var Where in FWheres do
      WhereList := WhereList + [Where.Build(Params, Level + 1)];
    Result := Result + ' WHERE ' + string.Join(' AND ', WhereList);
  end;

  // ORDER BY
  if Length(FOrderBy) > 0 then
  begin
    Result := Result + #13#10;
    for var i := 0 to Level do
      Result := Result + '  ';
    var OrderList: TArray<string>;
    for var OrderBy in FOrderBy do
    begin
      if IsSQLField(OrderBy) then
        OrderList := OrderList + [GetFieldName(Alias, OrderBy)]
      else if OrderBy.IsType<TOrderField>(False) then
        OrderList := OrderList + [GetFieldName(Alias, OrderBy.AsType<TOrderField>.Field) + ' ' + OrderBy.AsType<TOrderField>.OrderType]
    end;
    Result := Result + ' ORDER BY ' + string.Join(', ', OrderList);
  end;

  // GROUP BY
  if Length(FGroupBy) > 0 then
  begin
    Result := Result + #13#10;
    for var i := 0 to Level do
      Result := Result + '  ';
    var GroupList: TArray<string>;
    for var GroupBy in FGroupBy do
    begin
      if IsSQLField(GroupBy) then
        GroupList := GroupList + [GetFieldName(Alias, GroupBy)];
    end;
    Result := Result + ' GROUP BY ' + string.Join(', ', GroupList);
  end;
end;

function TSQLSelect.From(const Items: TArray<TValue>): TSQLSelect;
begin
  FFroms := Items;
  Result := Self;
end;

function TSQLSelect.From(const Item: TValue): TSQLSelect;
begin
  FFroms := FFroms + [Item];
  Result := Self;
end;

function TSQLSelect.GroupBy(const Field: TValue): TSQLSelect;
begin
  FGroupBy := FGroupBy + [Field];
  Result := Self;
end;

function TSQLSelect.GroupBy(const Fields: TArray<TValue>): TSQLSelect;
begin
  FGroupBy := FGroupBy + Fields;
  Result := Self;
end;

function TSQLSelect.Join(const Select: TSQLSelect; const Alias: string): TSQLJoin;
begin
  Result.FPredict := ' ';
  Result.FTable := nil;
  Result.FSelectName := Alias;
  Result.FSelect := TValue.From(Select);
  Result.FParent := TValue.From(Self);
end;

function TSQLSelect.LeftJoin(const Select: TSQLSelect; const Alias: string): TSQLJoin;
begin
  Result.FPredict := ' LEFT ';
  Result.FTable := nil;
  Result.FSelectName := Alias;
  Result.FSelect := TValue.From(Select);
  Result.FParent := TValue.From(Self);
end;

function TSQLSelect.OrderBy(const Field: TValue): TSQLSelect;
begin
  FOrderBy := FOrderBy + [Field];
  Result := Self;
end;

function TSQLSelect.OrderBy(const Fields: TArray<TValue>): TSQLSelect;
begin
  FOrderBy := FOrderBy + Fields;
  Result := Self;
end;

function TSQLSelect.Join(const Table: TSQLTable): TSQLJoin;
begin
  Result.FPredict := ' ';
  Result.FTable := Table;
  Result.FParent := TValue.From(Self);
end;

function TSQLSelect.LeftJoin(const Table: TSQLTable): TSQLJoin;
begin
  Result.FPredict := ' LEFT ';
  Result.FTable := Table;
  Result.FParent := TValue.From(Self);
end;

function TSQLSelect.RightJoin(const Table: TSQLTable): TSQLJoin;
begin
  Result.FPredict := ' RIGHT ';
  Result.FTable := Table;
  Result.FParent := TValue.From(Self);
end;

function TSQLSelect.Where(const Condition: TSQLCondition): TSQLSelect;
begin
  FWheres := FWheres + [Condition];
  Result := Self;
end;

function TSQLSelect.RightJoin(const Select: TSQLSelect; const Alias: string): TSQLJoin;
begin
  Result.FPredict := ' RIGHT ';
  Result.FTable := nil;
  Result.FSelectName := Alias;
  Result.FSelect := TValue.From(Select);
  Result.FParent := TValue.From(Self);
end;

{ TSQLSelect.TSQLJoin }

function TSQLSelect.TSQLJoin.Build(var Params: TSQLParams; const Level: Integer): string;
begin
  if FTable <> nil then
    Result := FPredict + 'JOIN ' + FTable.TableName
  else
    Result := FPredict + 'JOIN (' + FSelect.AsType<TSQLSelect>.Build(Params, '', Level + 1) + ') ' + FSelectName;
  Result := Result + ' ON ' + FOn.Build(Params);
end;

function TSQLSelect.TSQLJoin.&On(const Condition: TSQLCondition): TSQLSelect;
begin
  FOn := Condition;
  Result := FParent.AsType<TSQLSelect>;
  Result.FJoins := Result.FJoins + [Self];
end;

{ TOrderField }

class operator TOrderField.Implicit(Left: TOrderField): TValue;
begin
  Result := TValue.From(Left);
end;

end.

