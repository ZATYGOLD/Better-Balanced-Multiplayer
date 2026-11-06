-- Town Specializations
-- Food Towns
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownFishingBoatResourceFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownAtollFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownLotusFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownReefFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownColdReefFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownCoastTerrainFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownNavigableRiverFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownPastureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownPlantationFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownDesertFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownGrasslandFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownPlainsFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownTropicalFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownTundraFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='AQTownFlatTerrainFood';

-- Food Towns: include Ocean Marine tiles in both Farming and Fishing Town bonuses.
-- These statements are age-gated by the presence of each Age's normal Town warehouse data.
INSERT OR IGNORE INTO Warehouse_YieldChanges
    (ID, Age, YieldType, YieldChange, TerrainInCity)
SELECT
    'MPTBalanceAQTownOceanTerrainFood', 'AGE_ANTIQUITY', 'YIELD_FOOD', 2, 'TERRAIN_OCEAN'
WHERE EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID='AQTownCoastTerrainFood');

UPDATE ModifierArguments
SET Value = Value || ', MPTBalanceAQTownOceanTerrainFood'
WHERE ModifierId IN ('ATTACH_GRANARY_WAREHOUSE_FOOD_FROM_PROJECT', 'ATTACH_FISHING_WAREHOUSE_FOOD_FROM_PROJECT')
  AND Name='WarehouseYieldChange'
  AND EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID='AQTownCoastTerrainFood')
  AND instr(Value, 'MPTBalanceAQTownOceanTerrainFood')=0;
