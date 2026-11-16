--*******************************************************
--***************** PARAMETER GROUPS ********************
--*******************************************************
-- The Pace tab's groups (ui/setup/bbm-setup-layout.js).
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('GamePacingOptions', 'LOC_GROUPID_BBM_GAMEPACINGOPTIONS'),
        ('MPAdvancedGamePacingOptions', 'LOC_GROUPID_BBM_GAMEPACINGOPTIONS'),
        ('PacingAntiquityOptions', 'LOC_AGE_ANTIQUITY_NAME'),
        ('MPAdvancedPacingAntiquityOptions', 'LOC_AGE_ANTIQUITY_NAME'),
        ('PacingExplorationOptions', 'LOC_AGE_EXPLORATION_NAME'),
        ('MPAdvancedPacingExplorationOptions', 'LOC_AGE_EXPLORATION_NAME'),
        ('PacingModernOptions', 'LOC_AGE_MODERN_NAME'),
        ('MPAdvancedPacingModernOptions', 'LOC_AGE_MODERN_NAME');

--*******************************************************
--***************** PACE SET ****************************
--*******************************************************
-- Preset selector on Game Settings, mirrored at the top of Pace Settings on the
-- Pace tab. A preset sets every Pace Setting; changing one afterwards switches
-- it to Custom (ui/pace/bbm-pace-rules.js).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMPacePreset', 'LOC_BBM_PACE_PRESET_NAME', 'LOC_BBM_PACE_PRESET_DESC', 'BBMPacePresets', 0, 'BBM_PACE_PRESET_MULTIPLAYER', 'Game', 'BBMPacePreset', 'GameOptions', NULL, 0, 0, 15),
        ('BBMPaceSetMirror', 'LOC_BBM_PACE_PRESET_NAME', 'LOC_BBM_PACE_PRESET_DESC', 'BBMPacePresets', 0, 'BBM_PACE_PRESET_MULTIPLAYER', 'Game', 'BBMPaceSetMirror', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 28);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMPacePresets', 'BBM_PACE_PRESET_STANDARD', 'LOC_BBM_PACE_PRESET_STANDARD_NAME', 'LOC_BBM_PACE_PRESET_STANDARD_DESC', 10),
        ('BBMPacePresets', 'BBM_PACE_PRESET_BALANCED', 'LOC_BBM_PACE_PRESET_BALANCED_NAME', 'LOC_BBM_PACE_PRESET_BALANCED_DESC', 20),
        ('BBMPacePresets', 'BBM_PACE_PRESET_MULTIPLAYER', 'LOC_BBM_PACE_PRESET_MULTIPLAYER_NAME', 'LOC_BBM_PACE_PRESET_MULTIPLAYER_DESC', 30),
        ('BBMPacePresets', 'BBM_PACE_PRESET_CUSTOM', 'LOC_BBM_PACE_PRESET_CUSTOM_NAME', 'LOC_BBM_PACE_PRESET_CUSTOM_DESC', 40);

--*******************************************************
--***************** PACE SETTINGS ***********************
--*******************************************************
-- All Ages (Pace Settings) holds each setting; the Antiquity, Exploration and
-- Modern groups hold its per-Age rows, which ui/pace/bbm-pace-rules.js keeps on the
-- setting's values (Custom leaves them to the host). The per-Age rows are what
-- the game data reads (data/pace/), one file per Age and value.

