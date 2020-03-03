SELECT master.namefirst AS first, master.namelast AS last, appearances FROM halloffame
JOIN (SELECT COUNT(playerid) AS appearances, playerid FROM allstarfull GROUP BY playerid) AS a
ON halloffame.playerid = a.playerid
JOIN master ON a.playerid=master.playerid
WHERE halloffame.yearid=2000
ORDER BY appearances DESC, master.birthmonth
LIMIT 8;