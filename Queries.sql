/* База данных «Прокат автомобилей» */

-- вывод вспомогательных справочников
select * from Streets;
select * from Brands;
select * from Models;
select * from Colors;
go

-- Вывод записей таблицы автомобилей с расшифровкой всех полей
select
    Cars.Id 
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Colors.[Name] as Color
    , Cars.Plate
    , Cars.YearManuf
    , Cars.InsurValue
    , Cars.Rental
from
    Cars join Brands on Cars.IdBrand = Brands.Id
         join Models on Cars.IdModel = Models.Id
         join Colors on Cars.IdColor = Colors.Id;
go

-- Вывод таблицы КЛИЕНТЫ с расшифровкой всех полей
select
    Clients.Id
    , Clients.Surname
    , Clients.[Name]
    , Clients.Patronymic
    , Clients.Passport
    , Streets.[Name]      as Street
    , Clients.Building
    , Clients.Flat
from
    Clients join Streets on Clients.IdStreet = Streets.Id;
go


-- Вывод записей таблицы фактов проката с расшифровкой всех полей
select
    Hires.Id
    , Hires.DateStart
    , Hires.Duration

    , Cars.Plate
    , Cars.Rental
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Colors.[Name] as Color

    , Clients.Surname + ' ' + Substring(Clients.[Name], 1, 1) + '.' + 
          Substring(Clients.Patronymic, 1, 1) + '.' as Client
    , Clients.Passport
    , Streets.[Name] as Street
    , Clients.Building
    , Clients.Flat
from
    Hires join (Cars join Brands on Cars.IdBrand = Brands.Id
                     join Models on Cars.IdModel = Models.Id
                     join Colors on Cars.IdColor = Colors.Id) 
               on Hires.IdCar = Cars.Id
          join (Clients join Streets on Clients.IdStreet = Streets.Id) on Hires.IdClient = Clients.Id
-- order by
--    Cars.Plate
;
go

--  1. Запрос с параметром	
--     Выбирает из таблицы АВТОМОБИЛИ информацию об автомобилях заданной модели
--     (например, ВАЗ-2110)
declare @brand nvarchar(30) = 'Skoda', @model nvarchar(30) = 'Octavia A5';
-- declare @brand nvarchar(30) = 'Suzuki', @model nvarchar(30) = 'Grand Vitara';

select
    Cars.Id 
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Colors.[Name] as Color
    , Cars.Plate
    , Cars.YearManuf
    , Cars.InsurValue
    , Cars.Rental
from
    Cars join Brands on Cars.IdBrand = Brands.Id
         join Models on Cars.IdModel = Models.Id
         join Colors on Cars.IdColor = Colors.Id
where
    Brands.[Name] = @brand and Models.[Name] = @model;
go

-- вывести факты проката автомобиля с заданным номерным знаком
declare @plate nvarchar(15) = N'Н179РК';
select
    Hires.Id
    , Hires.DateStart
    , Hires.Duration

    , Cars.Plate
    , Cars.Rental
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Colors.[Name] as Color

    , Clients.Surname + ' ' + Substring(Clients.[Name], 1, 1) + '.' + 
          Substring(Clients.Patronymic, 1, 1) + '.' as Client
    , Clients.Passport
    , Streets.[Name] as Street
    , Clients.Building
    , Clients.Flat
from
    Hires join (Cars join Brands on Cars.IdBrand = Brands.Id
                     join Models on Cars.IdModel = Models.Id
                     join Colors on Cars.IdColor = Colors.Id) 
               on Hires.IdCar = Cars.Id
          join (Clients join Streets on Clients.IdStreet = Streets.Id) on Hires.IdClient = Clients.Id
where
     Cars.Plate = @plate;
go


--  2. Запрос с параметром	
--     Выбирает из таблицы АВТОМОБИЛИ информацию об автомобилях, изготовленных 
--     до заданного года (например, до 2016)
declare @yearManuf int = 2018;

select
    Cars.Id 
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Colors.[Name] as Color
    , Cars.Plate
    , Cars.YearManuf
    , Cars.InsurValue
    , Cars.Rental
from
    Cars join Brands on Cars.IdBrand = Brands.Id
         join Models on Cars.IdModel = Models.Id
         join Colors on Cars.IdColor = Colors.Id
where
    Cars.YearManuf < @yearManuf;
go

--  3. Запрос с параметром	
--     Выбирает из таблицы АВТОМОБИЛИ информацию об автомобилях, имеющих 
--     заданные модель и цвет, изготовленных после заданного года
declare @brand nvarchar(30) = 'Suzuki', @model nvarchar(30) = 'Grand Vitara', @color nvarchar(30)=N'серебристый', 
        @yearManuf int = 2016;

select
    Cars.Id 
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Colors.[Name] as Color
    , Cars.Plate
    , Cars.YearManuf
    , Cars.InsurValue
    , Cars.Rental
