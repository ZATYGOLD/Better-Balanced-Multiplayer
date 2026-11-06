-- general
UPDATE Unit_Stats
SET Range=3
WHERE UnitType="UNIT_TREBUCHET";
UPDATE Unit_Stats
SET Range=3
WHERE UnitType="UNIT_BOMBARD";

-- Chola
UPDATE Unit_Stats SET Combat=25 WHERE UnitType="UNIT_KALAM";
UPDATE Unit_Stats SET Combat=30 WHERE UnitType="UNIT_KALAM_2";
UPDATE Unit_Stats SET Combat=35 WHERE UnitType="UNIT_KALAM_3";
UPDATE Unit_Stats
SET Bombard="25"
WHERE UnitType="UNIT_KALAM";
UPDATE Unit_Stats
SET RangedCombat="30"
WHERE UnitType="UNIT_KALAM";

UPDATE Unit_Stats
SET Bombard="30"
WHERE UnitType="UNIT_KALAM_2";
UPDATE Unit_Stats
SET RangedCombat="35"
WHERE UnitType="UNIT_KALAM_2";

UPDATE Unit_Stats
SET Bombard="35"
WHERE UnitType="UNIT_KALAM_3";
UPDATE Unit_Stats
SET RangedCombat="40"
WHERE UnitType="UNIT_KALAM_3";

-- Ming
UPDATE ModifierArguments
SET Value=0
WHERE Name="Amount" AND ModifierId="XUNLEICHONG_MOD_COMBAT_NO_FEATURE_COMBAT_STRENGTH";
--UPDATE ModifierArguments
--SET Value=1
--WHERE Name="Amount" AND ModifierId="XUNLEICHONG_MOD_RANGED";
UPDATE Unit_Stats
SET Range=2, RangedCombat=17
WHERE UnitType="UNIT_XUNLEICHONG";
UPDATE Unit_Stats
SET Range=2, RangedCombat=22
WHERE UnitType="UNIT_XUNLEICHONG_2";
UPDATE Unit_Stats
SET Range=2, RangedCombat=27
WHERE UnitType="UNIT_XUNLEICHONG_3";


-- Sengoku
UPDATE Units
SET BaseMoves="2"
WHERE UnitType="UNIT_NINJA";

