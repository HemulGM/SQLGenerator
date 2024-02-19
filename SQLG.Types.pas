unit SQLG.Types;

interface

uses
  System.Rtti, SQLG.Condition;

type
  TCustomAttributeValue<T> = class(TCustomAttribute)
  private
    FValue: T;
  public
    constructor Create(const Value: T);
    property Value: T read FValue;
  end;

  FieldNameAttribute = class(TCustomAttributeValue<string>);

  TableNameAttribute = class(TCustomAttributeValue<string>);

  DEFAULTAttribute = class(TCustomAttribute)
  private
    FValue: TValue;
  public
    constructor Create(const Value: Variant);
    property Value: TValue read FValue;
  end;

  UNIQUEAttribute = class(TCustomAttribute);

  NOTNULLAttribute = class(TCustomAttribute);

  PRIMARYKEYAttribute = class(TCustomAttribute);

  CHECKAttribute = class(TCustomAttributeValue<TSQLCondition>);

  LENGTHAttribute = class(TCustomAttributeValue<Integer>);

implementation

{ TCustomAttributeValue<T> }

constructor TCustomAttributeValue<T>.Create(const Value: T);
begin
  inherited Create;
  FValue := Value;
end;

{ DEFAULTAttribute }

constructor DEFAULTAttribute.Create(const Value: Variant);
begin
  inherited Create;
  FValue := TValue.From(Value);
end;

end.

