-- Standard Culture, Economic, and Military victory-threshold curve.
-- Science is intentionally excluded and remains fixed at 100 Innovation.

DELETE FROM VictoryDominationPercents
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

WITH VictoryClasses(VictoryType) AS (
    VALUES
        ('VICTORY_CULTURE_MODERN'),
        ('VICTORY_ECONOMIC_MODERN'),
        ('VICTORY_MILITARY_MODERN')
),
ThresholdCurve(Name, StartingAge, MinAgeProgressPercent, DominationPercent, PreviousAgeCount) AS (
    VALUES
        -- Full campaign: thresholds begin midway through Exploration.
        ('LOC_VICTORY_NAME_1',                 'AGE_ANTIQUITY', 50, 500, 1),
        ('LOC_MPT_BALANCE_VICTORY_NAME_OVERWHELMING',  'AGE_ANTIQUITY', 60, 450, 1),
        ('LOC_MPT_BALANCE_VICTORY_NAME_COMMANDING',     'AGE_ANTIQUITY', 70, 400, 1),
        ('LOC_MPT_BALANCE_VICTORY_NAME_DOMINATING',     'AGE_ANTIQUITY', 80, 350, 1),
        ('LOC_VICTORY_NAME_2',                 'AGE_ANTIQUITY', 90, 300, 1),

        -- Full campaign: Modern Age.
        ('LOC_VICTORY_NAME_2',                 'AGE_ANTIQUITY',  0, 300, 2),
        ('LOC_MPT_BALANCE_VICTORY_NAME_RESOUNDING',     'AGE_ANTIQUITY', 10, 250, 2),
        ('LOC_VICTORY_NAME_3',                 'AGE_ANTIQUITY', 20, 200, 2),
        ('LOC_MPT_BALANCE_VICTORY_NAME_CONVINCING',     'AGE_ANTIQUITY', 30, 150, 2),
        ('LOC_VICTORY_NAME_4',                 'AGE_ANTIQUITY', 40, 100, 2),
        ('LOC_MPT_BALANCE_VICTORY_NAME_SOLID',          'AGE_ANTIQUITY', 50,  75, 2),
        ('LOC_VICTORY_NAME_5',                 'AGE_ANTIQUITY', 60,  50, 2),
        ('LOC_MPT_BALANCE_VICTORY_NAME_CLEAR',          'AGE_ANTIQUITY', 70,  40, 2),
        ('LOC_VICTORY_NAME_6',                 'AGE_ANTIQUITY', 80,  30, 2),
        ('LOC_MPT_BALANCE_VICTORY_NAME_SLIM',           'AGE_ANTIQUITY', 90,  20, 2),

        -- Exploration advanced start: Modern Age.
        ('LOC_VICTORY_NAME_2',                 'AGE_EXPLORATION',  0, 300, 1),
        ('LOC_MPT_BALANCE_VICTORY_NAME_RESOUNDING',     'AGE_EXPLORATION', 10, 250, 1),
        ('LOC_VICTORY_NAME_3',                 'AGE_EXPLORATION', 20, 200, 1),
        ('LOC_MPT_BALANCE_VICTORY_NAME_CONVINCING',     'AGE_EXPLORATION', 30, 150, 1),
        ('LOC_VICTORY_NAME_4',                 'AGE_EXPLORATION', 40, 100, 1),
        ('LOC_MPT_BALANCE_VICTORY_NAME_SOLID',          'AGE_EXPLORATION', 50,  75, 1),
        ('LOC_VICTORY_NAME_5',                 'AGE_EXPLORATION', 60,  50, 1),
        ('LOC_MPT_BALANCE_VICTORY_NAME_CLEAR',          'AGE_EXPLORATION', 70,  40, 1),
        ('LOC_VICTORY_NAME_6',                 'AGE_EXPLORATION', 80,  30, 1),
        ('LOC_MPT_BALANCE_VICTORY_NAME_SLIM',           'AGE_EXPLORATION', 90,  20, 1),

        -- Modern advanced start: preserve the base game's later activation.
        ('LOC_VICTORY_NAME_4',                 'AGE_MODERN', 40, 100, 0),
        ('LOC_MPT_BALANCE_VICTORY_NAME_SOLID',          'AGE_MODERN', 50,  75, 0),
        ('LOC_VICTORY_NAME_5',                 'AGE_MODERN', 60,  50, 0),
        ('LOC_MPT_BALANCE_VICTORY_NAME_CLEAR',          'AGE_MODERN', 70,  40, 0),
        ('LOC_VICTORY_NAME_6',                 'AGE_MODERN', 80,  30, 0),
        ('LOC_MPT_BALANCE_VICTORY_NAME_SLIM',           'AGE_MODERN', 90,  20, 0)
)
INSERT INTO VictoryDominationPercents
    (VictoryType, Name, StartingAge, MinAgeProgressPercent, DominationPercent, PreviousAgeCount)
SELECT
    VictoryClasses.VictoryType,
    ThresholdCurve.Name,
    ThresholdCurve.StartingAge,
    ThresholdCurve.MinAgeProgressPercent,
    ThresholdCurve.DominationPercent,
    ThresholdCurve.PreviousAgeCount
FROM VictoryClasses
CROSS JOIN ThresholdCurve;
