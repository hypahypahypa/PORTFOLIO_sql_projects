--График случаев заражения и параллелльно график вакцинаций (в России)
SELECT
	d.location,
	d.date,
	d.total_cases,
	v.total_vaccinations
FROM
	sqlcoviddeaths d
JOIN
	sqlcovidvaccinations v
	ON
		d.date = v.date AND d.iso_code = v.iso_code
WHERE
	d.location = 'Russia'
ORDER BY
	d.date;

-- join, агрегатные функции
-- статистика случаев заболеваний и вакцинаций, сгруппированная по странам и континентам
SELECT
	d.location,
	d.population,
	MAX(d.total_cases) AS max_infected,
	MAX(v.total_vaccinations) AS max_vaccinations
FROM
	sqlcoviddeaths d
JOIN
	sqlcovidvaccinations v
	ON d.date = v.date
WHERE
	d.continent IS NOT NULL
GROUP BY
	d.location,
	d.population
ORDER BY
	d.population DESC;

-- CASE
-- значения по миру
SELECT
	location,
	date,
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	CASE
		WHEN SUM(new_cases) = 0
		THEN 0
		ELSE SUM(new_deaths)/SUM(new_cases)
	END * 100 AS death_percentage	
FROM
	sqlcoviddeaths
WHERE
	continent IS NOT NULL
GROUP BY
	1, 2
ORDER BY
	location, date;

-- оконные функции
-- сравнение количества вакцинаций в конкретный день и общего количества 
-- в крупнейших странах, начиная с 1 января 2021 года
SELECT
	d.location,
	d.date,
	v.new_vaccinations AS vac_in_that_cert_day,
	SUM(v.new_vaccinations) 
		OVER 
			(PARTITION BY 
				d.location
			ORDER BY
				d.location,
				d.date) AS rolling_vac
FROM
	sqlcoviddeaths d
JOIN
	sqlcovidvaccinations v
	ON
		d.date = v.date AND d.iso_code = v.iso_code
WHERE
	d.date > '2020-12-31'
	AND d.location
		IN ('France', 'Germany', 'United Kingdom', 'Italy', 'United States', 'Russia')
ORDER BY 1, 2;

-- CTE Common Table Expressions (общие табличные выражения)
-- создается для дальнейших рассчетов (процент вакцинированного населения)
-- ? (для себя) для просмотра итогового значения можно убрать столбец даты
WITH pop_vs_vac (
	location,
	date,
	population,
	vac_in_that_cert_day,
	rolling_vac) AS
(
	SELECT
		d.location,
		d.date,
		d.population,
		v.new_vaccinations AS vac_in_that_cert_day,
		SUM(v.new_vaccinations) 
			OVER 
				(PARTITION BY 
					d.location
				ORDER BY
					d.location,
					d.date) AS rolling_vac
	FROM
		sqlcoviddeaths d
	JOIN
		sqlcovidvaccinations v
		ON
			d.date = v.date AND d.iso_code = v.iso_code
	WHERE
		d.date > '2020-12-31'
		AND d.location
			IN ('France', 'Germany', 'United Kingdom', 'Italy', 'United States', 'Russia')
	ORDER BY 1, 2
)
SELECT
	*,
	(rolling_vac/population)*100 AS percent_of_vac_ppl
FROM pop_vs_vac;

-- временные таблицы
-- 1. создание временной таблицы
CREATE TABLE percent_ppl_vaccinated (
	location varchar(50),
	date date,
	population bigint,
	new_vaccinations int,
	vac_in_that_cert_day int,
	rolling_vac float
);

-- 2. импорт данных во временную таблицу
INSERT INTO percent_ppl_vaccinated
SELECT
		d.location,
		d.date,
		d.population,
		v.new_vaccinations AS vac_in_that_cert_day,
		SUM(v.new_vaccinations) 
			OVER 
				(PARTITION BY 
					d.location
				ORDER BY
					d.location,
					d.date) AS rolling_vac
	FROM
		sqlcoviddeaths d
	JOIN
		sqlcovidvaccinations v
		ON
			d.date = v.date AND d.iso_code = v.iso_code
	WHERE
		d.date > '2020-12-31'
		AND d.location
			IN ('France', 'Germany', 'United Kingdom', 'Italy', 'United States', 'Russia')
	ORDER BY 1, 2
;
-- 3. проверка данных
SELECT * FROM percent_ppl_vaccinated;

SELECT
	*,
	(rolling_vac/population)*100 AS percent_of_vac_ppl
FROM percent_ppl_vaccinated;

-- Создание представления для хранения данных, для дальнейших визуализаций
CREATE VIEW v_percent_ppl_vaccinated AS
SELECT
		d.location,
		d.date,
		d.population,
		v.new_vaccinations AS vac_in_that_cert_day,
		SUM(v.new_vaccinations) 
			OVER 
				(PARTITION BY 
					d.location
				ORDER BY
					d.location,
					d.date) AS rolling_vac
	FROM
		sqlcoviddeaths d
	JOIN
		sqlcovidvaccinations v
		ON
			d.date = v.date AND d.iso_code = v.iso_code
	WHERE
		d.date > '2020-12-31'
		AND d.location
			IN ('France', 'Germany', 'United Kingdom', 'Italy', 'United States', 'Russia')
	ORDER BY 1, 2;