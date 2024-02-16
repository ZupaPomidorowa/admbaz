/* 1. Korzystając ze skryptu z Z1 proszę utworzyć minimum 5 baz*/

create database pwx_db
create database db1
create database db2
create database db3
create database db4

/*
2. W 3ech z nich proszę utworzyć tabele i dane z wykładu z BAZ (WOJ,MIASTA,OSOBY,ETATY)
i wypełnić wartościami
*/

--USE db1
--USE db2
USE db3

create table woj 
(	kod_woj 	char(3) 	not null 	
	constraint pk_woj primary key
,	nazwa 		varchar(30) 	not null
)

create table miasta 
(	id_miasta 	int 		not null identity 
	constraint pk_miasta primary key
,	kod_woj 	char(3) 	not null 
	constraint fk_miasta__woj foreign key 
	references woj(kod_woj)
,	nazwa 		varchar(30) 	not null
)

create table osoby 
(	id_osoby	int 		not null identity
	constraint pk_osoby primary key
,	id_miasta	int 		not null
	constraint fk_osoby__miasta foreign key
	references miasta(id_miasta)
,	imie		varchar(20) 	not null
,	nazwisko	varchar(30) 	not null
,	imie_i_nazwisko as convert(char(24),left(imie,1)+'. ' + nazwisko)
)

create table firmy 
(	nazwa_skr	char(3) 	not null
	constraint pk_firmy primary key
,	id_miasta	int 		not null
	constraint fk_firmy__miasta foreign key
	references miasta(id_miasta)
,	nazwa		varchar(60) 	not null
,	kod_pocztowy	char(6)		not null
,	ulica		varchar(60)	not null
)

create table etaty 
(	id_osoby 	int 		not null 
	constraint fk_etaty__osoby 
	foreign key references osoby(id_osoby)
,	id_firmy 	char(3) 	not null 
	constraint fk_etaty__firmy 
	foreign key references firmy(nazwa_skr)
,	stanowisko	varchar(60)	not null
,	pensja 		money 		not null
,	od 		datetime 	not null
,	do 		datetime 	null
,	id_etatu 	int 		not null identity 
	constraint pk_etaty primary key
)

insert into woj values ('Maz', 'Mazowieckie')
insert into woj values ('Pom', 'Pomorskie')
insert into woj values ('Lod', 'Lodzkie')

DECLARE @id_wwa int
,	@id_wes int
,	@id_gda int
,	@id_sop	int
,	@id_ms	int
,	@id_jk	int
,	@id_jn	int
,	@id_kn	int
,	@id_br1 int
,	@id_br	int
,	@id_am	int

insert into miasta (kod_woj, nazwa) values ('MAZ', 'WESOLA')
SET @id_wes = SCOPE_IDENTITY()
insert into miasta (kod_woj, nazwa) values ('MAZ', 'WARSZAWA')
SET @id_wwa = SCOPE_IDENTITY()
insert into miasta (kod_woj, nazwa) values ('POM', 'GDANSK')
SET @id_gda = SCOPE_IDENTITY()
insert into miasta (kod_woj, nazwa) values ('POM', 'SOPOT')
SET @id_sop = SCOPE_IDENTITY()

insert into osoby (imie, nazwisko, id_miasta) values ('Maciej', 'Stodolski', @id_wes)
SET @id_ms = SCOPE_IDENTITY()

insert into osoby (imie, nazwisko, id_miasta) values ('Jacek', 'Korytkowski', @id_wwa)
SET @id_jk = SCOPE_IDENTITY()

insert into osoby (imie, nazwisko, id_miasta) values ('Mis', 'Nieznany', @id_gda)

insert into osoby (imie, nazwisko, id_miasta) values ('Krol', 'Neptun', @id_sop)
set @id_kn = SCOPE_IDENTITY()

insert into osoby (imie, nazwisko, id_miasta) values ('Juz', 'Niepracujacy', @id_wwa)
SET @id_jn = SCOPE_IDENTITY()


insert into firmy (nazwa_skr, nazwa, id_miasta,	kod_pocztowy, ulica) values 
('HP', 'Hewlett Packard', @id_wwa, '00-000', 'Szturmowa 2a')

insert into firmy (nazwa_skr, nazwa, id_miasta,	kod_pocztowy, ulica) values 
('PW', 'Politechnika Warszawska', @id_wwa, '00-000', 'Pl. Politechniki 1')

insert into firmy (nazwa_skr, nazwa, id_miasta,	kod_pocztowy, ulica) values 
('FLP',	'Fabryka Lodzi Podwodnych',	@id_wwa, '00-000',	'Na dnie 4')


