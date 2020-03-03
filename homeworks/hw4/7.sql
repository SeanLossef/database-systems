SELECT b.* FROM (
SELECT playerid, hits/atbats AS career_avg
FROM (SELECT playerid, SUM(ab) AS atbats, SUM(h) AS hits FROM batting GROUP BY playerid) AS a
WHERE atbats>300 ORDER BY career_avg DESC ) AS b
LEFT JOIN master ON b.playerid=master.playerid WHERE birthyear >= 1958 AND birthyear <= 1960