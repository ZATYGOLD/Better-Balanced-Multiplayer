--*******************************************************
--***************** MAP LIST ****************************
--*******************************************************
-- Pangaea Ultima and the multiplayer copies of the standard maps
-- (maps/standard/, which apply the Map Settings climate and terrain), listed
-- in multiplayer setup only, where the copies replace the base scripts
-- (Multiplayer Only Maps, below). Each copy joins the list as a row of its own
-- with the base map's name, order, start positions and Sea Level dependencies;
-- its Sea Level row is under Terrain, below.
INSERT OR IGNORE INTO Maps (File, Name, Description, SortIndex)
    VALUES
        ('{zatygolds-multiplayer-balance}maps/pangaea-ultima.js', 'LOC_BBM_MAPS_PANGAEA_ULTIMA_NAME', 'LOC_BBM_MAPS_PANGAEA_ULTIMA_DESC', 110);

INSERT OR IGNORE INTO Maps (Domain, File, Name, Description, Image, StaticMap, WorldBuilderOnly, SortIndex)
SELECT Domain, REPLACE(File, '{base-standard}maps/', '{zatygolds-multiplayer-balance}maps/standard/'), Name, Description, Image, StaticMap, WorldBuilderOnly, SortIndex
FROM Maps
WHERE File IN (
    '{base-standard}maps/archipelago.js',
    '{base-standard}maps/archipelago-voronoi.js',
    '{base-standard}maps/continents.js',
    '{base-standard}maps/continents-plus.js',
    '{base-standard}maps/continents-voronoi.js',
    '{base-standard}maps/donut-voronoi.js',
    '{base-standard}maps/fractal.js',
    '{base-standard}maps/fractal-voronoi.js',
    '{base-standard}maps/pangaea-plus.js',
    '{base-standard}maps/pangaea-voronoi.js',
    '{base-standard}maps/shattered-seas-voronoi.js',
    '{base-standard}maps/shuffle.js',
    '{base-standard}maps/shuffle-voronoi.js',
    '{base-standard}maps/terra-incognita.js',
    '{base-standard}maps/terra-incognita-voronoi.js'
);

