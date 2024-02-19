program SQLG;

{$APPTYPE CONSOLE}

{$R *.res}

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

