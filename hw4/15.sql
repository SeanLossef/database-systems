SELECT * FROM (
SELECT namefirst AS first,namelast AS last,birthcity AS city FROM (
SELECT playerid FROM batting JOIN (
SELECT teamid FROM teams WHERE franchid='NYY' GROUP BY teamid
) AS a
ON batting.teamid=a.teamid
GROUP BY playerid ) AS b
JOIN master ON b.playerid=master.playerid
WHERE birthstate='NY') AS d
ORDER BY LAST,first;