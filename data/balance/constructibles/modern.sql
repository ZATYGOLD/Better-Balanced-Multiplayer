-- Tier 1 Buildings
UPDATE Constructibles
SET Cost = 320
WHERE ConstructibleType IN (
    'BUILDING_CANNERY',
    'BUILDING_CITY_PARK',
    'BUILDING_MILITARY_ACADEMY',
    'BUILDING_MUSEUM',
    'BUILDING_PORT',
    'BUILDING_SCHOOLHOUSE'
);

-- Tier 2 Buildings, Aerodrome and Rail Station
UPDATE Constructibles
SET Cost = 520
WHERE ConstructibleType IN (
    'BUILDING_DEPARTMENT_STORE',
    'BUILDING_FACTORY',
    'BUILDING_LABORATORY',
    'BUILDING_OPERA_HOUSE',
    'BUILDING_RADIO_STATION',
    'BUILDING_STOCK_EXCHANGE',
    'BUILDING_TENEMENT',
    'BUILDING_AIRFIELD',
    'BUILDING_RAIL_STATION'
);

-- Warehouse Buildings
UPDATE Constructibles
SET Cost = 300
WHERE ConstructibleType IN (
    'BUILDING_GROCER',
    'BUILDING_IRONWORKS',
    'BUILDING_MODERN_BRIDGE'
);

-- Aerodromes can be built in Towns.
UPDATE Buildings
SET Town = 1
WHERE ConstructibleType = 'BUILDING_AIRFIELD';

-- Civilization and City-State Unique Improvements
UPDATE Constructibles
SET Cost = 150
WHERE ConstructibleType IN (
    'IMPROVEMENT_BANG',
    'IMPROVEMENT_KABAKAS_LAKE',
    'IMPROVEMENT_OBSHCHINA',
    'IMPROVEMENT_STEPWELL',
    'IMPROVEMENT_SHORE_BATTERY',
    'IMPROVEMENT_OPEN_AIR_MUSEUM',
    'IMPROVEMENT_ENTREPOT',
    'IMPROVEMENT_INSTITUTE',
    'IMPROVEMENT_ABATTOIR',
    'IMPROVEMENT_CIRCUS_FAIR'
);

-- Unique Buildings
UPDATE Constructibles
SET Cost = 450
WHERE ConstructibleType IN (
    'BUILDING_RAILYARD',
    'BUILDING_STEEL_MILL',
    'BUILDING_GINKO',
    'BUILDING_JUKOGYO',
    'BUILDING_FORMAL_GARDEN',
    'BUILDING_SALON',
    'BUILDING_CATEDRAL',
    'BUILDING_PORTAL_DE_MERCADERES',
    'BUILDING_EXAMINATION_HALL',
    'BUILDING_MONEY_SHOP',
    'BUILDING_ROYAL_EXCHANGE',
    'BUILDING_MANUFACTORY',
    'BUILDING_CAMII',
    'BUILDING_HAMMAM',
    'BUILDING_GHAHVE_KHANE',
    'BUILDING_TAKYEH',
    'BUILDING_CONFUCIAN_ACADEMY',
    'BUILDING_PRINTING_HOUSE'
);

-- Food Towns: +2 Food on every Farming and Fishing Town tile (base +1).
UPDATE Warehouse_YieldChanges
SET YieldChange = 2
WHERE ID IN (
    'MOTownFishingBoatResourceFood',
    'MOTownAtollFeatureFood',
    'MOTownLotusFeatureFood',
    'MOTownReefFeatureFood',
    'MOTownColdReefFeatureFood',
    'MOTownCoastTerrainFood',
    'MOTownNavigableRiverFood',
    'MOTownPastureFood',
    'MOTownPlantationFood',
    'MOTownDesertFloodplainFeatureFood',
    'MOTownGrasslandFloodplainFeatureFood',
    'MOTownPlainsFloodplainFeatureFood',
    'MOTownTropicalFloodplainFeatureFood',
    'MOTownTundraFloodplainFeatureFood',
    'MOTownFlatTerrainFood'
);

-- Food Towns: Ocean tiles count for both Farming and Fishing Town bonuses.
INSERT OR IGNORE INTO Warehouse_YieldChanges (ID, Age, YieldType, YieldChange, TerrainInCity)
    VALUES ('MPTBalanceMOTownOceanTerrainFood', 'AGE_MODERN', 'YIELD_FOOD', 2, 'TERRAIN_OCEAN');

UPDATE ModifierArguments
SET Value = Value || ', MPTBalanceMOTownOceanTerrainFood'
WHERE Name = 'WarehouseYieldChange'
  AND ModifierId IN ('ATTACH_GRANARY_WAREHOUSE_FOOD_FROM_PROJECT', 'ATTACH_FISHING_WAREHOUSE_FOOD_FROM_PROJECT');

-- Wonders
UPDATE Constructibles
SET Cost = 1100
WHERE ConstructibleType IN (
    'WONDER_MUZIBU_AZAALA_MPANGA',
    'WONDER_DOI_SUTHEP',
    'WONDER_BOUDHANATH',
    'WONDER_TAJ_MAHAL',
    'WONDER_PALACIO_DE_BELLAS_ARTES'
);
UPDATE Constructibles
SET Cost = 1200
WHERE ConstructibleType IN (
    'WONDER_ERAM_GARDEN',
    'WONDER_STATUE_OF_LIBERTY',
    'WONDER_RED_FORT',
    'WONDER_NIRAYAMA_REVERBERATORY_FURNACE'
);
UPDATE Constructibles
SET Cost = 1300
WHERE ConstructibleType IN (
    'WONDER_HERMITAGE'
);
UPDATE Constructibles
SET Cost = 1400
WHERE ConstructibleType IN (
    'WONDER_BRANDENBURG_GATE',
    'WONDER_EIFFEL_TOWER',
    'WONDER_MANHATTAN_PROJECT'
);

-- Doi Suthep
UPDATE ModifierArguments
SET Value = 10
WHERE Name = 'Amount'
  AND ModifierId IN ('MOD_DOI_SUTHEP_SUZERAIN_CULTURE', 'MOD_DOI_SUTHEP_SUZERAIN_GOLD');

-- Boudhanath
UPDATE ModifierArguments
SET Value = 50
WHERE Name = 'FavorsAmount'
  AND ModifierId = 'MOD_BOUDHANATH_INCREASED_RELATIONSHIP';
