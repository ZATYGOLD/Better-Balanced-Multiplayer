--*******************************************************
--***************** PARAMETER GROUPS *******************
--*******************************************************
-- Advanced Settings Pro's groups, so both mods share them and their Map tabs.
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('TerrainOptions', 'LOC_GROUPID_MPT_TERRAINOPTIONS'),
        ('MPAdvancedTerrainOptions', 'LOC_GROUPID_MPT_TERRAINOPTIONS'),
        ('NaturalWonderSelectionOptions', 'LOC_GROUPID_MPT_NATURALWONDERSELECTIONOPTIONS'),
        ('MPAdvancedNaturalWonderSelectionOptions', 'LOC_GROUPID_MPT_NATURALWONDERSELECTIONOPTIONS'),
        ('CrisisOptions', 'LOC_GROUPID_MPT_CRISISOPTIONS');

-- With Crises on Game Settings, the multiplayer disaster group holds only disasters.
UPDATE ParameterGroups SET Name = 'LOC_GROUPID_MPT_DISASTEROPTIONS' WHERE GroupId = 'MPAdvancedDisasterOptions';

--*******************************************************
--***************** DISASTERS **************************
--*******************************************************
-- Replaces Disaster Intensity in multiplayer (hidden there, kept in single player)
-- with Disabled and Custom added; Custom sets each Age (maps/data/disasters/).
INSERT OR IGNORE INTO ParameterDependencies (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES ('DisasterIntensity', 'Game', 'MPTMultiplayerSetup', 'NotEquals', 1);

-- Crises leave the Disaster group in multiplayer for their own group on Game Settings,
-- as in Advanced Settings Pro (a group without the "MPAdvanced" prefix stays there).
UPDATE Parameters SET GroupIDMultiplayerOverride = 'CrisisOptions' WHERE ParameterID = 'Crises';

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTDisasters', 'LOC_MPT_MAPS_DISASTERS_NAME', 'LOC_ADVANCED_OPTIONS_DISASTER_INTENSITY_DESC', 'MPTDisasterFrequencies', 'MPT_MAPS_DISASTERS_LIGHT', 'Map', 'MPTDisasters', 'DisasterOptions', 'MPAdvancedDisasterOptions', 0, 0, 0, 3010),
        ('MPTDisastersAntiquity', 'LOC_AGE_ANTIQUITY_NAME', 'LOC_MPT_MAPS_DISASTERS_AGE_DESC', 'MPTDisasterAgeFrequencies', 'MPT_MAPS_DISASTERS_LIGHT', 'Map', 'MPTDisastersAntiquity', 'DisasterOptions', 'MPAdvancedDisasterOptions', 0, 0, 0, 3011),
        ('MPTDisastersExploration', 'LOC_AGE_EXPLORATION_NAME', 'LOC_MPT_MAPS_DISASTERS_AGE_DESC', 'MPTDisasterAgeFrequencies', 'MPT_MAPS_DISASTERS_LIGHT', 'Map', 'MPTDisastersExploration', 'DisasterOptions', 'MPAdvancedDisasterOptions', 0, 0, 0, 3012),
        ('MPTDisastersModern', 'LOC_AGE_MODERN_NAME', 'LOC_MPT_MAPS_DISASTERS_AGE_DESC', 'MPTDisasterAgeFrequencies', 'MPT_MAPS_DISASTERS_LIGHT', 'Map', 'MPTDisastersModern', 'DisasterOptions', 'MPAdvancedDisasterOptions', 0, 0, 0, 3013);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTDisasterFrequencies', 'MPT_MAPS_DISASTERS_DISABLED', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_MAPS_DISASTERS_DISABLED_DESC', 10),
        ('MPTDisasterFrequencies', 'MPT_MAPS_DISASTERS_LIGHT', 'LOC_ADVANCED_OPTIONS_LIGHT', 'LOC_ADVANCED_OPTIONS_LIGHT_TOOLTIP', 20),
        ('MPTDisasterFrequencies', 'MPT_MAPS_DISASTERS_MODERATE', 'LOC_ADVANCED_OPTIONS_MODERATE', 'LOC_ADVANCED_OPTIONS_MODERATE_TOOLTIP', 30),
        ('MPTDisasterFrequencies', 'MPT_MAPS_DISASTERS_CATASTROPHIC', 'LOC_ADVANCED_OPTIONS_CATASTROPHIC', 'LOC_ADVANCED_OPTIONS_CATASTROPHIC_TOOLTIP', 40),
        ('MPTDisasterFrequencies', 'MPT_MAPS_DISASTERS_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_MAPS_DISASTERS_CUSTOM_DESC', 50),
        ('MPTDisasterAgeFrequencies', 'MPT_MAPS_DISASTERS_DISABLED', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_MAPS_DISASTERS_DISABLED_DESC', 10),
        ('MPTDisasterAgeFrequencies', 'MPT_MAPS_DISASTERS_LIGHT', 'LOC_ADVANCED_OPTIONS_LIGHT', 'LOC_ADVANCED_OPTIONS_LIGHT_TOOLTIP', 20),
        ('MPTDisasterAgeFrequencies', 'MPT_MAPS_DISASTERS_MODERATE', 'LOC_ADVANCED_OPTIONS_MODERATE', 'LOC_ADVANCED_OPTIONS_MODERATE_TOOLTIP', 30),
        ('MPTDisasterAgeFrequencies', 'MPT_MAPS_DISASTERS_CATASTROPHIC', 'LOC_ADVANCED_OPTIONS_CATASTROPHIC', 'LOC_ADVANCED_OPTIONS_CATASTROPHIC_TOOLTIP', 40);

--*******************************************************
--***************** NATURAL WONDERS ********************
--*******************************************************
-- How many Natural Wonders a map places (maps/data/natural-wonders/count-*.sql).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTNaturalWonders', 'LOC_MPT_MAPS_NATURAL_WONDERS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDERS_DESC', 'MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_STANDARD', 'Map', 'MPTNaturalWonders', 'MapOptions', 'MPAdvancedMapOptions', 0, 0, 0, 1034);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_NONE', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_MAPS_NATURAL_WONDERS_NONE_DESC', 10),
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_HALF', 'LOC_MPT_MAPS_HALF_NAME', 'LOC_MPT_MAPS_NATURAL_WONDERS_HALF_DESC', 20),
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_NATURAL_WONDERS_STANDARD_DESC', 30),
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_MORE', 'LOC_MPT_MAPS_MORE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDERS_MORE_DESC', 40),
        ('MPTNaturalWonderCounts', 'MPT_MAPS_NATURAL_WONDERS_DOUBLE', 'LOC_MPT_MAPS_DOUBLE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDERS_DOUBLE_DESC', 50);

--*******************************************************
--***************** NATURAL WONDER SELECTION ***********
--*******************************************************
-- One toggle per Natural Wonder; Off keeps it off the map (maps/data/natural-wonders/).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTNaturalWonderBarrierReef', 'LOC_FEATURE_BARRIER_REEF_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderBarrierReef', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 200),
        ('MPTNaturalWonderBermudaTriangle', 'LOC_FEATURE_BERMUDA_TRIANGLE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderBermudaTriangle', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 210),
        ('MPTNaturalWonderGrandCanyon', 'LOC_FEATURE_GRAND_CANYON_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderGrandCanyon', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 220),
        ('MPTNaturalWonderGreatBlueHole', 'LOC_FEATURE_GREAT_BLUE_HOLE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderGreatBlueHole', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 230),
        ('MPTNaturalWonderGullfoss', 'LOC_FEATURE_GULLFOSS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderGullfoss', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 240),
        ('MPTNaturalWonderHoerikwaggo', 'LOC_FEATURE_HOERIKWAGGO_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderHoerikwaggo', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 250),
        ('MPTNaturalWonderIguazuFalls', 'LOC_FEATURE_IGUAZU_FALLS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderIguazuFalls', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 260),
        ('MPTNaturalWonderKilimanjaro', 'LOC_FEATURE_KILIMANJARO_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderKilimanjaro', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 270),
        ('MPTNaturalWonderMachapuchare', 'LOC_FEATURE_MACHAPUCHARE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderMachapuchare', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 280),
        ('MPTNaturalWonderMapuAVaeaBlowholes', 'LOC_FEATURE_MAPU_A_VAEA_BLOWHOLES_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderMapuAVaeaBlowholes', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 290),
        ('MPTNaturalWonderMountEverest', 'LOC_FEATURE_MOUNT_EVEREST_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderMountEverest', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 300),
        ('MPTNaturalWonderMountFuji', 'LOC_FEATURE_MOUNT_FUJI_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderMountFuji', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 310),
        ('MPTNaturalWonderNachiFalls', 'LOC_FEATURE_NACHI_FALLS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderNachiFalls', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 320),
        ('MPTNaturalWonderRedwoodForest', 'LOC_FEATURE_REDWOOD_FOREST_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderRedwoodForest', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 330),
        ('MPTNaturalWonderSeongsanIlchulbong', 'LOC_FEATURE_SEONGSAN_ILCHULBONG_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderSeongsanIlchulbong', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 340),
        ('MPTNaturalWonderThera', 'LOC_FEATURE_THERA_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderThera', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 350),
        ('MPTNaturalWonderTorresDelPaine', 'LOC_FEATURE_TORRES_DEL_PAINE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderTorresDelPaine', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 360),
        ('MPTNaturalWonderUluru', 'LOC_FEATURE_ULURU_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderUluru', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 370),
        ('MPTNaturalWonderValleyOfFlowers', 'LOC_FEATURE_VALLEY_OF_FLOWERS_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderValleyOfFlowers', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 380),
        ('MPTNaturalWonderVihren', 'LOC_FEATURE_VIHREN_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderVihren', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 390),
        ('MPTNaturalWonderVinicunca', 'LOC_FEATURE_VINICUNCA_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderVinicunca', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 400),
        ('MPTNaturalWonderZhangjiajie', 'LOC_FEATURE_ZHANGJIAJIE_NAME', 'LOC_MPT_MAPS_NATURAL_WONDER_DESC', 'MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'Map', 'MPTNaturalWonderZhangjiajie', 'NaturalWonderSelectionOptions', 'MPAdvancedNaturalWonderSelectionOptions', 0, 0, 0, 410);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_ON', 'LOC_ADVANCED_OPTIONS_ON', 'LOC_MPT_MAPS_NATURAL_WONDER_ON_DESC', 10),
        ('MPTNaturalWonderToggles', 'MPT_MAPS_NATURAL_WONDER_OFF', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_MAPS_NATURAL_WONDER_OFF_DESC', 20);

--*******************************************************
--***************** TERRAIN ****************************
--*******************************************************
-- Lakes (maps/data/lakes/), with Sea Level beside it in multiplayer.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, Hash, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTLakes', 'LOC_MPT_MAPS_LAKES_NAME', 'LOC_MPT_MAPS_LAKES_DESC', 'MPTLakeFrequencies', 'MPT_MAPS_LAKES_STANDARD', 'Map', 'MPTLakes', 'TerrainOptions', 'MPAdvancedTerrainOptions', 0, 0, 0, 150);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTLakeFrequencies', 'MPT_MAPS_LAKES_LESS', 'LOC_MPT_MAPS_LESS_NAME', 'LOC_MPT_MAPS_LAKES_LESS_DESC', 20),
        ('MPTLakeFrequencies', 'MPT_MAPS_LAKES_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_MAPS_LAKES_STANDARD_DESC', 30),
        ('MPTLakeFrequencies', 'MPT_MAPS_LAKES_MORE', 'LOC_MPT_MAPS_MORE_NAME', 'LOC_MPT_MAPS_LAKES_MORE_DESC', 40);

UPDATE Parameters SET GroupIDMultiplayerOverride = 'MPAdvancedTerrainOptions' WHERE ParameterID = 'MapSeaLevel';
