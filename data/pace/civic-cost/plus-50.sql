-- Civic Cost +50%: costs x1.5.
UPDATE ProgressionTreeNodes
SET Cost = CAST(ROUND(Cost * 1.5) AS INTEGER),
    RepeatableCostProgressionParam1 = CASE
        WHEN RepeatableCostProgressionParam1 > 0 THEN CAST(ROUND(RepeatableCostProgressionParam1 * 1.5) AS INTEGER)
        ELSE RepeatableCostProgressionParam1
    END
WHERE ProgressionTree LIKE 'TREE_CIVIC%'
AND Cost > 1;