insert into etaty (id_osoby, id_firmy, pensja, od, stanowisko) values 
(@id_ms, 'PW', 2200, convert(datetime,'19990101',112), 'Sprzatacz')

insert into etaty (id_osoby, id_firmy, pensja, od, stanowisko) values 
(@id_ms, 'HP', 20000, convert(datetime,'20000101',112),	'Konsultant')

insert into etaty (id_osoby, id_firmy, pensja, od, stanowisko) values 
(@id_jk, 'PW', 3200, convert(datetime,'20011110',112), 'Adjunkt')


/*3. Proszę w jednej z baz dodać kilka rekordów więcej do ETATY i OSOBY (według uznania)*/

USE db1

DECLARE @id_wwa int, @id_gda int

SET @id_wwa = (select id_miasta from miasta where nazwa = 'WARSZAWA')
SET @id_gda = (select id_miasta from miasta where nazwa = 'GDANSK')

DECLARE @id_jak int,
		@id_rm int,
		@id_an int

insert into osoby (imie, nazwisko, id_miasta) values ('Jan', 'Kowalski', @id_wwa)
SET @id_jak = SCOPE_IDENTITY()

insert into osoby (imie, nazwisko, id_miasta) values ('Remigiusz', 'Mroz', @id_wwa)
SET @id_rm = SCOPE_IDENTITY()

insert into osoby (imie, nazwisko, id_miasta) values ('Anna', 'Nowak', @id_gda)
SET @id_an = SCOPE_IDENTITY()

insert into etaty (id_osoby, id_firmy, pensja, od, stanowisko) values 
(@id_jak, 'HP', 20000, convert(datetime,'20000101',112),	'Programista')

insert into etaty (id_osoby, id_firmy, pensja, od, stanowisko) values 
(@id_rm, 'HP', 20000, convert(datetime,'20000101',112),	'Menazdzer')

insert into etaty (id_osoby, id_firmy, pensja, od, stanowisko) values 
(@id_an, 'HP', 20000, convert(datetime,'20000101',112),	'Dryektor')


/*
select * from osoby
1	1	Maciej	Stodolski	M. Stodolski            
2	2	Jacek	Korytkowski	J. Korytkowski          
3	3	Mis	Nieznany	M. Nieznany             
4	4	Krol	Neptun	K. Neptun               
5	2	Juz	Niepracujacy	J. Niepracujacy         
6	2	Jan	Kowalski	J. Kowalski             
7	2	Remigiusz	Mroz	R. Mroz                 
8	3	Anna	Nowak	A. Nowak                

select * from etaty
1	PW 	Sprzatacz	2200.00	1999-01-01 00:00:00.000	NULL	1
1	HP 	Konsultant	20000.00	2000-01-01 00:00:00.000	NULL	2
2	PW 	Adjunkt	3200.00	2001-11-10 00:00:00.000	NULL	3
6	HP 	Programista	20000.00	2000-01-01 00:00:00.000	NULL	4
7	HP 	Menazdzer	20000.00	2000-01-01 00:00:00.000	NULL	5
8	HP 	Dryektor	20000.00	2000-01-01 00:00:00.000	NULL	6
*/

/*4.1 Proszę utworzyć tabele*/
CREATE DATABASE APBD23_ADM

CREATE TABLE APBD23_ADM.dbo.DB_CHECK
( check_id int not null IDENTITY CONSTRAINT PK_DB_CHECK PRIMARY KEY
, db_nam nvarchar(50) not null 
, d_stamp datetime NOT NULL DEFAULT GETDATE() 
, opis nvarchar(50) NOT NULL
)
CREATE TABLE APBD23_ADM.dbo.DB_CHECK_ITEMS
( check_id int not null CONSTRAINT FK_DB_CHECK__DB_CHECK_ITEMS FOREIGN KEY
	REFERENCES APBD23_ADM.dbo.DB_CHECK (check_id)
, tb_nam nvarchar(50) not null
, tb_check_d_stamp datetime NOT NULL DEFAULT GETDATE() 
, tb_num int
)

/*
4.2 Trzeba utworzyć procedurę, która ma kursor po wszystkich bazach
Trzeba utworzyć procedurę, która dla podanej bazy wylistuje wszystkie tabele
wstawi rekord do tabeli APBD23_ADM.dbo.DB_CHECK i z tak uzyskanym identyfikatorem
wstawi dla kazdej tabeli aktualną liczbę rekordów do tabeli
APBD23_ADM.dbo.DB_CHECK_ITEMS
*/

