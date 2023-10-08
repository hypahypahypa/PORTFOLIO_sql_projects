-- Задание 1
-- Найдите номер модели, скорость и размер жесткого диска для всех ПК стоимостью менее 500 дол. 
-- Вывести: model, speed и hd
SELECT model, speed, hd
FROM PC
WHERE price < 500;

-- Задание 2
-- Найдите производителей принтеров. 
-- Вывести: maker
SELECT DISTINCT maker 
FROM Product  
WHERE type = 'Printer';

-- Задание 3
-- Найдите номер модели, объем памяти и размеры экранов ПК-блокнотов, цена которых превышает 1000 дол.
SELECT model, ram, screen
FROM laptop
WHERE price > 1000;

-- Задание 4
-- Найдите все записи таблицы Printer для цветных принтеров.
SELECT *
FROM Printer
WHERE color = 'y';

-- Задание 5
-- Найдите номер модели, скорость и размер жесткого диска ПК, имеющих 12x или 24x CD и цену менее 600 дол.
SELECT model, speed, hd
FROM pc
WHERE cd IN ('12x', '24x')
	AND price < 600;

-- Задание 6
-- Для каждого производителя, выпускающего ПК-блокноты c объёмом жесткого диска не менее 10 Гбайт, 
-- найти скорости таких ПК-блокнотов. 
-- Вывод: производитель, скорость.
SELECT DISTINCT product.maker, laptop.speed
FROM product, laptop
WHERE product.model = laptop.model
	AND laptop.hd >= 10;

-- Второй вариант решения.
SELECT DISTINCT Product.maker, Laptop.speed
FROM Product JOIN 
 Laptop ON Product.model = Laptop.model 
WHERE Laptop.hd >= 10;

-- Задание 7
-- Найдите номера моделей и цены всех имеющихся в продаже продуктов (любого типа) производителя B.
SELECT DISTINCT product.model, price
FROM product
JOIN laptop ON product.model = laptop.model
WHERE product.maker = 'B'

UNION ALL

SELECT DISTINCT product.model, price
FROM product
JOIN pc ON product.model = pc.model
WHERE product.maker = 'B'

UNION ALL

SELECT DISTINCT product.model, price
FROM product
JOIN printer ON product.model = printer.model
WHERE product.maker = 'B';

-- Задание 8
-- Найдите производителя, выпускающего ПК, но не ПК-блокноты.
SELECT DISTINCT maker
FROM product
WHERE type = 'PC' 
EXCEPT
SELECT DISTINCT maker
FROM product
WHERE type = 'Laptop';

-- Решение 2. Чрезмерно заумное
select maker
from (
select maker, 
sum(case type when 'PC' then 1 else 0 end) as pc,
sum(case type when 'Laptop' then 1 else 0 end) as laptop
 from 
Product
group by maker
) a
where a.pc > 0 and a.laptop = 0;

-- Задание 9
-- Найдите производителей ПК с процессором не менее 450 Мгц. 
-- Вывести: Maker
SELECT DISTINCT product.maker
FROM product
JOIN pc ON pc.model = product.model
WHERE speed >= 450;

-- Задание 10
-- Найдите модели принтеров, имеющих самую высокую цену. 
-- Вывести: model, price
SELECT uq.model, uq.price
FROM
	(
	SELECT p.model, p.price, rank() OVER (ORDER BY price DESC) AS price_rank
	FROM printer p
	) uq
WHERE uq.price_rank = 1

-- Задание 11
-- Найдите среднюю скорость ПК.
SELECT AVG(speed)
FROM pc;

-- Задание 12
-- Найдите среднюю скорость ПК-блокнотов, цена которых превышает 1000$
SELECT AVG(speed)
FROM laptop
WHERE price > 1000;

-- Задание 13
-- Найдите среднюю скорость ПК, выпущенных производителем A.
SELECT AVG(pc.speed)
FROM pc
JOIN product ON pc.model = product.model
WHERE maker = 'A';

