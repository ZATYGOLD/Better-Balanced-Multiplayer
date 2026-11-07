--*******************************************************
--***************** MATCH TYPE **************************
--*******************************************************
-- One choice that sets a match's map settings (multiplayer only), in Multiplayer
-- Settings on Game Settings, after Hidden Game. The Match Type decides Player
-- Placement (maps/config/map-options.sql keeps it hidden): Free for All places
-- over the whole map and leaves the other settings to the host. Choosing one also
-- returns every other game setting to Standard, on Online speed and the
-- Competitive timer (ui/mp-setup/match-type-rules.js).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTMatchType', 'LOC_MPT_MATCHTYPE_NAME', 'LOC_MPT_MATCHTYPE_DESC', 'MPTMatchTypes', 0, 'MPT_MATCHTYPE_FFA', 'Game', 'MPTMatchType', 'LobbyOptions', 'SimpleSelectWindow', 0, 0, 25);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTMatchTypes', 'MPT_MATCHTYPE_FFA', 'LOC_MPT_MATCHTYPE_FFA_NAME', 'LOC_MPT_MATCHTYPE_FFA_DESC', 0),
        ('MPTMatchTypes', 'MPT_MATCHTYPE_1V1', 'LOC_MPT_MATCHTYPE_1V1_NAME', 'LOC_MPT_MATCHTYPE_1V1_DESC', 10),
        ('MPTMatchTypes', 'MPT_MATCHTYPE_2V2', 'LOC_MPT_MATCHTYPE_2V2_NAME', 'LOC_MPT_MATCHTYPE_2V2_DESC', 20),
        ('MPTMatchTypes', 'MPT_MATCHTYPE_3V3', 'LOC_MPT_MATCHTYPE_3V3_NAME', 'LOC_MPT_MATCHTYPE_3V3_DESC', 30),
        ('MPTMatchTypes', 'MPT_MATCHTYPE_4V4', 'LOC_MPT_MATCHTYPE_4V4_NAME', 'LOC_MPT_MATCHTYPE_4V4_DESC', 40);

-- Player Placement, Start Position, Strict Start Biases and Map Size per Match Type.
INSERT OR IGNORE INTO ConfigurationUpdates (SourceGroup, SourceKey, SourceValue, TargetGroup, TargetKey, TargetValue, Hash)
    VALUES
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_FFA', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_BASE', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_1V1', 'Map', 'StartPosition', 'START_POSITION_BALANCED', 1),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_1V1', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_DUEL', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_1V1', 'Map', 'MPTStrictStartBiases', 'MPT_MAPS_STRICT_BIASES_ON', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_1V1', 'Map', 'SizeType', 'MAPSIZE_TINY', 1),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_1V1', 'Map', 'SizeTypeName', 'MAPSIZE_TINY', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_2V2', 'Map', 'StartPosition', 'START_POSITION_BALANCED', 1),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_2V2', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_2V2', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_2V2', 'Map', 'MPTStrictStartBiases', 'MPT_MAPS_STRICT_BIASES_ON', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_2V2', 'Map', 'SizeType', 'MAPSIZE_TINY', 1),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_2V2', 'Map', 'SizeTypeName', 'MAPSIZE_TINY', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_3V3', 'Map', 'StartPosition', 'START_POSITION_BALANCED', 1),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_3V3', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_3V3', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_3V3', 'Map', 'MPTStrictStartBiases', 'MPT_MAPS_STRICT_BIASES_ON', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_3V3', 'Map', 'SizeType', 'MAPSIZE_SMALL', 1),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_3V3', 'Map', 'SizeTypeName', 'MAPSIZE_SMALL', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_4V4', 'Map', 'StartPosition', 'START_POSITION_BALANCED', 1),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_4V4', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_4V4', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_4V4', 'Map', 'MPTStrictStartBiases', 'MPT_MAPS_STRICT_BIASES_ON', 0),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_4V4', 'Map', 'SizeType', 'MAPSIZE_STANDARD', 1),
        ('Game', 'MPTMatchType', 'MPT_MATCHTYPE_4V4', 'Map', 'SizeTypeName', 'MAPSIZE_STANDARD', 0);
