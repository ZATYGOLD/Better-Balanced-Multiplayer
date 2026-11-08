-- Food Towns: +2 Food on every Farming and Fishing Town tile (base +1).
UPDATE Warehouse_YieldChanges
SET YieldChange = 2
WHERE ID IN (
    'AQTownFishingBoatResourceFood',
    'AQTownAtollFeatureFood',
    'AQTownLotusFeatureFood',
    'AQTownReefFeatureFood',
    'AQTownColdReefFeatureFood',
    'AQTownCoastTerrainFood',
    'AQTownNavigableRiverFood',
    'AQTownPastureFood',
    'AQTownPlantationFood',
    'AQTownDesertFloodplainFeatureFood',
    'AQTownGrasslandFloodplainFeatureFood',
    'AQTownPlainsFloodplainFeatureFood',
    'AQTownTropicalFloodplainFeatureFood',
    'AQTownTundraFloodplainFeatureFood',
    'AQTownFlatTerrainFood'
);

-- Food Towns: Ocean tiles count for both Farming and Fishing Town bonuses.
INSERT OR IGNORE INTO Warehouse_YieldChanges (ID, Age, YieldType, YieldChange, TerrainInCity)
    VALUES ('BBMBalanceAQTownOceanTerrainFood', 'AGE_ANTIQUITY', 'YIELD_FOOD', 2, 'TERRAIN_OCEAN');

UPDATE ModifierArguments
SET Value = Value || ', BBMBalanceAQTownOceanTerrainFood'
WHERE Name = 'WarehouseYieldChange'
  AND ModifierId IN ('ATTACH_GRANARY_WAREHOUSE_FOOD_FROM_PROJECT', 'ATTACH_FISHING_WAREHOUSE_FOOD_FROM_PROJECT');
