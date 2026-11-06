-- Town Specializations
-- Food Towns
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownFishingBoatResourceFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownAtollFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownLotusFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownReefFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownColdReefFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownCoastTerrainFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownNavigableRiverFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownPastureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownPlantationFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownDesertFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownGrasslandFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownPlainsFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownTropicalFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownTundraFloodplainFeatureFood';
UPDATE Warehouse_YieldChanges
SET YieldChange='2'
WHERE ID='EXTownFlatTerrainFood';

INSERT OR IGNORE INTO Warehouse_YieldChanges
    (ID, Age, YieldType, YieldChange, TerrainInCity)
SELECT
    'MPTBalanceEXTownOceanTerrainFood', 'AGE_EXPLORATION', 'YIELD_FOOD', 2, 'TERRAIN_OCEAN'
WHERE EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID='EXTownCoastTerrainFood');

UPDATE ModifierArguments
SET Value = Value || ', MPTBalanceEXTownOceanTerrainFood'
WHERE ModifierId IN ('ATTACH_GRANARY_WAREHOUSE_FOOD_FROM_PROJECT', 'ATTACH_FISHING_WAREHOUSE_FROM_PROJECT')
  AND Name='WarehouseYieldChange'
  AND EXISTS (SELECT 1 FROM Warehouse_YieldChanges WHERE ID='EXTownCoastTerrainFood')
  AND instr(Value, 'MPTBalanceEXTownOceanTerrainFood')=0;
