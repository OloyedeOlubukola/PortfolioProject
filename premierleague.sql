Select * FROM PremierLeague

--Clean Data

--Standardize Date 

;With CTE as (
Select date, 
case when try_cast(left(date, 2) as int) is not null then left(date, 2) else left(date, 1) end as day,
SUBSTRING(date, CHARINDEX(' ', date) + 1, CHARINDEX(' ', date, CHARINDEX(' ', date) + 1) - CHARINDEX(' ', date) - 1) AS month,
SUBSTRING(date, CHARINDEX(' ', date, CHARINDEX(' ', date) + 1), LEN(date)) AS year
from PremierLeague
)
Select date, cast(concat(year, '-', month, '-', day) as date) as dateconverted 
from cte



--Create Temp Table


 ;With CTE as (
select date, 
case when try_cast(left(date, 2) as int) is not null then left(date, 2) else left(date, 1) end as day,
SUBSTRING(date, CHARINDEX(' ', date) + 1, CHARINDEX(' ', date, CHARINDEX(' ', date) + 1) - CHARINDEX(' ', date) - 1) AS month,
SUBSTRING(date, CHARINDEX(' ', date, CHARINDEX(' ', date) + 1), LEN(date)) AS year
from PremierLeague
)
Select date, cast(concat(year, '-', month, '-', day) as date) as dateconverted
into #temp2
from cte

select * from #temp2


--Update Table 

UPDATE PremierLeague
set premierleague.date = b.dateconverted
from PremierLeague
left join #temp2 b on PremierLeague.date = b.date


--Rename Column


exec sp_rename 'PremierLeague.Home Team' , 'HomeTeam', 'Column';
exec sp_rename 'PremierLeague.Goals Home' , 'HomeGoal', 'Column';
exec sp_rename 'PremierLeague.Away Team' , 'AwayTeam', 'Column';
exec sp_rename 'PremierLeague.Away Goals' , 'AwayGoal', 'Column';


--Total Home Goals & Total Away Goals

Select HomeTeam,
Sum(HomeGoal) as TotalHomeGoals,
Sum(AwayGoal) as TotalAwayGoal,
Sum(HomeGoal) + Sum(AwayGoal) as TotalGoals
From PremierLeague
Group By HomeTeam
Order By Sum(HomeGoal) + Sum(AwayGoal) desc


-- Attendance By Date

Select date,
SUM (attendance) as TotalAttendanceByDate 
From PremierLeague
Group By date
Order By SUM (attendance) asc 


--Attendance By Stadium 

Select stadium,
SUM(attendance) as TotalAttendanceByStadium
From PremierLeague
Group By stadium
Order by SUM(attendance) asc

-- Game Outcome 

SELECT HomeTeam, AwayTeam,
 CASE WHEN HomeGoal > AwayGoal THEN Concat(HomeTeam, ' Win')
      WHEN HomeGoal  < AwayGoal THEN Concat(AwayTeam, ' Win')
      ELSE 'Draw'
      END AS Outcome
FROM PremierLeague;



--Total Red/Yellow Cards Issued In Each Match 

SELECT date, HomeTeam, AwayTeam, home_red, away_red, home_yellow, away_yellow,
    home_red + away_red AS TotalRedCards,
    home_yellow + away_yellow AS TotalYellowCards
FROM PremierLeague


SELECT HomeTeam, AwayTeam, date, home_red, away_red, home_yellow, away_yellow
From PremierLeague


--TEAM RANKER: This Query Shows The Rank Of Each Team According To The Highest Goal Scorer  


With CTE  as(
select hometeam, sum(HomeGoal) + sum(AwayGoal) as TotalGoals 
from PremierLeague
group by HomeTeam
),
 DTE as (
 select *, ROW_NUMBER() over (order by TotalGoals Desc) as Ranker
 from CTE
 )
 select * from DTE


--MATCH PLAYED: This Query Shows The Number of Matches Played By Each Team 

WITH MatchCounts AS (
     Select  HomeTeam AS Team,
     COUNT(*) AS HomeMatches  
     From  Premierleague
     Group By HomeTeam      
),
AwayMatchCounts AS (
    Select AwayTeam AS Team,
    COUNT(*) AS AwayMatches    
    From  Premierleague
    Group By AwayTeam       
)
Select  mc.Team,
    COALESCE(mc.HomeMatches, 0) AS HomeMatches,
    COALESCE(amc.AwayMatches, 0) AS AwayMatches,
    COALESCE(mc.HomeMatches, 0) + COALESCE(amc.AwayMatches, 0) AS TotalMatches
From MatchCounts mc  
    LEFT JOIN
    AwayMatchCounts amc ON mc.Team = amc.Team
    Order By TotalMatches DESC;
  
  

-- MATCH RESULT: This Query Shows The Total Number Of Points Earned By Each Team 

WITH MatchResults AS (
     Select HomeTeam AS Team,
     SUM(CASE WHEN HomeGoal > AwayGoal THEN 3
             WHEN HomeGoal = AwayGoal THEN 1
             ELSE 0
			 END) AS Points        
From Premierleague
Group By HomeTeam      
),
AwayMatchResults AS (
    Select AwayTeam AS Team, 
    SUM(CASE WHEN AwayGoal > HomeGoal THEN 3
             WHEN AwayGoal = HomeGoal THEN 1
             ELSE 0
             END) AS Points    
From Premierleague
Group By AwayTeam 
)
Select Teams.Team,
    COALESCE(MatchResults.Points, 0) + COALESCE(AwayMatchResults.Points, 0) AS TotalPoints
From
    (Select Team FROM MatchResults
     UNION
     Select Team FROM AwayMatchResults) AS Teams
     LEFT JOIN
    MatchResults ON Teams.Team = MatchResults.Team
     LEFT JOIN
    AwayMatchResults ON Teams.Team = AwayMatchResults.Team
Order By
    TotalPoints DESC;



--TEAM STATISTICS: This Shows The Total Number Of Goals Scored, Total Number Of Goals Conceded and Goal Differences By Each Team 

WITH TeamStats AS (
 Select  HomeTeam AS Team,
        SUM(HomeGoal) AS GoalsScored,
        SUM(AwayGoal) AS GoalsConceded
From Premierleague
          GROUP BY
        HomeTeam
    UNION ALL
    SELECT
        AwayTeam AS Team,
        SUM(AwayGoal) AS GoalsScored,
        SUM(HomeGoal) AS GoalsConceded
    FROM
        Premierleague
    GROUP BY
        AwayTeam
)
SELECT
    Team,
    SUM(GoalsScored) AS TotalGoalsScored,
    SUM(GoalsConceded) AS TotalGoalsConceded,
    SUM(GoalsScored) - SUM(GoalsConceded) AS GoalDifference
FROM
    TeamStats
GROUP BY
    Team
ORDER BY
    GoalDifference DESC;
