SELECT park FROM seriespost
JOIN teams ON seriespost.teamidwinner=teams.teamid AND seriespost.yearid=teams.yearid
WHERE seriespost.ROUND LIKE '%DS%'
AND NOT LOWER(park) LIKE '%field%'
AND NOT LOWER(park) LIKE '%park%'
AND NOT LOWER(park) LIKE '%stadium%'
GROUP BY park;