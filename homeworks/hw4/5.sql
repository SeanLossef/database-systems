SELECT franchname AS franchise, AVG(CAST(attendance AS numeric)) AS attendance FROM teams
JOIN teamsfranchises ON teamsfranchises.franchid = teams.franchid
WHERE teams.yearid >= 1997 GROUP BY franchname ORDER BY franchname;