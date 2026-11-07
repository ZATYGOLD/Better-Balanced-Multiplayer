--*******************************************************
--***************** MAP LIST ****************************
--*******************************************************
-- Pangaea Ultima, listed in multiplayer setup only (multiplayer-only.sql).
INSERT OR IGNORE INTO Maps (File, Name, Description, SortIndex)
    VALUES
        ('{multiplayer-toolkit}maps/maps/pangaea-ultima.js', 'LOC_MPT_MAPS_PANGAEA_ULTIMA_NAME', 'LOC_MPT_MAPS_PANGAEA_ULTIMA_DESC', 110);

--*******************************************************
--***************** MULTIPLAYER DEFAULTS ****************
--*******************************************************
-- Pangaea Ultima is the default multiplayer map (the multiplayer-only Map row). Settings
-- shared with single player (speed, Age length, countdown, size) are set by
-- ui/multiplayer-defaults.js on the multiplayer setup screen.
UPDATE Parameters SET DefaultValue = '{multiplayer-toolkit}maps/maps/pangaea-ultima.js' WHERE ParameterID = 'Map' AND SupportsSinglePlayer = 0;

--*******************************************************
--***************** MAP SETTINGS ************************
--*******************************************************
-- Map Settings join the base Map Options group, so Advanced Settings' Map tab shows them.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, Hash, SupportsSinglePlayer, SortIndex)
    VALUES
        ('MPTStrictStartBiases', 'LOC_MPT_MAPS_STRICT_BIASES_NAME', 'LOC_MPT_MAPS_STRICT_BIASES_DESC', 'MPTStrictStartBiasOptions', 'MPT_MAPS_STRICT_BIASES_ON', 'Map', 'MPTStrictStartBiases', 'MapOptions', 'SimpleSelectWindow', 0, 0, 126),
        ('MPTResourceSystem', 'LOC_MPT_MAPS_RESOURCE_SYSTEM_NAME', 'LOC_MPT_MAPS_RESOURCE_SYSTEM_DESC', 'MPTResourceSystemOptions', 'MPT_MAPS_RESOURCE_SYSTEM_ON', 'Map', 'MPTResourceSystem', 'MapOptions', 'SimpleSelectWindow', 0, 0, 127);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_BASE', 'LOC_MPT_MAPS_PLACEMENT_BASE_NAME', 'LOC_MPT_MAPS_PLACEMENT_BASE_DESC', 10),
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_DUEL', 'LOC_MPT_MAPS_PLACEMENT_DUEL_NAME', 'LOC_MPT_MAPS_PLACEMENT_DUEL_DESC', 20),
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_2V2', 'LOC_MPT_MAPS_PLACEMENT_2V2_NAME', 'LOC_MPT_MAPS_PLACEMENT_2V2_DESC', 30),
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_3V3', 'LOC_MPT_MAPS_PLACEMENT_3V3_NAME', 'LOC_MPT_MAPS_PLACEMENT_3V3_DESC', 40),
        ('MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_4V4', 'LOC_MPT_MAPS_PLACEMENT_4V4_NAME', 'LOC_MPT_MAPS_PLACEMENT_4V4_DESC', 50),
        ('MPTStrictStartBiasOptions', 'MPT_MAPS_STRICT_BIASES_ON', 'LOC_MPT_MAPS_STRICT_BIASES_ON_NAME', 'LOC_MPT_MAPS_STRICT_BIASES_ON_DESC', 10),
        ('MPTStrictStartBiasOptions', 'MPT_MAPS_STRICT_BIASES_OFF', 'LOC_MPT_MAPS_STRICT_BIASES_OFF_NAME', 'LOC_MPT_MAPS_STRICT_BIASES_OFF_DESC', 20),
        ('MPTResourceSystemOptions', 'MPT_MAPS_RESOURCE_SYSTEM_ON', 'LOC_MPT_MAPS_RESOURCE_SYSTEM_ON_NAME', 'LOC_MPT_MAPS_RESOURCE_SYSTEM_ON_DESC', 10),
        ('MPTResourceSystemOptions', 'MPT_MAPS_RESOURCE_SYSTEM_OFF', 'LOC_MPT_MAPS_RESOURCE_SYSTEM_OFF_NAME', 'LOC_MPT_MAPS_RESOURCE_SYSTEM_OFF_DESC', 20);

--*******************************************************
--***************** PLAYER PLACEMENT ********************
--*******************************************************
-- Hidden: set by the Multiplayer Rule Set (config/rule-sets.sql).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, Hidden, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTPlayerPlacement', 'LOC_MPT_MAPS_PLAYER_PLACEMENT_NAME', 'LOC_MPT_MAPS_PLAYER_PLACEMENT_DESC', 'MPTPlayerPlacements', 'MPT_MAPS_PLACEMENT_BASE', 'Map', 'MPTPlayerPlacement', 'MapOptions', 1, 0, 0, 0, 9001);

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
