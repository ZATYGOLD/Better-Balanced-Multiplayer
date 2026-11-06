-- Fremch
UPDATE ModifierArguments
SET Value="25"
WHERE Name="PercentCost" AND ModifierId="STYLE_EMPIRE_I_MOD_CULTURE_ON_BUILDING_CREATED" AND type="ScaleByGameSpeed";

UPDATE ModifierArguments
SET Value="50"
WHERE Name="PercentCost" AND ModifierId="STYLE_EMPIRE_MOD_CULTURE_ON_BUILDING_CREATED" AND type="ScaleByGameSpeed";

UPDATE ModifierArguments
SET Value="25"
WHERE Name="PercentDefeatedStrength" AND ModifierId="COCORICO_MOD_I_CULTURE_ON_UNIT_DEFEAT";

UPDATE ModifierArguments
SET Value="50"
WHERE Name="PercentDefeatedStrength" AND ModifierId="COCORICO_MOD_CULTURE_ON_UNIT_DEFEAT";

-- Joseon
UPDATE ModifierArguments
SET Value="25"
WHERE Name="Percent" AND ModifierId="MOD_SEOWON_YIELD_CONVERSION";

UPDATE Buildings
SET CapitalForbidden=0
WHERE ConstructibleType IN ('BUILDING_CONFUCIAN_ACADEMY', 'BUILDING_PRINTING_HOUSE');

-- Qajar
-- UPDATE ModifierArguments
-- SET Value="1"
-- WHERE Name="Amount" AND ModifierId="MOD_CIV_QAJAR_YIELDS_UNDER_SETTLEMENT_CAP_AQ";
-- UPDATE ModifierArguments
-- SET Value="2"
-- WHERE Name="Amount" AND ModifierId="MOD_CIV_QAJAR_YIELDS_UNDER_SETTLEMENT_CAP_EX";
-- UPDATE ModifierArguments
-- SET Value="3"
-- WHERE Name="Amount" AND ModifierId="MOD_CIV_QAJAR_YIELDS_UNDER_SETTLEMENT_CAP_MO";

-- Mughal
UPDATE ModifierArguments
SET Value="75"
WHERE Name="Percent" AND ModifierId="TRAIT_MOD_PARADISE_OF_NATIONS_GOLD";

-- policy cards
UPDATE ModifierArguments
SET Value="10"
WHERE Name="Amount" AND ModifierId="AVANT_GARDE_MOD_CULTURE_PER_GREAT_WORK";

UPDATE ModifierArguments
SET Value="15"
WHERE Name="Amount" AND ModifierId="MOD_AMBASSADORS_DIPLOMACY";

UPDATE ModifierArguments
SET Value="10"
WHERE Name="Amount" AND ModifierId="PRESERVATION_SOCIETIES_MOD_SCIENCE_PER_EPIC_GREAT_WORK";

UPDATE ModifierArguments
SET Value="15"
WHERE Name="Amount" AND ModifierId="CULTURAL_IMPERIALISM_MOD_SUZERAINS_CULTURE";
UPDATE ModifierArguments
SET Value="15"
WHERE Name="Amount" AND ModifierId="CULTURAL_IMPERIALISM_MOD_SUZERAINS_GOLD";
