-- Building Cost +50%: costs x1.5 (every building, unique buildings included;
-- wonders keep their own costs, and districts in this game have none).
UPDATE Constructibles
SET Cost = CAST(ROUND(Cost * 1.5) AS INTEGER)
WHERE ConstructibleClass = 'BUILDING'
AND Cost > 0;
