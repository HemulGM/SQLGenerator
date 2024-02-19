# SQLGenerator

```pascal
uses
  System.SysUtils,
  System.TypInfo,
  System.Rtti,
  SQLG.Table in 'SQLG.Table.pas',
  SQLG.Field in 'SQLG.Field.pas',
  SQLG.Condition in 'SQLG.Condition.pas',
  SQLG.Params in 'SQLG.Params.pas',
  SQLG.Select in 'SQLG.Select.pas',
  SQLG.CreateTable in 'SQLG.CreateTable.pas',
  SQLG.Types in 'SQLG.Types.pas';

type
  [TableName('user')]
  TUser = class(TSQLTable)
    [FieldName('id'),
    UNIQUE,
    PRIMARYKEY]
    Id: TFGUID;
    [FieldName('role_id')]
    RoleId: TFGUID;
    [FieldName('status')]
    Status: TFInteger;
    [FieldName('name')]
    Name: TFString;
  end;

  [TableName('user_role')]
  TUserRole = class(TSQLTable)
    [FieldName('id')]
    Id: TFGUID;
    [FieldName('type')]
    RoleType: TFInteger;
    [FieldName('desc')]
    Desc: TFString;
    [FieldName('name'),
    LENGTH(20)]
    Name: TFVARCHAR;
  end;

procedure Test;
begin
  var User := TUser.Create;
  var UserRole := TUserRole.Create;

  var Params: TSQLParams;
  var Sel :=
    Select([User, UserRole.Desc.Table('ur').&As('description')]).
    From(User).
    LeftJoin(
    Select('*').
    From(UserRole).Where(UserRole.RoleType = 1), 'ur').
    on(User.RoleId = UserRole.Id.Table('ur')).
    Where(not (User.Id = TGUID.NewGuid) or (User.Status in [1, 2, 3])).
    Where(User.Status and 1 = 0).
    Where(User.Name = 'Dan').
    Where(User.Status in
    Select(User.Status).From(User).Where(User.RoleId in [TGUID.NewGuid, TGUID.NewGuid])).
    OrderBy([User.Name, DESC(User.Status)]).
    GroupBy([User.Id]);

  writeln(Sel.Build(Params));
  writeln;
  for var Param in Params do
    writeln(Param.Key, ': ', Param.Value.TypeInfo.Name, ' = ', Param.ToString);

  User.Free;
  UserRole.Free;
end;

begin
  try
    Test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

```

output

```
SELECT user.*, ur.desc description
 FROM user
 LEFT JOIN (
    SELECT *
     FROM user_role
     WHERE user_role.type = :p0) ur ON user.role_id = ur.id
 WHERE (NOT (user.id = :p1)) OR (user.status in (:p2, :p3, :p4)) AND user.status & 1 = :p5 AND user.name = :p6 AND user.status in (
    SELECT user.status
     FROM user
     WHERE user.role_id in (:p7, :p8))
 ORDER BY user.name, user.status DESC
 GROUP BY user.id

p0: Integer = 1
p1: TGUID = {4D8FD3C0-9972-4269-BBB6-34E3925EABE2}
p2: Integer = 1
p3: Integer = 2
p4: Integer = 3
p5: Integer = 0
p6: string = Dan
p7: TGUID = {2A37B58A-3B2F-4320-9850-A70AA70C3971}
p8: TGUID = {3FBC11F6-381F-4443-8592-1E5FC5CDF479}
```