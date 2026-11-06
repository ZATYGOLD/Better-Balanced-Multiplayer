-- Low: multiply the Standard non-Science victory modifiers by 0.75.
-- Adding 2 before integer division rounds half values up to the nearest percent.
UPDATE VictoryDominationPercents
SET DominationPercent = ((DominationPercent * 3) + 2) / 4
WHERE VictoryType IN (
    'VICTORY_CULTURE_MODERN',
    'VICTORY_ECONOMIC_MODERN',
    'VICTORY_MILITARY_MODERN'
)
AND (
    (StartingAge = 'AGE_ANTIQUITY' AND PreviousAgeCount IN (1, 2))
    OR (StartingAge = 'AGE_EXPLORATION' AND PreviousAgeCount = 1)
    OR (StartingAge = 'AGE_MODERN' AND PreviousAgeCount = 0)
);
