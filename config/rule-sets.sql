--*******************************************************
--***************** MULTIPLAYER RULE SET ****************
--*******************************************************
-- One choice that sets a match's map settings (multiplayer only). The Rule Set
-- decides Player Placement (maps/config/map-options.sql keeps it hidden): Free
-- for All places over the whole map and leaves the other settings to the host.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTRuleSet', 'LOC_MPT_RULESET_NAME', 'LOC_MPT_RULESET_DESC', 'MPTRuleSets', 0, 'MPT_RULESET_FFA', 'Game', 'MPTRuleSet', 'GameOptions', 'SimpleSelectWindow', 0, 0, 12);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTRuleSets', 'MPT_RULESET_FFA', 'LOC_MPT_RULESET_FFA_NAME', 'LOC_MPT_RULESET_FFA_DESC', 0),
        ('MPTRuleSets', 'MPT_RULESET_1V1', 'LOC_MPT_RULESET_1V1_NAME', 'LOC_MPT_RULESET_1V1_DESC', 10),
        ('MPTRuleSets', 'MPT_RULESET_2V2', 'LOC_MPT_RULESET_2V2_NAME', 'LOC_MPT_RULESET_2V2_DESC', 20),
        ('MPTRuleSets', 'MPT_RULESET_3V3', 'LOC_MPT_RULESET_3V3_NAME', 'LOC_MPT_RULESET_3V3_DESC', 30),
        ('MPTRuleSets', 'MPT_RULESET_4V4', 'LOC_MPT_RULESET_4V4_NAME', 'LOC_MPT_RULESET_4V4_DESC', 40);

-- Player Placement, Start Position, Strict Start Biases and Map Size per Rule Set.
INSERT OR IGNORE INTO ConfigurationUpdates (SourceGroup, SourceKey, SourceValue, TargetGroup, TargetKey, TargetValue, Hash)
    VALUES
        ('Game', 'MPTRuleSet', 'MPT_RULESET_FFA', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_BASE', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_1V1', 'Map', 'StartPosition', 'START_POSITION_BALANCED', 1),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_1V1', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_DUEL', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_1V1', 'Map', 'MPTStrictStartBiases', 'MPT_MAPS_STRICT_BIASES_ON', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_1V1', 'Map', 'SizeType', 'MAPSIZE_TINY', 1),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_1V1', 'Map', 'SizeTypeName', 'MAPSIZE_TINY', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_2V2', 'Map', 'StartPosition', 'START_POSITION_BALANCED', 1),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_2V2', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_2V2', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_2V2', 'Map', 'MPTStrictStartBiases', 'MPT_MAPS_STRICT_BIASES_ON', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_2V2', 'Map', 'SizeType', 'MAPSIZE_TINY', 1),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_2V2', 'Map', 'SizeTypeName', 'MAPSIZE_TINY', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_3V3', 'Map', 'StartPosition', 'START_POSITION_BALANCED', 1),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_3V3', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_3V3', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_3V3', 'Map', 'MPTStrictStartBiases', 'MPT_MAPS_STRICT_BIASES_ON', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_3V3', 'Map', 'SizeType', 'MAPSIZE_SMALL', 1),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_3V3', 'Map', 'SizeTypeName', 'MAPSIZE_SMALL', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_4V4', 'Map', 'StartPosition', 'START_POSITION_BALANCED', 1),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_4V4', 'Map', 'MPTPlayerPlacement', 'MPT_MAPS_PLACEMENT_4V4', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_4V4', 'Map', 'MPTStrictStartBiases', 'MPT_MAPS_STRICT_BIASES_ON', 0),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_4V4', 'Map', 'SizeType', 'MAPSIZE_STANDARD', 1),
        ('Game', 'MPTRuleSet', 'MPT_RULESET_4V4', 'Map', 'SizeTypeName', 'MAPSIZE_STANDARD', 0);
