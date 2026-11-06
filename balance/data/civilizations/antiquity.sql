-- Aksum
UPDATE ModifierArguments
SET value=2
WHERE name='Amount' AND ModifierId='AKSUM_SYNCRETISM_EXPLORATION_TRADE_ROUTE_PRODUCTION';
UPDATE ModifierArguments
SET value=3
WHERE name='Amount' AND ModifierId='AKSUM_SYNCRETISM_MODERN_TRADE_ROUTE_PRODUCTION';

-- Assyria
UPDATE ModifierArguments
SET value=3
WHERE name='Amount' AND ModifierId='GIRRU_MOD_COMBAT';

-- Babylon
-- Remove its Settlement Limit penalty in every Age.
DELETE FROM TraitModifiers
WHERE TraitType='TRAIT_BABYLON_ABILITY' AND ModifierId='TRAIT_LESS_SETTLEMENT_CAP';

-- Egypt
-- Gifts of Osiris: +1 Production per Age on river tiles (1/2/3).
UPDATE ModifierArguments
SET Value=1, Type='ScaleByGameAge', Extra=100
WHERE Name='Amount' AND ModifierId='TRAIT_MOD_GIFTS_OF_OSIRIS_NAVIGABLE_RIVER';

-- Gifts of Osiris: Wonders provide +2 Tourism in Modern.
UPDATE VictoryScorings
SET Points=2
WHERE ScoringId='VICTORY_TRACKER_WONDERS_EGYPT_TRADITION';

UPDATE ModifierArguments
SET value=1
WHERE name='Amount' AND ModifierId='KEMET_I_MOD_NAVIGABLE_RIVER_CULTURE';
UPDATE ModifierArguments
SET value=2
WHERE name='Amount' AND ModifierId='KEMET_II_MOD_NAVIGABLE_RIVER_CULTURE';

UPDATE ModifierArguments
SET value=1
WHERE name='Amount' AND ModifierId='AKHET_I_MOD_NAVIGABLE_RIVER_FOOD';
UPDATE ModifierArguments
SET value=2
WHERE name='Amount' AND ModifierId='AKHET_II_MOD_NAVIGABLE_RIVER_FOOD';

-- Greece
UPDATE ModifierArguments
SET value=3
WHERE name='Amount' AND ModifierId='MOD_GREECE_ACROPOLIS_PARTHENON_GOLD_PER_SUZERAIN';

UPDATE ModifierArguments
SET value=2
WHERE name='Amount' AND ModifierId='HAN_SYNCRETISM_EXPLORATION_MOD_SCIENCE_PER_TRADITION';
UPDATE ModifierArguments
SET value=3
WHERE name='Amount' AND ModifierId='HAN_SYNCRETISM_MODERN_MOD_SCIENCE_PER_TRADITION';

-- Persia
-- In the current game data, the Infantry maintenance effects are attached
-- to Kara I/II (rather than Shahanshah I/II).
DELETE FROM TraditionModifiers
WHERE TraditionType='TRADITION_KARA' AND ModifierId='KARA_MOD_CLASS_INFANTRY_MAINTENANCE';

UPDATE ModifierArguments
SET Value=2
WHERE Name='Amount' AND ModifierId='KARA_II_MOD_CLASS_INFANTRY_MAINTENANCE';

-- Heian
UPDATE Adjacency_YieldChanges
SET YieldChange='1'
WHERE ID='JinjaAppealCharmingCulture';

-- Maurya
UPDATE ModifierArguments
SET Value=25
WHERE Name='Percent' AND ModifierId='MOD_MAURYA_MATHA_HAPPINESS';

-- Khmer
UPDATE ModifierArguments
SET value='YIELD_GOLD, YIELD_SCIENCE'
WHERE name='YieldType' AND ModifierId='KHMER_SYNCRETISM_WORKER_GOLD';
UPDATE ModifierArguments
SET value='YIELD_GOLD, YIELD_SCIENCE'
WHERE name='YieldType' AND ModifierId='KHMER_SYNCRETISM_WORKER_SCIENCE';

-- Sila
UPDATE ModifierArguments
SET value='50'
WHERE name='SelfPercent' AND ModifierId='STRATEGIC_ALLIES_MOD_ALLIANCE_ROUTE_YIELDS';
UPDATE ModifierArguments
SET value='YIELD_GOLD'
WHERE name='YieldTypeOther' AND ModifierId='STRATEGIC_ALLIES_MOD_ALLIANCE_ROUTE_YIELDS';

UPDATE ModifierArguments
SET value='25'
WHERE name='SelfPercent' AND ModifierId='THE_GOLDEN_ROAD_MOD_ALLIANCE_ROUTE_YIELDS';
UPDATE ModifierArguments
SET value='YIELD_GOLD'
WHERE name='YieldTypeOther' AND ModifierId='THE_GOLDEN_ROAD_MOD_ALLIANCE_ROUTE_YIELDS';

UPDATE ModifierArguments
SET value='50'
WHERE name='SelfPercent' AND ModifierId='THE_GOLDEN_ROAD_II_MOD_ALLIANCE_ROUTE_YIELDS';
UPDATE ModifierArguments
SET value='YIELD_GOLD'
WHERE name='YieldTypeOther' AND ModifierId='THE_GOLDEN_ROAD_II_MOD_ALLIANCE_ROUTE_YIELDS';
