--*******************************************************
--***************** PARAMETER GROUPS ********************
--*******************************************************
-- The Map tab's Terrain and Natural Wonder Selection groups
-- (ui/mp-setup/setup-layout.js).
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('TerrainOptions', 'LOC_GROUPID_MPT_TERRAINOPTIONS'),
        ('MPAdvancedTerrainOptions', 'LOC_GROUPID_MPT_TERRAINOPTIONS'),
        ('NaturalWonderSelectionOptions', 'LOC_GROUPID_MPT_NATURALWONDERSELECTIONOPTIONS'),
        ('MPAdvancedNaturalWonderSelectionOptions', 'LOC_GROUPID_MPT_NATURALWONDERSELECTIONOPTIONS');

--*******************************************************
--***************** CLIMATE *****************************
--*******************************************************
-- Map Age, Map Temperature and Map Zones, in Map Settings, read by the terrain,
-- biome, feature and snow passes of the multiplayer maps (maps/maps/generation/).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTMapAge', 'LOC_MPT_MAPS_MAP_AGE_NAME', 'LOC_MPT_MAPS_MAP_AGE_DESC', 'MPTMapAges', 'MPT_MAPS_MAP_AGE_STANDARD', 'Map', 'MPTMapAge', 'MapOptions', 0, 0, 0, 1031),
        ('MPTMapTemperature', 'LOC_MPT_MAPS_TEMPERATURE_NAME', 'LOC_MPT_MAPS_TEMPERATURE_DESC', 'MPTMapTemperatures', 'MPT_MAPS_TEMPERATURE_STANDARD', 'Map', 'MPTMapTemperature', 'MapOptions', 0, 0, 0, 1032),
        ('MPTMapZones', 'LOC_MPT_MAPS_MAP_ZONES_NAME', 'LOC_MPT_MAPS_MAP_ZONES_DESC', 'MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_STANDARD', 'Map', 'MPTMapZones', 'MapOptions', 0, 0, 0, 1033);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTMapAges', 'MPT_MAPS_MAP_AGE_OLD', 'LOC_ADVANCED_OPTIONS_OLD', 'LOC_MPT_MAPS_MAP_AGE_OLD_DESC', 10),
        ('MPTMapAges', 'MPT_MAPS_MAP_AGE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_MAP_AGE_STANDARD_DESC', 20),
        ('MPTMapAges', 'MPT_MAPS_MAP_AGE_NEW', 'LOC_ADVANCED_OPTIONS_NEW', 'LOC_MPT_MAPS_MAP_AGE_NEW_DESC', 30),
        ('MPTMapTemperatures', 'MPT_MAPS_TEMPERATURE_FRIGID', 'LOC_MPT_MAPS_FRIGID_NAME', 'LOC_MPT_MAPS_TEMPERATURE_FRIGID_DESC', 10),
        ('MPTMapTemperatures', 'MPT_MAPS_TEMPERATURE_COLD', 'LOC_MPT_MAPS_COLD_NAME', 'LOC_MPT_MAPS_TEMPERATURE_COLD_DESC', 20),
        ('MPTMapTemperatures', 'MPT_MAPS_TEMPERATURE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_TEMPERATURE_STANDARD_DESC', 30),
        ('MPTMapTemperatures', 'MPT_MAPS_TEMPERATURE_HOT', 'LOC_MPT_MAPS_HOT_NAME', 'LOC_MPT_MAPS_TEMPERATURE_HOT_DESC', 40),
        ('MPTMapTemperatures', 'MPT_MAPS_TEMPERATURE_SCORCHING', 'LOC_MPT_MAPS_SCORCHING_NAME', 'LOC_MPT_MAPS_TEMPERATURE_SCORCHING_DESC', 50),
        ('MPTMapTemperatures', 'MPT_MAPS_TEMPERATURE_RANDOM', 'LOC_ADVANCED_OPTIONS_RANDOM', 'LOC_MPT_MAPS_TEMPERATURE_RANDOM_DESC', 60),
        ('MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_MAP_ZONES_STANDARD_DESC', 10),
        ('MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_HOT_POLES', 'LOC_MPT_MAPS_MAP_ZONES_HOT_POLES_NAME', 'LOC_MPT_MAPS_MAP_ZONES_HOT_POLES_DESC', 20),
        ('MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_HOT_EDGE', 'LOC_MPT_MAPS_MAP_ZONES_HOT_EDGE_NAME', 'LOC_MPT_MAPS_MAP_ZONES_HOT_EDGE_DESC', 30),
        ('MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_HOT_CENTER', 'LOC_MPT_MAPS_MAP_ZONES_HOT_CENTER_NAME', 'LOC_MPT_MAPS_MAP_ZONES_HOT_CENTER_DESC', 40),
        ('MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_COLD_CENTER', 'LOC_MPT_MAPS_MAP_ZONES_COLD_CENTER_NAME', 'LOC_MPT_MAPS_MAP_ZONES_COLD_CENTER_DESC', 50),
        ('MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_WARM_RING', 'LOC_MPT_MAPS_MAP_ZONES_WARM_RING_NAME', 'LOC_MPT_MAPS_MAP_ZONES_WARM_RING_DESC', 60),
        ('MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_PATCHWORK', 'LOC_MPT_MAPS_MAP_ZONES_PATCHWORK_NAME', 'LOC_MPT_MAPS_MAP_ZONES_PATCHWORK_DESC', 70),
        ('MPTMapZoneOptions', 'MPT_MAPS_MAP_ZONES_RANDOM', 'LOC_ADVANCED_OPTIONS_RANDOM', 'LOC_MPT_MAPS_MAP_ZONES_RANDOM_DESC', 80);

