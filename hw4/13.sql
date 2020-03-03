SELECT master.namefirst AS first, master.namelast AS last FROM (
	SELECT a.playerid FROM (
		SELECT * FROM batting WHERE stint=2
	) AS a
	LEFT JOIN (
		SELECT * FROM batting WHERE stint=1
	) AS b
	ON a.yearid=b.yearid AND a.playerid=b.playerid
	WHERE a.ab > b.ab AND a.h < b.h
	ORDER BY a.yearid,a.playerid
) AS d
JOIN master ON master.playerid=d.playerid
ORDER BY master.weight DESC;