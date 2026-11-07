-- Technology Cost -25%: costs x0.75.
UPDATE ProgressionTreeNodes
SET Cost = CAST(ROUND(Cost * 0.75) AS INTEGER),
    RepeatableCostProgressionParam1 = CASE
        WHEN RepeatableCostProgressionParam1 > 0 THEN CAST(ROUND(RepeatableCostProgressionParam1 * 0.75) AS INTEGER)
        ELSE RepeatableCostProgressionParam1
    END
WHERE ProgressionTree LIKE 'TREE_TECHS%'
AND Cost > 1;
