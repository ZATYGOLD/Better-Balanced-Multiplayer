--*******************************************************
--***************** PARAMETER GROUPS ********************
--*******************************************************
-- The Pace tab's groups (ui/setup/setup-layout.js).
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('GamePacingOptions', 'LOC_GROUPID_MPT_GAMEPACINGOPTIONS'),
        ('MPAdvancedGamePacingOptions', 'LOC_GROUPID_MPT_GAMEPACINGOPTIONS'),
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
-- it to Custom (ui/pace/pace-rules.js).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTPacePreset', 'LOC_MPT_PACE_PRESET_NAME', 'LOC_MPT_PACE_PRESET_DESC', 'MPTPacePresets', 0, 'MPT_PACE_PRESET_STANDARD', 'Game', 'MPTPacePreset', 'GameOptions', NULL, 0, 0, 15),
        ('MPTPaceSetMirror', 'LOC_MPT_PACE_PRESET_NAME', 'LOC_MPT_PACE_PRESET_DESC', 'MPTPacePresets', 0, 'MPT_PACE_PRESET_STANDARD', 'Game', 'MPTPaceSetMirror', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 28);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTPacePresets', 'MPT_PACE_PRESET_STANDARD', 'LOC_MPT_PACE_PRESET_STANDARD_NAME', 'LOC_MPT_PACE_PRESET_STANDARD_DESC', 10),
        ('MPTPacePresets', 'MPT_PACE_PRESET_BALANCED', 'LOC_MPT_PACE_PRESET_BALANCED_NAME', 'LOC_MPT_PACE_PRESET_BALANCED_DESC', 20),
        ('MPTPacePresets', 'MPT_PACE_PRESET_MULTIPLAYER', 'LOC_MPT_PACE_PRESET_MULTIPLAYER_NAME', 'LOC_MPT_PACE_PRESET_MULTIPLAYER_DESC', 30),
        ('MPTPacePresets', 'MPT_PACE_PRESET_CUSTOM', 'LOC_MPT_PACE_PRESET_CUSTOM_NAME', 'LOC_MPT_PACE_PRESET_CUSTOM_DESC', 40);

--*******************************************************
--***************** PACE SETTINGS ***********************
--*******************************************************
-- All Ages (Pace Settings) holds each setting; the Antiquity, Exploration and
-- Modern groups hold its per-Age rows, which ui/pace/pace-rules.js keeps on the
-- setting's values (Custom leaves them to the host). The per-Age rows are what
-- the game data reads (data/pace/), one file per Age and value.

