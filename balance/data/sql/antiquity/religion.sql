
-- Earth Goddess
UPDATE Adjacency_YieldChanges
SET YieldType="YIELD_SCIENCE"
WHERE ID="AltarWonderHappiness";

UPDATE Adjacency_YieldChanges
SET YieldType="YIELD_SCIENCE"
WHERE ID="AltarNaturalWonderHappiness";

-- God of the Forest
UPDATE Warehouse_YieldChanges
SET YieldType="YIELD_FOOD"
WHERE ID="PantheonAltarCampGold";

UPDATE Warehouse_YieldChanges
SET YieldType="YIELD_FOOD"
WHERE ID="PantheonAltarWoodcutterResourceGold";

UPDATE Warehouse_YieldChanges
SET YieldType="YIELD_FOOD"
WHERE ID="PantheonAltarVegetatedFeatureGold";

-- God of the Forge
UPDATE ModifierArguments
SET Value="15"
WHERE Name="Percent" AND ModifierId="ATTACH_PANTHEON_BUILDING_PRODUCTION";

-- God of the sun
UPDATE ModifierArguments
SET Value="1,2,1,1,2,1"
WHERE Name="Amount" AND ModifierId="ATTACH_PANTHEON_ALTAR_YIELD";

-- Oral Tradition
UPDATE ModifierArguments
SET Value=20
WHERE Name="Percent" AND ModifierId="ATTACH_PANTHEON_ALTAR_SETTLER_PRODUCTION";

-- Sacred Waters
UPDATE Adjacency_YieldChanges
SET YieldType="YIELD_CULTURE"
WHERE ID="AltarCoastHappiness";

UPDATE Adjacency_YieldChanges
SET YieldType="YIELD_CULTURE"
WHERE ID="AltarLakeHappiness";

UPDATE Adjacency_YieldChanges
SET YieldType="YIELD_CULTURE"
WHERE ID="AltarRiverHappiness";