-- Age Length is the mod's own in multiplayer: the base setting is hidden
-- there, and every option sets the same points for each base length.
INSERT OR IGNORE INTO ParameterDependencies (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('AgeLength', 'Game', 'BBMMultiplayerSetup', 'NotEquals', 1);

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMPaceAgeLength', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH_DESC', 'BBMPaceAgeLengthValues', 0, 'BBM_PACE_AGE_LENGTH_STANDARD', 'Game', 'BBMPaceAgeLength', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 30),
        ('BBMPaceAgeProgression', 'LOC_BBM_PACE_AGE_PROGRESSION_NAME', 'LOC_BBM_PACE_AGE_PROGRESSION_DESC', 'BBMPaceAgeProgressionValues', 0, 'BBM_PACE_AGE_PROGRESSION_STANDARD', 'Game', 'BBMPaceAgeProgression', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 32),
        ('BBMPaceTechnologyCost', 'LOC_BBM_PACE_TECHNOLOGY_COST_NAME', 'LOC_BBM_PACE_TECHNOLOGY_COST_DESC', 'BBMPaceTechnologyCostValues', 0, 'BBM_PACE_TECHNOLOGY_COST_STANDARD', 'Game', 'BBMPaceTechnologyCost', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 36),
        ('BBMPaceCivicCost', 'LOC_BBM_PACE_CIVIC_COST_NAME', 'LOC_BBM_PACE_CIVIC_COST_DESC', 'BBMPaceCivicCostValues', 0, 'BBM_PACE_CIVIC_COST_STANDARD', 'Game', 'BBMPaceCivicCost', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 40),
        ('BBMPaceBuildingCost', 'LOC_BBM_PACE_BUILDING_COST_NAME', 'LOC_BBM_PACE_BUILDING_COST_DESC', 'BBMPaceBuildingCostValues', 0, 'BBM_PACE_BUILDING_COST_STANDARD', 'Game', 'BBMPaceBuildingCost', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 42),
        ('BBMPaceVictoryProjectCost', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_NAME', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_DESC', 'BBMPaceVictoryProjectCostValues', 0, 'BBM_PACE_VICTORY_PROJECT_COST_STANDARD', 'Game', 'BBMPaceVictoryProjectCost', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 44),
        ('BBMPaceSettlementGrowth', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_NAME', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_DESC', 'BBMPaceSettlementGrowthValues', 0, 'BBM_PACE_SETTLEMENT_GROWTH_STANDARD', 'Game', 'BBMPaceSettlementGrowth', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 46),
        ('BBMPaceRoadSpeed', 'LOC_BBM_PACE_ROAD_SPEED_NAME', 'LOC_BBM_PACE_ROAD_SPEED_DESC', 'BBMPaceRoadSpeedValues', 0, 'BBM_PACE_ROAD_SPEED_STANDARD', 'Game', 'BBMPaceRoadSpeed', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 48),
        ('BBMPaceTradeSpeed', 'LOC_BBM_PACE_TRADE_SPEED_NAME', 'LOC_BBM_PACE_TRADE_SPEED_DESC', 'BBMPaceTradeSpeedValues', 0, 'BBM_PACE_TRADE_SPEED_INSTANT', 'Game', 'BBMPaceTradeSpeed', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 50),
        ('BBMPaceRazeSpeed', 'LOC_BBM_PACE_RAZE_SPEED_NAME', 'LOC_BBM_PACE_RAZE_SPEED_DESC', 'BBMPaceRazeSpeedValues', 0, 'BBM_PACE_RAZE_SPEED_STANDARD', 'Game', 'BBMPaceRazeSpeed', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 52),
        ('BBMPaceAgeLengthAntiquity', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceAgeLengthAgeValues', 0, 'BBM_PACE_AGE_LENGTH_140', 'Game', 'BBMPaceAgeLengthAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 100),
        ('BBMPaceAgeProgressionAntiquity', 'LOC_BBM_PACE_AGE_PROGRESSION_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceAgeProgressionAgeValues', 0, 'BBM_PACE_AGE_PROGRESSION_STANDARD', 'Game', 'BBMPaceAgeProgressionAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 101),
        ('BBMPaceTechnologyCostAntiquity', 'LOC_BBM_PACE_TECHNOLOGY_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceTechnologyCostAgeValues', 0, 'BBM_PACE_TECHNOLOGY_COST_STANDARD', 'Game', 'BBMPaceTechnologyCostAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 102),
        ('BBMPaceCivicCostAntiquity', 'LOC_BBM_PACE_CIVIC_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceCivicCostAgeValues', 0, 'BBM_PACE_CIVIC_COST_STANDARD', 'Game', 'BBMPaceCivicCostAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 103),
        ('BBMPaceBuildingCostAntiquity', 'LOC_BBM_PACE_BUILDING_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceBuildingCostAgeValues', 0, 'BBM_PACE_BUILDING_COST_STANDARD', 'Game', 'BBMPaceBuildingCostAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 104),
        ('BBMPaceVictoryProjectCostAntiquity', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceVictoryProjectCostAgeValues', 0, 'BBM_PACE_VICTORY_PROJECT_COST_STANDARD', 'Game', 'BBMPaceVictoryProjectCostAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 105),
        ('BBMPaceSettlementGrowthAntiquity', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceSettlementGrowthAgeValues', 0, 'BBM_PACE_SETTLEMENT_GROWTH_STANDARD', 'Game', 'BBMPaceSettlementGrowthAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 106),
        ('BBMPaceRoadSpeedAntiquity', 'LOC_BBM_PACE_ROAD_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceRoadSpeedAgeValues', 0, 'BBM_PACE_ROAD_SPEED_STANDARD', 'Game', 'BBMPaceRoadSpeedAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 107),
        ('BBMPaceTradeSpeedAntiquity', 'LOC_BBM_PACE_TRADE_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceTradeSpeedAgeValues', 0, 'BBM_PACE_TRADE_SPEED_INSTANT', 'Game', 'BBMPaceTradeSpeedAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 108),
        ('BBMPaceRazeSpeedAntiquity', 'LOC_BBM_PACE_RAZE_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceRazeSpeedAgeValues', 0, 'BBM_PACE_RAZE_SPEED_STANDARD', 'Game', 'BBMPaceRazeSpeedAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 109),
        ('BBMPaceAgeLengthExploration', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceAgeLengthAgeValues', 0, 'BBM_PACE_AGE_LENGTH_140', 'Game', 'BBMPaceAgeLengthExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 110),
        ('BBMPaceAgeProgressionExploration', 'LOC_BBM_PACE_AGE_PROGRESSION_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceAgeProgressionAgeValues', 0, 'BBM_PACE_AGE_PROGRESSION_STANDARD', 'Game', 'BBMPaceAgeProgressionExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 111),
        ('BBMPaceTechnologyCostExploration', 'LOC_BBM_PACE_TECHNOLOGY_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceTechnologyCostAgeValues', 0, 'BBM_PACE_TECHNOLOGY_COST_STANDARD', 'Game', 'BBMPaceTechnologyCostExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 112),
        ('BBMPaceCivicCostExploration', 'LOC_BBM_PACE_CIVIC_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceCivicCostAgeValues', 0, 'BBM_PACE_CIVIC_COST_STANDARD', 'Game', 'BBMPaceCivicCostExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 113),
        ('BBMPaceBuildingCostExploration', 'LOC_BBM_PACE_BUILDING_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceBuildingCostAgeValues', 0, 'BBM_PACE_BUILDING_COST_STANDARD', 'Game', 'BBMPaceBuildingCostExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 114),
        ('BBMPaceVictoryProjectCostExploration', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceVictoryProjectCostAgeValues', 0, 'BBM_PACE_VICTORY_PROJECT_COST_STANDARD', 'Game', 'BBMPaceVictoryProjectCostExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 115),
        ('BBMPaceSettlementGrowthExploration', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceSettlementGrowthAgeValues', 0, 'BBM_PACE_SETTLEMENT_GROWTH_STANDARD', 'Game', 'BBMPaceSettlementGrowthExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 116),
        ('BBMPaceRoadSpeedExploration', 'LOC_BBM_PACE_ROAD_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceRoadSpeedAgeValues', 0, 'BBM_PACE_ROAD_SPEED_STANDARD', 'Game', 'BBMPaceRoadSpeedExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 117),
        ('BBMPaceTradeSpeedExploration', 'LOC_BBM_PACE_TRADE_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceTradeSpeedAgeValues', 0, 'BBM_PACE_TRADE_SPEED_INSTANT', 'Game', 'BBMPaceTradeSpeedExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 118),
        ('BBMPaceRazeSpeedExploration', 'LOC_BBM_PACE_RAZE_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceRazeSpeedAgeValues', 0, 'BBM_PACE_RAZE_SPEED_STANDARD', 'Game', 'BBMPaceRazeSpeedExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 119),
        ('BBMPaceAgeLengthModern', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceAgeLengthAgeValues', 0, 'BBM_PACE_AGE_LENGTH_140', 'Game', 'BBMPaceAgeLengthModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 120),
        ('BBMPaceAgeProgressionModern', 'LOC_BBM_PACE_AGE_PROGRESSION_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceAgeProgressionAgeValues', 0, 'BBM_PACE_AGE_PROGRESSION_STANDARD', 'Game', 'BBMPaceAgeProgressionModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 121),
        ('BBMPaceTechnologyCostModern', 'LOC_BBM_PACE_TECHNOLOGY_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceTechnologyCostAgeValues', 0, 'BBM_PACE_TECHNOLOGY_COST_STANDARD', 'Game', 'BBMPaceTechnologyCostModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 122),
        ('BBMPaceCivicCostModern', 'LOC_BBM_PACE_CIVIC_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceCivicCostAgeValues', 0, 'BBM_PACE_CIVIC_COST_STANDARD', 'Game', 'BBMPaceCivicCostModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 123),
        ('BBMPaceBuildingCostModern', 'LOC_BBM_PACE_BUILDING_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceBuildingCostAgeValues', 0, 'BBM_PACE_BUILDING_COST_STANDARD', 'Game', 'BBMPaceBuildingCostModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 124),
        ('BBMPaceVictoryProjectCostModern', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceVictoryProjectCostAgeValues', 0, 'BBM_PACE_VICTORY_PROJECT_COST_STANDARD', 'Game', 'BBMPaceVictoryProjectCostModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 125),
        ('BBMPaceSettlementGrowthModern', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceSettlementGrowthAgeValues', 0, 'BBM_PACE_SETTLEMENT_GROWTH_STANDARD', 'Game', 'BBMPaceSettlementGrowthModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 126),
        ('BBMPaceRoadSpeedModern', 'LOC_BBM_PACE_ROAD_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceRoadSpeedAgeValues', 0, 'BBM_PACE_ROAD_SPEED_STANDARD', 'Game', 'BBMPaceRoadSpeedModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 127),
        ('BBMPaceTradeSpeedModern', 'LOC_BBM_PACE_TRADE_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceTradeSpeedAgeValues', 0, 'BBM_PACE_TRADE_SPEED_INSTANT', 'Game', 'BBMPaceTradeSpeedModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 128),
        ('BBMPaceRazeSpeedModern', 'LOC_BBM_PACE_RAZE_SPEED_NAME', 'LOC_BBM_PACE_AGE_DESC', 'BBMPaceRazeSpeedAgeValues', 0, 'BBM_PACE_RAZE_SPEED_STANDARD', 'Game', 'BBMPaceRazeSpeedModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 129);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMPaceAgeLengthValues', 'BBM_PACE_AGE_LENGTH_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_AGE_LENGTH_SWIFT_DESC', 7),
        ('BBMPaceAgeLengthValues', 'BBM_PACE_AGE_LENGTH_ABBREVIATED', 'LOC_ADVANCED_OPTIONS_ABBREVIATED', 'LOC_BBM_PACE_AGE_LENGTH_ABBREVIATED_DESC', 10),
        ('BBMPaceAgeLengthValues', 'BBM_PACE_AGE_LENGTH_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_AGE_LENGTH_STANDARD_DESC', 20),
        ('BBMPaceAgeLengthValues', 'BBM_PACE_AGE_LENGTH_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_AGE_LENGTH_CUSTOM_DESC', 40),
        ('BBMPaceAgeLengthAgeValues', 'BBM_PACE_AGE_LENGTH_90', 'LOC_BBM_PACE_POINTS_90', 'LOC_BBM_PACE_AGE_LENGTH_90_DESC', 10),
        ('BBMPaceAgeLengthAgeValues', 'BBM_PACE_AGE_LENGTH_100', 'LOC_BBM_PACE_POINTS_100', 'LOC_BBM_PACE_AGE_LENGTH_100_DESC', 20),
        ('BBMPaceAgeLengthAgeValues', 'BBM_PACE_AGE_LENGTH_110', 'LOC_BBM_PACE_POINTS_110', 'LOC_BBM_PACE_AGE_LENGTH_110_DESC', 30),
        ('BBMPaceAgeLengthAgeValues', 'BBM_PACE_AGE_LENGTH_120', 'LOC_BBM_PACE_POINTS_120', 'LOC_BBM_PACE_AGE_LENGTH_120_DESC', 40),
        ('BBMPaceAgeLengthAgeValues', 'BBM_PACE_AGE_LENGTH_130', 'LOC_BBM_PACE_POINTS_130', 'LOC_BBM_PACE_AGE_LENGTH_130_DESC', 50),
        ('BBMPaceAgeLengthAgeValues', 'BBM_PACE_AGE_LENGTH_140', 'LOC_BBM_PACE_POINTS_140', 'LOC_BBM_PACE_AGE_LENGTH_140_DESC', 60),
        ('BBMPaceAgeProgressionValues', 'BBM_PACE_AGE_PROGRESSION_SLOW', 'LOC_BBM_PACE_SLOW_NAME', 'LOC_BBM_PACE_AGE_PROGRESSION_SLOW_DESC', 10),
        ('BBMPaceAgeProgressionValues', 'BBM_PACE_AGE_PROGRESSION_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_AGE_PROGRESSION_STANDARD_DESC', 20),
        ('BBMPaceAgeProgressionValues', 'BBM_PACE_AGE_PROGRESSION_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_AGE_PROGRESSION_BALANCED_DESC', 30),
        ('BBMPaceAgeProgressionValues', 'BBM_PACE_AGE_PROGRESSION_FAST', 'LOC_BBM_PACE_FAST_NAME', 'LOC_BBM_PACE_AGE_PROGRESSION_FAST_DESC', 40),
        ('BBMPaceAgeProgressionValues', 'BBM_PACE_AGE_PROGRESSION_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 50),
        ('BBMPaceAgeProgressionAgeValues', 'BBM_PACE_AGE_PROGRESSION_SLOW', 'LOC_BBM_PACE_SLOW_NAME', 'LOC_BBM_PACE_AGE_PROGRESSION_AGE_SLOW_DESC', 10),
        ('BBMPaceAgeProgressionAgeValues', 'BBM_PACE_AGE_PROGRESSION_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_AGE_PROGRESSION_AGE_STANDARD_DESC', 20),
        ('BBMPaceAgeProgressionAgeValues', 'BBM_PACE_AGE_PROGRESSION_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_AGE_PROGRESSION_AGE_BALANCED_DESC', 30),
        ('BBMPaceAgeProgressionAgeValues', 'BBM_PACE_AGE_PROGRESSION_FAST', 'LOC_BBM_PACE_FAST_NAME', 'LOC_BBM_PACE_AGE_PROGRESSION_AGE_FAST_DESC', 40),
        ('BBMPaceTechnologyCostValues', 'BBM_PACE_TECHNOLOGY_COST_LOW', 'LOC_BBM_PACE_LOW_NAME', 'LOC_BBM_PACE_TECHNOLOGY_COST_LOW_DESC', 10),
        ('BBMPaceTechnologyCostValues', 'BBM_PACE_TECHNOLOGY_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_COST_STANDARD_DESC', 20),
        ('BBMPaceTechnologyCostValues', 'BBM_PACE_TECHNOLOGY_COST_MEDIUM', 'LOC_BBM_PACE_MEDIUM_NAME', 'LOC_BBM_PACE_TECHNOLOGY_COST_MEDIUM_DESC', 25),
        ('BBMPaceTechnologyCostValues', 'BBM_PACE_TECHNOLOGY_COST_HIGH', 'LOC_BBM_PACE_HIGH_NAME', 'LOC_BBM_PACE_TECHNOLOGY_COST_HIGH_DESC', 30),
        ('BBMPaceTechnologyCostValues', 'BBM_PACE_TECHNOLOGY_COST_DOUBLE', 'LOC_BBM_PACE_DOUBLE_NAME', 'LOC_BBM_PACE_TECHNOLOGY_COST_DOUBLE_DESC', 40),
        ('BBMPaceTechnologyCostValues', 'BBM_PACE_TECHNOLOGY_COST_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_TECHNOLOGY_COST_SWIFT_DESC', 43),
        ('BBMPaceTechnologyCostValues', 'BBM_PACE_TECHNOLOGY_COST_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_TECHNOLOGY_COST_BALANCED_DESC', 45),
        ('BBMPaceTechnologyCostValues', 'BBM_PACE_TECHNOLOGY_COST_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 50),
        ('BBMPaceTechnologyCostAgeValues', 'BBM_PACE_TECHNOLOGY_COST_MINUS_25', 'LOC_BBM_PACE_PCT_MINUS_25', 'LOC_BBM_PACE_TECHNOLOGY_COST_AGE_MINUS_25_DESC', 10),
        ('BBMPaceTechnologyCostAgeValues', 'BBM_PACE_TECHNOLOGY_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_COST_STANDARD_DESC', 20),
        ('BBMPaceTechnologyCostAgeValues', 'BBM_PACE_TECHNOLOGY_COST_PLUS_25', 'LOC_BBM_PACE_PCT_PLUS_25', 'LOC_BBM_PACE_TECHNOLOGY_COST_AGE_PLUS_25_DESC', 30),
        ('BBMPaceTechnologyCostAgeValues', 'BBM_PACE_TECHNOLOGY_COST_PLUS_50', 'LOC_BBM_PACE_PCT_PLUS_50', 'LOC_BBM_PACE_TECHNOLOGY_COST_AGE_PLUS_50_DESC', 60),
        ('BBMPaceTechnologyCostAgeValues', 'BBM_PACE_TECHNOLOGY_COST_PLUS_100', 'LOC_BBM_PACE_PCT_PLUS_100', 'LOC_BBM_PACE_TECHNOLOGY_COST_AGE_PLUS_100_DESC', 100),
        ('BBMPaceCivicCostValues', 'BBM_PACE_CIVIC_COST_LOW', 'LOC_BBM_PACE_LOW_NAME', 'LOC_BBM_PACE_CIVIC_COST_LOW_DESC', 10),
        ('BBMPaceCivicCostValues', 'BBM_PACE_CIVIC_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_COST_STANDARD_DESC', 20),
        ('BBMPaceCivicCostValues', 'BBM_PACE_CIVIC_COST_MEDIUM', 'LOC_BBM_PACE_MEDIUM_NAME', 'LOC_BBM_PACE_CIVIC_COST_MEDIUM_DESC', 25),
        ('BBMPaceCivicCostValues', 'BBM_PACE_CIVIC_COST_HIGH', 'LOC_BBM_PACE_HIGH_NAME', 'LOC_BBM_PACE_CIVIC_COST_HIGH_DESC', 30),
        ('BBMPaceCivicCostValues', 'BBM_PACE_CIVIC_COST_DOUBLE', 'LOC_BBM_PACE_DOUBLE_NAME', 'LOC_BBM_PACE_CIVIC_COST_DOUBLE_DESC', 40),
        ('BBMPaceCivicCostValues', 'BBM_PACE_CIVIC_COST_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_CIVIC_COST_SWIFT_DESC', 43),
        ('BBMPaceCivicCostValues', 'BBM_PACE_CIVIC_COST_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_CIVIC_COST_BALANCED_DESC', 45),
        ('BBMPaceCivicCostValues', 'BBM_PACE_CIVIC_COST_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 50),
        ('BBMPaceCivicCostAgeValues', 'BBM_PACE_CIVIC_COST_MINUS_25', 'LOC_BBM_PACE_PCT_MINUS_25', 'LOC_BBM_PACE_CIVIC_COST_AGE_MINUS_25_DESC', 10),
        ('BBMPaceCivicCostAgeValues', 'BBM_PACE_CIVIC_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_COST_STANDARD_DESC', 20),
        ('BBMPaceCivicCostAgeValues', 'BBM_PACE_CIVIC_COST_PLUS_25', 'LOC_BBM_PACE_PCT_PLUS_25', 'LOC_BBM_PACE_CIVIC_COST_AGE_PLUS_25_DESC', 30),
        ('BBMPaceCivicCostAgeValues', 'BBM_PACE_CIVIC_COST_PLUS_50', 'LOC_BBM_PACE_PCT_PLUS_50', 'LOC_BBM_PACE_CIVIC_COST_AGE_PLUS_50_DESC', 60),
        ('BBMPaceCivicCostAgeValues', 'BBM_PACE_CIVIC_COST_PLUS_100', 'LOC_BBM_PACE_PCT_PLUS_100', 'LOC_BBM_PACE_CIVIC_COST_AGE_PLUS_100_DESC', 100),
        ('BBMPaceBuildingCostValues', 'BBM_PACE_BUILDING_COST_LOW', 'LOC_BBM_PACE_LOW_NAME', 'LOC_BBM_PACE_BUILDING_COST_LOW_DESC', 10),
        ('BBMPaceBuildingCostValues', 'BBM_PACE_BUILDING_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_COST_STANDARD_DESC', 20),
        ('BBMPaceBuildingCostValues', 'BBM_PACE_BUILDING_COST_MEDIUM', 'LOC_BBM_PACE_MEDIUM_NAME', 'LOC_BBM_PACE_BUILDING_COST_MEDIUM_DESC', 25),
        ('BBMPaceBuildingCostValues', 'BBM_PACE_BUILDING_COST_HIGH', 'LOC_BBM_PACE_HIGH_NAME', 'LOC_BBM_PACE_BUILDING_COST_HIGH_DESC', 30),
        ('BBMPaceBuildingCostValues', 'BBM_PACE_BUILDING_COST_DOUBLE', 'LOC_BBM_PACE_DOUBLE_NAME', 'LOC_BBM_PACE_BUILDING_COST_DOUBLE_DESC', 40),
        ('BBMPaceBuildingCostValues', 'BBM_PACE_BUILDING_COST_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_BUILDING_COST_SWIFT_DESC', 43),
        ('BBMPaceBuildingCostValues', 'BBM_PACE_BUILDING_COST_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_BUILDING_COST_BALANCED_DESC', 45),
        ('BBMPaceBuildingCostValues', 'BBM_PACE_BUILDING_COST_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 50),
        ('BBMPaceBuildingCostAgeValues', 'BBM_PACE_BUILDING_COST_MINUS_25', 'LOC_BBM_PACE_PCT_MINUS_25', 'LOC_BBM_PACE_BUILDING_COST_AGE_MINUS_25_DESC', 10),
        ('BBMPaceBuildingCostAgeValues', 'BBM_PACE_BUILDING_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_COST_STANDARD_DESC', 20),
        ('BBMPaceBuildingCostAgeValues', 'BBM_PACE_BUILDING_COST_PLUS_25', 'LOC_BBM_PACE_PCT_PLUS_25', 'LOC_BBM_PACE_BUILDING_COST_AGE_PLUS_25_DESC', 30),
        ('BBMPaceBuildingCostAgeValues', 'BBM_PACE_BUILDING_COST_PLUS_50', 'LOC_BBM_PACE_PCT_PLUS_50', 'LOC_BBM_PACE_BUILDING_COST_AGE_PLUS_50_DESC', 60),
        ('BBMPaceBuildingCostAgeValues', 'BBM_PACE_BUILDING_COST_PLUS_100', 'LOC_BBM_PACE_PCT_PLUS_100', 'LOC_BBM_PACE_BUILDING_COST_AGE_PLUS_100_DESC', 100),
        ('BBMPaceVictoryProjectCostValues', 'BBM_PACE_VICTORY_PROJECT_COST_LOW', 'LOC_BBM_PACE_LOW_NAME', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_LOW_DESC', 10),
        ('BBMPaceVictoryProjectCostValues', 'BBM_PACE_VICTORY_PROJECT_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_STANDARD_DESC', 20),
        ('BBMPaceVictoryProjectCostValues', 'BBM_PACE_VICTORY_PROJECT_COST_MEDIUM', 'LOC_BBM_PACE_MEDIUM_NAME', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_MEDIUM_DESC', 25),
        ('BBMPaceVictoryProjectCostValues', 'BBM_PACE_VICTORY_PROJECT_COST_HIGH', 'LOC_BBM_PACE_HIGH_NAME', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_HIGH_DESC', 30),
        ('BBMPaceVictoryProjectCostValues', 'BBM_PACE_VICTORY_PROJECT_COST_DOUBLE', 'LOC_BBM_PACE_DOUBLE_NAME', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_DOUBLE_DESC', 40),
        ('BBMPaceVictoryProjectCostValues', 'BBM_PACE_VICTORY_PROJECT_COST_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_SWIFT_DESC', 43),
        ('BBMPaceVictoryProjectCostValues', 'BBM_PACE_VICTORY_PROJECT_COST_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_BALANCED_DESC', 45),
        ('BBMPaceVictoryProjectCostValues', 'BBM_PACE_VICTORY_PROJECT_COST_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 50),
        ('BBMPaceVictoryProjectCostAgeValues', 'BBM_PACE_VICTORY_PROJECT_COST_MINUS_25', 'LOC_BBM_PACE_PCT_MINUS_25', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_AGE_MINUS_25_DESC', 10),
        ('BBMPaceVictoryProjectCostAgeValues', 'BBM_PACE_VICTORY_PROJECT_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_COST_STANDARD_DESC', 20),
        ('BBMPaceVictoryProjectCostAgeValues', 'BBM_PACE_VICTORY_PROJECT_COST_PLUS_25', 'LOC_BBM_PACE_PCT_PLUS_25', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_AGE_PLUS_25_DESC', 30),
        ('BBMPaceVictoryProjectCostAgeValues', 'BBM_PACE_VICTORY_PROJECT_COST_PLUS_50', 'LOC_BBM_PACE_PCT_PLUS_50', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_AGE_PLUS_50_DESC', 60),
        ('BBMPaceVictoryProjectCostAgeValues', 'BBM_PACE_VICTORY_PROJECT_COST_PLUS_100', 'LOC_BBM_PACE_PCT_PLUS_100', 'LOC_BBM_PACE_VICTORY_PROJECT_COST_AGE_PLUS_100_DESC', 100),
        ('BBMPaceSettlementGrowthValues', 'BBM_PACE_SETTLEMENT_GROWTH_SLOW', 'LOC_BBM_PACE_SLOW_NAME', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_SLOW_DESC', 10),
        ('BBMPaceSettlementGrowthValues', 'BBM_PACE_SETTLEMENT_GROWTH_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_STANDARD_DESC', 20),
        ('BBMPaceSettlementGrowthValues', 'BBM_PACE_SETTLEMENT_GROWTH_QUICK', 'LOC_BBM_PACE_QUICK_NAME', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_QUICK_DESC', 30),
        ('BBMPaceSettlementGrowthValues', 'BBM_PACE_SETTLEMENT_GROWTH_FAST', 'LOC_BBM_PACE_FAST_NAME', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_FAST_DESC', 40),
        ('BBMPaceSettlementGrowthValues', 'BBM_PACE_SETTLEMENT_GROWTH_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_SWIFT_DESC', 43),
        ('BBMPaceSettlementGrowthValues', 'BBM_PACE_SETTLEMENT_GROWTH_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_BALANCED_DESC', 45),
        ('BBMPaceSettlementGrowthValues', 'BBM_PACE_SETTLEMENT_GROWTH_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 50),
        ('BBMPaceSettlementGrowthAgeValues', 'BBM_PACE_SETTLEMENT_GROWTH_PLUS_25', 'LOC_BBM_PACE_PCT_PLUS_25', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_SLOW_DESC', 10),
        ('BBMPaceSettlementGrowthAgeValues', 'BBM_PACE_SETTLEMENT_GROWTH_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_STANDARD_DESC', 20),
        ('BBMPaceSettlementGrowthAgeValues', 'BBM_PACE_SETTLEMENT_GROWTH_MINUS_25', 'LOC_BBM_PACE_PCT_MINUS_25', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_QUICK_DESC', 30),
        ('BBMPaceSettlementGrowthAgeValues', 'BBM_PACE_SETTLEMENT_GROWTH_MINUS_50', 'LOC_BBM_PACE_PCT_MINUS_50', 'LOC_BBM_PACE_SETTLEMENT_GROWTH_FAST_DESC', 40),
        ('BBMPaceRoadSpeedValues', 'BBM_PACE_ROAD_SPEED_SLOW', 'LOC_BBM_PACE_SLOW_NAME', 'LOC_BBM_PACE_ROAD_SPEED_SLOW_DESC', 10),
        ('BBMPaceRoadSpeedValues', 'BBM_PACE_ROAD_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_ROAD_SPEED_STANDARD_DESC', 20),
        ('BBMPaceRoadSpeedValues', 'BBM_PACE_ROAD_SPEED_QUICK', 'LOC_BBM_PACE_QUICK_NAME', 'LOC_BBM_PACE_ROAD_SPEED_QUICK_DESC', 30),
        ('BBMPaceRoadSpeedValues', 'BBM_PACE_ROAD_SPEED_FAST', 'LOC_BBM_PACE_FAST_NAME', 'LOC_BBM_PACE_ROAD_SPEED_FAST_DESC', 40),
        ('BBMPaceRoadSpeedValues', 'BBM_PACE_ROAD_SPEED_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_ROAD_SPEED_SWIFT_DESC', 43),
        ('BBMPaceRoadSpeedValues', 'BBM_PACE_ROAD_SPEED_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_ROAD_SPEED_BALANCED_DESC', 45),
        ('BBMPaceRoadSpeedValues', 'BBM_PACE_ROAD_SPEED_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 50),
        ('BBMPaceRoadSpeedAgeValues', 'BBM_PACE_ROAD_SPEED_PLUS_25', 'LOC_BBM_PACE_PCT_PLUS_25', 'LOC_BBM_PACE_ROAD_SPEED_SLOW_DESC', 10),
        ('BBMPaceRoadSpeedAgeValues', 'BBM_PACE_ROAD_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_ROAD_SPEED_STANDARD_DESC', 20),
        ('BBMPaceRoadSpeedAgeValues', 'BBM_PACE_ROAD_SPEED_MINUS_25', 'LOC_BBM_PACE_PCT_MINUS_25', 'LOC_BBM_PACE_ROAD_SPEED_QUICK_DESC', 30),
        ('BBMPaceRoadSpeedAgeValues', 'BBM_PACE_ROAD_SPEED_MINUS_50', 'LOC_BBM_PACE_PCT_MINUS_50', 'LOC_BBM_PACE_ROAD_SPEED_FAST_DESC', 40),
        ('BBMPaceTradeSpeedValues', 'BBM_PACE_TRADE_SPEED_SLOW', 'LOC_BBM_PACE_SLOW_NAME', 'LOC_BBM_PACE_TRADE_SPEED_SLOW_DESC', 10),
        ('BBMPaceTradeSpeedValues', 'BBM_PACE_TRADE_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_TRADE_SPEED_DEFAULT_DESC', 20),
        ('BBMPaceTradeSpeedValues', 'BBM_PACE_TRADE_SPEED_QUICK', 'LOC_BBM_PACE_QUICK_NAME', 'LOC_BBM_PACE_TRADE_SPEED_QUICK_DESC', 30),
        ('BBMPaceTradeSpeedValues', 'BBM_PACE_TRADE_SPEED_FAST', 'LOC_BBM_PACE_FAST_NAME', 'LOC_BBM_PACE_TRADE_SPEED_FAST_DESC', 40),
        ('BBMPaceTradeSpeedValues', 'BBM_PACE_TRADE_SPEED_INSTANT', 'LOC_BBM_PACE_INSTANT_NAME', 'LOC_BBM_PACE_TRADE_SPEED_INSTANT_DESC', 50),
        ('BBMPaceTradeSpeedValues', 'BBM_PACE_TRADE_SPEED_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_TRADE_SPEED_SWIFT_DESC', 53),
        ('BBMPaceTradeSpeedValues', 'BBM_PACE_TRADE_SPEED_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_TRADE_SPEED_BALANCED_DESC', 55),
        ('BBMPaceTradeSpeedValues', 'BBM_PACE_TRADE_SPEED_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 60),
        ('BBMPaceTradeSpeedAgeValues', 'BBM_PACE_TRADE_SPEED_MINUS_25', 'LOC_BBM_PACE_PCT_MINUS_25', 'LOC_BBM_PACE_TRADE_SPEED_SLOW_DESC', 10),
        ('BBMPaceTradeSpeedAgeValues', 'BBM_PACE_TRADE_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_TRADE_SPEED_STANDARD_DESC', 20),
        ('BBMPaceTradeSpeedAgeValues', 'BBM_PACE_TRADE_SPEED_PLUS_25', 'LOC_BBM_PACE_PCT_PLUS_25', 'LOC_BBM_PACE_TRADE_SPEED_QUICK_DESC', 30),
        ('BBMPaceTradeSpeedAgeValues', 'BBM_PACE_TRADE_SPEED_PLUS_50', 'LOC_BBM_PACE_PCT_PLUS_50', 'LOC_BBM_PACE_TRADE_SPEED_FAST_DESC', 40),
        ('BBMPaceTradeSpeedAgeValues', 'BBM_PACE_TRADE_SPEED_INSTANT', 'LOC_BBM_PACE_INSTANT_NAME', 'LOC_BBM_PACE_TRADE_SPEED_INSTANT_DESC', 50),
        ('BBMPaceRazeSpeedValues', 'BBM_PACE_RAZE_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_RAZE_SPEED_STANDARD_DESC', 10),
        ('BBMPaceRazeSpeedValues', 'BBM_PACE_RAZE_SPEED_FAST', 'LOC_BBM_PACE_FAST_NAME', 'LOC_BBM_PACE_RAZE_SPEED_SHORTER_DESC', 20),
        ('BBMPaceRazeSpeedValues', 'BBM_PACE_RAZE_SPEED_INSTANT', 'LOC_BBM_PACE_INSTANT_NAME', 'LOC_BBM_PACE_RAZE_SPEED_INSTANT_DESC', 30),
        ('BBMPaceRazeSpeedValues', 'BBM_PACE_RAZE_SPEED_SWIFT', 'LOC_BBM_PACE_SWIFT_NAME', 'LOC_BBM_PACE_RAZE_SPEED_SWIFT_DESC', 33),
        ('BBMPaceRazeSpeedValues', 'BBM_PACE_RAZE_SPEED_BALANCED', 'LOC_BBM_PACE_BALANCED_NAME', 'LOC_BBM_PACE_RAZE_SPEED_BALANCED_DESC', 35),
        ('BBMPaceRazeSpeedValues', 'BBM_PACE_RAZE_SPEED_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_CUSTOM_DESC', 40),
        ('BBMPaceRazeSpeedAgeValues', 'BBM_PACE_RAZE_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_RAZE_SPEED_STANDARD_DESC', 10),
        ('BBMPaceRazeSpeedAgeValues', 'BBM_PACE_RAZE_SPEED_PLUS_100', 'LOC_BBM_PACE_PCT_PLUS_100', 'LOC_BBM_PACE_RAZE_SPEED_SHORTER_DESC', 20),
        ('BBMPaceRazeSpeedAgeValues', 'BBM_PACE_RAZE_SPEED_INSTANT', 'LOC_BBM_PACE_INSTANT_NAME', 'LOC_BBM_PACE_RAZE_SPEED_INSTANT_DESC', 30);

--*******************************************************
--***************** VICTORY THRESHOLDS ******************
--*******************************************************
-- Culture, Economic and Military victory thresholds, each scaled on its own
-- (data/pace/victory-thresholds/), over the curve in use: the game's own, or
-- Game Balance's when it is Multiplayer. Science stays fixed. They sit on the
-- Advanced tab after Victory Settings; Victory Threshold, on Game Settings
-- (Victory Settings), sets all three (Standard by default), and shows Custom
-- when they differ (ui/pace/bbm-pace-rules.js).
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('VictoryThresholdOptions', 'LOC_GROUPID_BBM_VICTORYTHRESHOLDOPTIONS'),
        ('MPAdvancedVictoryThresholdOptions', 'LOC_GROUPID_BBM_VICTORYTHRESHOLDOPTIONS');

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMPaceVictoryThresholdSet', 'LOC_BBM_PACE_VICTORY_THRESHOLD_SET_NAME', 'LOC_BBM_PACE_VICTORY_THRESHOLD_SET_DESC', 'BBMPaceVictoryThresholdSets', 0, 'BBM_PACE_VICTORY_THRESHOLD_LOW', 'Game', 'BBMPaceVictoryThresholdSet', 'VictoryOptions', NULL, 0, 0, 4000),
        ('BBMPaceCultureVictoryThreshold', 'LOC_BBM_PACE_VICTORY_THRESHOLD_CULTURE_NAME', 'LOC_BBM_PACE_VICTORY_THRESHOLD_CULTURE_DESC', 'BBMPaceVictoryThresholds', 0, 'BBM_PACE_VICTORY_THRESHOLD_LOW', 'Game', 'BBMPaceCultureVictoryThreshold', 'VictoryThresholdOptions', 'MPAdvancedVictoryThresholdOptions', 0, 0, 4001),
        ('BBMPaceEconomicVictoryThreshold', 'LOC_BBM_PACE_VICTORY_THRESHOLD_ECONOMIC_NAME', 'LOC_BBM_PACE_VICTORY_THRESHOLD_ECONOMIC_DESC', 'BBMPaceVictoryThresholds', 0, 'BBM_PACE_VICTORY_THRESHOLD_LOW', 'Game', 'BBMPaceEconomicVictoryThreshold', 'VictoryThresholdOptions', 'MPAdvancedVictoryThresholdOptions', 0, 0, 4002),
        ('BBMPaceMilitaryVictoryThreshold', 'LOC_BBM_PACE_VICTORY_THRESHOLD_MILITARY_NAME', 'LOC_BBM_PACE_VICTORY_THRESHOLD_MILITARY_DESC', 'BBMPaceVictoryThresholds', 0, 'BBM_PACE_VICTORY_THRESHOLD_LOW', 'Game', 'BBMPaceMilitaryVictoryThreshold', 'VictoryThresholdOptions', 'MPAdvancedVictoryThresholdOptions', 0, 0, 4003);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMPaceVictoryThresholds', 'BBM_PACE_VICTORY_THRESHOLD_LOW', 'LOC_ADVANCED_OPTIONS_LOW', 'LOC_BBM_PACE_VICTORY_THRESHOLD_LOW_DESC', 10),
        ('BBMPaceVictoryThresholds', 'BBM_PACE_VICTORY_THRESHOLD_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_VICTORY_THRESHOLD_STANDARD_DESC', 20),
        ('BBMPaceVictoryThresholds', 'BBM_PACE_VICTORY_THRESHOLD_HIGH', 'LOC_ADVANCED_OPTIONS_HIGH', 'LOC_BBM_PACE_VICTORY_THRESHOLD_HIGH_DESC', 30),
        ('BBMPaceVictoryThresholdSets', 'BBM_PACE_VICTORY_THRESHOLD_LOW', 'LOC_ADVANCED_OPTIONS_LOW', 'LOC_BBM_PACE_VICTORY_THRESHOLD_SET_LOW_DESC', 10),
        ('BBMPaceVictoryThresholdSets', 'BBM_PACE_VICTORY_THRESHOLD_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_PACE_VICTORY_THRESHOLD_SET_STANDARD_DESC', 20),
        ('BBMPaceVictoryThresholdSets', 'BBM_PACE_VICTORY_THRESHOLD_HIGH', 'LOC_ADVANCED_OPTIONS_HIGH', 'LOC_BBM_PACE_VICTORY_THRESHOLD_SET_HIGH_DESC', 30),
        ('BBMPaceVictoryThresholdSets', 'BBM_PACE_VICTORY_THRESHOLD_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_PACE_VICTORY_THRESHOLD_SET_CUSTOM_DESC', 40);
