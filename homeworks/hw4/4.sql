SELECT yearid AS year,SUM(salary) AS salary 
FROM salaries 
WHERE teamid = (SELECT teamid FROM teams WHERE salaries.yearid = teams.yearid AND teams.wswin = 'Y') 
GROUP BY yearid, teamid 
ORDER BY salary DESC;