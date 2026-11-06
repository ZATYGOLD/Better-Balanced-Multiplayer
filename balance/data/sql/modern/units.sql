-- Genral
UPDATE Units
SET BaseMoves=3
WHERE UnitType="UNIT_EXPLORER";
UPDATE Units
SET CostProgressionParam1=100
WHERE UnitType="UNIT_EXPLORER";

UPDATE Unit_Stats
SET Range=3
WHERE UnitType="UNIT_MORTAR";

-- Britain
UPDATE ModifierArguments
SET value=5
WHERE name="Percent" AND ModifierId="REVENGE_MOD_SPLASH_ABILITY";

UPDATE Unit_Stats
SET Combat="53"
WHERE UnitType="UNIT_REVENGE";
UPDATE Unit_Stats
SET RangedCombat="58"
WHERE UnitType="UNIT_REVENGE";
UPDATE Unit_Stats
SET Bombard="53"
WHERE UnitType="UNIT_REVENGE";

UPDATE Unit_Stats
SET Combat="58"
WHERE UnitType="UNIT_REVENGE_2";
UPDATE Unit_Stats
SET RangedCombat="63"
WHERE UnitType="UNIT_REVENGE_2";
UPDATE Unit_Stats
SET Bombard="58"
WHERE UnitType="UNIT_REVENGE_2";

-- Ottomans
UPDATE ModifierArguments
SET value=3
WHERE name="Amount" AND ModifierId="JANISSARY_MOD_COMBAT_STRENGTH_VS_LAND";

UPDATE Unit_Stats
SET Combat="53"
WHERE UnitType="UNIT_BARBARY_CORSAIR";
UPDATE Unit_Stats
SET RangedCombat="28"
WHERE UnitType="UNIT_BARBARY_CORSAIR";
UPDATE Unit_Stats
SET Bombard="33"
WHERE UnitType="UNIT_BARBARY_CORSAIR";

UPDATE Unit_Stats
SET Combat="58"
WHERE UnitType="UNIT_BARBARY_CORSAIR_2";
UPDATE Unit_Stats
SET RangedCombat="33"
WHERE UnitType="UNIT_BARBARY_CORSAIR_2";
UPDATE Unit_Stats
SET Bombard="38"
WHERE UnitType="UNIT_BARBARY_CORSAIR_2";

UPDATE Unit_Stats
SET Combat="63"
WHERE UnitType="UNIT_BARBARY_CORSAIR_3";
UPDATE Unit_Stats
SET RangedCombat="38"
WHERE UnitType="UNIT_BARBARY_CORSAIR_3";
UPDATE Unit_Stats
SET Bombard="43"
WHERE UnitType="UNIT_BARBARY_CORSAIR_3";

-- Qajar
UPDATE ModifierArguments
SET Value=3
WHERE Name="Amount" AND ModifierId="GHILMAN_MOD_COMBAT";