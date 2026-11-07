-- City-State Unique Improvement balance changes.

-- Keep City-State Unique Improvement unlocks (and the bonus modifiers that
-- reference those improvements) after they have been earned.
UPDATE Modifiers
SET Permanent = 1
WHERE ModifierId IN (
    SELECT DISTINCT ma.ModifierId
    FROM ModifierArguments ma
    JOIN TypeTags tt
      ON tt.Type = ma.Value
     AND tt.Tag = 'CITY_STATE_UNIQUE_IMPROVEMENT'
    WHERE ma.Name = 'ConstructibleType'
);

-- These unlocks are permanent, so make the improvements themselves Ageless.
-- Otherwise the rollover system preserves their base yield but treats their
-- adjacency and constructible modifiers as effects from an obsolete Age.
UPDATE Constructibles
SET Age = NULL
WHERE ConstructibleType IN (
    SELECT Type
    FROM TypeTags
    WHERE Tag = 'CITY_STATE_UNIQUE_IMPROVEMENT'
);

-- City-State improvements remain usable in later Ages, so their intrinsic
-- adjacency bonuses must not expire with the Age in which they originated
-- (only where the later Age still defines the adjacency row).
UPDATE Adjacency_YieldChanges
SET Age = NULL
WHERE ID IN (
    SELECT ca.YieldChangeId
    FROM Constructible_Adjacencies ca
    JOIN TypeTags tt
      ON tt.Type = ca.ConstructibleType
     AND tt.Tag = 'CITY_STATE_UNIQUE_IMPROVEMENT'
);

-- Antiquity: Megalith, Step Pyramid, Age of Heroes, and Yakhchal.
UPDATE Adjacency_YieldChanges
SET AdjacentDistrict = NULL,
    AdjacentConstructible = 'IMPROVEMENT_MEGALITH'
WHERE ID = 'MegalithCulture';

UPDATE Adjacency_YieldChanges
SET AdjacentRiver = 0,
    AdjacentTerrain = 'TERRAIN_NAVIGABLE_RIVER'
WHERE ID = 'ZigguratScience';

UPDATE ModifierArguments
SET Value = 20
WHERE ModifierId = 'ATTACH_COMMANDER_XP_PRODUCTION'
  AND Name = 'Percent';

DELETE FROM Constructible_ValidBiomes
WHERE ConstructibleType = 'IMPROVEMENT_ICE_HOUSE';

INSERT OR IGNORE INTO Constructible_ValidBiomes (ConstructibleType, BiomeType)
SELECT 'IMPROVEMENT_ICE_HOUSE', 'BIOME_PLAINS'
WHERE EXISTS (SELECT 1 FROM Constructibles WHERE ConstructibleType = 'IMPROVEMENT_ICE_HOUSE');

INSERT OR IGNORE INTO Constructible_ValidBiomes (ConstructibleType, BiomeType)
SELECT 'IMPROVEMENT_ICE_HOUSE', 'BIOME_TROPICAL'
WHERE EXISTS (SELECT 1 FROM Constructibles WHERE ConstructibleType = 'IMPROVEMENT_ICE_HOUSE');

DELETE FROM ConstructibleModifiers
WHERE ConstructibleType = 'IMPROVEMENT_ICE_HOUSE'
  AND ModifierId = 'MOD_ICE_HOUSE_FOOD';

INSERT OR IGNORE INTO ConstructibleModifiers (ConstructibleType, ModifierId)
SELECT 'IMPROVEMENT_ICE_HOUSE', 'MPT_BALANCE_MOD_ICE_HOUSE_GROWTH'
WHERE EXISTS (SELECT 1 FROM Constructibles WHERE ConstructibleType = 'IMPROVEMENT_ICE_HOUSE');

-- Exploration: Stone Head, Monastery, Kasbah, and Saqiya.
UPDATE Constructible_YieldChanges
SET YieldChange = 2
WHERE ConstructibleType = 'IMPROVEMENT_STONE_HEAD'
  AND YieldType = 'YIELD_CULTURE';

UPDATE Constructible_YieldChanges
SET YieldChange = 3
WHERE ConstructibleType = 'IMPROVEMENT_MONASTERY'
  AND YieldType = 'YIELD_SCIENCE';

UPDATE ModifierArguments
SET Value = 2
WHERE ModifierId = 'MOD_MONASTERY_YIELD'
  AND Name = 'Amount';

DELETE FROM Constructible_ValidBiomes
WHERE ConstructibleType = 'IMPROVEMENT_KASBAH';

UPDATE Improvements
SET SameAdjacentValid = 0
WHERE ConstructibleType = 'IMPROVEMENT_KASBAH';

DELETE FROM Constructible_RequiredFeatureClasses
WHERE ConstructibleType = 'IMPROVEMENT_SAQIYA';

UPDATE Constructibles
SET AdjacentRiver = 1
WHERE ConstructibleType = 'IMPROVEMENT_SAQIYA';

-- Modern: Open-Air Museum and Abattoir.
INSERT OR IGNORE INTO Adjacency_YieldChanges (ID, Age, YieldType, YieldChange, TilesRequired, AdjacentBiome)
SELECT 'MPT_BALANCE_OpenAirMuseumGrasslandProduction', 'AGE_MODERN', 'YIELD_PRODUCTION', 1, 1, 'BIOME_GRASSLAND'
WHERE EXISTS (SELECT 1 FROM Constructibles WHERE ConstructibleType = 'IMPROVEMENT_OPEN_AIR_MUSEUM');

INSERT OR IGNORE INTO Adjacency_YieldChanges (ID, Age, YieldType, YieldChange, TilesRequired, AdjacentBiome)
SELECT 'MPT_BALANCE_OpenAirMuseumPlainsProduction', 'AGE_MODERN', 'YIELD_PRODUCTION', 1, 1, 'BIOME_PLAINS'
WHERE EXISTS (SELECT 1 FROM Constructibles WHERE ConstructibleType = 'IMPROVEMENT_OPEN_AIR_MUSEUM');

INSERT OR IGNORE INTO Constructible_Adjacencies (ConstructibleType, YieldChangeId)
SELECT 'IMPROVEMENT_OPEN_AIR_MUSEUM', 'MPT_BALANCE_OpenAirMuseumGrasslandProduction'
WHERE EXISTS (SELECT 1 FROM Constructibles WHERE ConstructibleType = 'IMPROVEMENT_OPEN_AIR_MUSEUM');

INSERT OR IGNORE INTO Constructible_Adjacencies (ConstructibleType, YieldChangeId)
SELECT 'IMPROVEMENT_OPEN_AIR_MUSEUM', 'MPT_BALANCE_OpenAirMuseumPlainsProduction'
WHERE EXISTS (SELECT 1 FROM Constructibles WHERE ConstructibleType = 'IMPROVEMENT_OPEN_AIR_MUSEUM');

DELETE FROM ConstructibleModifiers
WHERE ConstructibleType = 'IMPROVEMENT_ABATTOIR'
  AND ModifierId IN ('MOD_ABATTOIR_FOOD', 'MOD_ABATTOIR_UNHAPPINESS');

INSERT OR IGNORE INTO ConstructibleModifiers (ConstructibleType, ModifierId)
SELECT 'IMPROVEMENT_ABATTOIR', 'MPT_BALANCE_MOD_ABATTOIR_PRODUCTION'
WHERE EXISTS (SELECT 1 FROM Constructibles WHERE ConstructibleType = 'IMPROVEMENT_ABATTOIR');
