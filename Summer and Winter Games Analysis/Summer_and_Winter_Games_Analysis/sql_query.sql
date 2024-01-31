-- How many unique athletes are there for each sport, find the top 3?
SELECT 
	sport, 
    count(distinct athlete_id)  AS athletes
FROM summer_games
GROUP BY sport
ORDER BY athletes
LIMIT 3;

-- How many events and athletes are in each sport category
SELECT 
	sport, 
    count(distinct event) AS events, 
    count(distinct athlete_id) AS athletes
FROM summer_games
GROUP BY sport;

-- Select the age of the oldest athletes for each region
SELECT 
	region, 
    MAX(age) AS age_of_oldest_athlete
FROM athletes a
JOIN summer_games s
ON a.id = s.athlete_id
JOIN countries c
ON s.country_id = c.id
GROUP BY region;

-- Create a report that shows unique events by sport for both summer and winter events.
SELECT 
	sport, 
    count(distinct event) AS events
FROM summer_games
GROUP BY sport
UNION
SELECT 
	sport, 
    count(distinct event) AS events
FROM winter_games
GROUP BY sport
ORDER BY events DESC;

-- Who are the top gold medalist in the summer games (athlete with 3 or more gold medals)
SELECT 
	name AS athlete_name, 
    SUM(gold) AS gold_medals
FROM summer_games AS s
JOIN athletes AS a
ON s.athlete_id = a.id
GROUP BY name
Having SUM(gold)>3
ORDER BY gold_medals DESC;

-- Number of events by country and season
SELECT 
	'summer' AS season, 
    c.country, 
    COUNT(distinct event) AS events
FROM  summer_games AS s
JOIN countries AS c
ON s.country_id = c.id
GROUP BY c.country, season
UNION
SELECT 
	'winter' AS season, 
    c.country, 
    COUNT(distinct event) AS events
FROM winter_games AS w
JOIN countries AS c
ON w.country_id = c.id
GROUP BY c.country, season
ORDER BY events DESC;

-- Find out the number of athletes in each summer sport by different BMI bucket
-- bmi_bucket, which splits up BMI into three groups: <.25, .25-.30, >.30
SELECT 
	sport,	
    CASE WHEN weight/height^2*100 <.25 THEN '<.25'
    WHEN weight/height^2*100 <=.30 THEN '.25-.30'
    WHEN weight/height^2*100 >.30 THEN '>.30' 
	ELSE 'no weight recorded' END AS bmi_bucket,
    COUNT(DISTINCT athlete_id) AS athletes
FROM summer_games AS s
JOIN athletes AS a
ON s.athlete_id = a.id
GROUP BY sport, bmi_bucket
ORDER BY sport, athletes DESC;

-- Top 10 most athletes event from nobel prize winners countries
SELECT 
    event,
    CASE WHEN event LIKE '%Women%' THEN 'female' 
    ELSE 'male' END AS gender,
    COUNT(DISTINCT athlete_id) AS athletes
FROM summer_games
WHERE country_id IN 
	(SELECT country_id 
    FROM country_stats 
    WHERE nobel_prize_winners > 0)
GROUP BY event
UNION
SELECT 
    event,
    CASE WHEN event LIKE '%Women%' THEN 'female' 
    ELSE 'male' END AS gender,
    COUNT(DISTINCT athlete_id) AS athletes
FROM winter_games
WHERE country_id IN 
	(SELECT country_id 
    FROM country_stats 
    WHERE nobel_prize_winners > 0)
GROUP BY event
ORDER BY athletes DESC
LIMIT 10;

/*-- What are the top 25 countries those have high medal rates per population?
 The table should include country_code (first three character of coutry column), 
pop_in_millions, medals, adn medals_per_million*/

SELECT
    LEFT(REPLACE(UPPER(LTRIM(c.country)), '.', ''), 3) as country_code,
	pop_in_millions,
	SUM(COALESCE(bronze,0) + COALESCE(silver,0) + COALESCE(gold,0)) AS medals,
	SUM(COALESCE(bronze,0) + COALESCE(silver,0) + COALESCE(gold,0)) / CAST(cs.pop_in_millions AS float) AS medals_per_million
FROM summer_games AS s
JOIN countries AS c 
ON s.country_id = c.id
JOIN country_stats AS cs 
ON s.country_id = cs.country_id AND s.year = CAST(cs.year AS date)
WHERE pop_in_millions IS NOT NULL
GROUP BY c.country, pop_in_millions
ORDER BY medals_per_million DESC
LIMIT 25;

-- Average tallest people and percent of gdp per region
SELECT
    region,
    AVG(height) AS avg_tallest,
    SUM(gdp)/SUM(SUM(gdp)) OVER () AS perc_world_gdp    
FROM countries AS c
JOIN
    (SELECT 
        country_id, 
        height, 
        ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY height DESC) AS row_num
    FROM winter_games AS w 
    JOIN athletes AS a ON w.athlete_id = a.id
    GROUP BY country_id, height
    ORDER BY country_id, height DESC) AS subquery
ON c.id = subquery.country_id
JOIN country_stats AS cs 
ON cs.country_id = c.id
WHERE row_num = 1
GROUP BY region;


