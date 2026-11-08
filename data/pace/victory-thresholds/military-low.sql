-- Military Victory Threshold Low: the threshold curve's percentages x0.5
-- (the game's curve, or Game Balance's when it is Multiplayer).
-- Adding 1 before integer division rounds half values up to the nearest percent.
UPDATE VictoryDominationPercents
SET DominationPercent = (DominationPercent + 1) / 2
WHERE VictoryType = 'VICTORY_MILITARY_MODERN'
AND (
    (StartingAge = 'AGE_ANTIQUITY' AND PreviousAgeCount IN (1, 2))
    OR (StartingAge = 'AGE_EXPLORATION' AND PreviousAgeCount = 1)
    OR (StartingAge = 'AGE_MODERN' AND PreviousAgeCount = 0)
);