-- Age Length is the mod's own in multiplayer: the base setting is hidden
-- there, and every option sets the same points for each base length.
INSERT OR IGNORE INTO ParameterDependencies (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES ('AgeLength', 'Game', 'MPTMultiplayerSetup', 'NotEquals', 1);

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTPaceAgeLength', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH_DESC', 'MPTPaceAgeLengthValues', 0, 'MPT_PACE_AGE_LENGTH_STANDARD', 'Game', 'MPTPaceAgeLength', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 30),
        ('MPTPaceAgeProgression', 'LOC_MPT_PACE_AGE_PROGRESSION_NAME', 'LOC_MPT_PACE_AGE_PROGRESSION_DESC', 'MPTPaceAgeProgressionValues', 0, 'MPT_PACE_AGE_PROGRESSION_STANDARD', 'Game', 'MPTPaceAgeProgression', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 32),
        ('MPTPaceTechnologyCost', 'LOC_MPT_PACE_TECHNOLOGY_COST_NAME', 'LOC_MPT_PACE_TECHNOLOGY_COST_DESC', 'MPTPaceTechnologyCostValues', 0, 'MPT_PACE_TECHNOLOGY_COST_STANDARD', 'Game', 'MPTPaceTechnologyCost', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 36),
        ('MPTPaceCivicCost', 'LOC_MPT_PACE_CIVIC_COST_NAME', 'LOC_MPT_PACE_CIVIC_COST_DESC', 'MPTPaceCivicCostValues', 0, 'MPT_PACE_CIVIC_COST_STANDARD', 'Game', 'MPTPaceCivicCost', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 40),
        ('MPTPaceBuildingCost', 'LOC_MPT_PACE_BUILDING_COST_NAME', 'LOC_MPT_PACE_BUILDING_COST_DESC', 'MPTPaceBuildingCostValues', 0, 'MPT_PACE_BUILDING_COST_STANDARD', 'Game', 'MPTPaceBuildingCost', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 42),
        ('MPTPaceVictoryProjectCost', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_NAME', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_DESC', 'MPTPaceVictoryProjectCostValues', 0, 'MPT_PACE_VICTORY_PROJECT_COST_STANDARD', 'Game', 'MPTPaceVictoryProjectCost', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 44),
        ('MPTPaceSettlementGrowth', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_NAME', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_DESC', 'MPTPaceSettlementGrowthValues', 0, 'MPT_PACE_SETTLEMENT_GROWTH_STANDARD', 'Game', 'MPTPaceSettlementGrowth', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 46),
        ('MPTPaceRoadSpeed', 'LOC_MPT_PACE_ROAD_SPEED_NAME', 'LOC_MPT_PACE_ROAD_SPEED_DESC', 'MPTPaceRoadSpeedValues', 0, 'MPT_PACE_ROAD_SPEED_STANDARD', 'Game', 'MPTPaceRoadSpeed', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 48),
        ('MPTPaceTradeSpeed', 'LOC_MPT_PACE_TRADE_SPEED_NAME', 'LOC_MPT_PACE_TRADE_SPEED_DESC', 'MPTPaceTradeSpeedValues', 0, 'MPT_PACE_TRADE_SPEED_STANDARD', 'Game', 'MPTPaceTradeSpeed', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 50),
        ('MPTPaceRazeSpeed', 'LOC_MPT_PACE_RAZE_SPEED_NAME', 'LOC_MPT_PACE_RAZE_SPEED_DESC', 'MPTPaceRazeSpeedValues', 0, 'MPT_PACE_RAZE_SPEED_STANDARD', 'Game', 'MPTPaceRazeSpeed', 'GamePacingOptions', 'MPAdvancedGamePacingOptions', 0, 0, 52),
        ('MPTPaceAgeLengthAntiquity', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceAgeLengthAgeValues', 0, 'MPT_PACE_AGE_LENGTH_140', 'Game', 'MPTPaceAgeLengthAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 100),
        ('MPTPaceAgeProgressionAntiquity', 'LOC_MPT_PACE_AGE_PROGRESSION_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceAgeProgressionAgeValues', 0, 'MPT_PACE_AGE_PROGRESSION_STANDARD', 'Game', 'MPTPaceAgeProgressionAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 101),
        ('MPTPaceTechnologyCostAntiquity', 'LOC_MPT_PACE_TECHNOLOGY_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceTechnologyCostAgeValues', 0, 'MPT_PACE_TECHNOLOGY_COST_STANDARD', 'Game', 'MPTPaceTechnologyCostAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 102),
        ('MPTPaceCivicCostAntiquity', 'LOC_MPT_PACE_CIVIC_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceCivicCostAgeValues', 0, 'MPT_PACE_CIVIC_COST_STANDARD', 'Game', 'MPTPaceCivicCostAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 103),
        ('MPTPaceBuildingCostAntiquity', 'LOC_MPT_PACE_BUILDING_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceBuildingCostAgeValues', 0, 'MPT_PACE_BUILDING_COST_STANDARD', 'Game', 'MPTPaceBuildingCostAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 104),
        ('MPTPaceVictoryProjectCostAntiquity', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceVictoryProjectCostAgeValues', 0, 'MPT_PACE_VICTORY_PROJECT_COST_STANDARD', 'Game', 'MPTPaceVictoryProjectCostAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 105),
        ('MPTPaceSettlementGrowthAntiquity', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceSettlementGrowthAgeValues', 0, 'MPT_PACE_SETTLEMENT_GROWTH_STANDARD', 'Game', 'MPTPaceSettlementGrowthAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 106),
        ('MPTPaceRoadSpeedAntiquity', 'LOC_MPT_PACE_ROAD_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceRoadSpeedAgeValues', 0, 'MPT_PACE_ROAD_SPEED_STANDARD', 'Game', 'MPTPaceRoadSpeedAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 107),
        ('MPTPaceTradeSpeedAntiquity', 'LOC_MPT_PACE_TRADE_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceTradeSpeedAgeValues', 0, 'MPT_PACE_TRADE_SPEED_STANDARD', 'Game', 'MPTPaceTradeSpeedAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 108),
        ('MPTPaceRazeSpeedAntiquity', 'LOC_MPT_PACE_RAZE_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceRazeSpeedAgeValues', 0, 'MPT_PACE_RAZE_SPEED_STANDARD', 'Game', 'MPTPaceRazeSpeedAntiquity', 'PacingAntiquityOptions', 'MPAdvancedPacingAntiquityOptions', 0, 0, 109),
        ('MPTPaceAgeLengthExploration', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceAgeLengthAgeValues', 0, 'MPT_PACE_AGE_LENGTH_140', 'Game', 'MPTPaceAgeLengthExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 110),
        ('MPTPaceAgeProgressionExploration', 'LOC_MPT_PACE_AGE_PROGRESSION_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceAgeProgressionAgeValues', 0, 'MPT_PACE_AGE_PROGRESSION_STANDARD', 'Game', 'MPTPaceAgeProgressionExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 111),
        ('MPTPaceTechnologyCostExploration', 'LOC_MPT_PACE_TECHNOLOGY_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceTechnologyCostAgeValues', 0, 'MPT_PACE_TECHNOLOGY_COST_STANDARD', 'Game', 'MPTPaceTechnologyCostExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 112),
        ('MPTPaceCivicCostExploration', 'LOC_MPT_PACE_CIVIC_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceCivicCostAgeValues', 0, 'MPT_PACE_CIVIC_COST_STANDARD', 'Game', 'MPTPaceCivicCostExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 113),
        ('MPTPaceBuildingCostExploration', 'LOC_MPT_PACE_BUILDING_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceBuildingCostAgeValues', 0, 'MPT_PACE_BUILDING_COST_STANDARD', 'Game', 'MPTPaceBuildingCostExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 114),
        ('MPTPaceVictoryProjectCostExploration', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceVictoryProjectCostAgeValues', 0, 'MPT_PACE_VICTORY_PROJECT_COST_STANDARD', 'Game', 'MPTPaceVictoryProjectCostExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 115),
        ('MPTPaceSettlementGrowthExploration', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceSettlementGrowthAgeValues', 0, 'MPT_PACE_SETTLEMENT_GROWTH_STANDARD', 'Game', 'MPTPaceSettlementGrowthExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 116),
        ('MPTPaceRoadSpeedExploration', 'LOC_MPT_PACE_ROAD_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceRoadSpeedAgeValues', 0, 'MPT_PACE_ROAD_SPEED_STANDARD', 'Game', 'MPTPaceRoadSpeedExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 117),
        ('MPTPaceTradeSpeedExploration', 'LOC_MPT_PACE_TRADE_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceTradeSpeedAgeValues', 0, 'MPT_PACE_TRADE_SPEED_STANDARD', 'Game', 'MPTPaceTradeSpeedExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 118),
        ('MPTPaceRazeSpeedExploration', 'LOC_MPT_PACE_RAZE_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceRazeSpeedAgeValues', 0, 'MPT_PACE_RAZE_SPEED_STANDARD', 'Game', 'MPTPaceRazeSpeedExploration', 'PacingExplorationOptions', 'MPAdvancedPacingExplorationOptions', 0, 0, 119),
        ('MPTPaceAgeLengthModern', 'LOC_ADVANCED_OPTIONS_AGE_LENGTH', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceAgeLengthAgeValues', 0, 'MPT_PACE_AGE_LENGTH_140', 'Game', 'MPTPaceAgeLengthModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 120),
        ('MPTPaceAgeProgressionModern', 'LOC_MPT_PACE_AGE_PROGRESSION_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceAgeProgressionAgeValues', 0, 'MPT_PACE_AGE_PROGRESSION_STANDARD', 'Game', 'MPTPaceAgeProgressionModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 121),
        ('MPTPaceTechnologyCostModern', 'LOC_MPT_PACE_TECHNOLOGY_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceTechnologyCostAgeValues', 0, 'MPT_PACE_TECHNOLOGY_COST_STANDARD', 'Game', 'MPTPaceTechnologyCostModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 122),
        ('MPTPaceCivicCostModern', 'LOC_MPT_PACE_CIVIC_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceCivicCostAgeValues', 0, 'MPT_PACE_CIVIC_COST_STANDARD', 'Game', 'MPTPaceCivicCostModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 123),
        ('MPTPaceBuildingCostModern', 'LOC_MPT_PACE_BUILDING_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceBuildingCostAgeValues', 0, 'MPT_PACE_BUILDING_COST_STANDARD', 'Game', 'MPTPaceBuildingCostModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 124),
        ('MPTPaceVictoryProjectCostModern', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceVictoryProjectCostAgeValues', 0, 'MPT_PACE_VICTORY_PROJECT_COST_STANDARD', 'Game', 'MPTPaceVictoryProjectCostModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 125),
        ('MPTPaceSettlementGrowthModern', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceSettlementGrowthAgeValues', 0, 'MPT_PACE_SETTLEMENT_GROWTH_STANDARD', 'Game', 'MPTPaceSettlementGrowthModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 126),
        ('MPTPaceRoadSpeedModern', 'LOC_MPT_PACE_ROAD_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceRoadSpeedAgeValues', 0, 'MPT_PACE_ROAD_SPEED_STANDARD', 'Game', 'MPTPaceRoadSpeedModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 127),
        ('MPTPaceTradeSpeedModern', 'LOC_MPT_PACE_TRADE_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceTradeSpeedAgeValues', 0, 'MPT_PACE_TRADE_SPEED_INSTANT', 'Game', 'MPTPaceTradeSpeedModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 128),
        ('MPTPaceRazeSpeedModern', 'LOC_MPT_PACE_RAZE_SPEED_NAME', 'LOC_MPT_PACE_AGE_DESC', 'MPTPaceRazeSpeedAgeValues', 0, 'MPT_PACE_RAZE_SPEED_STANDARD', 'Game', 'MPTPaceRazeSpeedModern', 'PacingModernOptions', 'MPAdvancedPacingModernOptions', 0, 0, 129);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTPaceAgeLengthValues', 'MPT_PACE_AGE_LENGTH_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_AGE_LENGTH_SWIFT_DESC', 7),
        ('MPTPaceAgeLengthValues', 'MPT_PACE_AGE_LENGTH_ABBREVIATED', 'LOC_ADVANCED_OPTIONS_ABBREVIATED', 'LOC_MPT_PACE_AGE_LENGTH_ABBREVIATED_DESC', 10),
        ('MPTPaceAgeLengthValues', 'MPT_PACE_AGE_LENGTH_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_AGE_LENGTH_STANDARD_DESC', 20),
        ('MPTPaceAgeLengthValues', 'MPT_PACE_AGE_LENGTH_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_AGE_LENGTH_BALANCED_DESC', 25),
        ('MPTPaceAgeLengthValues', 'MPT_PACE_AGE_LENGTH_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_AGE_LENGTH_CUSTOM_DESC', 40),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_90', 'LOC_MPT_PACE_POINTS_90', 'LOC_MPT_PACE_AGE_LENGTH_90_DESC', 10),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_100', 'LOC_MPT_PACE_POINTS_100', 'LOC_MPT_PACE_AGE_LENGTH_100_DESC', 20),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_110', 'LOC_MPT_PACE_POINTS_110', 'LOC_MPT_PACE_AGE_LENGTH_110_DESC', 30),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_120', 'LOC_MPT_PACE_POINTS_120', 'LOC_MPT_PACE_AGE_LENGTH_120_DESC', 40),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_130', 'LOC_MPT_PACE_POINTS_130', 'LOC_MPT_PACE_AGE_LENGTH_130_DESC', 50),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_140', 'LOC_MPT_PACE_POINTS_140', 'LOC_MPT_PACE_AGE_LENGTH_140_DESC', 60),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_150', 'LOC_MPT_PACE_POINTS_150', 'LOC_MPT_PACE_AGE_LENGTH_150_DESC', 70),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_160', 'LOC_MPT_PACE_POINTS_160', 'LOC_MPT_PACE_AGE_LENGTH_160_DESC', 100),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_170', 'LOC_MPT_PACE_POINTS_170', 'LOC_MPT_PACE_AGE_LENGTH_170_DESC', 120),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_180', 'LOC_MPT_PACE_POINTS_180', 'LOC_MPT_PACE_AGE_LENGTH_180_DESC', 130),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_190', 'LOC_MPT_PACE_POINTS_190', 'LOC_MPT_PACE_AGE_LENGTH_190_DESC', 140),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_200', 'LOC_MPT_PACE_POINTS_200', 'LOC_MPT_PACE_AGE_LENGTH_200_DESC', 160),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_220', 'LOC_MPT_PACE_POINTS_220', 'LOC_MPT_PACE_AGE_LENGTH_220_DESC', 170),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_240', 'LOC_MPT_PACE_POINTS_240', 'LOC_MPT_PACE_AGE_LENGTH_240_DESC', 180),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_260', 'LOC_MPT_PACE_POINTS_260', 'LOC_MPT_PACE_AGE_LENGTH_260_DESC', 190),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_280', 'LOC_MPT_PACE_POINTS_280', 'LOC_MPT_PACE_AGE_LENGTH_280_DESC', 200),
        ('MPTPaceAgeLengthAgeValues', 'MPT_PACE_AGE_LENGTH_300', 'LOC_MPT_PACE_POINTS_300', 'LOC_MPT_PACE_AGE_LENGTH_300_DESC', 210),
        ('MPTPaceAgeProgressionValues', 'MPT_PACE_AGE_PROGRESSION_SLOW', 'LOC_MPT_PACE_SLOW_NAME', 'LOC_MPT_PACE_AGE_PROGRESSION_SLOW_DESC', 10),
        ('MPTPaceAgeProgressionValues', 'MPT_PACE_AGE_PROGRESSION_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_AGE_PROGRESSION_STANDARD_DESC', 20),
        ('MPTPaceAgeProgressionValues', 'MPT_PACE_AGE_PROGRESSION_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_AGE_PROGRESSION_BALANCED_DESC', 30),
        ('MPTPaceAgeProgressionValues', 'MPT_PACE_AGE_PROGRESSION_FAST', 'LOC_MPT_PACE_FAST_NAME', 'LOC_MPT_PACE_AGE_PROGRESSION_FAST_DESC', 40),
        ('MPTPaceAgeProgressionValues', 'MPT_PACE_AGE_PROGRESSION_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 50),
        ('MPTPaceAgeProgressionAgeValues', 'MPT_PACE_AGE_PROGRESSION_SLOW', 'LOC_MPT_PACE_SLOW_NAME', 'LOC_MPT_PACE_AGE_PROGRESSION_AGE_SLOW_DESC', 10),
        ('MPTPaceAgeProgressionAgeValues', 'MPT_PACE_AGE_PROGRESSION_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_AGE_PROGRESSION_AGE_STANDARD_DESC', 20),
        ('MPTPaceAgeProgressionAgeValues', 'MPT_PACE_AGE_PROGRESSION_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_AGE_PROGRESSION_AGE_BALANCED_DESC', 30),
        ('MPTPaceAgeProgressionAgeValues', 'MPT_PACE_AGE_PROGRESSION_FAST', 'LOC_MPT_PACE_FAST_NAME', 'LOC_MPT_PACE_AGE_PROGRESSION_AGE_FAST_DESC', 40),
        ('MPTPaceTechnologyCostValues', 'MPT_PACE_TECHNOLOGY_COST_LOW', 'LOC_MPT_PACE_LOW_NAME', 'LOC_MPT_PACE_TECHNOLOGY_COST_LOW_DESC', 10),
        ('MPTPaceTechnologyCostValues', 'MPT_PACE_TECHNOLOGY_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_COST_STANDARD_DESC', 20),
        ('MPTPaceTechnologyCostValues', 'MPT_PACE_TECHNOLOGY_COST_MEDIUM', 'LOC_MPT_PACE_MEDIUM_NAME', 'LOC_MPT_PACE_TECHNOLOGY_COST_MEDIUM_DESC', 25),
        ('MPTPaceTechnologyCostValues', 'MPT_PACE_TECHNOLOGY_COST_HIGH', 'LOC_MPT_PACE_HIGH_NAME', 'LOC_MPT_PACE_TECHNOLOGY_COST_HIGH_DESC', 30),
        ('MPTPaceTechnologyCostValues', 'MPT_PACE_TECHNOLOGY_COST_DOUBLE', 'LOC_MPT_PACE_DOUBLE_NAME', 'LOC_MPT_PACE_TECHNOLOGY_COST_DOUBLE_DESC', 40),
        ('MPTPaceTechnologyCostValues', 'MPT_PACE_TECHNOLOGY_COST_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_TECHNOLOGY_COST_SWIFT_DESC', 43),
        ('MPTPaceTechnologyCostValues', 'MPT_PACE_TECHNOLOGY_COST_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_TECHNOLOGY_COST_BALANCED_DESC', 45),
        ('MPTPaceTechnologyCostValues', 'MPT_PACE_TECHNOLOGY_COST_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 50),
        ('MPTPaceTechnologyCostAgeValues', 'MPT_PACE_TECHNOLOGY_COST_MINUS_25', 'LOC_MPT_PACE_PCT_MINUS_25', 'LOC_MPT_PACE_TECHNOLOGY_COST_AGE_MINUS_25_DESC', 10),
        ('MPTPaceTechnologyCostAgeValues', 'MPT_PACE_TECHNOLOGY_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_COST_STANDARD_DESC', 20),
        ('MPTPaceTechnologyCostAgeValues', 'MPT_PACE_TECHNOLOGY_COST_PLUS_25', 'LOC_MPT_PACE_PCT_PLUS_25', 'LOC_MPT_PACE_TECHNOLOGY_COST_AGE_PLUS_25_DESC', 30),
        ('MPTPaceTechnologyCostAgeValues', 'MPT_PACE_TECHNOLOGY_COST_PLUS_50', 'LOC_MPT_PACE_PCT_PLUS_50', 'LOC_MPT_PACE_TECHNOLOGY_COST_AGE_PLUS_50_DESC', 60),
        ('MPTPaceTechnologyCostAgeValues', 'MPT_PACE_TECHNOLOGY_COST_PLUS_100', 'LOC_MPT_PACE_PCT_PLUS_100', 'LOC_MPT_PACE_TECHNOLOGY_COST_AGE_PLUS_100_DESC', 100),
        ('MPTPaceCivicCostValues', 'MPT_PACE_CIVIC_COST_LOW', 'LOC_MPT_PACE_LOW_NAME', 'LOC_MPT_PACE_CIVIC_COST_LOW_DESC', 10),
        ('MPTPaceCivicCostValues', 'MPT_PACE_CIVIC_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_COST_STANDARD_DESC', 20),
        ('MPTPaceCivicCostValues', 'MPT_PACE_CIVIC_COST_MEDIUM', 'LOC_MPT_PACE_MEDIUM_NAME', 'LOC_MPT_PACE_CIVIC_COST_MEDIUM_DESC', 25),
        ('MPTPaceCivicCostValues', 'MPT_PACE_CIVIC_COST_HIGH', 'LOC_MPT_PACE_HIGH_NAME', 'LOC_MPT_PACE_CIVIC_COST_HIGH_DESC', 30),
        ('MPTPaceCivicCostValues', 'MPT_PACE_CIVIC_COST_DOUBLE', 'LOC_MPT_PACE_DOUBLE_NAME', 'LOC_MPT_PACE_CIVIC_COST_DOUBLE_DESC', 40),
        ('MPTPaceCivicCostValues', 'MPT_PACE_CIVIC_COST_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_CIVIC_COST_SWIFT_DESC', 43),
        ('MPTPaceCivicCostValues', 'MPT_PACE_CIVIC_COST_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_CIVIC_COST_BALANCED_DESC', 45),
        ('MPTPaceCivicCostValues', 'MPT_PACE_CIVIC_COST_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 50),
        ('MPTPaceCivicCostAgeValues', 'MPT_PACE_CIVIC_COST_MINUS_25', 'LOC_MPT_PACE_PCT_MINUS_25', 'LOC_MPT_PACE_CIVIC_COST_AGE_MINUS_25_DESC', 10),
        ('MPTPaceCivicCostAgeValues', 'MPT_PACE_CIVIC_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_COST_STANDARD_DESC', 20),
        ('MPTPaceCivicCostAgeValues', 'MPT_PACE_CIVIC_COST_PLUS_25', 'LOC_MPT_PACE_PCT_PLUS_25', 'LOC_MPT_PACE_CIVIC_COST_AGE_PLUS_25_DESC', 30),
        ('MPTPaceCivicCostAgeValues', 'MPT_PACE_CIVIC_COST_PLUS_50', 'LOC_MPT_PACE_PCT_PLUS_50', 'LOC_MPT_PACE_CIVIC_COST_AGE_PLUS_50_DESC', 60),
        ('MPTPaceCivicCostAgeValues', 'MPT_PACE_CIVIC_COST_PLUS_100', 'LOC_MPT_PACE_PCT_PLUS_100', 'LOC_MPT_PACE_CIVIC_COST_AGE_PLUS_100_DESC', 100),
        ('MPTPaceBuildingCostValues', 'MPT_PACE_BUILDING_COST_LOW', 'LOC_MPT_PACE_LOW_NAME', 'LOC_MPT_PACE_BUILDING_COST_LOW_DESC', 10),
        ('MPTPaceBuildingCostValues', 'MPT_PACE_BUILDING_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_COST_STANDARD_DESC', 20),
        ('MPTPaceBuildingCostValues', 'MPT_PACE_BUILDING_COST_MEDIUM', 'LOC_MPT_PACE_MEDIUM_NAME', 'LOC_MPT_PACE_BUILDING_COST_MEDIUM_DESC', 25),
        ('MPTPaceBuildingCostValues', 'MPT_PACE_BUILDING_COST_HIGH', 'LOC_MPT_PACE_HIGH_NAME', 'LOC_MPT_PACE_BUILDING_COST_HIGH_DESC', 30),
        ('MPTPaceBuildingCostValues', 'MPT_PACE_BUILDING_COST_DOUBLE', 'LOC_MPT_PACE_DOUBLE_NAME', 'LOC_MPT_PACE_BUILDING_COST_DOUBLE_DESC', 40),
        ('MPTPaceBuildingCostValues', 'MPT_PACE_BUILDING_COST_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_BUILDING_COST_SWIFT_DESC', 43),
        ('MPTPaceBuildingCostValues', 'MPT_PACE_BUILDING_COST_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_BUILDING_COST_BALANCED_DESC', 45),
        ('MPTPaceBuildingCostValues', 'MPT_PACE_BUILDING_COST_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 50),
        ('MPTPaceBuildingCostAgeValues', 'MPT_PACE_BUILDING_COST_MINUS_25', 'LOC_MPT_PACE_PCT_MINUS_25', 'LOC_MPT_PACE_BUILDING_COST_AGE_MINUS_25_DESC', 10),
        ('MPTPaceBuildingCostAgeValues', 'MPT_PACE_BUILDING_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_COST_STANDARD_DESC', 20),
        ('MPTPaceBuildingCostAgeValues', 'MPT_PACE_BUILDING_COST_PLUS_25', 'LOC_MPT_PACE_PCT_PLUS_25', 'LOC_MPT_PACE_BUILDING_COST_AGE_PLUS_25_DESC', 30),
        ('MPTPaceBuildingCostAgeValues', 'MPT_PACE_BUILDING_COST_PLUS_50', 'LOC_MPT_PACE_PCT_PLUS_50', 'LOC_MPT_PACE_BUILDING_COST_AGE_PLUS_50_DESC', 60),
        ('MPTPaceBuildingCostAgeValues', 'MPT_PACE_BUILDING_COST_PLUS_100', 'LOC_MPT_PACE_PCT_PLUS_100', 'LOC_MPT_PACE_BUILDING_COST_AGE_PLUS_100_DESC', 100),
        ('MPTPaceVictoryProjectCostValues', 'MPT_PACE_VICTORY_PROJECT_COST_LOW', 'LOC_MPT_PACE_LOW_NAME', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_LOW_DESC', 10),
        ('MPTPaceVictoryProjectCostValues', 'MPT_PACE_VICTORY_PROJECT_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_STANDARD_DESC', 20),
        ('MPTPaceVictoryProjectCostValues', 'MPT_PACE_VICTORY_PROJECT_COST_MEDIUM', 'LOC_MPT_PACE_MEDIUM_NAME', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_MEDIUM_DESC', 25),
        ('MPTPaceVictoryProjectCostValues', 'MPT_PACE_VICTORY_PROJECT_COST_HIGH', 'LOC_MPT_PACE_HIGH_NAME', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_HIGH_DESC', 30),
        ('MPTPaceVictoryProjectCostValues', 'MPT_PACE_VICTORY_PROJECT_COST_DOUBLE', 'LOC_MPT_PACE_DOUBLE_NAME', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_DOUBLE_DESC', 40),
        ('MPTPaceVictoryProjectCostValues', 'MPT_PACE_VICTORY_PROJECT_COST_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_SWIFT_DESC', 43),
        ('MPTPaceVictoryProjectCostValues', 'MPT_PACE_VICTORY_PROJECT_COST_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_BALANCED_DESC', 45),
        ('MPTPaceVictoryProjectCostValues', 'MPT_PACE_VICTORY_PROJECT_COST_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 50),
        ('MPTPaceVictoryProjectCostAgeValues', 'MPT_PACE_VICTORY_PROJECT_COST_MINUS_25', 'LOC_MPT_PACE_PCT_MINUS_25', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_AGE_MINUS_25_DESC', 10),
        ('MPTPaceVictoryProjectCostAgeValues', 'MPT_PACE_VICTORY_PROJECT_COST_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_COST_STANDARD_DESC', 20),
        ('MPTPaceVictoryProjectCostAgeValues', 'MPT_PACE_VICTORY_PROJECT_COST_PLUS_25', 'LOC_MPT_PACE_PCT_PLUS_25', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_AGE_PLUS_25_DESC', 30),
        ('MPTPaceVictoryProjectCostAgeValues', 'MPT_PACE_VICTORY_PROJECT_COST_PLUS_50', 'LOC_MPT_PACE_PCT_PLUS_50', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_AGE_PLUS_50_DESC', 60),
        ('MPTPaceVictoryProjectCostAgeValues', 'MPT_PACE_VICTORY_PROJECT_COST_PLUS_100', 'LOC_MPT_PACE_PCT_PLUS_100', 'LOC_MPT_PACE_VICTORY_PROJECT_COST_AGE_PLUS_100_DESC', 100),
        ('MPTPaceSettlementGrowthValues', 'MPT_PACE_SETTLEMENT_GROWTH_SLOW', 'LOC_MPT_PACE_SLOW_NAME', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_SLOW_DESC', 10),
        ('MPTPaceSettlementGrowthValues', 'MPT_PACE_SETTLEMENT_GROWTH_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_STANDARD_DESC', 20),
        ('MPTPaceSettlementGrowthValues', 'MPT_PACE_SETTLEMENT_GROWTH_QUICK', 'LOC_MPT_PACE_QUICK_NAME', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_QUICK_DESC', 30),
        ('MPTPaceSettlementGrowthValues', 'MPT_PACE_SETTLEMENT_GROWTH_FAST', 'LOC_MPT_PACE_FAST_NAME', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_FAST_DESC', 40),
        ('MPTPaceSettlementGrowthValues', 'MPT_PACE_SETTLEMENT_GROWTH_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_SWIFT_DESC', 43),
        ('MPTPaceSettlementGrowthValues', 'MPT_PACE_SETTLEMENT_GROWTH_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_BALANCED_DESC', 45),
        ('MPTPaceSettlementGrowthValues', 'MPT_PACE_SETTLEMENT_GROWTH_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 50),
        ('MPTPaceSettlementGrowthAgeValues', 'MPT_PACE_SETTLEMENT_GROWTH_PLUS_25', 'LOC_MPT_PACE_PCT_PLUS_25', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_SLOW_DESC', 10),
        ('MPTPaceSettlementGrowthAgeValues', 'MPT_PACE_SETTLEMENT_GROWTH_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_STANDARD_DESC', 20),
        ('MPTPaceSettlementGrowthAgeValues', 'MPT_PACE_SETTLEMENT_GROWTH_MINUS_25', 'LOC_MPT_PACE_PCT_MINUS_25', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_QUICK_DESC', 30),
        ('MPTPaceSettlementGrowthAgeValues', 'MPT_PACE_SETTLEMENT_GROWTH_MINUS_50', 'LOC_MPT_PACE_PCT_MINUS_50', 'LOC_MPT_PACE_SETTLEMENT_GROWTH_FAST_DESC', 40),
        ('MPTPaceRoadSpeedValues', 'MPT_PACE_ROAD_SPEED_SLOW', 'LOC_MPT_PACE_SLOW_NAME', 'LOC_MPT_PACE_ROAD_SPEED_SLOW_DESC', 10),
        ('MPTPaceRoadSpeedValues', 'MPT_PACE_ROAD_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_ROAD_SPEED_STANDARD_DESC', 20),
        ('MPTPaceRoadSpeedValues', 'MPT_PACE_ROAD_SPEED_QUICK', 'LOC_MPT_PACE_QUICK_NAME', 'LOC_MPT_PACE_ROAD_SPEED_QUICK_DESC', 30),
        ('MPTPaceRoadSpeedValues', 'MPT_PACE_ROAD_SPEED_FAST', 'LOC_MPT_PACE_FAST_NAME', 'LOC_MPT_PACE_ROAD_SPEED_FAST_DESC', 40),
        ('MPTPaceRoadSpeedValues', 'MPT_PACE_ROAD_SPEED_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_ROAD_SPEED_SWIFT_DESC', 43),
        ('MPTPaceRoadSpeedValues', 'MPT_PACE_ROAD_SPEED_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_ROAD_SPEED_BALANCED_DESC', 45),
        ('MPTPaceRoadSpeedValues', 'MPT_PACE_ROAD_SPEED_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 50),
        ('MPTPaceRoadSpeedAgeValues', 'MPT_PACE_ROAD_SPEED_PLUS_25', 'LOC_MPT_PACE_PCT_PLUS_25', 'LOC_MPT_PACE_ROAD_SPEED_SLOW_DESC', 10),
        ('MPTPaceRoadSpeedAgeValues', 'MPT_PACE_ROAD_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_ROAD_SPEED_STANDARD_DESC', 20),
        ('MPTPaceRoadSpeedAgeValues', 'MPT_PACE_ROAD_SPEED_MINUS_25', 'LOC_MPT_PACE_PCT_MINUS_25', 'LOC_MPT_PACE_ROAD_SPEED_QUICK_DESC', 30),
        ('MPTPaceRoadSpeedAgeValues', 'MPT_PACE_ROAD_SPEED_MINUS_50', 'LOC_MPT_PACE_PCT_MINUS_50', 'LOC_MPT_PACE_ROAD_SPEED_FAST_DESC', 40),
        ('MPTPaceTradeSpeedValues', 'MPT_PACE_TRADE_SPEED_SLOW', 'LOC_MPT_PACE_SLOW_NAME', 'LOC_MPT_PACE_TRADE_SPEED_SLOW_DESC', 10),
        ('MPTPaceTradeSpeedValues', 'MPT_PACE_TRADE_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_TRADE_SPEED_DEFAULT_DESC', 20),
        ('MPTPaceTradeSpeedValues', 'MPT_PACE_TRADE_SPEED_QUICK', 'LOC_MPT_PACE_QUICK_NAME', 'LOC_MPT_PACE_TRADE_SPEED_QUICK_DESC', 30),
        ('MPTPaceTradeSpeedValues', 'MPT_PACE_TRADE_SPEED_FAST', 'LOC_MPT_PACE_FAST_NAME', 'LOC_MPT_PACE_TRADE_SPEED_FAST_DESC', 40),
        ('MPTPaceTradeSpeedValues', 'MPT_PACE_TRADE_SPEED_INSTANT', 'LOC_MPT_PACE_INSTANT_NAME', 'LOC_MPT_PACE_TRADE_SPEED_INSTANT_DESC', 50),
        ('MPTPaceTradeSpeedValues', 'MPT_PACE_TRADE_SPEED_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_TRADE_SPEED_SWIFT_DESC', 53),
        ('MPTPaceTradeSpeedValues', 'MPT_PACE_TRADE_SPEED_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_TRADE_SPEED_BALANCED_DESC', 55),
        ('MPTPaceTradeSpeedValues', 'MPT_PACE_TRADE_SPEED_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 60),
        ('MPTPaceTradeSpeedAgeValues', 'MPT_PACE_TRADE_SPEED_MINUS_25', 'LOC_MPT_PACE_PCT_MINUS_25', 'LOC_MPT_PACE_TRADE_SPEED_SLOW_DESC', 10),
        ('MPTPaceTradeSpeedAgeValues', 'MPT_PACE_TRADE_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_TRADE_SPEED_STANDARD_DESC', 20),
        ('MPTPaceTradeSpeedAgeValues', 'MPT_PACE_TRADE_SPEED_PLUS_25', 'LOC_MPT_PACE_PCT_PLUS_25', 'LOC_MPT_PACE_TRADE_SPEED_QUICK_DESC', 30),
        ('MPTPaceTradeSpeedAgeValues', 'MPT_PACE_TRADE_SPEED_PLUS_50', 'LOC_MPT_PACE_PCT_PLUS_50', 'LOC_MPT_PACE_TRADE_SPEED_FAST_DESC', 40),
        ('MPTPaceTradeSpeedAgeValues', 'MPT_PACE_TRADE_SPEED_INSTANT', 'LOC_MPT_PACE_INSTANT_NAME', 'LOC_MPT_PACE_TRADE_SPEED_INSTANT_DESC', 50),
        ('MPTPaceRazeSpeedValues', 'MPT_PACE_RAZE_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_RAZE_SPEED_STANDARD_DESC', 10),
        ('MPTPaceRazeSpeedValues', 'MPT_PACE_RAZE_SPEED_FAST', 'LOC_MPT_PACE_FAST_NAME', 'LOC_MPT_PACE_RAZE_SPEED_SHORTER_DESC', 20),
        ('MPTPaceRazeSpeedValues', 'MPT_PACE_RAZE_SPEED_INSTANT', 'LOC_MPT_PACE_INSTANT_NAME', 'LOC_MPT_PACE_RAZE_SPEED_INSTANT_DESC', 30),
        ('MPTPaceRazeSpeedValues', 'MPT_PACE_RAZE_SPEED_SWIFT', 'LOC_MPT_PACE_SWIFT_NAME', 'LOC_MPT_PACE_RAZE_SPEED_SWIFT_DESC', 33),
        ('MPTPaceRazeSpeedValues', 'MPT_PACE_RAZE_SPEED_BALANCED', 'LOC_MPT_PACE_BALANCED_NAME', 'LOC_MPT_PACE_RAZE_SPEED_BALANCED_DESC', 35),
        ('MPTPaceRazeSpeedValues', 'MPT_PACE_RAZE_SPEED_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_CUSTOM_DESC', 40),
        ('MPTPaceRazeSpeedAgeValues', 'MPT_PACE_RAZE_SPEED_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_RAZE_SPEED_STANDARD_DESC', 10),
        ('MPTPaceRazeSpeedAgeValues', 'MPT_PACE_RAZE_SPEED_PLUS_100', 'LOC_MPT_PACE_PCT_PLUS_100', 'LOC_MPT_PACE_RAZE_SPEED_SHORTER_DESC', 20),
        ('MPTPaceRazeSpeedAgeValues', 'MPT_PACE_RAZE_SPEED_INSTANT', 'LOC_MPT_PACE_INSTANT_NAME', 'LOC_MPT_PACE_RAZE_SPEED_INSTANT_DESC', 30);

--*******************************************************
--***************** VICTORY THRESHOLDS ******************
--*******************************************************
-- Culture, Economic and Military victory thresholds, each scaled on its own
-- (data/pace/victory-thresholds/), over the curve in use: the game's own, or
-- Game Balance's when it is Multiplayer. Science stays fixed. They sit on the
-- Advanced tab after Victory Settings; Victory Threshold Set, on Game Settings
-- (Victory Settings), sets all three, and shows Custom when they differ
-- (ui/pace/pace-rules.js).
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('VictoryThresholdOptions', 'LOC_GROUPID_MPT_VICTORYTHRESHOLDOPTIONS'),
        ('MPAdvancedVictoryThresholdOptions', 'LOC_GROUPID_MPT_VICTORYTHRESHOLDOPTIONS');

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTPaceVictoryThresholdSet', 'LOC_MPT_PACE_VICTORY_THRESHOLD_SET_NAME', 'LOC_MPT_PACE_VICTORY_THRESHOLD_SET_DESC', 'MPTPaceVictoryThresholdSets', 0, 'MPT_PACE_VICTORY_THRESHOLD_LOW', 'Game', 'MPTPaceVictoryThresholdSet', 'VictoryOptions', NULL, 0, 0, 4000),
        ('MPTPaceCultureVictoryThreshold', 'LOC_MPT_PACE_VICTORY_THRESHOLD_CULTURE_NAME', 'LOC_MPT_PACE_VICTORY_THRESHOLD_CULTURE_DESC', 'MPTPaceVictoryThresholds', 0, 'MPT_PACE_VICTORY_THRESHOLD_LOW', 'Game', 'MPTPaceCultureVictoryThreshold', 'VictoryThresholdOptions', 'MPAdvancedVictoryThresholdOptions', 0, 0, 4001),
        ('MPTPaceEconomicVictoryThreshold', 'LOC_MPT_PACE_VICTORY_THRESHOLD_ECONOMIC_NAME', 'LOC_MPT_PACE_VICTORY_THRESHOLD_ECONOMIC_DESC', 'MPTPaceVictoryThresholds', 0, 'MPT_PACE_VICTORY_THRESHOLD_LOW', 'Game', 'MPTPaceEconomicVictoryThreshold', 'VictoryThresholdOptions', 'MPAdvancedVictoryThresholdOptions', 0, 0, 4002),
        ('MPTPaceMilitaryVictoryThreshold', 'LOC_MPT_PACE_VICTORY_THRESHOLD_MILITARY_NAME', 'LOC_MPT_PACE_VICTORY_THRESHOLD_MILITARY_DESC', 'MPTPaceVictoryThresholds', 0, 'MPT_PACE_VICTORY_THRESHOLD_LOW', 'Game', 'MPTPaceMilitaryVictoryThreshold', 'VictoryThresholdOptions', 'MPAdvancedVictoryThresholdOptions', 0, 0, 4003);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTPaceVictoryThresholds', 'MPT_PACE_VICTORY_THRESHOLD_LOW', 'LOC_ADVANCED_OPTIONS_LOW', 'LOC_MPT_PACE_VICTORY_THRESHOLD_LOW_DESC', 10),
        ('MPTPaceVictoryThresholds', 'MPT_PACE_VICTORY_THRESHOLD_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_VICTORY_THRESHOLD_STANDARD_DESC', 20),
        ('MPTPaceVictoryThresholds', 'MPT_PACE_VICTORY_THRESHOLD_HIGH', 'LOC_ADVANCED_OPTIONS_HIGH', 'LOC_MPT_PACE_VICTORY_THRESHOLD_HIGH_DESC', 30),
        ('MPTPaceVictoryThresholdSets', 'MPT_PACE_VICTORY_THRESHOLD_LOW', 'LOC_ADVANCED_OPTIONS_LOW', 'LOC_MPT_PACE_VICTORY_THRESHOLD_SET_LOW_DESC', 10),
        ('MPTPaceVictoryThresholdSets', 'MPT_PACE_VICTORY_THRESHOLD_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_PACE_VICTORY_THRESHOLD_SET_STANDARD_DESC', 20),
        ('MPTPaceVictoryThresholdSets', 'MPT_PACE_VICTORY_THRESHOLD_HIGH', 'LOC_ADVANCED_OPTIONS_HIGH', 'LOC_MPT_PACE_VICTORY_THRESHOLD_SET_HIGH_DESC', 30),
        ('MPTPaceVictoryThresholdSets', 'MPT_PACE_VICTORY_THRESHOLD_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_PACE_VICTORY_THRESHOLD_SET_CUSTOM_DESC', 40);
