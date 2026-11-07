-- Building Cost +25%: costs x1.25 (every building, unique buildings included;
-- wonders keep their own costs, and districts in this game have none).
UPDATE Constructibles
SET Cost = CAST(ROUND(Cost * 1.25) AS INTEGER)
WHERE ConstructibleClass = 'BUILDING'
AND Cost > 0;
