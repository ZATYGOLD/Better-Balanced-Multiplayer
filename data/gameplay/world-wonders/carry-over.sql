-- World Wonders: Carry Over. Loaded in every Age. World Wonders of earlier Ages
-- (outside this Age's tech and civic trees, not victory wonders) become wonders
-- of the current Age that need no unlock; the game still allows one of each
-- wonder per world.

CREATE TEMP TABLE BBM_CurrentAge AS
SELECT a.AgeType, a.ChronologyIndex
FROM ProgressionTreeNodeUnlocks u
JOIN Constructibles c ON c.ConstructibleType = u.TargetType
JOIN Ages a ON a.AgeType = c.Age
WHERE c.ConstructibleClass = 'WONDER'
ORDER BY a.ChronologyIndex DESC
LIMIT 1;

UPDATE Constructibles SET RequiresUnlock = 0, Age = (SELECT AgeType FROM BBM_CurrentAge)
WHERE ConstructibleClass = 'WONDER' AND VictoryItem = 0
    AND Age IN (SELECT a.AgeType FROM Ages a WHERE a.ChronologyIndex < (SELECT ChronologyIndex FROM BBM_CurrentAge))
    AND ConstructibleType NOT IN (SELECT TargetType FROM ProgressionTreeNodeUnlocks);

DROP TABLE BBM_CurrentAge;