--*******************************************************
--***************** NATURAL WONDERS *********************
--*******************************************************
-- How many Natural Wonders a map places (maps/data/natural-wonders/count-*.sql), in Map Settings.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTNaturalWonders', 'LOC_MPT_MAPS_NATURAL_WONDERS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDERS_DESC', 'MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_STANDARD', 'Map', 'MPTNaturalWonders', 'MapOptions', 0, 0, 0, 1034);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_NONE', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_MAPS_NATURAL_WONDERS_NONE_DESC', 10),
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_HALF', 'LOC_MPT_MAPS_HALF_NAME', 'LOC_MPT_MAPS_NATURAL_WONDERS_HALF_DESC', 20),
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_NATURAL_WONDERS_STANDARD_DESC', 30),
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_MORE', 'LOC_MPT_MAPS_MORE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDERS_MORE_DESC', 40),
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_DOUBLE', 'LOC_MPT_MAPS_DOUBLE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDERS_DOUBLE_DESC', 50);

--*******************************************************
--***************** NATURAL WONDER SELECTION ************
--*******************************************************
-- One toggle per Natural Wonder; Off keeps it off the map (maps/data/natural-wonders/).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTNaturalWonderBarrierReef', 'LOC_MPT_MAPS_BARRIER_REEF_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderBarrierReef', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 200),
        ('MPTNaturalWonderBermudaTriangle', 'LOC_MPT_MAPS_BERMUDA_TRIANGLE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderBermudaTriangle', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 210),
        ('MPTNaturalWonderGrandCanyon', 'LOC_MPT_MAPS_GRAND_CANYON_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderGrandCanyon', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 220),
        ('MPTNaturalWonderGreatBlueHole', 'LOC_MPT_MAPS_GREAT_BLUE_HOLE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderGreatBlueHole', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 230),
        ('MPTNaturalWonderGullfoss', 'LOC_MPT_MAPS_GULLFOSS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderGullfoss', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 240),
        ('MPTNaturalWonderHoerikwaggo', 'LOC_MPT_MAPS_HOERIKWAGGO_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderHoerikwaggo', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 250),
        ('MPTNaturalWonderIguazuFalls', 'LOC_MPT_MAPS_IGUAZU_FALLS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderIguazuFalls', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 260),
        ('MPTNaturalWonderKilimanjaro', 'LOC_MPT_MAPS_KILIMANJARO_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderKilimanjaro', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 270),
        ('MPTNaturalWonderMachapuchare', 'LOC_MPT_MAPS_MACHAPUCHARE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderMachapuchare', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 280),
        ('MPTNaturalWonderMapuAVaeaBlowholes', 'LOC_MPT_MAPS_MAPU_A_VAEA_BLOWHOLES_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderMapuAVaeaBlowholes', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 290),
        ('MPTNaturalWonderMountEverest', 'LOC_MPT_MAPS_MOUNT_EVEREST_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderMountEverest', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 300),
        ('MPTNaturalWonderMountFuji', 'LOC_MPT_MAPS_MOUNT_FUJI_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderMountFuji', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 310),
        ('MPTNaturalWonderNachiFalls', 'LOC_MPT_MAPS_NACHI_FALLS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderNachiFalls', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 315),
        ('MPTNaturalWonderRedwoodForest', 'LOC_MPT_MAPS_REDWOOD_FOREST_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderRedwoodForest', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 320),
        ('MPTNaturalWonderSeongsanIlchulbong', 'LOC_MPT_MAPS_SEONGSAN_ILCHULBONG_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderSeongsanIlchulbong', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 325),
        ('MPTNaturalWonderThera', 'LOC_MPT_MAPS_THERA_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderThera', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 330),
        ('MPTNaturalWonderTorresDelPaine', 'LOC_MPT_MAPS_TORRES_DEL_PAINE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderTorresDelPaine', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 340),
        ('MPTNaturalWonderUluru', 'LOC_MPT_MAPS_ULURU_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderUluru', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 350),
        ('MPTNaturalWonderValleyOfFlowers', 'LOC_MPT_MAPS_VALLEY_OF_FLOWERS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderValleyOfFlowers', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 360),
        ('MPTNaturalWonderVihren', 'LOC_MPT_MAPS_VIHREN_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderVihren', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 370),
        ('MPTNaturalWonderVinicunca', 'LOC_MPT_MAPS_VINICUNCA_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderVinicunca', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 380),
        ('MPTNaturalWonderZhangjiajie', 'LOC_MPT_MAPS_ZHANGJIAJIE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderZhangjiajie', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 390);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'LOC_ADVANCED_OPTIONS_ON', 'LOC_MPT_MAPS_NATURAL_WONDER_ON_DESC', 10),
        ('MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_OFF', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_MAPS_NATURAL_WONDER_OFF_DESC', 20);

--*******************************************************
--***************** TERRAIN *****************************
--*******************************************************
-- Lakes (maps/data/lakes/), Rivers and Mountains (the multiplayer maps' passes,
-- maps/maps/generation/), with Sea Level after them in multiplayer.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTLakes', 'LOC_MPT_MAPS_LAKES_NAME', 'LOC_MPT_MAPS_LAKES_DESC', 'MPTLakeFrequencies', 'MPT_MAPS_LAKES_STANDARD', 'Map', 'MPTLakes', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 0, 150),
        ('MPTMapRivers', 'LOC_MPT_MAPS_RIVERS_NAME', 'LOC_MPT_MAPS_RIVERS_DESC', 'MPTMapRiverOptions', 'MPT_MAPS_RIVERS_STANDARD', 'Map', 'MPTMapRivers', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 0, 151),
        ('MPTMapMountains', 'LOC_MPT_MAPS_MOUNTAINS_NAME', 'LOC_MPT_MAPS_MOUNTAINS_DESC', 'MPTMapMountainOptions', 'MPT_MAPS_MOUNTAINS_STANDARD', 'Map', 'MPTMapMountains', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 0, 152);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTLakeFrequencies', 'MPT_MAPS_LAKES_LESS', 'LOC_MPT_MAPS_LESS_NAME', 'LOC_MPT_MAPS_LAKES_LESS_DESC', 20),
        ('MPTLakeFrequencies', 'MPT_MAPS_LAKES_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_LAKES_STANDARD_DESC', 30),
        ('MPTLakeFrequencies', 'MPT_MAPS_LAKES_MORE', 'LOC_MPT_MAPS_MORE_NAME', 'LOC_MPT_MAPS_LAKES_MORE_DESC', 40),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_WADI', 'LOC_MPT_MAPS_RIVERS_WADI_NAME', 'LOC_MPT_MAPS_RIVERS_WADI_DESC', 10),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_ARID', 'LOC_MPT_MAPS_RIVERS_ARID_NAME', 'LOC_MPT_MAPS_RIVERS_ARID_DESC', 20),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_CHANNEL', 'LOC_MPT_MAPS_RIVERS_CHANNEL_NAME', 'LOC_MPT_MAPS_RIVERS_CHANNEL_DESC', 30),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_SHALLOW', 'LOC_MPT_MAPS_RIVERS_SHALLOW_NAME', 'LOC_MPT_MAPS_RIVERS_SHALLOW_DESC', 40),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_RIVERS_STANDARD_DESC', 50),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_WATERWAY', 'LOC_MPT_MAPS_RIVERS_WATERWAY_NAME', 'LOC_MPT_MAPS_RIVERS_WATERWAY_DESC', 60),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_STREAM', 'LOC_MPT_MAPS_RIVERS_STREAM_NAME', 'LOC_MPT_MAPS_RIVERS_STREAM_DESC', 70),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_RIVERLAND', 'LOC_MPT_MAPS_RIVERS_RIVERLAND_NAME', 'LOC_MPT_MAPS_RIVERS_RIVERLAND_DESC', 80),
        ('MPTMapRiverOptions', 'MPT_MAPS_RIVERS_DEEP', 'LOC_MPT_MAPS_RIVERS_DEEP_NAME', 'LOC_MPT_MAPS_RIVERS_DEEP_DESC', 90),
        ('MPTMapMountainOptions', 'MPT_MAPS_MOUNTAINS_LESS', 'LOC_MPT_MAPS_LESS_NAME', 'LOC_MPT_MAPS_MOUNTAINS_LESS_DESC', 20),
        ('MPTMapMountainOptions', 'MPT_MAPS_MOUNTAINS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_MOUNTAINS_STANDARD_DESC', 30),
        ('MPTMapMountainOptions', 'MPT_MAPS_MOUNTAINS_MORE', 'LOC_MPT_MAPS_MORE_NAME', 'LOC_MPT_MAPS_MOUNTAINS_MORE_DESC', 40);

