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
        ('{multiplayer-toolkit}maps/pangaea-ultima.js', 'LOC_MPT_MAPS_PANGAEA_ULTIMA_NAME', 'LOC_MPT_MAPS_PANGAEA_ULTIMA_DESC', 110);

INSERT OR IGNORE INTO Maps (Domain, File, Name, Description, Image, StaticMap, WorldBuilderOnly, SortIndex)
SELECT Domain, REPLACE(File, '{base-standard}maps/', '{multiplayer-toolkit}maps/standard/'), Name, Description, Image, StaticMap, WorldBuilderOnly, SortIndex
FROM Maps
WHERE File IN (
    '{base-standard}maps/archipelago.js',
    '{base-standard}maps/archipelago-voronoi.js',
    '{base-standard}maps/continents.js',
    '{base-standard}maps/continents-plus.js',
    '{base-standard}maps/continents-voronoi.js',
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
SELECT REPLACE(Map, '{base-standard}maps/', '{multiplayer-toolkit}maps/standard/'), PlayerID, Domain, Value
FROM SupportedValuesByMap
WHERE Map IN (SELECT REPLACE(File, '{multiplayer-toolkit}maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{multiplayer-toolkit}maps/standard/%');

INSERT OR IGNORE INTO ParameterDependencies (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
SELECT ParameterID, ConfigurationGroup, ConfigurationKey, Operator, REPLACE(ConfigurationValue, '{base-standard}maps/', '{multiplayer-toolkit}maps/standard/')
FROM ParameterDependencies
WHERE ConfigurationKey = 'MapScript'
AND ConfigurationValue IN (SELECT REPLACE(File, '{multiplayer-toolkit}maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{multiplayer-toolkit}maps/standard/%');

--*******************************************************
--***************** MULTIPLAYER DEFAULTS ****************
--*******************************************************
-- Pangaea Ultima is the default multiplayer map (the multiplayer-only Map row). Settings
-- whose row hotseat shares with single player (speed, map) and Map Size are set by
-- ui/maps/multiplayer-defaults.js on the multiplayer setup screen.
UPDATE Parameters SET DefaultValue = '{multiplayer-toolkit}maps/pangaea-ultima.js' WHERE ParameterID = 'Map' AND SupportsSinglePlayer = 0;

--*******************************************************
--***************** SPAWN SETTINGS **********************
--*******************************************************
-- A Spawn Settings group before Map Settings on the Map tab
-- (ui/setup/setup-layout.js): the game's multiplayer Start Position row, then
-- Start Bias: Multiplayer (default) holds supported leaders and civilizations to
-- strict start biases (maps/strict-start-biases.js), Standard keeps the game's
-- own. Single player keeps Start Position in Map Options.
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('SpawnOptions', 'LOC_GROUPID_MPT_SPAWNOPTIONS');

UPDATE Parameters SET GroupIDMultiplayerOverride = 'SpawnOptions' WHERE ParameterID = 'StartPosition' AND SupportsSinglePlayer = 0;

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, Hash, SupportsSinglePlayer, SortIndex)
    VALUES
        ('MPTStartBias', 'LOC_MPT_MAPS_START_BIAS_NAME', 'LOC_MPT_MAPS_START_BIAS_DESC', 'MPTStartBiasOptions', 'MPT_MAPS_START_BIAS_MULTIPLAYER', 'Map', 'MPTStartBias', 'SpawnOptions', 'SimpleSelectWindow', 0, 0, 121);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTStartBiasOptions', 'MPT_MAPS_START_BIAS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_START_BIAS_STANDARD_DESC', 10),
        ('MPTStartBiasOptions', 'MPT_MAPS_START_BIAS_MULTIPLAYER', 'LOC_MPT_MAPS_START_BIAS_MULTIPLAYER_NAME', 'LOC_MPT_MAPS_START_BIAS_MULTIPLAYER_DESC', 20);

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
-- Amount and Clusters apply to either (maps/global-resource-system.js).
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('ResourceOptions', 'LOC_GROUPID_MPT_RESOURCEOPTIONS');

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, Hash, SupportsSinglePlayer, SortIndex)
    VALUES
        ('MPTResourceList', 'LOC_MPT_MAPS_RESOURCE_LIST_NAME', 'LOC_MPT_MAPS_RESOURCE_LIST_DESC', 'MPTResourceLists', 'MPT_MAPS_RESOURCE_LIST_ALL', 'Map', 'MPTResourceList', 'ResourceOptions', 'SimpleSelectWindow', 0, 0, 10),
        ('MPTResourceAmount', 'LOC_MPT_MAPS_RESOURCE_AMOUNT_NAME', 'LOC_MPT_MAPS_RESOURCE_AMOUNT_DESC', 'MPTResourceAmounts', 'MPT_MAPS_RESOURCE_AMOUNT_STANDARD', 'Map', 'MPTResourceAmount', 'ResourceOptions', 'SimpleSelectWindow', 0, 0, 20),
        ('MPTResourceClusters', 'LOC_MPT_MAPS_RESOURCE_CLUSTERS_NAME', 'LOC_MPT_MAPS_RESOURCE_CLUSTERS_DESC', 'MPTResourceClusterOptions', 'MPT_MAPS_RESOURCE_CLUSTERS_OFF', 'Map', 'MPTResourceClusters', 'ResourceOptions', 'SimpleSelectWindow', 0, 0, 30);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTResourceLists', 'MPT_MAPS_RESOURCE_LIST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_RESOURCE_LIST_STANDARD_DESC', 10),
        ('MPTResourceLists', 'MPT_MAPS_RESOURCE_LIST_ALL', 'LOC_MPT_MAPS_RESOURCE_LIST_ALL_NAME', 'LOC_MPT_MAPS_RESOURCE_LIST_ALL_DESC', 20),
        ('MPTResourceAmounts', 'MPT_MAPS_RESOURCE_AMOUNT_SCARCE', 'LOC_MPT_MAPS_RESOURCE_AMOUNT_SCARCE_NAME', 'LOC_MPT_MAPS_RESOURCE_AMOUNT_SCARCE_DESC', 10),
        ('MPTResourceAmounts', 'MPT_MAPS_RESOURCE_AMOUNT_SPARSE', 'LOC_ADVANCED_OPTIONS_SPARSE', 'LOC_MPT_MAPS_RESOURCE_AMOUNT_SPARSE_DESC', 20),
        ('MPTResourceAmounts', 'MPT_MAPS_RESOURCE_AMOUNT_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_RESOURCE_AMOUNT_STANDARD_DESC', 30),
        ('MPTResourceAmounts', 'MPT_MAPS_RESOURCE_AMOUNT_ABUNDANT', 'LOC_ADVANCED_OPTIONS_ABUNDANT', 'LOC_MPT_MAPS_RESOURCE_AMOUNT_ABUNDANT_DESC', 40),
        ('MPTResourceClusterOptions', 'MPT_MAPS_RESOURCE_CLUSTERS_OFF', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_MAPS_RESOURCE_CLUSTERS_OFF_DESC', 10),
        ('MPTResourceClusterOptions', 'MPT_MAPS_RESOURCE_CLUSTERS_SMALL', 'LOC_MPT_MAPS_RESOURCE_CLUSTERS_SMALL_NAME', 'LOC_MPT_MAPS_RESOURCE_CLUSTERS_SMALL_DESC', 20),
        ('MPTResourceClusterOptions', 'MPT_MAPS_RESOURCE_CLUSTERS_LARGE', 'LOC_MPT_MAPS_RESOURCE_CLUSTERS_LARGE_NAME', 'LOC_MPT_MAPS_RESOURCE_CLUSTERS_LARGE_DESC', 30);

-- The Earth map keeps the game's resources: Resource Settings hide there and
-- choosing it sets Resource List to Standard (no mod resource data loads).
INSERT OR IGNORE INTO ParameterDependencies (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('MPTResourceList', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge.Civ7Map'),
        ('MPTResourceAmount', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge.Civ7Map'),
        ('MPTResourceClusters', 'Map', 'MapScript', 'NotEquals', '{base-standard}maps/EarthMaps/Earth_Huge.Civ7Map');

INSERT OR IGNORE INTO ConfigurationUpdates (SourceGroup, SourceKey, SourceValue, TargetGroup, TargetKey, TargetValue, Hash)
    VALUES
        ('Map', 'Script', '{base-standard}maps/EarthMaps/Earth_Huge.Civ7Map', 'Map', 'MPTResourceList', 'MPT_MAPS_RESOURCE_LIST_STANDARD', 0);

--*******************************************************
--***************** PLAYER PLACEMENT ********************
--*******************************************************
-- Hidden: set by the Match Type (config/match-types.sql).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hidden, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTPlayerPlacement', 'LOC_MPT_MAPS_PLAYER_PLACEMENT_NAME', 'LOC_MPT_MAPS_PLAYER_PLACEMENT_DESC', 'MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_BASE', 'Map', 'MPTPlayerPlacement', 'MapOptions', 1, 0, 0, 0, 9001);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_BASE', 'LOC_MPT_MAPS_PLACEMENT_BASE_NAME', 'LOC_MPT_MAPS_PLACEMENT_BASE_DESC', 10),
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_DUEL', 'LOC_MPT_MAPS_PLACEMENT_DUEL_NAME', 'LOC_MPT_MAPS_PLACEMENT_DUEL_DESC', 20),
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_2V2', 'LOC_MPT_MAPS_PLACEMENT_2V2_NAME', 'LOC_MPT_MAPS_PLACEMENT_2V2_DESC', 30),
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_3V3', 'LOC_MPT_MAPS_PLACEMENT_3V3_NAME', 'LOC_MPT_MAPS_PLACEMENT_3V3_DESC', 40),
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_4V4', 'LOC_MPT_MAPS_PLACEMENT_4V4_NAME', 'LOC_MPT_MAPS_PLACEMENT_4V4_DESC', 50);

--*******************************************************
--***************** CHOSEN MAP SIZE *********************
--*******************************************************
-- Hidden: the size the lobby chose when a Spectator slot made the host launch the
-- next size up (ui/maps/match-slots.js); the map is still built at the chosen size.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hidden, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTChosenMapSize', 'LOC_MPT_MAPS_CHOSEN_MAP_SIZE', 'LOC_MPT_MAPS_CHOSEN_MAP_SIZE', 'MPTChosenMapSizes', 'MPT_MAPS_CHOSEN_SIZE_NONE', 'Map', 'MPTChosenMapSize', 'MapOptions', 1, 0, 0, 0, 9002);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTChosenMapSizes', 'MPT_MAPS_CHOSEN_SIZE_NONE', 'LOC_MPT_MAPS_CHOSEN_MAP_SIZE', 'LOC_MPT_MAPS_CHOSEN_MAP_SIZE', 10),
        ('MPTChosenMapSizes', 'MAPSIZE_TINY', 'LOC_MAPSIZE_TINY_NAME', 'LOC_MAPSIZE_TINY_DESCRIPTION', 20),
        ('MPTChosenMapSizes', 'MAPSIZE_SMALL', 'LOC_MAPSIZE_SMALL_NAME', 'LOC_MAPSIZE_SMALL_DESCRIPTION', 30);

--*******************************************************
--***************** SPECTATOR SLOT **********************
--*******************************************************
-- Hidden: the lobby slot kept for Zatygold's Spectator in team matches (-1: none);
-- the Spectator makes the player in it the Observer.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hidden, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTSpectatorSlot', 'LOC_MPT_MAPS_SPECTATOR_SLOT', 'LOC_MPT_MAPS_SPECTATOR_SLOT', 'int', -1, 'Game', 'MPTSpectatorSlot', 'GameOptions', 1, 0, 0, 0, 9003);

--*******************************************************
--***************** PARAMETER GROUPS ********************
--*******************************************************
-- The Map tab's Terrain and Natural Wonder Selection groups
-- (ui/setup/setup-layout.js).
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
-- biome, feature and snow passes of the multiplayer maps (maps/generation/).
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
-- How many Natural Wonders a map places (data/maps/natural-wonders/count-*.sql), in Map Settings.
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
-- One toggle per Natural Wonder; Off keeps it off the map (data/maps/natural-wonders/).
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
-- Lakes (data/maps/lakes/), Rivers and Mountains (the multiplayer maps' passes,
-- maps/generation/), with Sea Level after them in multiplayer.
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
        ('Map', '{multiplayer-toolkit}maps/pangaea-ultima.js', 'MapSeaLevel', 'LOC_MAP_SEA_LEVEL_NAME', 'LOC_MAP_SEA_LEVEL_DESCRIPTION', 'SeaLevels', 'SEA_LEVEL_STANDARD', 'Map', 'SeaLevel', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 153);

INSERT OR IGNORE INTO Parameters (Key1, Key2, ParameterID, Name, Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, GroupID, GroupIDMultiplayerOverride, Hidden, ReadOnly, SupportsSinglePlayer, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, SortIndex)
SELECT Key1, REPLACE(Key2, '{base-standard}maps/', '{multiplayer-toolkit}maps/standard/'), ParameterID, Name, Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, 'TerrainOptions', 'MPAdvancedTerrainOptions', Hidden, ReadOnly, 0, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, 153
FROM Parameters
WHERE ParameterID = 'MapSeaLevel' AND Key1 = 'Map'
AND Key2 IN (SELECT REPLACE(File, '{multiplayer-toolkit}maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{multiplayer-toolkit}maps/standard/%');

--*******************************************************
--***************** MULTIPLAYER ONLY MAPS ***************
--*******************************************************
-- The map list is shared with single player, so this hidden multiplayer-only
-- flag picks each mode's scripts: Pangaea Ultima and the copies of the standard
-- maps are filtered out whenever it is unset (single-player setup), and the base
-- scripts that have a copy whenever it is set (multiplayer setup).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupID, Hidden, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTMultiplayerSetup', 'LOC_MPT_MAPS_MULTIPLAYER_SETUP', 'LOC_MPT_MAPS_MULTIPLAYER_SETUP', 'bool', 0, 1, 'Game', 'MPTMultiplayerSetup', 'GameOptions', 1, 0, 0, 9001);

INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('MPTMultiplayerOnlyMaps', 'DomainValueFilters', 'SELECT Domain, File AS Value, ''Difference'' AS Filter FROM Maps WHERE File LIKE ''{multiplayer-toolkit}maps/%'''),
        ('MPTSinglePlayerOnlyMaps', 'DomainValueFilters', 'SELECT Domain, REPLACE(File, ''{multiplayer-toolkit}maps/standard/'', ''{base-standard}maps/'') AS Value, ''Difference'' AS Filter FROM Maps WHERE File LIKE ''{multiplayer-toolkit}maps/standard/%''');

INSERT OR IGNORE INTO QueryCriteria (QueryID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('MPTMultiplayerOnlyMaps', 'Game', 'MPTMultiplayerSetup', 'NotEquals', 1),
        ('MPTSinglePlayerOnlyMaps', 'Game', 'MPTMultiplayerSetup', 'Equals', 1);
