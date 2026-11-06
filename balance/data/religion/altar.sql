-- Keep the Altar available and functional after Antiquity.
UPDATE Constructibles
SET Age = NULL,
    CostProgressionModel = 'NO_COST_PROGRESSION',
    CostProgressionParam1 = 0
WHERE ConstructibleType = 'BUILDING_ALTAR';

-- Warehouse buildings neither raise later building costs nor scale with the
-- number of buildings or Cities. The base Altar is treated as a standard
-- building in both systems, so remove that contribution as well.
DELETE FROM Constructible_BuildingCostProgressions
WHERE ConstructibleType = 'BUILDING_ALTAR';

DELETE FROM TypeTags
WHERE Type = 'BUILDING_ALTAR'
  AND Tag = 'ANTIQUITY_HAPPINESS';

INSERT OR IGNORE INTO TypeTags (Type, Tag)
SELECT 'BUILDING_ALTAR', 'HAPPINESS'
WHERE EXISTS (SELECT 1 FROM Types WHERE Type = 'BUILDING_ALTAR');

INSERT OR IGNORE INTO TypeTags (Type, Tag)
SELECT 'BUILDING_ALTAR', 'AGELESS'
WHERE EXISTS (SELECT 1 FROM Types WHERE Type = 'BUILDING_ALTAR');

INSERT OR IGNORE INTO TypeTags (Type, Tag)
SELECT 'BUILDING_ALTAR', 'WAREHOUSE'
WHERE EXISTS (SELECT 1 FROM Types WHERE Type = 'BUILDING_ALTAR');

-- The WAREHOUSE tag controls the Altar's reduced Specialist maintenance, but
-- warehouse buildings also carry explicit zero building-maintenance records.
-- Replace the Altar's base 2 Gold upkeep and add the matching Happiness record
-- so it uses the same maintenance setup as the Granary and other warehouses.
INSERT OR REPLACE INTO Constructible_Maintenances
	(ConstructibleType, YieldType, Amount)
VALUES
	('BUILDING_ALTAR', 'YIELD_GOLD', 0),
	('BUILDING_ALTAR', 'YIELD_HAPPINESS', 0);
