-- Building Cost +100%: costs x2 (every building, unique buildings included;
-- wonders keep their own costs, and districts in this game have none).
UPDATE Constructibles
SET Cost = CAST(ROUND(Cost * 2) AS INTEGER)
WHERE ConstructibleClass = 'BUILDING'
AND Cost > 0;
