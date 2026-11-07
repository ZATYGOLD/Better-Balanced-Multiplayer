-- Natural Wonder Spawn Fixes: Gullfoss, Iguazu Falls and Valley of Flowers get relaxed
-- placement requirements; their strict ones make them fail to spawn almost every time.

-- TypeTags: Valley of Flowers can spawn near the coast.
DELETE FROM TypeTags
WHERE Type = 'FEATURE_VALLEY_OF_FLOWERS'
AND Tag = 'NOTNEARCOAST';

-- Feature_ValidBiomes: more biomes for Valley of Flowers, Iguazu Falls and Gullfoss.
INSERT OR IGNORE INTO Feature_ValidBiomes (FeatureType, BiomeType, ReplaceRange, ReplaceWithBiomeType)
    VALUES
        ('FEATURE_VALLEY_OF_FLOWERS', 'BIOME_GRASSLAND', NULL, NULL),
        ('FEATURE_VALLEY_OF_FLOWERS', 'BIOME_TUNDRA', NULL, NULL),
        ('FEATURE_IGUAZU_FALLS', 'BIOME_GRASSLAND', NULL, NULL),
        ('FEATURE_IGUAZU_FALLS', 'BIOME_PLAINS', NULL, NULL),
        ('FEATURE_GULLFOSS', 'BIOME_PLAINS', 1, 'BIOME_TUNDRA');

-- TerrainBiomeFeature_YieldChanges: yields for the new biomes, mirroring the normal yields.
-- Valley of Flowers
INSERT OR IGNORE INTO TerrainBiomeFeature_YieldChanges (FeatureType, BiomeType, TerrainType, YieldType, ScaleByGameAge, YieldChange)
SELECT 'FEATURE_VALLEY_OF_FLOWERS', 'BIOME_GRASSLAND', TerrainType, YieldType, ScaleByGameAge, YieldChange
FROM TerrainBiomeFeature_YieldChanges
WHERE FeatureType = 'FEATURE_VALLEY_OF_FLOWERS';

INSERT OR IGNORE INTO TerrainBiomeFeature_YieldChanges (FeatureType, BiomeType, TerrainType, YieldType, ScaleByGameAge, YieldChange)
SELECT 'FEATURE_VALLEY_OF_FLOWERS', 'BIOME_TUNDRA', TerrainType, YieldType, ScaleByGameAge, YieldChange
FROM TerrainBiomeFeature_YieldChanges
WHERE FeatureType = 'FEATURE_VALLEY_OF_FLOWERS';

-- Iguazu Falls
INSERT OR IGNORE INTO TerrainBiomeFeature_YieldChanges (FeatureType, BiomeType, TerrainType, YieldType, ScaleByGameAge, YieldChange)
SELECT 'FEATURE_IGUAZU_FALLS', 'BIOME_GRASSLAND', TerrainType, YieldType, ScaleByGameAge, YieldChange
FROM TerrainBiomeFeature_YieldChanges
WHERE FeatureType = 'FEATURE_IGUAZU_FALLS';

INSERT OR IGNORE INTO TerrainBiomeFeature_YieldChanges (FeatureType, BiomeType, TerrainType, YieldType, ScaleByGameAge, YieldChange)
SELECT 'FEATURE_IGUAZU_FALLS', 'BIOME_PLAINS', TerrainType, YieldType, ScaleByGameAge, YieldChange
FROM TerrainBiomeFeature_YieldChanges
WHERE FeatureType = 'FEATURE_IGUAZU_FALLS';

-- Gullfoss needs no yield rows: it turns its own biome into Tundra.