UPDATE Parameters SET GroupIDMultiplayerOverride = 'MPAdvancedTerrainOptions' WHERE ParameterID = 'MapSeaLevel';

-- The game defines Sea Level per map script; Pangaea Ultima and the multiplayer
-- copies of the standard maps that have it (multiplayer only) get the same row,
-- sorted after Mountains.
INSERT OR IGNORE INTO Parameters (Key1, Key2, ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, SortIndex)
    VALUES
        ('Map', '{multiplayer-toolkit}maps/maps/pangaea-ultima.js', 'MapSeaLevel', 'LOC_MAP_SEA_LEVEL_NAME', 'LOC_MAP_SEA_LEVEL_DESCRIPTION', 'SeaLevels', 'SEA_LEVEL_STANDARD', 'Map', 'SeaLevel', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 153);

INSERT OR IGNORE INTO Parameters (Key1, Key2, ParameterID, Name, Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, GroupID, GroupIDMultiplayerOverride, Hidden, ReadOnly, SupportsSinglePlayer, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, SortIndex)
SELECT Key1, REPLACE(Key2, '{base-standard}maps/', '{multiplayer-toolkit}maps/maps/standard/'), ParameterID, Name, Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, 'TerrainOptions', 'MPAdvancedTerrainOptions', Hidden, ReadOnly, 0, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, 153
FROM Parameters
WHERE ParameterID = 'MapSeaLevel' AND Key1 = 'Map'
AND Key2 IN (SELECT REPLACE(File, '{multiplayer-toolkit}maps/maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{multiplayer-toolkit}maps/maps/standard/%');
