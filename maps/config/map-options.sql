--*******************************************************
--***************** MAP LIST ****************************
--*******************************************************
-- Pangaea Ultima and the multiplayer copies of the standard maps
-- (maps/maps/standard/, which apply the Map Settings climate and terrain), listed
-- in multiplayer setup only, where the copies replace the base scripts
-- (multiplayer-only.sql). Each copy joins the list as a row of its own with the
-- base map's name, order, start positions and Sea Level dependencies; its Sea
-- Level row is in map-settings.sql.
INSERT OR IGNORE INTO Maps (File, Name, Description, SortIndex)
    VALUES
        ('{multiplayer-toolkit}maps/maps/pangaea-ultima.js', 'LOC_MPT_MAPS_PANGAEA_ULTIMA_NAME', 'LOC_MPT_MAPS_PANGAEA_ULTIMA_DESC', 110);

INSERT OR IGNORE INTO Maps (Domain, File, Name, Description, Image, StaticMap, WorldBuilderOnly, SortIndex)
SELECT Domain, REPLACE(File, '{base-standard}maps/', '{multiplayer-toolkit}maps/maps/standard/'), Name, Description, Image, StaticMap, WorldBuilderOnly, SortIndex
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
SELECT REPLACE(Map, '{base-standard}maps/', '{multiplayer-toolkit}maps/maps/standard/'), PlayerID, Domain, Value
FROM SupportedValuesByMap
WHERE Map IN (SELECT REPLACE(File, '{multiplayer-toolkit}maps/maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{multiplayer-toolkit}maps/maps/standard/%');

INSERT OR IGNORE INTO ParameterDependencies (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
SELECT ParameterID, ConfigurationGroup, ConfigurationKey, Operator, REPLACE(ConfigurationValue, '{base-standard}maps/', '{multiplayer-toolkit}maps/maps/standard/')
FROM ParameterDependencies
WHERE ConfigurationKey = 'MapScript'
AND ConfigurationValue IN (SELECT REPLACE(File, '{multiplayer-toolkit}maps/maps/standard/', '{base-standard}maps/') FROM Maps WHERE File LIKE '{multiplayer-toolkit}maps/maps/standard/%');

--*******************************************************
--***************** MULTIPLAYER DEFAULTS ****************
--*******************************************************
-- Pangaea Ultima is the default multiplayer map (the multiplayer-only Map row). Settings
-- shared with single player (speed, Age length, countdown, size) are set by
-- ui/multiplayer-defaults.js on the multiplayer setup screen.
UPDATE Parameters SET DefaultValue = '{multiplayer-toolkit}maps/maps/pangaea-ultima.js' WHERE ParameterID = 'Map' AND SupportsSinglePlayer = 0;

--*******************************************************
--***************** SPAWN SETTINGS **********************
--*******************************************************
-- A Spawn Settings group before Map Settings on the Map tab
-- (ui/mp-setup/setup-layout.js): the game's multiplayer Start Position row, then
-- Strict Start Biases. Single player keeps Start Position in Map Options.
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('SpawnOptions', 'LOC_GROUPID_MPT_SPAWNOPTIONS');

UPDATE Parameters SET GroupIDMultiplayerOverride = 'SpawnOptions' WHERE ParameterID = 'StartPosition' AND SupportsSinglePlayer = 0;

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, Hash, SupportsSinglePlayer, SortIndex)
    VALUES
        ('MPTStrictStartBiases', 'LOC_MPT_MAPS_STRICT_BIASES_NAME', 'LOC_MPT_MAPS_STRICT_BIASES_DESC', 'MPTStrictStartBiasOptions', 'MPT_MAPS_STRICT_BIASES_ON', 'Map', 'MPTStrictStartBiases', 'SpawnOptions', 'SimpleSelectWindow', 0, 0, 121);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTStrictStartBiasOptions', 'MPT_MAPS_STRICT_BIASES_ON', 'LOC_MPT_MAPS_STRICT_BIASES_ON_NAME', 'LOC_MPT_MAPS_STRICT_BIASES_ON_DESC', 10),
        ('MPTStrictStartBiasOptions', 'MPT_MAPS_STRICT_BIASES_OFF', 'LOC_MPT_MAPS_STRICT_BIASES_OFF_NAME', 'LOC_MPT_MAPS_STRICT_BIASES_OFF_DESC', 20);

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
-- the Toolkit's resource data (modinfo criteria maps-resource-list-all-*). Resource
-- Amount and Clusters apply to either (maps/maps/global-resource-system.js).
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
-- choosing it sets Resource List to Standard (no Toolkit resource data loads).
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
-- next size up (maps/ui/match-slots.js); the map is still built at the chosen size.
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
