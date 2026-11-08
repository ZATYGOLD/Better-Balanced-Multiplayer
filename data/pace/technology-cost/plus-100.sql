-- Technology Cost +100%: costs x2.
UPDATE ProgressionTreeNodes
SET Cost = CAST(ROUND(Cost * 2) AS INTEGER),
    RepeatableCostProgressionParam1 = CASE
        WHEN RepeatableCostProgressionParam1 > 0 THEN CAST(ROUND(RepeatableCostProgressionParam1 * 2) AS INTEGER)
        ELSE RepeatableCostProgressionParam1
    END
WHERE ProgressionTree LIKE 'TREE_TECHS%'
AND Cost > 1;