INSERT OR IGNORE INTO SupportedValuesByMap (Map, PlayerID, Domain, Value)
SELECT REPLACE(Map, '{base-standard}maps/', '{zatygolds-multiplayer-balance}maps/standard/'), PlayerID, Domain, Value
FROM SupportedValuesByMap
WHERE Map IN (SELECT REPLACE(File, '{zatygolds-multiplayer-balance}maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{zatygolds-multiplayer-balance}maps/standard/%');

INSERT OR IGNORE INTO ParameterDependencies (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
SELECT ParameterID, ConfigurationGroup, ConfigurationKey, Operator, REPLACE(ConfigurationValue, '{base-standard}maps/', '{zatygolds-multiplayer-balance}maps/standard/')
FROM ParameterDependencies
WHERE ConfigurationKey = 'MapScript'
AND ConfigurationValue IN (SELECT REPLACE(File, '{zatygolds-multiplayer-balance}maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{zatygolds-multiplayer-balance}maps/standard/%');

--*******************************************************
--***************** MULTIPLAYER DEFAULTS ****************
--*******************************************************
-- Pangaea Ultima is the default multiplayer map (the multiplayer-only Map row). Settings
-- whose row hotseat shares with single player (speed, map) and Map Size are set by
-- ui/maps/bbm-multiplayer-defaults.js on the multiplayer setup screen.
UPDATE Parameters SET DefaultValue = '{zatygolds-multiplayer-balance}maps/pangaea-ultima.js' WHERE ParameterID = 'Map' AND SupportsSinglePlayer = 0;

--*******************************************************
--***************** SPAWN SETTINGS **********************
--*******************************************************
-- A Spawn Settings group before Map Settings on the Map tab
-- (ui/setup/bbm-setup-layout.js): the game's multiplayer Start Position row, then
-- Start Bias: Multiplayer (default) holds supported leaders and civilizations to
-- strict start biases (maps/bbm-strict-start-biases.js), Standard keeps the game's
-- own. Single player keeps Start Position in Map Options.
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('SpawnOptions', 'LOC_GROUPID_BBM_SPAWNOPTIONS');

UPDATE Parameters SET GroupIDMultiplayerOverride = 'SpawnOptions' WHERE ParameterID = 'StartPosition' AND SupportsSinglePlayer = 0;

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, Hash, SupportsSinglePlayer, SortIndex)
    VALUES
        ('BBMStartBias', 'LOC_BBM_MAPS_START_BIAS_NAME', 'LOC_BBM_MAPS_START_BIAS_DESC', 'BBMStartBiasOptions', 'BBM_MAPS_START_BIAS_MULTIPLAYER', 'Map', 'BBMStartBias', 'SpawnOptions', 'SimpleSelectWindow', 0, 0, 121);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMStartBiasOptions', 'BBM_MAPS_START_BIAS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_START_BIAS_STANDARD_DESC', 10),
        ('BBMStartBiasOptions', 'BBM_MAPS_START_BIAS_MULTIPLAYER', 'LOC_BBM_MAPS_START_BIAS_MULTIPLAYER_NAME', 'LOC_BBM_MAPS_START_BIAS_MULTIPLAYER_DESC', 20);

--*******************************************************
--***************** MAP SETTINGS ************************
--*******************************************************
-- One Map Settings group in multiplayer, the game's Map Options: the Map Seed joins
-- it rather than a second multiplayer Map Settings group. The multiplayer Map row
-- sorts before Map Size, as in single player.
UPDATE Parameters SET SortIndex = 1010 WHERE ParameterID = 'Map' AND SupportsSinglePlayer = 0;
UPDATE Parameters SET GroupIDMultiplayerOverride = 'MapOptions' WHERE ParameterID = 'MapRandomSeed';

--*******************************************************
--***************** RESOURCE SETTINGS *******************
--*******************************************************
-- A Resource Settings group after Map Settings on the Map tab. Resource
-- List picks the resources: Standard keeps the game's list and rules, All loads
-- the mod's resource data (modinfo criteria maps-resource-list-all-*). Resource
-- Amount and Clusters apply to either (maps/bbm-global-resource-system.js).
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('ResourceOptions', 'LOC_GROUPID_BBM_RESOURCEOPTIONS');

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, Hash, SupportsSinglePlayer, SortIndex)
    VALUES
        ('BBMResourceList', 'LOC_BBM_MAPS_RESOURCE_LIST_NAME', 'LOC_BBM_MAPS_RESOURCE_LIST_DESC', 'BBMResourceLists', 'BBM_MAPS_RESOURCE_LIST_ALL', 'Map', 'BBMResourceList', 'ResourceOptions', 'SimpleSelectWindow', 0, 0, 10),
        ('BBMResourceAmount', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_NAME', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_DESC', 'BBMResourceAmounts', 'BBM_MAPS_RESOURCE_AMOUNT_MULTIPLAYER', 'Map', 'BBMResourceAmount', 'ResourceOptions', 'SimpleSelectWindow', 0, 0, 20),
        ('BBMResourceClusters', 'LOC_BBM_MAPS_RESOURCE_CLUSTERS_NAME', 'LOC_BBM_MAPS_RESOURCE_CLUSTERS_DESC', 'BBMResourceClusterOptions', 'BBM_MAPS_RESOURCE_CLUSTERS_OFF', 'Map', 'BBMResourceClusters', 'ResourceOptions', 'SimpleSelectWindow', 0, 0, 30);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMResourceLists', 'BBM_MAPS_RESOURCE_LIST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_RESOURCE_LIST_STANDARD_DESC', 10),
        ('BBMResourceLists', 'BBM_MAPS_RESOURCE_LIST_ALL', 'LOC_BBM_MAPS_RESOURCE_LIST_ALL_NAME', 'LOC_BBM_MAPS_RESOURCE_LIST_ALL_DESC', 20),
        ('BBMResourceAmounts', 'BBM_MAPS_RESOURCE_AMOUNT_SCARCE', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_SCARCE_NAME', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_SCARCE_DESC', 10),
        ('BBMResourceAmounts', 'BBM_MAPS_RESOURCE_AMOUNT_LIMITED', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_LIMITED_NAME', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_LIMITED_DESC', 20),
        ('BBMResourceAmounts', 'BBM_MAPS_RESOURCE_AMOUNT_MULTIPLAYER', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_MULTIPLAYER_NAME', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_MULTIPLAYER_DESC', 30),
        ('BBMResourceAmounts', 'BBM_MAPS_RESOURCE_AMOUNT_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_RESOURCE_AMOUNT_STANDARD_DESC', 40),
        ('BBMResourceClusterOptions', 'BBM_MAPS_RESOURCE_CLUSTERS_OFF', 'LOC_BBM_DISABLED_NAME', 'LOC_BBM_MAPS_RESOURCE_CLUSTERS_OFF_DESC', 10),
        ('BBMResourceClusterOptions', 'BBM_MAPS_RESOURCE_CLUSTERS_SMALL', 'LOC_BBM_MAPS_RESOURCE_CLUSTERS_SMALL_NAME', 'LOC_BBM_MAPS_RESOURCE_CLUSTERS_SMALL_DESC', 20),
        ('BBMResourceClusterOptions', 'BBM_MAPS_RESOURCE_CLUSTERS_LARGE', 'LOC_BBM_MAPS_RESOURCE_CLUSTERS_LARGE_NAME', 'LOC_BBM_MAPS_RESOURCE_CLUSTERS_LARGE_DESC', 30);

-- The Earth maps keep the game's resources: Resource Settings hide there, and the
-- hidden Resource Map flag, set from each map script, keeps the Resource List All
-- data off them (modinfo criteria maps-resource-list-all-*) without changing the
-- chosen Resource List.
INSERT OR IGNORE INTO ParameterDependencies (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('BBMResourceList', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge.Civ7Map'),
        ('BBMResourceAmount', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge.Civ7Map'),
        ('BBMResourceClusters', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge.Civ7Map'),
        ('BBMResourceList', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge_Random.Civ7Map'),
        ('BBMResourceAmount', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge_Random.Civ7Map'),
        ('BBMResourceClusters', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge_Random.Civ7Map');

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupID, Hidden, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMResourceMap', 'LOC_BBM_MAPS_RESOURCE_MAP', 'LOC_BBM_MAPS_RESOURCE_MAP', 'BBMResourceMaps', 0, 'BBM_MAPS_RESOURCE_MAP_SUPPORTED', 'Map', 'BBMResourceMap', 'ResourceOptions', 1, 0, 0, 40);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMResourceMaps', 'BBM_MAPS_RESOURCE_MAP_SUPPORTED', 'LOC_BBM_MAPS_RESOURCE_MAP', 'LOC_BBM_MAPS_RESOURCE_MAP', 10),
        ('BBMResourceMaps', 'BBM_MAPS_RESOURCE_MAP_EARTH', 'LOC_BBM_MAPS_RESOURCE_MAP', 'LOC_BBM_MAPS_RESOURCE_MAP', 20);

INSERT OR IGNORE INTO ConfigurationUpdates (SourceGroup, SourceKey, SourceValue, TargetGroup, TargetKey, TargetValue, Hash)
SELECT 'Map', 'Script', File, 'Map', 'BBMResourceMap',
    CASE WHEN File LIKE '{base-standard}maps/EarthMaps/%' THEN 'BBM_MAPS_RESOURCE_MAP_EARTH' ELSE 'BBM_MAPS_RESOURCE_MAP_SUPPORTED' END, 0
FROM Maps;

--*******************************************************
--***************** PLAYER PLACEMENT ********************
--*******************************************************
-- Hidden: set by the Match Type (config/match-types.sql).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hidden, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMPlayerPlacement', 'LOC_BBM_MAPS_PLAYER_PLACEMENT_NAME', 'LOC_BBM_MAPS_PLAYER_PLACEMENT_DESC', 'BBMPlayerPlacements', 'BBM_MAPS_PLACEMENT_BASE', 'Map', 'BBMPlayerPlacement', 'MapOptions', 1, 0, 0, 0, 9001);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMPlayerPlacements', 'BBM_MAPS_PLACEMENT_BASE', 'LOC_BBM_MAPS_PLACEMENT_BASE_NAME', 'LOC_BBM_MAPS_PLACEMENT_BASE_DESC', 10),
        ('BBMPlayerPlacements', 'BBM_MAPS_PLACEMENT_DUEL', 'LOC_BBM_MAPS_PLACEMENT_DUEL_NAME', 'LOC_BBM_MAPS_PLACEMENT_DUEL_DESC', 20),
        ('BBMPlayerPlacements', 'BBM_MAPS_PLACEMENT_2V2', 'LOC_BBM_MAPS_PLACEMENT_2V2_NAME', 'LOC_BBM_MAPS_PLACEMENT_2V2_DESC', 30),
        ('BBMPlayerPlacements', 'BBM_MAPS_PLACEMENT_3V3', 'LOC_BBM_MAPS_PLACEMENT_3V3_NAME', 'LOC_BBM_MAPS_PLACEMENT_3V3_DESC', 40),
        ('BBMPlayerPlacements', 'BBM_MAPS_PLACEMENT_4V4', 'LOC_BBM_MAPS_PLACEMENT_4V4_NAME', 'LOC_BBM_MAPS_PLACEMENT_4V4_DESC', 50);

--*******************************************************
--***************** CHOSEN MAP SIZE *********************
--*******************************************************
-- Hidden: the size the lobby chose when a Spectator slot made the host launch the
-- next size up (ui/maps/bbm-match-slots.js); the map is still built at the chosen size.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hidden, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMChosenMapSize', 'LOC_BBM_MAPS_CHOSEN_MAP_SIZE', 'LOC_BBM_MAPS_CHOSEN_MAP_SIZE', 'BBMChosenMapSizes', 'BBM_MAPS_CHOSEN_SIZE_NONE', 'Map', 'BBMChosenMapSize', 'MapOptions', 1, 0, 0, 0, 9002);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMChosenMapSizes', 'BBM_MAPS_CHOSEN_SIZE_NONE', 'LOC_BBM_MAPS_CHOSEN_MAP_SIZE', 'LOC_BBM_MAPS_CHOSEN_MAP_SIZE', 10),
        ('BBMChosenMapSizes', 'MAPSIZE_TINY', 'LOC_MAPSIZE_TINY_NAME', 'LOC_MAPSIZE_TINY_DESCRIPTION', 20),
        ('BBMChosenMapSizes', 'MAPSIZE_SMALL', 'LOC_MAPSIZE_SMALL_NAME', 'LOC_MAPSIZE_SMALL_DESCRIPTION', 30);

--*******************************************************
--***************** SPECTATOR SLOT **********************
--*******************************************************
-- Hidden: the lobby slot kept for Zatygold's Spectator in team matches (-1: none);
-- the Spectator makes the player in it the Observer.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hidden, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMSpectatorSlot', 'LOC_BBM_MAPS_SPECTATOR_SLOT', 'LOC_BBM_MAPS_SPECTATOR_SLOT', 'int', -1, 'Game', 'BBMSpectatorSlot', 'GameOptions', 1, 0, 0, 0, 9003);

--*******************************************************
--***************** PARAMETER GROUPS ********************
--*******************************************************
-- The Map tab's Terrain and Natural Wonder Selection groups
-- (ui/setup/bbm-setup-layout.js).
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('TerrainOptions', 'LOC_GROUPID_BBM_TERRAINOPTIONS'),
        ('MPAdvancedTerrainOptions', 'LOC_GROUPID_BBM_TERRAINOPTIONS'),
        ('NaturalWonderSelectionOptions', 'LOC_GROUPID_BBM_NATURALWONDERSELECTIONOPTIONS'),
        ('MPAdvancedNaturalWonderSelectionOptions', 'LOC_GROUPID_BBM_NATURALWONDERSELECTIONOPTIONS');

--*******************************************************
--***************** CLIMATE *****************************
--*******************************************************
-- Map Age, Map Temperature and Map Zones, in Map Settings, read by the terrain,
-- biome, feature and snow passes of the multiplayer maps (maps/generation/).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMMapAge', 'LOC_BBM_MAPS_MAP_AGE_NAME', 'LOC_BBM_MAPS_MAP_AGE_DESC', 'BBMMapAges', 'BBM_MAPS_MAP_AGE_STANDARD', 'Map', 'BBMMapAge', 'MapOptions', 0, 0, 0, 1031),
        ('BBMMapTemperature', 'LOC_BBM_MAPS_TEMPERATURE_NAME', 'LOC_BBM_MAPS_TEMPERATURE_DESC', 'BBMMapTemperatures', 'BBM_MAPS_TEMPERATURE_STANDARD', 'Map', 'BBMMapTemperature', 'MapOptions', 0, 0, 0, 1032),
        ('BBMMapZones', 'LOC_BBM_MAPS_MAP_ZONES_NAME', 'LOC_BBM_MAPS_MAP_ZONES_DESC', 'BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_STANDARD', 'Map', 'BBMMapZones', 'MapOptions', 0, 0, 0, 1033);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMMapAges', 'BBM_MAPS_MAP_AGE_OLD', 'LOC_ADVANCED_OPTIONS_OLD', 'LOC_BBM_MAPS_MAP_AGE_OLD_DESC', 10),
        ('BBMMapAges', 'BBM_MAPS_MAP_AGE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_MAP_AGE_STANDARD_DESC', 20),
        ('BBMMapAges', 'BBM_MAPS_MAP_AGE_NEW', 'LOC_ADVANCED_OPTIONS_NEW', 'LOC_BBM_MAPS_MAP_AGE_NEW_DESC', 30),
        ('BBMMapTemperatures', 'BBM_MAPS_TEMPERATURE_FRIGID', 'LOC_BBM_MAPS_FRIGID_NAME', 'LOC_BBM_MAPS_TEMPERATURE_FRIGID_DESC', 10),
        ('BBMMapTemperatures', 'BBM_MAPS_TEMPERATURE_COLD', 'LOC_BBM_MAPS_COLD_NAME', 'LOC_BBM_MAPS_TEMPERATURE_COLD_DESC', 20),
        ('BBMMapTemperatures', 'BBM_MAPS_TEMPERATURE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_TEMPERATURE_STANDARD_DESC', 30),
        ('BBMMapTemperatures', 'BBM_MAPS_TEMPERATURE_HOT', 'LOC_BBM_MAPS_HOT_NAME', 'LOC_BBM_MAPS_TEMPERATURE_HOT_DESC', 40),
        ('BBMMapTemperatures', 'BBM_MAPS_TEMPERATURE_SCORCHING', 'LOC_BBM_MAPS_SCORCHING_NAME', 'LOC_BBM_MAPS_TEMPERATURE_SCORCHING_DESC', 50),
        ('BBMMapTemperatures', 'BBM_MAPS_TEMPERATURE_RANDOM', 'LOC_ADVANCED_OPTIONS_RANDOM', 'LOC_BBM_MAPS_TEMPERATURE_RANDOM_DESC', 60),
        ('BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_MAP_ZONES_STANDARD_DESC', 10),
        ('BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_HOT_POLES', 'LOC_BBM_MAPS_MAP_ZONES_HOT_POLES_NAME', 'LOC_BBM_MAPS_MAP_ZONES_HOT_POLES_DESC', 20),
        ('BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_HOT_EDGE', 'LOC_BBM_MAPS_MAP_ZONES_HOT_EDGE_NAME', 'LOC_BBM_MAPS_MAP_ZONES_HOT_EDGE_DESC', 30),
        ('BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_HOT_CENTER', 'LOC_BBM_MAPS_MAP_ZONES_HOT_CENTER_NAME', 'LOC_BBM_MAPS_MAP_ZONES_HOT_CENTER_DESC', 40),
        ('BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_COLD_CENTER', 'LOC_BBM_MAPS_MAP_ZONES_COLD_CENTER_NAME', 'LOC_BBM_MAPS_MAP_ZONES_COLD_CENTER_DESC', 50),
        ('BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_WARM_RING', 'LOC_BBM_MAPS_MAP_ZONES_WARM_RING_NAME', 'LOC_BBM_MAPS_MAP_ZONES_WARM_RING_DESC', 60),
        ('BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_PATCHWORK', 'LOC_BBM_MAPS_MAP_ZONES_PATCHWORK_NAME', 'LOC_BBM_MAPS_MAP_ZONES_PATCHWORK_DESC', 70),
        ('BBMMapZoneOptions', 'BBM_MAPS_MAP_ZONES_RANDOM', 'LOC_ADVANCED_OPTIONS_RANDOM', 'LOC_BBM_MAPS_MAP_ZONES_RANDOM_DESC', 80);

--*******************************************************
--***************** NATURAL WONDERS *********************
--*******************************************************
-- How many Natural Wonders a map places (data/maps/natural-wonders/count-*.sql), in Map Settings.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMNaturalWonders', 'LOC_BBM_MAPS_NATURAL_WONDERS_NAME', 'LOC_BBM_MAPS_NATURAL_WONDERS_DESC', 'BBMNaturalWonderCounts', 'BBM_MAPS_NATURAL_WONDERS_STANDARD', 'Map', 'BBMNaturalWonders', 'MapOptions', 0, 0, 0, 1034);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMNaturalWonderCounts', 'BBM_MAPS_NATURAL_WONDERS_NONE', 'LOC_BBM_DISABLED_NAME', 'LOC_BBM_MAPS_NATURAL_WONDERS_NONE_DESC', 10),
        ('BBMNaturalWonderCounts', 'BBM_MAPS_NATURAL_WONDERS_HALF', 'LOC_BBM_MAPS_HALF_NAME', 'LOC_BBM_MAPS_NATURAL_WONDERS_HALF_DESC', 20),
        ('BBMNaturalWonderCounts', 'BBM_MAPS_NATURAL_WONDERS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_NATURAL_WONDERS_STANDARD_DESC', 30),
        ('BBMNaturalWonderCounts', 'BBM_MAPS_NATURAL_WONDERS_MORE', 'LOC_BBM_MAPS_MORE_NAME', 'LOC_BBM_MAPS_NATURAL_WONDERS_MORE_DESC', 40),
        ('BBMNaturalWonderCounts', 'BBM_MAPS_NATURAL_WONDERS_DOUBLE', 'LOC_BBM_MAPS_DOUBLE_NAME', 'LOC_BBM_MAPS_NATURAL_WONDERS_DOUBLE_DESC', 50);

--*******************************************************
--***************** NATURAL WONDER SELECTION ************
--*******************************************************
-- One toggle per Natural Wonder; Off keeps it off the map (data/maps/natural-wonders/).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMNaturalWonderBarrierReef', 'LOC_BBM_MAPS_BARRIER_REEF_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderBarrierReef', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 200),
        ('BBMNaturalWonderBermudaTriangle', 'LOC_BBM_MAPS_BERMUDA_TRIANGLE_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderBermudaTriangle', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 210),
        ('BBMNaturalWonderGrandCanyon', 'LOC_BBM_MAPS_GRAND_CANYON_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderGrandCanyon', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 220),
        ('BBMNaturalWonderGreatBlueHole', 'LOC_BBM_MAPS_GREAT_BLUE_HOLE_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderGreatBlueHole', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 230),
        ('BBMNaturalWonderGullfoss', 'LOC_BBM_MAPS_GULLFOSS_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderGullfoss', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 240),
        ('BBMNaturalWonderHoerikwaggo', 'LOC_BBM_MAPS_HOERIKWAGGO_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderHoerikwaggo', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 250),
        ('BBMNaturalWonderIguazuFalls', 'LOC_BBM_MAPS_IGUAZU_FALLS_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderIguazuFalls', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 260),
        ('BBMNaturalWonderKilimanjaro', 'LOC_BBM_MAPS_KILIMANJARO_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderKilimanjaro', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 270),
        ('BBMNaturalWonderMachapuchare', 'LOC_BBM_MAPS_MACHAPUCHARE_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderMachapuchare', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 280),
        ('BBMNaturalWonderMapuAVaeaBlowholes', 'LOC_BBM_MAPS_MAPU_A_VAEA_BLOWHOLES_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderMapuAVaeaBlowholes', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 290),
        ('BBMNaturalWonderMountEverest', 'LOC_BBM_MAPS_MOUNT_EVEREST_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderMountEverest', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 300),
        ('BBMNaturalWonderMountFuji', 'LOC_BBM_MAPS_MOUNT_FUJI_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderMountFuji', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 310),
        ('BBMNaturalWonderNachiFalls', 'LOC_BBM_MAPS_NACHI_FALLS_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderNachiFalls', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 315),
        ('BBMNaturalWonderRedwoodForest', 'LOC_BBM_MAPS_REDWOOD_FOREST_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderRedwoodForest', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 320),
        ('BBMNaturalWonderSeongsanIlchulbong', 'LOC_BBM_MAPS_SEONGSAN_ILCHULBONG_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderSeongsanIlchulbong', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 325),
        ('BBMNaturalWonderThera', 'LOC_BBM_MAPS_THERA_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderThera', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 330),
        ('BBMNaturalWonderTorresDelPaine', 'LOC_BBM_MAPS_TORRES_DEL_PAINE_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderTorresDelPaine', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 340),
        ('BBMNaturalWonderUluru', 'LOC_BBM_MAPS_ULURU_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderUluru', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 350),
        ('BBMNaturalWonderValleyOfFlowers', 'LOC_BBM_MAPS_VALLEY_OF_FLOWERS_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderValleyOfFlowers', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 360),
        ('BBMNaturalWonderVihren', 'LOC_BBM_MAPS_VIHREN_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderVihren', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 370),
        ('BBMNaturalWonderVinicunca', 'LOC_BBM_MAPS_VINICUNCA_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderVinicunca', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 380),
        ('BBMNaturalWonderZhangjiajie', 'LOC_BBM_MAPS_ZHANGJIAJIE_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_DESC', 'BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'Map', 'BBMNaturalWonderZhangjiajie', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 390);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_ON', 'LOC_BBM_ENABLED_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_ON_DESC', 10),
        ('BBMNaturalWonderToggles', 'BBM_MAPS_NATURAL_WONDER_OFF', 'LOC_BBM_DISABLED_NAME', 'LOC_BBM_MAPS_NATURAL_WONDER_OFF_DESC', 20);

--*******************************************************
--***************** TERRAIN *****************************
--*******************************************************
-- Lakes (data/maps/lakes/), Rivers and Mountains (the multiplayer maps' passes,
-- maps/generation/), with Sea Level after them in multiplayer.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMLakes', 'LOC_BBM_MAPS_LAKES_NAME', 'LOC_BBM_MAPS_LAKES_DESC', 'BBMLakeFrequencies', 'BBM_MAPS_LAKES_STANDARD', 'Map', 'BBMLakes', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 0, 150),
        ('BBMMapRivers', 'LOC_BBM_MAPS_RIVERS_NAME', 'LOC_BBM_MAPS_RIVERS_DESC', 'BBMMapRiverOptions', 'BBM_MAPS_RIVERS_STANDARD', 'Map', 'BBMMapRivers', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 0, 151),
        ('BBMMapMountains', 'LOC_BBM_MAPS_MOUNTAINS_NAME', 'LOC_BBM_MAPS_MOUNTAINS_DESC', 'BBMMapMountainOptions', 'BBM_MAPS_MOUNTAINS_STANDARD', 'Map', 'BBMMapMountains', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 0, 152);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMLakeFrequencies', 'BBM_MAPS_LAKES_LESS', 'LOC_BBM_MAPS_LESS_NAME', 'LOC_BBM_MAPS_LAKES_LESS_DESC', 20),
        ('BBMLakeFrequencies', 'BBM_MAPS_LAKES_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_LAKES_STANDARD_DESC', 30),
        ('BBMLakeFrequencies', 'BBM_MAPS_LAKES_MORE', 'LOC_BBM_MAPS_MORE_NAME', 'LOC_BBM_MAPS_LAKES_MORE_DESC', 40),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_WADI', 'LOC_BBM_MAPS_RIVERS_WADI_NAME', 'LOC_BBM_MAPS_RIVERS_WADI_DESC', 10),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_ARID', 'LOC_BBM_MAPS_RIVERS_ARID_NAME', 'LOC_BBM_MAPS_RIVERS_ARID_DESC', 20),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_CHANNEL', 'LOC_BBM_MAPS_RIVERS_CHANNEL_NAME', 'LOC_BBM_MAPS_RIVERS_CHANNEL_DESC', 30),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_SHALLOW', 'LOC_BBM_MAPS_RIVERS_SHALLOW_NAME', 'LOC_BBM_MAPS_RIVERS_SHALLOW_DESC', 40),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_RIVERS_STANDARD_DESC', 50),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_WATERWAY', 'LOC_BBM_MAPS_RIVERS_WATERWAY_NAME', 'LOC_BBM_MAPS_RIVERS_WATERWAY_DESC', 60),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_STREAM', 'LOC_BBM_MAPS_RIVERS_STREAM_NAME', 'LOC_BBM_MAPS_RIVERS_STREAM_DESC', 70),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_RIVERLAND', 'LOC_BBM_MAPS_RIVERS_RIVERLAND_NAME', 'LOC_BBM_MAPS_RIVERS_RIVERLAND_DESC', 80),
        ('BBMMapRiverOptions', 'BBM_MAPS_RIVERS_DEEP', 'LOC_BBM_MAPS_RIVERS_DEEP_NAME', 'LOC_BBM_MAPS_RIVERS_DEEP_DESC', 90),
        ('BBMMapMountainOptions', 'BBM_MAPS_MOUNTAINS_LESS', 'LOC_BBM_MAPS_LESS_NAME', 'LOC_BBM_MAPS_MOUNTAINS_LESS_DESC', 20),
        ('BBMMapMountainOptions', 'BBM_MAPS_MOUNTAINS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_MAPS_MOUNTAINS_STANDARD_DESC', 30),
        ('BBMMapMountainOptions', 'BBM_MAPS_MOUNTAINS_MORE', 'LOC_BBM_MAPS_MORE_NAME', 'LOC_BBM_MAPS_MOUNTAINS_MORE_DESC', 40);

