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
-- Найдите среднюю скорость ПК-блокнотов, цена которых превышает 1000 дол.
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