from
    Cars join Brands on Cars.IdBrand = Brands.Id
         join Models on Cars.IdModel = Models.Id
         join Colors on Cars.IdColor = Colors.Id
where
    Brands.[Name] = @brand and Models.[Name] = @model and Colors.[Name] = @color and Cars.YearManuf > @yearManuf;
go

--  4. Запрос с параметром	
--     Выбирает из таблицы АВТОМОБИЛИ информацию об автомобиле с заданным
--     госномером
-- declare @plate nvarchar(12) = N'В015РК';
declare @plate nvarchar(12) = N'С';

select
    Cars.Id 
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Colors.[Name] as Color
    , Cars.Plate
    , Cars.YearManuf
    , Cars.InsurValue
    , Cars.Rental
from
    Cars join Brands on Cars.IdBrand = Brands.Id
         join Models on Cars.IdModel = Models.Id
         join Colors on Cars.IdColor = Colors.Id
where
    -- такой вариант лучше при поиске конкретного номера 
    -- Cars.Plate = @plate;
   Cars.Plate like @plate + '%';
go


--  5. Запрос с параметром	
--     Выбирает из таблиц КЛИЕНТЫ, АВТОМОБИЛИ и ФАКТЫ_ПРОКАТА информацию обо
--     всех зафиксированных фактах проката автомобилей (ФИО клиента, Модель 
--     автомобиля, Госномер автомобиля, дата проката) в некоторый заданный 
--     интервал времени. Нижняя и верхняя границы интервала задаются при 
--     выполнении запроса
--     формат даты:   мм-дд-гггг
declare @from date = '03-01-2023', @to date = '03-31-2023';

select
    Hires.Id
    , Clients.Surname + ' ' + Substring(Clients.[Name], 1, 1) + '.' + 
          Substring(Clients.Patronymic, 1, 1) + '.' as Client
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Cars.Plate
    , Hires.DateStart
    , Hires.Duration
from
    Hires join (Cars join Brands on Cars.IdBrand = Brands.Id
                     join Models on Cars.IdModel = Models.Id) 
               on Hires.IdCar = Cars.Id
          join Clients on Hires.IdClient = Clients.Id
where
    Hires.DateStart between @from and @to 
order by
    Hires.DateStart;
go

--  6. Запрос с вычисляемыми полями	
--     Вычисляет для каждого факта проката стоимость проката. Включает поля 
--     Дата проката, Госномер автомобиля, Модель автомобиля, Стоимость проката.
--     Сортировка по полю Дата проката
select
    Hires.Id
    , Hires.DateStart
    , Cars.Plate
    , Brands.[Name]                 as Brand
    , Models.[Name]                 as Model
    , Colors.[Name]                 as Color
    , Cars.Rental                   as RentalPerDay
    , Hires.Duration
    , Cars.Rental * Hires.Duration as Price 
from
    Hires join (Cars join Brands on Cars.IdBrand = Brands.Id
                     join Models on Cars.IdModel = Models.Id
                     join Colors on Cars.IdColor = Colors.Id) 
               on Hires.IdCar = Cars.Id
order by
    Hires.DateStart;
go


-- 7. Запрос с подзапросом	
--    Вывести автомобили прокатной фирмы с годом выпуска, меньшим года выпуска
--    всех автомобилей заданного бренда, использовать all
declare @brand nvarchar(30)='Suzuki';

select
    Cars.Id 
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Colors.[Name] as Color
    , Cars.Plate
    , Cars.YearManuf
    , Cars.InsurValue
    , Cars.Rental
from
    Cars join Brands on Cars.IdBrand = Brands.Id
         join Models on Cars.IdModel = Models.Id
         join Colors on Cars.IdColor = Colors.Id
where
    Cars.YearManuf < all (select Cars.YearManuf 
                          from Cars join Brands on Cars.IdBrand = Brands.Id 
                          where Brands.[Name] = @brand /* 'Suzuki' */ )
go

-- 8. Запрос с подзапросом	
--    Вывести факты проката с количеством дней проката большим максимального 
--    количества дней проката автомобиля заданного бренда, использовать some 
--    (any)
declare @brand nvarchar(30)='Skoda';

select
    Hires.Id
    , Clients.Surname + ' ' + Substring(Clients.[Name], 1, 1) + '.' + 
          Substring(Clients.Patronymic, 1, 1) + '.' as Client
    , Brands.[Name] as Brand
    , Models.[Name] as Model
    , Cars.Plate
    , Hires.DateStart
    , Hires.Duration
from
    Hires join (Cars join Brands on Cars.IdBrand = Brands.Id
                     join Models on Cars.IdModel = Models.Id) 
               on Hires.IdCar = Cars.Id
          join Clients on Hires.IdClient = Clients.Id
