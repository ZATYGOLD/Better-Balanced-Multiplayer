-- Non-Warehouse Buildings: reduce the empire-wide cost increase from each
-- additional City beyond the Capital from 10% to 5%.
INSERT OR REPLACE INTO GlobalParameters (Name, Value)
VALUES ('BUILDING_COST_INCREASE_PERCENT_PER_CITY', '5');

-- The modifier can then target all Buildings without also affecting Improvements.
INSERT OR IGNORE INTO Tags (Tag, Category)
VALUES ("MBM_BUILDING", "CONSTRUCTIBLE_TAG");

INSERT OR IGNORE INTO TypeTags (Type, Tag)
SELECT ConstructibleType, "MBM_BUILDING"
FROM Constructibles
WHERE ConstructibleClass="BUILDING";

-- Town Specializations
-- Food Towns
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownFishingBoatResourceFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownAtollFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownLotusFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownReefFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownColdReefFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownCoastTerrainFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownNavigableRiverFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownPastureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownPlantationFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownDesertFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownGrasslandFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownPlainsFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownTropicalFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownTundraFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="AQTownFlatTerrainFood";

-- Exploration
-- Tier 2
UPDATE Constructibles
SET Cost="340"
WHERE ConstructibleType="BUILDING_ARMORER";
UPDATE Constructibles
SET Cost="340"
WHERE ConstructibleType="BUILDING_BANK";
UPDATE Constructibles
SET Cost="340"
WHERE ConstructibleType="BUILDING_HOSPITAL";
UPDATE Constructibles
SET Cost="340"
WHERE ConstructibleType="BUILDING_MENAGERIE";
UPDATE Constructibles
SET Cost="340"
WHERE ConstructibleType="BUILDING_PAVILION";
UPDATE Constructibles
SET Cost="340"
WHERE ConstructibleType="BUILDING_UNIVERSITY";
UPDATE Constructibles
SET Cost="340"
WHERE ConstructibleType="BUILDING_SHIPYARD";
-- Town Specializations
-- Food Towns
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownFishingBoatResourceFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownAtollFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownLotusFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownReefFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownColdReefFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownCoastTerrainFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownNavigableRiverFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownPastureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownPlantationFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownDesertFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownGrasslandFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownPlainsFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownTropicalFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownTundraFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="EXTownFlatTerrainFood";

-- Modern
-- Tier 1
UPDATE Constructibles
SET Cost="320"
WHERE ConstructibleType="BUILDING_CANNERY";
UPDATE Constructibles
SET Cost="320"
WHERE ConstructibleType="BUILDING_CITY_PARK";
UPDATE Constructibles
SET Cost="320"
WHERE ConstructibleType="BUILDING_MILITARY_ACADEMY";
UPDATE Constructibles
SET Cost="320"
WHERE ConstructibleType="BUILDING_MUSEUM";
UPDATE Constructibles
SET Cost="320"
WHERE ConstructibleType="BUILDING_PORT";
UPDATE Constructibles
SET Cost="320"
WHERE ConstructibleType="BUILDING_SCHOOLHOUSE";
-- Tier 2
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_DEPARTMENT_STORE";
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_FACTORY";
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_LABORATORY";
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_OPERA_HOUSE";
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_RADIO_STATION";
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_STOCK_EXCHANGE";
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_TENEMENT";
-- Wearhouse
UPDATE Constructibles
SET Cost="300"
WHERE ConstructibleType="BUILDING_GROCER";
UPDATE Constructibles
SET Cost="300"
WHERE ConstructibleType="BUILDING_IRONWORKS";
UPDATE Constructibles
SET Cost="300"
WHERE ConstructibleType="BUILDING_MODERN_BRIDGE";
-- Aerodome and Rail station
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_AIRFIELD";
UPDATE Buildings
SET Town="true"
WHERE ConstructibleType="BUILDING_AIRFIELD";
UPDATE Constructibles
SET Cost="520"
WHERE ConstructibleType="BUILDING_RAIL_STATION";
-- Unique Improvments civ
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_BANG";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_BANG";
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_KABAKAS_LAKE";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_KABAKAS_LAKE";
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_OBSHCHINA";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_OBSHCHINA";
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_STEPWELL";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_STEPWELL";
-- Unique Improvments cs
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_SHORE_BATTERY";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_SHORE_BATTERY";
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_OPEN_AIR_MUSEUM";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_OPEN_AIR_MUSEUM";
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_ENTREPOT";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_ENTREPOT";
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_INSTITUTE";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_INSTITUTE";
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_ABATTOIR";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_ABATTOIR";
UPDATE Constructibles
SET Cost="150"
WHERE ConstructibleType="IMPROVEMENT_CIRCUS_FAIR";
UPDATE Constructibles
SET CostProgressionParam1="50"
WHERE ConstructibleType="IMPROVEMENT_CIRCUS_FAIR";
-- Unique Buildings
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_RAILYARD";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_STEEL_MILL";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_GINKO";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_JUKOGYO";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_FORMAL_GARDEN";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_SALON";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_CATEDRAL";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_PORTAL_DE_MERCADERES";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_EXAMINATION_HALL";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_MONEY_SHOP";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_ROYAL_EXCHANGE";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_MANUFACTORY";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_CAMII";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_HAMMAM";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_GHAHVE_KHANE";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_TAKYEH";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_CONFUCIAN_ACADEMY";
UPDATE Constructibles
SET Cost="450"
WHERE ConstructibleType="BUILDING_PRINTING_HOUSE";
-- Town Specializations
-- Food Towns
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownFishingBoatResourceFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownAtollFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownLotusFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownReefFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownColdReefFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownCoastTerrainFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownNavigableRiverFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownPastureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownPlantationFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownDesertFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownGrasslandFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownPlainsFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownTropicalFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownTundraFloodplainFeatureFood";
UPDATE Warehouse_YieldChanges
SET YieldChange="2"
WHERE ID="MOTownFlatTerrainFood";

