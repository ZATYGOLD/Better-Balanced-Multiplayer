-- Fleet Commanders
UPDATE Units
SET TraitType = NULL
WHERE UnitType = 'UNIT_FLEET_COMMANDER';

-- Egypt
UPDATE ModifierArguments
SET value=2
WHERE name='Amount' AND ModifierId='MEDJAY_MOD_COMBAT_FRIENDLY_TERRITORY';
UPDATE ModifierArguments
SET value=2
WHERE name='Amount' AND ModifierId='MEDJAY_MOD_COMBAT_URBAN_PLOT';

-- Heian
UPDATE Units
SET BaseMoves='3'
WHERE UnitType='UNIT_DANTINAS_TATHA';
UPDATE Units
SET BaseMoves='3'
WHERE UnitType='UNIT_DANTINAS_TATHA_2';

-- Khmer
UPDATE Unit_Stats
SET Combat='33'
WHERE UnitType='UNIT_DANTINAS_TATHA';
UPDATE Unit_Stats
SET Combat='38'
WHERE UnitType='UNIT_DANTINAS_TATHA_2';