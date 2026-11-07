-- Building Cost -25%: costs x0.75 (every building, unique buildings included;
-- wonders keep their own costs, and districts in this game have none).
UPDATE Constructibles
SET Cost = CAST(ROUND(Cost * 0.75) AS INTEGER)
WHERE ConstructibleClass = 'BUILDING'
AND Cost > 0;
