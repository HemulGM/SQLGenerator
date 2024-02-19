unit SQLG.Table;

interface

uses
  System.Rtti, SQLG.Types;

type
  TSQLTable = class
  protected
    FTableName: string;
  public
    property TableName: string read FTableName;
    constructor Create;
  end;

var
  Context: TRttiContext;

implementation

uses
  SQLG.Field;

{ TSQLTable }

constructor TSQLTable.Create;
begin
  inherited;
  var FClass := Context.GetType(Self.ClassType);
  if FClass.HasAttribute(TableNameAttribute) then
    FTableName := FClass.GetAttribute<TableNameAttribute>.Value;
  for var FField in FClass.GetFields do
  begin
    if FField.HasAttribute(FieldNameAttribute) then
      if FField.FieldType.IsRecord then
      begin
        if FField.GetValue(Self).IsType<TFInteger>(False) then
          FField.SetValue(Self, TValue.From(TFInteger.Create(FTableName, FField.GetAttribute<FieldNameAttribute>.Value)))
        else if FField.GetValue(Self).IsType<TFString>(False) then
          FField.SetValue(Self, TValue.From(TFString.Create(FTableName, FField.GetAttribute<FieldNameAttribute>.Value)))
        else if FField.GetValue(Self).IsType<TFGUID>(False) then
          FField.SetValue(Self, TValue.From(TFGUID.Create(FTableName, FField.GetAttribute<FieldNameAttribute>.Value)));
      end;
  end;
end;

end.

