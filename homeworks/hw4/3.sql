SELECT m1.yearid AS years FROM managers m1 
JOIN teams ON m1.teamid=teams.teamid AND m1.yearid=teams.yearid
WHERE m1.yearid >= 1975 AND m1.w = (SELECT MAX(m2.w) FROM managers m2 WHERE m2.yearid = m1.yearid) AND teams.divwin='Y' ORDER BY m1.yearid DESC;