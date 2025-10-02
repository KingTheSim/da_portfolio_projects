SELECT
	cd."location", 
	cd."date",
	cd.total_cases,
	cd.new_cases,
	cd.total_deaths,
	cd.population
FROM covid_deaths AS cd
ORDER BY cd."location", cd."date";

-- Percentage of Total Deaths compared to Total Infection Cases
SELECT
	cd."location",
	cd."date",
	cd.total_cases,
	cd.total_deaths,
	CASE
		WHEN cd.total_deaths = 0 THEN 0.00
		ELSE (CAST(cd.total_cases AS REAL) / CAST(cd.total_deaths AS REAL)) * 100.0
	END AS death_percentage
FROM covid_deaths AS cd
WHERE cd.continent IS NOT NULL
ORDER BY cd."location", cd."date";

-- Percentage of Pupulation that has been infected
SELECT
	cd."location",
	cd."date",
	cd.population,
	cd.total_cases,
	CASE
		WHEN cd.total_cases = 0 THEN 0.00
		ELSE (CAST(cd.total_cases AS REAL) / CAST(cd.population AS REAL)) * 100.0
	END AS infection_percentage
FROM covid_deaths AS cd
WHERE cd.continent IS NOT NULL
ORDER BY cd."location", cd."date";

-- Highest infection rate compared to population
SELECT
	cd."location",
	cd.population,
	MAX(cd.total_cases) AS maximum_total_cases,
	MAX(CASE
		WHEN cd.total_cases = 0 THEN 0.00
		ELSE (CAST(cd.total_cases AS REAL) / CAST(cd.population AS REAL)) * 100.0
	END) AS percentage_population_infected
FROM covid_deaths AS cd
WHERE cd.continent IS NOT NULL
GROUP BY
	cd."location",
	cd.population
ORDER BY percentage_population_infected DESC;

-- Highest death count per Population for countries
SELECT
	cd."location", 
	cd.population,
	MAX(cd.total_deaths) AS max_total_deaths,
	MAX(CASE
		WHEN cd.total_deaths = 0 THEN 0.00
		ELSE (CAST(cd.total_deaths AS REAL) / CAST(cd.population AS REAL)) * 100
	END) AS total_deaths_per_population_percentage
FROM covid_deaths AS cd
WHERE cd.continent IS NOT NULL
GROUP BY
	cd."location",
	cd.population
ORDER BY total_deaths_per_population_percentage DESC;

-- Highest death count per Population for continents, super-states or other groups
SELECT
	cd."location", 
	cd.population,
	MAX(cd.total_deaths) AS max_total_deaths,
	MAX(CASE
		WHEN cd.total_deaths = 0 THEN 0.00
		ELSE (CAST(cd.total_deaths AS REAL) / CAST(cd.population AS REAL)) * 100
	END) AS total_deaths_per_population_percentage
FROM covid_deaths AS cd
WHERE cd.continent IS NULL
GROUP BY
	cd."location",
	cd.population
ORDER BY total_deaths_per_population_percentage DESC;

-- Total global death count per population percentage
SELECT
	SUM(cd.new_cases) AS total_cases,
	SUM(cd.new_deaths) AS total_deaths,
	(CAST(SUM(cd.new_deaths) AS FLOAT) / CAST(SUM(cd.new_cases) AS FLOAT)) * 100.0 AS global_death_per_case_percentage
FROM covid_deaths AS cd
WHERE cd.continent IS NOT NULL;

-- Total population vs vaccinations with CTE
WITH population_vs_vaxed (
	continent,
	"location",
	"date",
	population,
	new_vaccinations,
	rolling_people_vaccinated
) AS (
SELECT
	cd.continent,
	cd."location",
	cd."date",
	cd.population,
	cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd."location" ORDER BY cd."location", cd."date") AS rolling_people_vaccinated
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
	ON cd."location" = cv."location"
	AND cd."date" = cv."date"
WHERE cd.continent IS NOT NULL)
SELECT
	*,
	(CAST(rolling_people_vaccinated AS REAL) / CAST(population AS REAL)) * 100.0 AS percentage_of_population_vaccinated
FROM population_vs_vaxed
ORDER BY
	continent,
	"location",
	"date";

-- View of the highest death count per Population for continents, super-states or other groups
CREATE VIEW death_percentage_to_population_continents AS
SELECT
	cd."location", 
	cd.population,
	MAX(cd.total_deaths) AS max_total_deaths,
	MAX(CASE
		WHEN cd.total_deaths = 0 THEN 0.00
		ELSE (CAST(cd.total_deaths AS REAL) / CAST(cd.population AS REAL)) * 100
	END) AS total_deaths_per_population_percentage
FROM covid_deaths AS cd
WHERE cd.continent IS NULL
GROUP BY
	cd."location",
	cd.population;