-- General
UPDATE Unit_Stats
SET Range = 3
WHERE UnitType IN ('UNIT_TREBUCHET', 'UNIT_BOMBARD');

-- Defender of the Faith
UPDATE ModifierArguments
SET Value = 3
WHERE Name = 'Amount'
  AND ModifierId = 'ATTACH_COMBAT_STRENGTH_FRIENDLY_RELIGIOUS_CITY';

-- Chola
UPDATE Unit_Stats
SET Combat = 25, RangedCombat = 30, Bombard = 25
WHERE UnitType = 'UNIT_KALAM';
UPDATE Unit_Stats
SET Combat = 30, RangedCombat = 35, Bombard = 30
WHERE UnitType = 'UNIT_KALAM_2';
UPDATE Unit_Stats
SET Combat = 35, RangedCombat = 40, Bombard = 35
WHERE UnitType = 'UNIT_KALAM_3';

-- Ming
UPDATE ModifierArguments
SET Value = 0
WHERE Name = 'Amount'
  AND ModifierId = 'XUNLEICHONG_MOD_COMBAT_NO_FEATURE_COMBAT_STRENGTH';
UPDATE Unit_Stats
SET Range = 2, RangedCombat = CASE UnitType
    WHEN 'UNIT_XUNLEICHONG' THEN 17
    WHEN 'UNIT_XUNLEICHONG_2' THEN 22
    WHEN 'UNIT_XUNLEICHONG_3' THEN 27
END
WHERE UnitType IN ('UNIT_XUNLEICHONG', 'UNIT_XUNLEICHONG_2', 'UNIT_XUNLEICHONG_3');

-- Sengoku
UPDATE Units
SET BaseMoves = 2
WHERE UnitType = 'UNIT_NINJA';
