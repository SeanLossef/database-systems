SELECT yearid AS year, AVG(sum) AS salary FROM (
SELECT yearid,teamid,SUM(salary) FROM salaries GROUP BY yearid,teamid
) AS a GROUP BY yearid
ORDER BY yearid ASC;