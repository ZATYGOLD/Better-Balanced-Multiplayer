-- General
UPDATE Units
SET BaseMoves = 3, CostProgressionParam1 = 100
WHERE UnitType = 'UNIT_EXPLORER';

UPDATE Unit_Stats
SET Range = 3
WHERE UnitType = 'UNIT_MORTAR';

-- Britain
UPDATE ModifierArguments
SET Value = 5
WHERE Name = 'Percent'
  AND ModifierId = 'REVENGE_MOD_SPLASH_ABILITY';

UPDATE Unit_Stats
SET Combat = 53, RangedCombat = 58, Bombard = 53
WHERE UnitType = 'UNIT_REVENGE';
UPDATE Unit_Stats
SET Combat = 58, RangedCombat = 63, Bombard = 58
WHERE UnitType = 'UNIT_REVENGE_2';

-- Ottomans
UPDATE ModifierArguments
SET Value = 3
WHERE Name = 'Amount'
  AND ModifierId = 'JANISSARY_MOD_COMBAT_STRENGTH_VS_LAND';

UPDATE Unit_Stats
SET Combat = 53, RangedCombat = 28, Bombard = 33
WHERE UnitType = 'UNIT_BARBARY_CORSAIR';
UPDATE Unit_Stats
SET Combat = 58, RangedCombat = 33, Bombard = 38
WHERE UnitType = 'UNIT_BARBARY_CORSAIR_2';
UPDATE Unit_Stats
SET Combat = 63, RangedCombat = 38, Bombard = 43
WHERE UnitType = 'UNIT_BARBARY_CORSAIR_3';

-- Qajar
UPDATE ModifierArguments
SET Value = 3
WHERE Name = 'Amount'
  AND ModifierId = 'GHILMAN_MOD_COMBAT';