-- Задание 14
-- Найдите класс, имя и страну для кораблей из таблицы Ships, имеющих не менее 10 орудий.
-- Здесь потребуется DB_Ships
SELECT c.class, s.name, c.country
FROM classes c
JOIN ships s
	ON c.class = s.class
WHERE c.numguns >= 10;

-- Задание 15
-- Найдите размеры жестких дисков, совпадающих у двух и более PC. 
-- Вывести: HD
SELECT uq.hd
FROM
	(SELECT hd, rank() OVER(ORDER BY hd) AS hd_rank
	FROM pc
	) uq
GROUP BY uq.hd
HAVING count(uq.hd_rank) >= 2;

-- Задание 16
-- Найдите пары моделей PC, имеющих одинаковые скорость и RAM. В результате каждая пара указывается только один раз, т.е. (i,j), но не (j,i). 
-- Порядок вывода: модель с большим номером, модель с меньшим номером, скорость и RAM.
SELECT P.model, L.model, P.speed, P.ram
FROM PC p
JOIN 
     (SELECT speed, ram
      FROM PC
      GROUP BY speed, ram
      HAVING SUM(speed)/speed = 2 AND 
             SUM(ram)/ram = 2 
      ) S 
      ON P.speed = S.speed AND 
         P.ram = S.ram 
JOIN PC L 
	ON L.speed = S.speed AND 
       L.ram = S.ram AND 
       L.model < P.model;

-- Задание 16. Вариант решения 2.
SELECT MAX(model1), MIN(model2), MAX(speed), MAX(ram) 
FROM (SELECT pc1.model AS model1, pc2.model AS model2, pc1.speed, pc2.ram, 
             CASE WHEN CAST(pc1.model AS NUMERIC(6,2)) > 
                       CAST(pc2.model AS NUMERIC(6,2)) 
                  THEN pc1.model+pc2.model  
                  ELSE pc2.model+pc1.model  
             END AS sm 
      FROM PC pc1, PC pc2 
      WHERE pc1.speed = pc2.speed AND 
            pc1.ram = pc2.ram AND 
            pc1.model <> pc2.model
      ) a 
GROUP BY a.sm

-- Задание 17
-- Найдите модели ПК-блокнотов, скорость которых меньше скорости каждого из ПК.
-- Вывести: type, model, speed
SELECT DISTINCT p.type, p.model, l.speed
FROM product p
JOIN laptop l ON p.model = l.model
WHERE l.speed < ALL (SELECT pc.speed FROM pc)

-- Перечислите номера моделей любых типов, имеющих самую высокую цену по всей имеющейся в базе данных продукции.
WITH mp AS (
  SELECT model, price FROM pc
	
  UNION
	
  SELECT model, price FROM printer
	
  UNION
	
  SELECT model, price FROM laptop
)
SELECT model FROM mp 
WHERE price = (SELECT max(price) FROM mp);

--
select
  ROW_NUMBER() OVER(ORDER BY count desc, maker asc, model asc) rownum, 
	maker, 
	model
  from (
    -- tmp table with count of models for each maker
    select
      count(model) over(partition by maker) as count
      , p.*
    from product p
  ) p

--
with M as (
select maker from product p
where
  model in (
  -- model with MIN ram AND
  -- MAX speed in MIN ram models
    select model from pc
    where
      ram=(select min(ram) from pc)
      and speed=(
        -- max speed from pc with minimum RAN
        select max(speed) from pc
        where ram=(select min(ram) from pc)
      )
  )
)
select distinct maker from product
where type='Printer' and maker in (select maker from M)

-- Определить страны, которые потеряли в сражениях все свои корабли
with sh as (
  select c.country, s.name from classes c join ships s on c.class=s.class
  union
  select c.country, o.ship from outcomes o join classes c on c.class=o.ship
),
shs as(
  -- number of sunked ships
  select
    country
    , count(*) as total
  from sh
    left join outcomes o on sh.name=o.ship
  where result = 'sunk'
  group by country
),
sht as (
  -- total number of ships
  select
    country
    , count(*) as total
  from sh
  group by country
)
select x.country from sht x join shs y on x.country=y.country
where x.total=y.total

