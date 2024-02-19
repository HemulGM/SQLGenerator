unit SQLG.CreateTable;

interface

uses
  System.SysUtils, System.Rtti, SQLG.Params, SQLG.Table;

type
  TSQLCreateTable = record
  private
    FTable: TSQLTable;
    FIfNotExists: Boolean;
  public
    function Build(var Params: TSQLParams): string;
  end;

function CreateTable(const Table: TSQLTable): TSQLCreateTable; overload;

function CreateTableIfNotExists(const Table: TSQLTable): TSQLCreateTable; overload;

implementation

function CreateTableIfNotExists(const Table: TSQLTable): TSQLCreateTable;
begin
  Result.FTable := Table;
  Result.FIfNotExists := True;
end;

function CreateTable(const Table: TSQLTable): TSQLCreateTable;
begin
  Result.FTable := Table;
  Result.FIfNotExists := False;
end;

{ TSQLCreateTable }

function TSQLCreateTable.Build(var Params: TSQLParams): string;
begin

end;

end.

