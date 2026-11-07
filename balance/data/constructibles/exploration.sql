-- Food Towns: +2 Food on every Farming and Fishing Town tile (base +1).
UPDATE Warehouse_YieldChanges
SET YieldChange = 2
WHERE ID IN (
    'EXTownFishingBoatResourceFood',
    'EXTownAtollFeatureFood',
    'EXTownLotusFeatureFood',
    'EXTownReefFeatureFood',
    'EXTownColdReefFeatureFood',
    'EXTownCoastTerrainFood',
    'EXTownNavigableRiverFood',
    'EXTownPastureFood',
    'EXTownPlantationFood',
    'EXTownDesertFloodplainFeatureFood',
    'EXTownGrasslandFloodplainFeatureFood',
    'EXTownPlainsFloodplainFeatureFood',
    'EXTownTropicalFloodplainFeatureFood',
    'EXTownTundraFloodplainFeatureFood',
    'EXTownFlatTerrainFood'
);

-- Food Towns: Ocean tiles count for both Farming and Fishing Town bonuses.
INSERT OR IGNORE INTO Warehouse_YieldChanges (ID, Age, YieldType, YieldChange, TerrainInCity)
    VALUES ('MPTBalanceEXTownOceanTerrainFood', 'AGE_EXPLORATION', 'YIELD_FOOD', 2, 'TERRAIN_OCEAN');

UPDATE ModifierArguments
SET Value = Value || ', MPTBalanceEXTownOceanTerrainFood'
WHERE Name = 'WarehouseYieldChange'
  AND ModifierId IN ('ATTACH_GRANARY_WAREHOUSE_FOOD_FROM_PROJECT', 'ATTACH_FISHING_WAREHOUSE_FROM_PROJECT');

-- Thanh Hue
UPDATE Wonders
SET RequiredConstructibleInSettlementCount = 3
WHERE ConstructibleType = 'WONDER_THANH_HUE';
