/*
 * База данных «Прокат автомобилей»
 *
 * База данных должна включать как минимум таблицы КЛИЕНТЫ, АВТОМОБИЛИ, 
 * ФАКТЫ_ПРОКАТА, содержащие следующую информацию:
 *     • Фамилия клиента
 *     • Имя клиента
 *     • Отчество клиента
 *     • Серия, и номер паспорта клиента
 *     • Адрес проживания клиента: улица, дом, квартира
 *     • Производитель (бренд) автомобиля
 *     • Модель автомобиля
 *     • Цвет автомобиля 
 *     • Год выпуска автомобиля
 *     • Госномер автомобиля
 *     • Страховая стоимость автомобиля
 *     • Стоимость одного дня проката
 *     • Дата начала проката
 *     • Количество дней проката
 *
 */

print(N'*** Старт скрипта создание таблиц базы данных ***' + char(13));

-- при повторном запуске скрипта удаляем старые варианты таблиц, не разбирая пустые они или нет
-- таблицы удаляем в порядке, обратном порядку создания
print(N'    Удаление предыдущих версий таблиц базы данных');
drop table if exists Hires;   -- факты проката
drop table if exists Clients; -- клиенты
drop table if exists Streets; -- улицы
drop table if exists Cars;    -- автомобили в арендной фирмы
drop table if exists Colors;  -- цвета автомобилей
drop table if exists Brands;  -- название бренда
drop table if exists Models;  -- название модели
print('    OK' + char(13));

-- названия брендов автомобилей
print(N'    Создание таблицы справочника ПРОИЗВОДИТЕЛЕЙ');
create table Brands (
	Id      int          not null primary key identity (1, 1),
	[Name]  nvarchar(30) not null    -- название бренда
);
print('    OK' + char(13));
go


-- названия моделей автомобилей
print(N'    Создание таблицы справочника МОДЕЛЕЙ');
create table Models (
	Id      int          not null primary key identity (1, 1),
	[Name]  nvarchar(30) not null    -- название модели
);
print('    OK' + char(13));
go


-- названия цветов автомобилей
print(N'    Создание таблицы справочника ЦВЕТА АВТОМОБИЛЕЙ');
create table Colors (
	Id      int          not null primary key identity (1, 1),
	[Name]  nvarchar(30) not null    -- название цвета
);
go
print('    OK' + char(13));
go

-- названия улиц
print(N'    Создание таблицы справочника НАЗВАНИЯ УЛИЦ');
create table Streets (
	Id          int          not null primary key identity (1, 1),
	[Name]      nvarchar(30) not null    -- название улицы
);
print('    OK' + char(13));
go


-- автомобили фирмы проката
print(N'    Создание таблицы справочника АВТОМОБИЛИ');
-- таблица 
create table dbo.Cars (
    Id          int          not null primary key identity (1, 1),
	IdBrand     int          not null, -- внешний ключ, ссылка на Bravds, бренд автомобиля
	IdModel     int          not null, -- внешний ключ, ссылка на Models, модель автомобиля
	IdColor     int          not null, -- внешний ключ, ссылка на Colors, цвет автомобиля
	Plate       nvarchar(12) not null, -- гос. регистрационный номер автомобиля
	YearManuf   int          not null, -- год производства автомобиля
	InsurValue  int          not null, -- страховая стоимость
	Rental      int          not null, -- стоимость одного дня проката

	-- проверочные ограничения
	constraint  CK_Cars_YearManuf   check(YearManuf >= 2010),
	constraint  CK_Cars_InsurValue  check(InsurValue > 0),

	-- ограничение уникальности значения столбца
	-- https://docs.microsoft.com/ru-ru/sql/relational-databases/tables/create-unique-constraints?view=sql-server-ver15
	constraint  CK_Cars_Plate       unique(Plate),
	
	constraint  CK_Cars_Rental      check(Rental > 0),

	-- внешние ключи
	constraint  FK_Cars_Brands foreign key (IdBrand) references dbo.Brands(Id), 
	constraint  FK_Cars_Models foreign key (IdModel) references dbo.Models(Id), 
	constraint  FK_Cars_Colors foreign key (IdColor) references dbo.Colors(Id) 
);
print('    OK' + char(13));
go

-- клиенты фирмы проката
print(N'    Создание таблицы справочника КЛИЕНТЫ');
create table dbo.Clients (
	Id          int          not null primary key identity (1, 1),
	Surname     nvarchar(60) not null,    -- Фамилия клиента
	[Name]      nvarchar(50) not null,    -- Имя клиента
	Patronymic  nvarchar(60) not null,    -- Отчество клиента
	Passport    nvarchar(15) not null,    -- Серия и номер паспорта

	IdStreet    int          not null,    -- внешний ключ, ссылка на Streets, название улицы
	Building    nvarchar(12) not null,    -- номер дома, может включать буквы, 12а или 8-бис
	Flat        int,                      -- номер квартиры, не обязателен, для частного сектора это нормально

	-- ограничение уникальности значения столбца
	constraint  CK_Clients_Passport unique(Passport),

	-- внешний ключ
	constraint  FK_Clients_Streets foreign key (IdStreet) references dbo.Streets(Id)
);
print('    OK' + char(13));
go

-- факты проката
print(N'    Создание таблицы регистра ФАКТЫ_ПРОКАТА');
create table Hires(
	Id          int   not null primary key identity (1, 1),
	IdClient    int   not null,  -- внешний ключ, ссылка на таблицу Clients 
	IdCar       int   not null,  -- внешний ключ, ссылка на таблицу Cars
	DateStart   date  not null,  -- дата начала проката
	Duration    int   not null,  -- длительность проката

	-- проверочные ограничения
	constraint  CK_Hires_DateStart check(DateStart > '01-01-2023'),
	constraint  CK_Hires_Duration  check(Duration between 1 and 15),

	-- внешние ключи
	constraint  FK_Hires_Clients   foreign key (IdClient) references dbo.Clients(Id),
	constraint  FK_Hires_Cars      foreign key (IdCar)    references dbo.Cars(Id)
);
print('    OK' + char(13));
go

print(N'*** Финиш скрипта ***');
