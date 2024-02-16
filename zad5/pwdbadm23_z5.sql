USE DB_STAT

CREATE TABLE dbo.test_us_kol 
(	[id] nchar(6) not null
,	czy_wazny bit NOT NULL default 0 
)

INSERT INTO test_us_kol ([id]) VALUES (N'ala')
INSERT INTO test_us_kol ([id], czy_wazny) VALUES (N'kot', 1)
SELECT * FROM test_us_kol 
/*
id	czy_wazny
ala   	0
kot   	1
*/

/*1. Proszę poszukać/stworzyć zapytanie wyszukujące dla danej tabeli, danej kolumny - ograniczenia jakie są nałożone
*/
SELECT *
FROM sys.default_constraints 
WHERE parent_object_id = OBJECT_ID('dbo.test_us_kol')
  AND parent_column_id IN (
      SELECT column_id
      FROM sys.columns
      WHERE object_id = OBJECT_ID('dbo.test_us_kol')
        AND name = 'czy_wazny'
  );

/*
name							object_id	principal_id	schema_id	parent_object_id	type	type_desc			create_date
DF__test_us_k__czy_w__4222D4EF	1109578991	NULL			1			1093578934			D 		DEFAULT_CONSTRAINT	2023-12-26 23:17:14.513
*/

/*2.Stworzyć procedure usun_kolumne z parametrami @nazwa_tabeli, @nazwa_kolumny
która tworzy kursor z zapytania numer 1 i w petli kasuje wszystkie ograniczenia
na koncu kasuję tę kolumnę
*/
ALTER PROCEDURE RemoveColumn @TableName NVARCHAR(255), @ColumnName NVARCHAR(255)
AS
BEGIN
    DECLARE @SqlStatement NVARCHAR(MAX);

    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName AND COLUMN_NAME = @ColumnName
    )
    BEGIN
        -- Drop all default constraints on the table
        DECLARE @DefaultConstraintName NVARCHAR(255);

        DECLARE RemoveDefaultConstraints CURSOR FOR
        SELECT name
        FROM sys.default_constraints
        WHERE parent_object_id = OBJECT_ID(QUOTENAME(@TableName))

        OPEN RemoveDefaultConstraints;
        FETCH NEXT FROM RemoveDefaultConstraints INTO @DefaultConstraintName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SqlStatement = 'ALTER TABLE ' + QUOTENAME(@TableName) + ' DROP CONSTRAINT ' + QUOTENAME(@DefaultConstraintName);
            EXEC sp_executesql @SqlStatement;
            FETCH NEXT FROM RemoveDefaultConstraints INTO @DefaultConstraintName;
        END

        CLOSE RemoveDefaultConstraints;
        DEALLOCATE RemoveDefaultConstraints;

        SET @SqlStatement = 'ALTER TABLE ' + QUOTENAME(@TableName) + ' DROP COLUMN ' + QUOTENAME(@ColumnName);
		EXEC sp_executesql @SqlStatement;

    END
END;

/* 3. udowodnić na przykladzie jak powyżej że działa - jest kolumna przed
** ma ograniczenia a procedura usuwa ją i pokazujemy, że już nie ma takowej
*/
ALTER TABLE test_us_kol drop column czy_wazny
/*
Msg 5074, Level 16, State 1, Line 81
The object 'DF__test_us_k__czy_w__440B1D61' is dependent on column 'czy_wazny'.
Msg 4922, Level 16, State 9, Line 81
ALTER TABLE DROP COLUMN czy_wazny failed because one or more objects access this column.
*/

EXEC RemoveColumn 'test_us_kol', 'czy_wazny';

SELECT * FROM test_us_kol
/*
id
ala
kot
*/








