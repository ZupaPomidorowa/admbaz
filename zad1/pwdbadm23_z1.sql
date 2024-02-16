DECLARE @adm_db nvarchar(50), @sql nvarchar(2000)
SET @adm_db = N'APBD23_ADM'
if not exists (select 1 from sysdatabases d where d.name = @adm_db)
BEGIN
	SET @sql = N'CREATE database ' + @adm_db
	EXEC sp_sqlExec @sql
END

CREATE TABLE APBD23_ADM.dbo.CRDB_LOG 
(row_id int not null IDENTITY CONSTRAINT PK_CRDB_LOG PRIMARY KEY
, db_nam nvarchar(50) not null
, cr_dt datetime not null default GETDATE()
, err_msg nvarchar(200) NULL 
)

CREATE TABLE APBD23_ADM.dbo.CRUSR_LOG 
(row_id int not null IDENTITY CONSTRAINT PK_CRUSR_LOG PRIMARY KEY
, db_nam nvarchar(50) not null
, u_nam nvarchar(50) not null
, cr_dt datetime not null default GETDATE()
, err_msg nvarchar(200) NULL
)

CREATE OR ALTER PROCEDURE create_db
    @db_name nvarchar(50),
    @u_name nvarchar(50)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sysdatabases d WHERE d.name = @db_name)
		BEGIN
			DECLARE @sql_db NVARCHAR(2000);
			SET @sql_db = N'CREATE DATABASE ' + QUOTENAME(@db_name)
			PRINT @sql_db
			EXEC sp_executesql @sql_db;	
			INSERT INTO APBD23_ADM.dbo.CRDB_LOG (db_nam, err_msg)
			VALUES (@db_name, 'BAZA ISTNIEJE');
		END
	ELSE
		INSERT INTO APBD23_ADM.dbo.CRDB_LOG (db_nam, err_msg)
		VALUES (@db_name, 'BAZA NIE UTWORZONA, JUZ ISTNIEJE');

	DECLARE @sql nvarchar(2000);

	IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @u_name)
		INSERT INTO APBD23_ADM.dbo.CRUSR_LOG (db_nam, u_nam, err_msg)
		VALUES (@db_name, @u_name, 'UZYTKOWNIK NIE UTWORZONY, JUZ ISTNIEJE');
	ELSE
		SET @sql = 'USE ' + QUOTENAME(@db_name) + 
			'; EXEC sp_addlogin @loginame=''' + @u_name + ''', @passwd=''' + '1234#ABCabc' + ''', @defdb=' + QUOTENAME(@db_name) + 
			'; EXEC sp_adduser @loginame=''' + @u_name + '''; EXEC sp_addrolemember @rolename = ''' + 'db_owner' + ''', @membername= ''' + @u_name + ''';';
		EXEC sp_sqlExec @sql;
		INSERT INTO APBD23_ADM.dbo.CRUSR_LOG (db_nam, u_nam, err_msg)
		VALUES (@db_name, @u_name, 'UZYTKOWNIK ISTNIEJE');

END;

EXEC create_db 'APBD23_TEST', 'APBD23_TEST';

SELECT * FROM sysdatabases WHERE name = 'APBD23_TEST';
/*
APBD23_TEST	9	0x010500000000000515000000F5210978A249929E583AA0C9F4010000	0	65536	1627389952	2023-10-15 12:08:09.493	1900-01-01 00:00:00.000	0	150	C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\APBD23_TEST.mdf	904
*/

SELECT * FROM sys.syslogins WHERE name LIKE 'APBD23_TEST';
/*
0xF028FD2C28EFF84791823C2D81A32FD9	9	2023-10-15 12:08:09.817	2023-10-15 12:08:09.830	2023-10-15 12:08:09.817	0	0	0	0	0	APBD23_TEST	APBD23_TEST	NULL	us_english	0	1	0	0	0	0	0	0	0	0	0	0	0	APBD23_TEST
*/


CREATE TABLE #u ([db_name] nvarchar(50) not null, usr_name nvarchar(50) not null)

CREATE TABLE APBD23_ADM.dbo.CR_LOG 
(row_id int not null IDENTITY CONSTRAINT PK_CR_LOG PRIMARY KEY
, db_usr nvarchar(50) not null
, cr_dt datetime not null default GETDATE()
, err_msg nvarchar(200) NULL 
)


insert into #u ([db_name],usr_name) VALUES ('aa','aa')
insert into #u ([db_name],usr_name) VALUES ('bb','bb')
insert into #u ([db_name],usr_name) VALUES ('cc','cc')
insert into #u ([db_name],usr_name) VALUES ('dd','dd')
insert into #u ([db_name],usr_name) VALUES ('ee','ee')
insert into #u ([db_name],usr_name) VALUES ('ff','ff')
insert into #u ([db_name],usr_name) VALUES ('gg','gg')
insert into #u ([db_name],usr_name) VALUES ('hh','hh')
insert into #u ([db_name],usr_name) VALUES ('ii','ii')
insert into #u ([db_name],usr_name) VALUES ('jj','jj')
insert into #u ([db_name],usr_name) VALUES ('kk','kk')
insert into #u ([db_name],usr_name) VALUES ('ll','ll')
insert into #u ([db_name],usr_name) VALUES ('mm','mm')
insert into #u ([db_name],usr_name) VALUES ('aa','aa')
insert into #u ([db_name],usr_name) VALUES ('bb','bb')
insert into #u ([db_name],usr_name) VALUES ('cc','cc')
insert into #u ([db_name],usr_name) VALUES ('dd','dd')
insert into #u ([db_name],usr_name) VALUES ('ee','ee')
insert into #u ([db_name],usr_name) VALUES ('ff','ff')
insert into #u ([db_name],usr_name) VALUES ('gg','gg')
insert into #u ([db_name],usr_name) VALUES ('APBD23_TEST','APBD23_TEST')

DECLARE @d nvarchar(50), @u nvarchar(50)
DECLARE @sql2 NVARCHAR(200)
DECLARE CI INSENSITIVE CURSOR FOR SELECT u.[db_name], u.usr_name FROM #u u
OPEN CI
FETCH NEXT FROM CI INTO @d, @u
WHILE @@FETCH_STATUS = 0
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sysdatabases d WHERE d.name = @d)
		INSERT INTO APBD23_ADM.dbo.CR_LOG(db_usr, err_msg) VALUES (@u, 'BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE')
	ELSE
		BEGIN
			SET @sql2 = 'USE ' + @d + ';if exists (select 1 from sysusers u where u.name=''' + @u + ''') insert into #u VALUES(1)'
			EXEC sp_executesql @sql2;	
			IF EXISTS (SELECT 1 FROM #u) 
				INSERT INTO APBD23_ADM.dbo.CR_LOG(db_usr, err_msg) VALUES (@u, 'UZYTKOWNIK ISTNIEJE')
			ELSE 
				INSERT INTO APBD23_ADM.dbo.CR_LOG(db_usr, err_msg) VALUES (@u, 'UZYTKOWNIK NIE ISTNIEJE')
		END
	FETCH NEXT FROM CI INTO @d, @u
END
CLOSE CI
DEALLOCATE CI

select * from APBD23_ADM.dbo.CR_LOG

/*
1	aa	2023-10-15 13:34:21.230	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
2	bb	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
3	cc	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
4	dd	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
5	ee	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
6	ff	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
7	gg	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
8	hh	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
9	ii	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
10	jj	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
11	kk	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
12	ll	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
13	mm	2023-10-15 13:34:21.240	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
14	aa	2023-10-15 13:34:21.243	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
15	bb	2023-10-15 13:34:21.243	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
16	cc	2023-10-15 13:34:21.243	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
17	dd	2023-10-15 13:34:21.243	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
18	ee	2023-10-15 13:34:21.243	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
19	ff	2023-10-15 13:34:21.243	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
20	gg	2023-10-15 13:34:21.243	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
21	aa	2023-10-15 13:36:10.323	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
22	bb	2023-10-15 13:36:10.327	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
23	cc	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
24	dd	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
25	ee	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
26	ff	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
27	gg	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
28	hh	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
29	ii	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
30	jj	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
31	kk	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
32	ll	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
33	mm	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
34	aa	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
35	bb	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
36	cc	2023-10-15 13:36:10.330	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
37	dd	2023-10-15 13:36:10.333	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
38	ee	2023-10-15 13:36:10.333	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
39	ff	2023-10-15 13:36:10.333	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
40	gg	2023-10-15 13:36:10.333	BAZA NIE ISTNIEJE, UZYTKOWNIK NIE ISTNIEJE
41	APBD23_TEST	2023-10-15 13:36:10.350	UZYTKOWNIK ISTNIEJE
*/