where 
    -- используем any/some по заданию
    Hires.Duration > any(select Hires.Duration
                        from   Hires join (Cars join Brands on Cars.IdBrand = Brands.Id) on Hires.IdCar = Cars.Id
                        where  Brands.[Name] = @brand    /* 'Skoda' */)
    
    -- эквивалент без any/some
   -- Hires.Duration > (select Min(Hires.Duration) 
   --                   from   Hires join (Cars join Brands on Cars.IdBrand = Brands.Id) on Hires.IdCar = Cars.Id
   --                   where  Brands.[Name] = @brand  /* 'Skoda'  */)
order by
    Hires.DateStart;
go


--  9. Запрос с левым соединением	
--     Для всех автомобилей прокатной фирмы вычисляет количество фактов 
--     проката, сумму вырученную за прокаты
select
    Cars.Id
    , Cars.Plate
    , Brands.[Name]      as Brand
    , Models.[Name]      as Model
    , Count(Hires.IdCar) as Amount
    , IsNull(Sum(Cars.Rental * Hires.Duration), 0) as SumRental
from
    (Cars join Brands on Cars.IdBrand = Brands.Id join Models on Cars.IdModel = Models.Id)
    left join 
    Hires on Cars.Id = Hires.IdCar
group by
    Cars.Id, Cars.Plate, Brands.[Name], Models.[Name] 
order by
    SumRental desc;
go


-- 10. Итоговый запрос	
--     Выполняет группировку по полю Год выпуска автомобиля. Для каждого года 
--     вычисляет минимальное и максимальное значения по полю Стоимость одного 
--     дня проката
select
    YearManuf
    , Count(*)    as AmountYearManuf
    , Min(Rental) as MinRental
    , Max(Rental) as MaxRental
from  
    Cars
group by
    YearManuf;
go


-- 11. Запрос на добавление	
--     Добавляет в таблицу ФАКТЫ_ПРОКАТА данные о факте проката. 
--     Данные передавайте параметрами, используйте подзапросы
declare @passport nvarchar(15) = '13 21 185659', @plate nvarchar(12) = N'С192РК', 
        @dateStart date = '05-26-2023', @duration int = 12;

insert Hires
    (IdClient, IdCar, DateStart, Duration)
values (
    (select Id from Clients where Passport = @passport),
    (select Id from Cars where Plate = @plate), 
    @dateStart, @duration);
go

-- 12. Запрос на добавление	
--     Добавляет в таблицу АВТОМОБИЛИ данные о новом автомобиле в прокатной 
--     фирме. Данные автомобиля задавайте параметрами, используйте подзапросы
declare 
    @brand nvarchar(30)='Mercedes', @model nvarchar(3)='210', @color nvarchar(30) = N'серебристый',
    @plate nvarchar(12)=N'М345РК', @yearManuf int = 2020, @insurValue int = 4500000,
    @rental int = 5100;

insert Cars
   (IdBrand, IdModel, IdColor, Plate, YearManuf, InsurValue, Rental)
values (
   (select Id from Brands where [Name] = @brand),
   (select Id from Models where [Name] = @model),
   (select Id from Colors where [Name] = @color),
   @plate, @yearManuf, @insurValue, @rental);
go


-- 13. Запрос на удаление	
--     Удаляет из таблицы ФАКТЫ_ПРОКАТА запись по идентификатору, заданному 
--     параметром запроса
declare @id int = 21;

delete from  
    Hires
where
    Id = @id;
go


-- 14. Запрос на удаление	
--     Удаляет из таблицы ФАКТЫ_ПРОКАТА записи за указанный период 
--     для заданного клиента
declare @passport nvarchar(15) = N'12 21 123122', @from date = '05-01-2023', @to date = '05-31-2023';

delete from  
    Hires
where
    IdClient = (select Id from Clients where Passport = @passport)
    and 
    DateStart between @from and @to;
go


-- 15. Запрос на обновление	
--     Увеличивает значение в поле Стоимость одного дня проката на заданное 
--     количество процентов для автомобилей, изготовленных после заданного года
declare @percent float = 10, @yearManuf int = 2018;

update
    Cars
set
    Rental *= (100 + @percent) / 100
where
    Cars.YearManuf > @yearManuf;
go

-- 16. Запрос на обновление	
--     Изменяет данные клиента по его идентификатору на указанные в параметрах 
--     запроса значение
declare @id int = 1,
	@surname    nvarchar(60) = N'Иванов',
	@name       nvarchar(50) = N'Иван',
	@patronymic nvarchar(60) = N'Иванович',
    @passport   nvarchar(15) = N'99 21 000001';

update
    Clients
set
    Surname = @surname
    , [Name] = @name
    , Patronymic = @patronymic
    , Passport = @passport
where
    Clients.Id = @id;
go