ALTER PROCEDURE check_tables @db_name nvarchar(50)
AS
BEGIN
	DECLARE @sql NVARCHAR(2000), @i int, @d nvarchar(50), @check_id int;
	INSERT INTO APBD23_ADM.dbo.DB_CHECK(db_nam, opis) VALUES (@db_name, 'Procedura check_tables')
	SET @check_id = SCOPE_IDENTITY();

	CREATE TABLE #t (t_name nvarchar(50) NOT NULL);
	SET @sql = N'USE ' +  QUOTENAME(@db_name)
	+ N';INSERT INTO #t (t_name) '
	+ N' SELECT o.[name] FROM sysobjects o WHERE OBJECTPROPERTY(o.[ID],N''IsUserTable'')=1';
	
	EXEC sp_executesql @sql;

	DECLARE CI CURSOR FOR SELECT t_name FROM #t
	OPEN CI
	FETCH NEXT FROM CI INTO @d
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql = N'USE ' + QUOTENAME(@db_name)
                    + N'; SELECT @i = COUNT(*) FROM ' + QUOTENAME(@d);      
        EXEC sp_executesql @sql, N'@i INT OUTPUT', @i OUTPUT;
		INSERT INTO APBD23_ADM.dbo.DB_CHECK_ITEMS(check_id, tb_nam, tb_num) VALUES (@check_id, @d, @i);
		FETCH NEXT FROM CI INTO @d;
	END

	CLOSE CI
	DEALLOCATE CI

    DROP TABLE #t;

END;

EXEC check_tables 'db1';

SELECT * FROM APBD23_ADM.dbo.DB_CHECK
/*
31	db1	2023-11-11 02:54:06.340	Procedura check_tables
32	db1	2023-11-11 03:04:35.620	Procedura check_tables
33	db1	2023-11-11 03:33:43.933	Procedura check_tables
34	db1	2023-11-11 03:44:56.120	Procedura check_tables
35	db_name	2023-11-11 04:22:18.027	Procedura check_tables
...
74	db4	2023-11-11 05:44:11.290	Procedura check_tables
75	APBD23_ADM	2023-11-11 05:44:11.310	Procedura check_tables
76	db1	2023-11-11 05:46:26.213	Procedura check_tables
*/

SELECT * FROM APBD23_ADM.dbo.DB_CHECK_ITEMS
/*
34	woj	2023-11-11 03:44:56.170	3
34	miasta	2023-11-11 03:44:56.170	4
34	osoby	2023-11-11 03:44:56.170	8
...
76	osoby	2023-11-11 05:46:26.247	8
76	firmy	2023-11-11 05:46:26.247	3
76	etaty	2023-11-11 05:46:26.247	6
*/

/*4.3 Napisać procedurę, która dla wszystkich baz wywoła procedurę z punktu 4.2*/

ALTER PROCEDURE check_all_tables
AS
BEGIN
	DECLARE @d NVARCHAR(50)
	DECLARE CI2 INSENSITIVE CURSOR FOR SELECT d.[name] FROM sysdatabases d
	OPEN CI2 
	FETCH NEXT FROM CI2 INTO @d
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @d AS db_name
		EXEC check_tables @d
		FETCH NEXT FROM CI2 INTO @d
	END
	CLOSE CI2
	DEALLOCATE CI2
END;

EXEC check_all_tables


/*
4.4 Napisać procedurę, która dla parametru nazwa bazy, 
nazwa tabeli wypisze historię liczby rekordów dla podanej tabeli w podanej bazie
*/

ALTER PROCEDURE history @db_name nvarchar(50), @tb_name nvarchar(50)
AS 
BEGIN
	SELECT * FROM APBD23_ADM.dbo.DB_CHECK_ITEMS, APBD23_ADM.dbo.DB_CHECK WHERE DB_CHECK.db_nam = @db_name AND 
	DB_CHECK.check_id = DB_CHECK_ITEMS.check_id AND DB_CHECK_ITEMS.tb_nam = @tb_name
END;

EXEC history 'db1', 'miasta';
/*
34	miasta	2023-11-11 03:44:56.170	4	34	db1	2023-11-11 03:44:56.120	Procedura check_tables
45	miasta	2023-11-11 04:26:43.233	4	45	db1	2023-11-11 04:26:43.213	Procedura check_tables
58	miasta	2023-11-11 05:41:30.803	4	58	db1	2023-11-11 05:41:30.783	Procedura check_tables
71	miasta	2023-11-11 05:44:11.223	4	71	db1	2023-11-11 05:44:11.203	Procedura check_tables
76	miasta	2023-11-11 05:46:26.247	4	76	db1	2023-11-11 05:46:26.213	Procedura check_tables
*/
