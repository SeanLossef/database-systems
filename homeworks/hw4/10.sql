SELECT name_full AS school_name, COUNT(*) FROM (
SELECT DISTINCT schools.name_full,master.playerid FROM schools JOIN collegeplaying ON schools.schoolid=collegeplaying.schoolid
JOIN allstarfull ON collegeplaying.playerid=allstarfull.playerid JOIN master ON allstarfull.playerid=master.playerid
) AS a GROUP BY name_full ORDER BY COUNT DESC, name_full LIMIT 10;