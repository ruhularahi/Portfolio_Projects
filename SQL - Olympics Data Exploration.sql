DROP TABLE IF EXISTS OLYMPICS_HISTORY;

CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY

(
    id VARCHAR,
    name VARCHAR,
    sex VARCHAR,
    age VARCHAR,
    height VARCHAR,
    weight VARCHAR,
    team VARCHAR,
	noc VARCHAR,
	games VARCHAR,
    year INT,
    season VARCHAR,
    city VARCHAR,
    sport VARCHAR,
	event VARCHAR,
	medal VARCHAR
);

DROP TABLE IF EXISTS NOC_REGION;

CREATE TABLE IF NOT EXISTS NOC_REGION

(   noc VARCHAR,
    region VARCHAR,
    notes VARCHAR
  
);

--identify all the sports which played in all the summer olympic games.

WITH t1 as
	(SELECT distinct(sport), games
	FROM olympics_history
	WHERE season = 'Summer'
	ORDER BY games),
t2 as
	(SELECT sport, count(sport)
	FROM t1
	GROUP BY sport
	ORDER BY count DESC)

SELECT *
FROM t2
WHERE count = (SELECT count(distinct(games))
	FROM olympics_history
	WHERE season = 'Summer');
	
--Fetch the top five Athlete who have own the most gold medal.

WITH t1 as 
	(SELECT name, count(medal) as total_medals
	FROM olympics_history
	WHERE medal = 'Gold'
	GROUP BY name
	ORDER BY total_medals DESC),
t2 as 
	(SELECT *, dense_rank() over(order by total_medals desc) as rank
	FROM t1
	ORDER BY rank)

SELECT *
FROM t2
WHERE rank <=5;

--Display the total gold, silver and bronze medal won by each country in Olympics.

CREATE EXTENSION tablefunc;

-- SELECT country,
-- coalesce(Gold, 0)as Gold,
-- coalesce(Silver, 0)as Silver,
-- coalesce(Bronze, 0) as Bronze

-- FROM crosstab('SELECT nr.region as country, oh.medal, count(medal) as medal_count
-- 		FROM olympics_history as oh
-- 		LEFT JOIN noc_region as nr
-- 		ON oh.noc = nr.noc
-- 		WHERE oh.medal <> ''NA'' and medal is not null
-- 		GROUP BY nr.region, oh.medal
-- 		ORDER BY nr.region, oh.medal',
-- 		'values (''Bronze''), (''Gold''), (''Silver'')')
-- 	as result(country varchar, bronze bigint, gold bigint, silver bigint)
-- ORDER BY Gold desc, Silver desc, Bronze desc;

SELECT country,
coalesce(Gold, 0)as Gold,
coalesce(Silver, 0)as Silver,
coalesce(Bronze, 0) as Bronze

FROM crosstab(
	'WITH combined as 
		(select *
		FROM olympics_history as oh
		LEFT JOIN noc_region as nr
		ON oh.noc = nr.noc 
		)
	SELECT region as country, medal, count(medal) as medal_count
	FROM combined
	WHERE medal <> ''NA'' and medal is not null
	GROUP BY region, medal
	ORDER BY region, medal',
		'values (''Bronze''), (''Gold''), (''Silver'')')
	as result(country varchar, bronze bigint, gold bigint, silver bigint)
ORDER BY Gold desc, Silver desc, Bronze desc;

--fetch the country which won the most gold, 
--most silver and most bronze medal during each Olympic game

WITH temp as
	(SELECT substring(games_country, 1, position(' - ' in games_country) - 1) as games,
	substring(games_country, position(' - ' in games_country) + 3) as country,
	coalesce(Gold, 0)as Gold,
	coalesce(Silver, 0)as Silver,
	coalesce(Bronze, 0) as Bronze

	FROM crosstab(
		'WITH combined as 
			(select *
			FROM olympics_history as oh
			LEFT JOIN noc_region as nr
			ON oh.noc = nr.noc 
			)
		SELECT concat(games, '' - '', region) as games_country, medal, count(medal) as medal_count
		FROM combined
		WHERE medal <> ''NA'' and medal is not null
		GROUP BY combined.games, region, medal
		ORDER BY combined.games, region, medal',
			'values (''Bronze''), (''Gold''), (''Silver'')')
		as result(games_country varchar, bronze bigint, gold bigint, silver bigint)
	ORDER BY games_country)
SELECT distinct(games),
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games order by gold desc), ' - '
	   ,FIRST_VALUE(gold) OVER(PARTITION BY games order by gold desc)) as gold,
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games order by silver desc), ' - '
	   ,FIRST_VALUE(silver) OVER(PARTITION BY games order by silver desc)) as silver,
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games order by bronze desc), ' - '
	   ,FIRST_VALUE(bronze) OVER(PARTITION BY games order by bronze desc)) as bronze
FROM temp
ORDER BY games;