-- Food Towns: include Ocean Marine tiles in both Farming and Fishing Town bonuses.
-- These statements are age-gated by the presence of each Age's normal Town warehouse data.
INSERT OR IGNORE INTO Warehouse_YieldChanges
    (ID, Age, YieldType, YieldChange, TerrainInCity)
SELECT
    "MBMAQTownOceanTerrainFood", "AGE_ANTIQUITY", "YIELD_FOOD", 2, "TERRAIN_OCEAN"
WHERE EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID="AQTownCoastTerrainFood");

UPDATE ModifierArguments
SET Value = Value || ", MBMAQTownOceanTerrainFood"
WHERE ModifierId IN ("ATTACH_GRANARY_WAREHOUSE_FOOD_FROM_PROJECT", "ATTACH_FISHING_WAREHOUSE_FOOD_FROM_PROJECT")
  AND Name="WarehouseYieldChange"
  AND EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID="AQTownCoastTerrainFood")
  AND instr(Value, "MBMAQTownOceanTerrainFood")=0;

INSERT OR IGNORE INTO Warehouse_YieldChanges
    (ID, Age, YieldType, YieldChange, TerrainInCity)
SELECT
    "MBMEXTownOceanTerrainFood", "AGE_EXPLORATION", "YIELD_FOOD", 2, "TERRAIN_OCEAN"
WHERE EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID="EXTownCoastTerrainFood");

UPDATE ModifierArguments
SET Value = Value || ", MBMEXTownOceanTerrainFood"
WHERE ModifierId IN ("ATTACH_GRANARY_WAREHOUSE_FOOD_FROM_PROJECT", "ATTACH_FISHING_WAREHOUSE_FROM_PROJECT")
  AND Name="WarehouseYieldChange"
  AND EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID="EXTownCoastTerrainFood")
  AND instr(Value, "MBMEXTownOceanTerrainFood")=0;

INSERT OR IGNORE INTO Warehouse_YieldChanges
    (ID, Age, YieldType, YieldChange, TerrainInCity)
SELECT
    "MBMMOTownOceanTerrainFood", "AGE_MODERN", "YIELD_FOOD", 2, "TERRAIN_OCEAN"
WHERE EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID="MOTownCoastTerrainFood");

UPDATE ModifierArguments
SET Value = Value || ", MBMMOTownOceanTerrainFood"
WHERE ModifierId IN ("ATTACH_GRANARY_WAREHOUSE_FOOD_FROM_PROJECT", "ATTACH_FISHING_WAREHOUSE_FOOD_FROM_PROJECT")
  AND Name="WarehouseYieldChange"
  AND EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID="MOTownCoastTerrainFood")
  AND instr(Value, "MBMMOTownOceanTerrainFood")=0;

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
