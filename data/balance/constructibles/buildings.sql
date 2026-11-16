-- Shared building changes, loaded after the Age file (the cost-progression rule
-- below reads the final Costs).

-- Non-Warehouse Buildings: reduce the empire-wide cost increase from each
-- additional City beyond the Capital from 10% to 5%.
INSERT OR REPLACE INTO GlobalParameters (Name, Value)
    VALUES ('BUILDING_COST_INCREASE_PERCENT_PER_CITY', '5');

-- The modifier can then target all Buildings without also affecting Improvements.
INSERT OR IGNORE INTO Tags (Tag, Category)
    VALUES ('BBM_BALANCE_BUILDING', 'CONSTRUCTIBLE_TAG');

INSERT OR IGNORE INTO TypeTags (Type, Tag)
SELECT ConstructibleType, 'BBM_BALANCE_BUILDING'
FROM Constructibles
WHERE ConstructibleClass='BUILDING';

-- Exploration
-- Tier 2
UPDATE Constructibles
SET Cost='340'
WHERE ConstructibleType='BUILDING_ARMORER';
UPDATE Constructibles
SET Cost='340'
WHERE ConstructibleType='BUILDING_BANK';
UPDATE Constructibles
SET Cost='340'
WHERE ConstructibleType='BUILDING_HOSPITAL';
UPDATE Constructibles
SET Cost='340'
WHERE ConstructibleType='BUILDING_MENAGERIE';
UPDATE Constructibles
SET Cost='340'
WHERE ConstructibleType='BUILDING_PAVILION';
UPDATE Constructibles
SET Cost='340'
WHERE ConstructibleType='BUILDING_UNIVERSITY';
UPDATE Constructibles
SET Cost='340'
WHERE ConstructibleType='BUILDING_SHIPYARD';

-- Unique Improvements increase in Production cost by 25% of their base cost
-- for each previous copy in the City, matching the Han and Ming Great Walls.
UPDATE Constructibles
SET CostProgressionParam1 = CAST((Cost * 0.25) + 0.5 AS INTEGER)
WHERE ConstructibleClass = 'IMPROVEMENT'
    AND CostProgressionModel = 'COST_PROGRESSION_PREVIOUS_COPIES_CITY'
    AND ConstructibleType NOT IN (
    'IMPROVEMENT_HAN_GREAT_WALL',
    'IMPROVEMENT_MING_GREAT_WALL'
    )
    AND ConstructibleType IN (
    SELECT Type
    FROM TypeTags
    WHERE Tag = 'UNIQUE_IMPROVEMENT'
    );