UPDATE Parameters SET GroupIDMultiplayerOverride = 'MPAdvancedTerrainOptions' WHERE ParameterID = 'MapSeaLevel';

-- The game defines Sea Level per map script; Pangaea Ultima and the multiplayer
-- copies of the standard maps that have it (multiplayer only) get the same row,
-- sorted after Mountains.
INSERT OR IGNORE INTO Parameters (Key1, Key2, ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, SortIndex)
    VALUES
        ('Map', '{zatygolds-multiplayer-balance}maps/pangaea-ultima.js', 'MapSeaLevel', 'LOC_MAP_SEA_LEVEL_NAME', 'LOC_MAP_SEA_LEVEL_DESCRIPTION', 'SeaLevels', 'SEA_LEVEL_STANDARD', 'Map', 'SeaLevel', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 153);

INSERT OR IGNORE INTO Parameters (Key1, Key2, ParameterID, Name, Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, GroupID, GroupIDMultiplayerOverride, Hidden, ReadOnly, SupportsSinglePlayer, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, SortIndex)
SELECT Key1, REPLACE(Key2, '{base-standard}maps/', '{zatygolds-multiplayer-balance}maps/standard/'), ParameterID, Name, Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, 'TerrainOptions', 'MPAdvancedTerrainOptions', Hidden, ReadOnly, 0, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, 153
FROM Parameters
WHERE ParameterID = 'MapSeaLevel' AND Key1 = 'Map'
AND Key2 IN (SELECT REPLACE(File, '{zatygolds-multiplayer-balance}maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{zatygolds-multiplayer-balance}maps/standard/%');

--*******************************************************
--***************** MULTIPLAYER ONLY MAPS ***************
--*******************************************************
-- The map list is shared with single player, so this hidden multiplayer-only
-- flag picks each mode's scripts: Pangaea Ultima and the copies of the standard
-- maps are filtered out whenever it is unset (single-player setup), and the base
-- scripts that have a copy whenever it is set (multiplayer setup).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupID, Hidden, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMMultiplayerSetup', 'LOC_BBM_MAPS_MULTIPLAYER_SETUP', 'LOC_BBM_MAPS_MULTIPLAYER_SETUP', 'bool', 0, 1, 'Game', 'BBMMultiplayerSetup', 'GameOptions', 1, 0, 0, 9001);

INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('BBMMultiplayerOnlyMaps', 'DomainValueFilters', 'SELECT Domain, File AS Value, ''Difference'' AS Filter FROM Maps WHERE File LIKE ''{zatygolds-multiplayer-balance}maps/%'''),
        ('BBMSinglePlayerOnlyMaps', 'DomainValueFilters', 'SELECT Domain, REPLACE(File, ''{zatygolds-multiplayer-balance}maps/standard/'', ''{base-standard}maps/'') AS Value, ''Difference'' AS Filter FROM Maps WHERE File LIKE ''{zatygolds-multiplayer-balance}maps/standard/%''');

INSERT OR IGNORE INTO QueryCriteria (QueryID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('BBMMultiplayerOnlyMaps', 'Game', 'BBMMultiplayerSetup', 'NotEquals', 1),
        ('BBMSinglePlayerOnlyMaps', 'Game', 'BBMMultiplayerSetup', 'Equals', 1);
