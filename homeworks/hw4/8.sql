SELECT b.yearid AS year, as_avg/player_avg AS ratio FROM (SELECT yearid, AVG(salary) AS player_avg FROM salaries GROUP BY yearid) AS b
JOIN (SELECT a.yearid, AVG(a.salary) AS as_avg FROM (SELECT yearid,playerid,SUM(salary) AS salary FROM salaries GROUP BY yearid,playerid) AS a
JOIN allstarfull ON a.yearid=allstarfull.yearid AND a.playerid=allstarfull.playerid GROUP BY a.yearid) AS d
ON b.yearid = d.yearid ORDER BY year ASC;