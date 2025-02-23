-- PART I: SCHOOL ANALYSIS
use maven_advanced_sql;
-- 1. View the schools and school details tables
select * from schools;
select * from school_details;
-- 2. In each decade, how many schools were there that produced players?
select ROUND(yearID - 1) as decade,COUNT(DISTINCT schoolID) as num_schools
from schools
group by decade
order by decade;
-- 3. What are the names of the top 5 schools that produced the most players?
SELECT sd.name_full, COUNT(DISTINCT s.playerID) AS num_players
FROM schools s 
LEFT JOIN school_details sd ON s.schoolID = sd.schoolID
GROUP BY s.schoolID, sd.name_full
ORDER BY num_players DESC
LIMIT 5;


-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
WITH ds AS (
    SELECT FLOOR(s.yearID / 10) * 10 AS decade, 
           sd.name_full, 
           COUNT(DISTINCT s.playerID) AS num_players
    FROM schools s 
    LEFT JOIN school_details sd ON s.schoolID = sd.schoolID
    GROUP BY decade, s.schoolID, sd.name_full
),
rn AS (
    SELECT decade, name_full, num_players,
           ROW_NUMBER() OVER (PARTITION BY decade ORDER BY num_players DESC) AS row_num
    FROM ds
)
SELECT decade, name_full, num_players
FROM rn
WHERE row_num <= 3
ORDER BY decade DESC, row_num;


-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
select * from salaries;
-- 2. Return the top 20% of teams in terms of average annual spending
WITH ts AS (
    SELECT teamID, yearID, SUM(salary) AS total_spend
    FROM salaries
    GROUP BY teamID, yearID
), 
sp AS (
    SELECT teamID, 
           AVG(total_spend) AS avg_spend,
           NTILE(5) OVER (ORDER BY AVG(total_spend) DESC) AS spend_pct
    FROM ts
    GROUP BY teamID
)
SELECT teamID, ROUND(avg_spend / 1000000, 1) AS avg_spend_millions
FROM sp
WHERE spend_pct = 1;

-- 3. For each team, show the cumulative sum of spending over the years
WITH ts AS (SELECT	 teamID, yearID, SUM(salary) AS total_spend
			FROM	 salaries
			GROUP BY teamID, yearID
			ORDER BY teamID, yearID) -- ORDER BY in CTE is not needed and can be omitted
            
SELECT	teamID, yearID,
		ROUND(SUM(total_spend) OVER (PARTITION BY teamID ORDER BY yearID) / 1000000, 1)
			AS cumulative_sum_millions
FROM	ts;
-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
WITH ts AS (SELECT	 teamID, yearID, SUM(salary) AS total_spend
			FROM	 salaries
			GROUP BY teamID, yearID
			ORDER BY teamID, yearID), -- ORDER BY in CTE is not needed and can be omitted
            
	 cs AS (SELECT	teamID, yearID,
					SUM(total_spend) OVER (PARTITION BY teamID ORDER BY yearID)
						AS cumulative_sum
			FROM	ts),
            
	 rn AS (SELECT	teamID, yearID, cumulative_sum,
					ROW_NUMBER() OVER (PARTITION BY teamID ORDER BY cumulative_sum) AS rn
			FROM	cs
			WHERE	cumulative_sum > 1000000000)
            
SELECT	teamID, yearID, ROUND(cumulative_sum / 1000000000, 2) AS cumulative_sum_billions
FROM	rn
WHERE	rn = 1;

-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
select * from players;
select count(*) from players;
-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
SELECT 	nameGiven,
        TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE), debut)
			AS starting_age,
		TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE), finalGame)
			AS ending_age,
		TIMESTAMPDIFF(YEAR, debut, finalGame) AS career_length
FROM	players;

-- 3. What team did each player play on for their starting and ending years?
SELECT  
    p.nameGiven,         
    TIMESTAMPDIFF(YEAR, 
        CAST(CONCAT(p.birthYear, '-', p.birthMonth, '-', p.birthDay) AS DATE), 
        STR_TO_DATE(p.debut, '%Y-%m-%d')
    ) AS starting_age,   
    TIMESTAMPDIFF(YEAR, 
        CAST(CONCAT(p.birthYear, '-', p.birthMonth, '-', p.birthDay) AS DATE), 
        STR_TO_DATE(p.finalGame, '%Y-%m-%d')
    ) AS ending_age,   
    TIMESTAMPDIFF(YEAR, 
        STR_TO_DATE(p.debut, '%Y-%m-%d'), 
        STR_TO_DATE(p.finalGame, '%Y-%m-%d')
    ) AS career_length 
FROM players p;


-- 4. How many players started and ended on the same team and also played for over a decade?
SELECT  
    p.nameGiven,
    s.yearID AS starting_year, 
    s.teamID AS starting_team,
    e.yearID AS ending_year, 
    e.teamID AS ending_team
FROM players p
INNER JOIN salaries s 
    ON p.playerID = s.playerID 
    AND p.debut = s.yearID   -- No YEAR() needed
INNER JOIN salaries e 
    ON p.playerID = e.playerID 
    AND p.finalGame = e.yearID  -- No YEAR() needed
WHERE s.teamID = e.teamID 
AND e.yearID - s.yearID > 10;

-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
SELECT * FROM players;
-- 2. Which players have the same birthday?
WITH bn AS (SELECT	CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE) AS birthdate,
					nameGiven
			FROM	players)
            
SELECT	birthdate, GROUP_CONCAT(nameGiven SEPARATOR ', ') AS players
FROM	bn
WHERE	YEAR(birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate
ORDER BY birthdate;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
SELECT	s.teamID,
		ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_right,
        ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_left,
        ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_both
FROM	salaries s LEFT JOIN players p
		ON s.playerID = p.playerID
GROUP BY s.teamID;

-- The duplicates exist because each row in the salaries table represents a player's salary on a particular team for a particular year
WITH up AS (SELECT DISTINCT s.teamID, s.playerID, p.bats
           FROM salaries s LEFT JOIN players p
           ON s.playerID = p.playerID) -- unique players CTE

SELECT teamID,
		ROUND(SUM(CASE WHEN bats = 'R' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_right,
        ROUND(SUM(CASE WHEN bats = 'L' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_left,
        ROUND(SUM(CASE WHEN bats = 'B' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_both
FROM up
GROUP BY teamID;
-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
WITH hw AS (SELECT	FLOOR(YEAR(debut) / 10) * 10 AS decade,
					AVG(height) AS avg_height, AVG(weight) AS avg_weight
			FROM	players
			GROUP BY decade)
            
SELECT	decade,
		avg_height - LAG(avg_height) OVER(ORDER BY decade) AS height_diff,
        avg_weight - LAG(avg_weight) OVER(ORDER BY decade) AS weight_diff
FROM	hw
WHERE	decade IS NOT NULL;
