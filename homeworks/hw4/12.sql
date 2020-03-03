SELECT name FROM (
	SELECT teamidloser, MAX(yearid) AS yearid, COUNT(*) AS losses FROM seriespost WHERE round = 'ALCS' OR round = 'NLCS'
	GROUP BY teamidloser
) AS a1
JOIN teams ON a1.teamidloser=teams.teamid AND a1.yearid=teams.yearid
WHERE a1.losses > 2
ORDER BY name;