-- another solution
with sh as (
  select c.country, s.name from classes c join ships s on c.class=s.class
  union
  select c.country, o.ship from outcomes o join classes c on c.class=o.ship
)
, a as (
  select
    country, name
    , case
        when result='sunk' then 1
        else 0
      end as sunk
  from sh left join outcomes o on o.ship=sh.name
)
select country from a
group by country
having count(distinct name)=sum(sunk)

-- Используя таблицу Product, определить количество производителей, выпускающих по одной модели.
select count(q.cm) "count of makers" from (
  select count(model) cm from product
  group by maker
  having count(model)=1
) q

-- Задание 29
-- В предположении, что приход и расход денег на каждом пункте приема фиксируется не чаще одного раза в день [т.е. первичный ключ (пункт, дата)], написать запрос с выходными данными (пункт, дата, приход, расход). Использовать таблицы Income_o и Outcome_o.
select
  isnull(i.point, o.point) point
  , isnull(i.date, o.date) [date]
  , inc
  , out
  from income_o i full outer join outcome_o o 
    on i.date=o.date and i.point=o.point

-- Задание 30
-- В предположении, что приход и расход денег на каждом пункте приема фиксируется произвольное число раз (первичным ключом в таблицах является столбец code), 
-- требуется получить таблицу, в которой каждому пункту за каждую дату выполнения операций будет соответствовать одна строка. Вывод: point, date, суммарный расход пункта за день (out), суммарный приход пункта за день (inc). Отсутствующие значения считать неопределенными (NULL).
select
 isnull(i.point, o.point) point
  , isnull(i.date, o.date) date
  , sum(o.out) outcome
  , sum(i.inc) income
  from income i
  full join outcome o
    on i.point=o.point and i.date=o.date and i.code=o.code
  group by isnull(i.point, o.point), isnull(i.date, o.date)

-- Задание 32
-- Одной из характеристик корабля является половина куба калибра его главных орудий (mw). С точностью до 2 десятичных знаков определите среднее значение mw для кораблей каждой страны, у которой есть корабли в базе данных.
with w as (
  select country, name, bore from classes c join ships s on c.class=s.class
  union
  select country, ship, bore from classes c join outcomes o on c.class=o.ship
)
select
  w.country
  , ROUND(AVG(w.bore*w.bore*w.bore*0.5), 2) as weight
  from w
  group by w.country

-- Задание 32
-- Одной из характеристик корабля является половина куба калибра его главных орудий (mw). С точностью до 2 десятичных знаков определите среднее значение mw для кораблей каждой страны, у которой есть корабли в базе данных.
with w as (
  select country, name, bore from classes c join ships s on c.class=s.class
  union
  select country, ship, bore from classes c join outcomes o on c.class=o.ship
)
select
  w.country
  , ROUND(AVG(w.bore*w.bore*w.bore*0.5), 2) as weight
  from w
  group by w.country

-- Задание 34
-- По Вашингтонскому международному договору от начала 1922 г. запрещалось строить линейные корабли водоизмещением более 35 тыс.тонн. Укажите корабли, нарушившие этот договор (учитывать только корабли c известным годом спуска на воду). 
-- Вывести названия кораблей.
Select s.name from ships s
  join classes c on s.class=c.class
  where
    s.launched >= 1922
    and c.displacement > 35000
    and type='bb'

-- Задание 35
-- В таблице Product найти модели, которые состоят только из цифр или только из латинских букв (A-Z, без учета регистра). 
-- Вывод: номер модели, тип модели. (Всё это было бы проще, если бы оно умело в регулярные выражения(?)).
select model, type from product
 where
  model not like '%[^0-9]%' or model not like '%[^a-z]%'

