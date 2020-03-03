SELECT a1.awardid AS awardid FROM (
	SELECT * FROM awardsplayers
	WHERE yearid >= 1950 AND yearid <= 1957
) AS a1
JOIN awardsplayers AS a2 ON a1.yearid=a2.yearid-1 AND a1.playerid=a2.playerid AND a1.awardid=a2.awardid
JOIN awardsplayers AS a3 ON a2.yearid=a3.yearid-1 AND a2.playerid=a3.playerid AND a2.awardid=a3.awardid
GROUP BY a1.awardid;