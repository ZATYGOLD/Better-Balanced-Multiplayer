-- Military Victory Threshold High: the curve's modifiers x1.5.
-- Adding 1 before integer division rounds half values up to the nearest percent.
UPDATE VictoryDominationPercents
SET DominationPercent = ((DominationPercent * 3) + 1) / 2
WHERE VictoryType = 'VICTORY_MILITARY_MODERN'
AND (
    (StartingAge = 'AGE_ANTIQUITY' AND PreviousAgeCount IN (1, 2))
    OR (StartingAge = 'AGE_EXPLORATION' AND PreviousAgeCount = 1)
    OR (StartingAge = 'AGE_MODERN' AND PreviousAgeCount = 0)
);