-- Задание 37
-- Найдите классы, в которые входит только один корабль из базы данных (учесть также корабли в Outcomes).
select q.class from (
  select class, name from ships
  union
  select c.class, o.ship from classes c
    join outcomes o on c.class=o.ship
) q
group by q.class
having count(q.class)=1
;

-- Задание 39
-- Найдите корабли, сохранившиеся для будущих сражений; т.е. выведенные из строя в одной битве (damaged), они участвовали в другой, произошедшей позже.
SELECT
  distinct o.ship
  FROM outcomes o JOIN Battles b ON b.name=o.battle
  WHERE
    o.result = 'damaged'
    and EXISTS(
      SELECT *
      FROM outcomes o2 JOIN Battles b2 ON b2.name=o2.battle
      WHERE
        o2.ship=o.ship
        and b2.date > b.date
    )

-- Задание 41
-- Для ПК с максимальным кодом из таблицы PC вывести все его характеристики (кроме кода) в два столбца:
-- название характеристики (имя соответствующего столбца в таблице PC);
-- значение характеристики
-- NOTE решение не принимается, "несовпадение данных" (потому, что начальная длина строк в 10 байт оказалась недостаточной)
select fields, nullif(value,'x') value from
(
  Select
    cast(model as NVARCHAR(50)) as model
  , cast (speed as NVARCHAR(50)) as speed
  , cast(ram as NVARCHAR(50)) as ram
  , cast(hd as NVARCHAR(50)) as hd
  , cast(cd as NVARCHAR(50)) as cd
  --, cast(price as NVARCHAR(50)) as price
  , COALESCE(CAST(price as NVARCHAR(50)),'x') as price
  from PC
  where code = (Select max(code) from PC)
) as t
unpivot
(
  value for fields in (model, speed, ram, hd, cd, price)
) as unp

-- Задание 45
-- Найдите названия всех кораблей в базе данных, состоящие из трех и более слов (например, King George V). Считать, что слова в названиях разделяются единичными пробелами, и нет концевых пробелов.
select name from ships where name like '_% _% _%'
union
select ship from outcomes where ship like '_% _% _%'

-- Задание 46
-- Для каждого корабля, участвовавшего в сражении при Гвадалканале (Guadalcanal), вывести название, водоизмещение и число орудий.
with allships as (
  select name, class from ships
  union
  select ship as name, ship as class from outcomes
  where ship not in (select name from ships)
)
select a.name, displacement, numGuns from allships a
  left join classes c on a.class=c.class
  join outcomes o on a.name=o.ship and o.battle='Guadalcanal';

-- More optimal
SELECT
  ship, displacement, numGuns
  FROM Outcomes A
    LEFT JOIN Ships C ON A.ship = C.name
    LEFT JOIN Classes B ON A.ship = B.class OR C.class = B.class
  WHERE battle = 'Guadalcanal'

-- Задание 47
-- Пронумеровать строки из таблицы Product в следующем порядке: 
-- имя производителя в порядке убывания числа производимых им моделей (при одинаковом числе моделей имя производителя в алфавитном порядке по возрастанию), 
-- номер модели (по возрастанию). Вывод: номер в соответствии с заданным порядком, имя производителя (maker), модель (model)
select
  ROW_NUMBER() OVER(ORDER BY count desc, maker asc, model asc) rownum
  , maker
  , model
  from (
    -- tmp table with count of models for each maker
    select
      count(model) over(partition by maker) as count
      , p.*
    from product p
  ) p

-- Задание 48
-- Найдите классы кораблей, в которых хотя бы один корабль был потоплен в сражении.
select distinct c.class from outcomes o
  left join ships s on o.ship = s.name
  join classes c on (o.ship=c.class or s.class=c.class)
where result = 'sunk'

-- Задание 49
select name from ships s join classes c on s.class=c.class
where bore=16
union
select ship from outcomes o join classes c on o.ship=c.class
where bore=16

-- one more solution (more effective)
select
  name
  from (
    select name, class from ships
    union
    select ship, ship from outcomes
  ) q
  join classes c on q.class=c.class
  where bore=16
