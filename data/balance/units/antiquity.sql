-- Fleet Commanders
UPDATE Units
SET TraitType = NULL
WHERE UnitType = 'UNIT_FLEET_COMMANDER';

-- Egypt
UPDATE ModifierArguments
SET Value = 2
WHERE Name = 'Amount'
  AND ModifierId IN ('MEDJAY_MOD_COMBAT_FRIENDLY_TERRITORY', 'MEDJAY_MOD_COMBAT_URBAN_PLOT');

-- Khmer: normal Cavalry Movement, +3 Combat Strength over the replaced Unit.
UPDATE Units
SET BaseMoves = 3
WHERE UnitType IN ('UNIT_DANTINAS_TATHA', 'UNIT_DANTINAS_TATHA_2');
UPDATE Unit_Stats
SET Combat = CASE UnitType
    WHEN 'UNIT_DANTINAS_TATHA' THEN 33
    WHEN 'UNIT_DANTINAS_TATHA_2' THEN 38
END
WHERE UnitType IN ('UNIT_DANTINAS_TATHA', 'UNIT_DANTINAS_TATHA_2');

-- Silla: Hwarang match the Production cost of the standard Ranged Unit at each tier.
UPDATE Unit_Costs
SET Cost = CASE UnitType
    WHEN 'UNIT_HWARANG' THEN 30
    WHEN 'UNIT_HWARANG_2' THEN 50
END
WHERE YieldType = 'YIELD_PRODUCTION'
  AND UnitType IN ('UNIT_HWARANG', 'UNIT_HWARANG_2');
