-- Amina
UPDATE ModifierArguments
SET Value=3
WHERE Name='Amount' AND ModifierId='AMINA_MOD_ADJUST_UNIT_COMBAT_STRENGTH_MODIFIER';

UPDATE ModifierArguments
SET Value=2
WHERE Name='Amount' AND ModifierId='AMINA_MOD_RESOURCE_GOLD';

-- Catherine
UPDATE ModifierArguments
SET Value=4
WHERE Name='Amount' AND ModifierId='CATHERINE_MOD_GREAT_WORK_CULTURE';

-- Friedrich, Baroque
UPDATE ModifierArguments
SET Value=3
WHERE Name='Amount' AND ModifierId='FRIEDRICH_ALT_MOD_GREAT_WORK_CULTURE';
UPDATE ModifierArguments
SET Value='YIELD_PRODUCTION'
WHERE Name='YieldType' AND ModifierId='FRIEDRICH_ALT_MOD_GREAT_WORK_CULTURE';

-- Genghis Khan: flat +3 for Cavalry inside and outside a Command Radius.
UPDATE ModifierArguments
SET Value=3
WHERE Name='Amount' AND ModifierId='GENGHIS_KHAN_COMMAND_RADIUS_COMBAT';

-- Himiko, High Shaman
UPDATE ModifierArguments
SET Value=-5
WHERE Name='Percent' AND ModifierId='HIMIKO_ALT_MOD_SCIENCE_PENALTY';
UPDATE ModifierArguments
SET Value=-5
WHERE Name='Percent' AND ModifierId='HIMIKO_ALT_MOD_SCIENCE_PENALTY_CELEBRATION';

-- Jose Rizal
UPDATE ModifierArguments
SET Value=40
WHERE Name='Amount' AND ModifierId='RIZAL_MOD_NARRATIVE_EVENT_CULTURE';
UPDATE ModifierArguments
SET Value=40
WHERE Name='Amount' AND ModifierId='RIZAL_MOD_NARRATIVE_EVENT_GOLD';
UPDATE ModifierArguments
SET Value=40
WHERE Name='Amount' AND ModifierId='RIZAL_MOD_NARRATIVE_EVENT_INFLUENCE';

-- Toyotomi Hideyoshi
UPDATE ModifierArguments
SET Value=50
WHERE Name='Percent' AND ModifierId='TOYOTOMI_HIDEYOSHI_MOD_ORIGINAL_CULTURE_BUILDING_PRODUCTION_TOWARDS';
