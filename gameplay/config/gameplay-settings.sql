--*******************************************************
--***************** PARAMETER GROUPS ********************
--*******************************************************
-- Multiplayer groups (ui/mp-setup/setup-layout.js): Disaster and Crisis Settings
-- and Crises on Game Settings, the rest on the Advanced tab with the per-Age
-- Triumph Sets.
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('DisasterCrisisOptions', 'LOC_GROUPID_DISASTER_CRISIS_OPTIONS'),
        ('CrisesOptions', 'LOC_GROUPID_MPT_CRISESOPTIONS'),
        ('MPAdvancedTriumphSettings', 'LOC_GROUPID_TRIUMPH_SETTINGS_NAME'),
        ('SettlementOptions', 'LOC_GROUPID_MPT_SETTLEMENTOPTIONS'),
        ('MPAdvancedSettlementOptions', 'LOC_GROUPID_MPT_SETTLEMENTOPTIONS'),
        ('IndependentPowerOptions', 'LOC_GROUPID_MPT_INDEPENDENTPOWEROPTIONS'),
        ('MPAdvancedIndependentPowerOptions', 'LOC_GROUPID_MPT_INDEPENDENTPOWEROPTIONS'),
        ('TradeOptions', 'LOC_GROUPID_MPT_TRADEOPTIONS'),
        ('MPAdvancedTradeOptions', 'LOC_GROUPID_MPT_TRADEOPTIONS');

--*******************************************************
--***************** SETTLEMENT SETTINGS *****************
--*******************************************************
-- Settlement Distance, and Settlement Limit with a row per Age that follows it
-- (gameplay/ui/gameplay-rules.js; Custom leaves the rows to the host). The game
-- data reads the rows: a file per limit, none for each Age's own.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTGameplaySettlementDistance', 'LOC_MPT_GAMEPLAY_SETTLEMENT_DISTANCE_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_DISTANCE_DESC', 'MPTGameplaySettlementDistanceValues', 0, 'MPT_GAMEPLAY_SETTLEMENT_DISTANCE_STANDARD', 'Game', 'MPTGameplaySettlementDistance', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4600),
        ('MPTGameplaySettlementLimit', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_DESC', 'MPTGameplaySettlementLimitValues', 0, 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_STANDARD', 'Game', 'MPTGameplaySettlementLimit', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4610),
        ('MPTGameplaySettlementLimitAntiquity', 'LOC_AGE_ANTIQUITY_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_AGE_DESC', 'MPTGameplaySettlementLimitAgeValues', 0, 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_3', 'Game', 'MPTGameplaySettlementLimitAntiquity', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4611),
        ('MPTGameplaySettlementLimitExploration', 'LOC_AGE_EXPLORATION_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_AGE_DESC', 'MPTGameplaySettlementLimitAgeValues', 0, 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_8', 'Game', 'MPTGameplaySettlementLimitExploration', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4612),
        ('MPTGameplaySettlementLimitModern', 'LOC_AGE_MODERN_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_AGE_DESC', 'MPTGameplaySettlementLimitAgeValues', 0, 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_16', 'Game', 'MPTGameplaySettlementLimitModern', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4613);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTGameplaySettlementDistanceValues', 'MPT_GAMEPLAY_SETTLEMENT_DISTANCE_LESS', 'LOC_MPT_GAMEPLAY_LESS_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_DISTANCE_LESS_DESC', 10),
        ('MPTGameplaySettlementDistanceValues', 'MPT_GAMEPLAY_SETTLEMENT_DISTANCE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_GAMEPLAY_SETTLEMENT_DISTANCE_STANDARD_DESC', 20),
        ('MPTGameplaySettlementDistanceValues', 'MPT_GAMEPLAY_SETTLEMENT_DISTANCE_MORE', 'LOC_MPT_GAMEPLAY_MORE_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_DISTANCE_MORE_DESC', 30),
        ('MPTGameplaySettlementLimitValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_LESS', 'LOC_MPT_GAMEPLAY_LESS_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_LESS_DESC', 10),
        ('MPTGameplaySettlementLimitValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_STANDARD_DESC', 20),
        ('MPTGameplaySettlementLimitValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_MORE', 'LOC_MPT_GAMEPLAY_MORE_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_MORE_DESC', 30),
        ('MPTGameplaySettlementLimitValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_CUSTOM_DESC', 40),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_1', 'LOC_MPT_GAMEPLAY_NUM_1', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 10),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_2', 'LOC_MPT_GAMEPLAY_NUM_2', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 20),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_3', 'LOC_MPT_GAMEPLAY_NUM_3', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 30),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_4', 'LOC_MPT_GAMEPLAY_NUM_4', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 40),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_5', 'LOC_MPT_GAMEPLAY_NUM_5', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 50),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_6', 'LOC_MPT_GAMEPLAY_NUM_6', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 60),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_7', 'LOC_MPT_GAMEPLAY_NUM_7', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 70),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_8', 'LOC_MPT_GAMEPLAY_NUM_8', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 80),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_9', 'LOC_MPT_GAMEPLAY_NUM_9', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 90),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_10', 'LOC_MPT_GAMEPLAY_NUM_10', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 100),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_11', 'LOC_MPT_GAMEPLAY_NUM_11', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 110),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_12', 'LOC_MPT_GAMEPLAY_NUM_12', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 120),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_13', 'LOC_MPT_GAMEPLAY_NUM_13', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 130),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_14', 'LOC_MPT_GAMEPLAY_NUM_14', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 140),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_15', 'LOC_MPT_GAMEPLAY_NUM_15', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 150),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_16', 'LOC_MPT_GAMEPLAY_NUM_16', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 160),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_17', 'LOC_MPT_GAMEPLAY_NUM_17', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 170),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_18', 'LOC_MPT_GAMEPLAY_NUM_18', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 180),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_19', 'LOC_MPT_GAMEPLAY_NUM_19', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 190),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_20', 'LOC_MPT_GAMEPLAY_NUM_20', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 200),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_21', 'LOC_MPT_GAMEPLAY_NUM_21', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 210),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_22', 'LOC_MPT_GAMEPLAY_NUM_22', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 220),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_23', 'LOC_MPT_GAMEPLAY_NUM_23', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 230),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_24', 'LOC_MPT_GAMEPLAY_NUM_24', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 240),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_25', 'LOC_MPT_GAMEPLAY_NUM_25', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 250),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_30', 'LOC_MPT_GAMEPLAY_NUM_30', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 300),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_35', 'LOC_MPT_GAMEPLAY_NUM_35', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 350),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_40', 'LOC_MPT_GAMEPLAY_NUM_40', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 400),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_45', 'LOC_MPT_GAMEPLAY_NUM_45', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 450),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_50', 'LOC_MPT_GAMEPLAY_NUM_50', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 500),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_55', 'LOC_MPT_GAMEPLAY_NUM_55', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 550),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_60', 'LOC_MPT_GAMEPLAY_NUM_60', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 600),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_65', 'LOC_MPT_GAMEPLAY_NUM_65', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 650),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_70', 'LOC_MPT_GAMEPLAY_NUM_70', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 700),
        ('MPTGameplaySettlementLimitAgeValues', 'MPT_GAMEPLAY_SETTLEMENT_LIMIT_75', 'LOC_MPT_GAMEPLAY_NUM_75', 'LOC_MPT_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 750);

--*******************************************************
--***************** INDEPENDENT POWER SETTINGS **********
--*******************************************************
-- Amount, spacing and aggression; the game's Initial Independent Hostility joins
-- them in multiplayer.
UPDATE Parameters SET GroupIDMultiplayerOverride = 'MPAdvancedIndependentPowerOptions' WHERE ParameterID = 'IndependentHostility';

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTGameplayIndependentCount', 'LOC_MPT_GAMEPLAY_INDEPENDENT_COUNT_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_COUNT_DESC', 'MPTGameplayIndependentCountValues', 0, 'MPT_GAMEPLAY_INDEPENDENT_COUNT_STANDARD', 'Game', 'MPTGameplayIndependentCount', 'IndependentPowerOptions', 'MPAdvancedIndependentPowerOptions', 0, 0, 4701),
        ('MPTGameplayIndependentSpacing', 'LOC_MPT_GAMEPLAY_INDEPENDENT_SPACING_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_SPACING_DESC', 'MPTGameplayIndependentSpacingValues', 0, 'MPT_GAMEPLAY_INDEPENDENT_SPACING_STANDARD', 'Game', 'MPTGameplayIndependentSpacing', 'IndependentPowerOptions', 'MPAdvancedIndependentPowerOptions', 0, 0, 4702),
        ('MPTGameplayIndependentAggression', 'LOC_MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_DESC', 'MPTGameplayIndependentAggressionValues', 0, 'MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_STANDARD', 'Game', 'MPTGameplayIndependentAggression', 'IndependentPowerOptions', 'MPAdvancedIndependentPowerOptions', 0, 0, 4703);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTGameplayIndependentCountValues', 'MPT_GAMEPLAY_INDEPENDENT_COUNT_NONE', 'LOC_MPT_GAMEPLAY_NONE_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_COUNT_NONE_DESC', 10),
        ('MPTGameplayIndependentCountValues', 'MPT_GAMEPLAY_INDEPENDENT_COUNT_LESS', 'LOC_MPT_GAMEPLAY_LESS_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_COUNT_LESS_DESC', 20),
        ('MPTGameplayIndependentCountValues', 'MPT_GAMEPLAY_INDEPENDENT_COUNT_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_GAMEPLAY_INDEPENDENT_COUNT_STANDARD_DESC', 30),
        ('MPTGameplayIndependentCountValues', 'MPT_GAMEPLAY_INDEPENDENT_COUNT_MORE', 'LOC_MPT_GAMEPLAY_MORE_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_COUNT_MORE_DESC', 40),
        ('MPTGameplayIndependentSpacingValues', 'MPT_GAMEPLAY_INDEPENDENT_SPACING_LESS', 'LOC_MPT_GAMEPLAY_LESS_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_SPACING_LESS_DESC', 10),
        ('MPTGameplayIndependentSpacingValues', 'MPT_GAMEPLAY_INDEPENDENT_SPACING_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_GAMEPLAY_INDEPENDENT_SPACING_STANDARD_DESC', 20),
        ('MPTGameplayIndependentSpacingValues', 'MPT_GAMEPLAY_INDEPENDENT_SPACING_MORE', 'LOC_MPT_GAMEPLAY_MORE_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_SPACING_MORE_DESC', 30),
        ('MPTGameplayIndependentAggressionValues', 'MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_CALM', 'LOC_MPT_GAMEPLAY_CALM_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_CALM_DESC', 10),
        ('MPTGameplayIndependentAggressionValues', 'MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_STANDARD_DESC', 20),
        ('MPTGameplayIndependentAggressionValues', 'MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_RAGING', 'LOC_MPT_GAMEPLAY_RAGING_NAME', 'LOC_MPT_GAMEPLAY_INDEPENDENT_AGGRESSION_RAGING_DESC', 30);

--*******************************************************
--***************** TRADE SETTINGS **********************
--*******************************************************
-- Trade Range scales each Age's land and sea trade range, with a row per Age
-- that follows it, as Settlement Limit does.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTGameplayTradeRange', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_DESC', 'MPTGameplayTradeRangeValues', 0, 'MPT_GAMEPLAY_TRADE_RANGE_STANDARD', 'Game', 'MPTGameplayTradeRange', 'TradeOptions', 'MPAdvancedTradeOptions', 0, 0, 4900),
        ('MPTGameplayTradeRangeAntiquity', 'LOC_AGE_ANTIQUITY_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_AGE_DESC', 'MPTGameplayTradeRangeAgeValues', 0, 'MPT_GAMEPLAY_TRADE_RANGE_STANDARD', 'Game', 'MPTGameplayTradeRangeAntiquity', 'TradeOptions', 'MPAdvancedTradeOptions', 0, 0, 4901),
        ('MPTGameplayTradeRangeExploration', 'LOC_AGE_EXPLORATION_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_AGE_DESC', 'MPTGameplayTradeRangeAgeValues', 0, 'MPT_GAMEPLAY_TRADE_RANGE_STANDARD', 'Game', 'MPTGameplayTradeRangeExploration', 'TradeOptions', 'MPAdvancedTradeOptions', 0, 0, 4902),
        ('MPTGameplayTradeRangeModern', 'LOC_AGE_MODERN_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_AGE_DESC', 'MPTGameplayTradeRangeAgeValues', 0, 'MPT_GAMEPLAY_TRADE_RANGE_STANDARD', 'Game', 'MPTGameplayTradeRangeModern', 'TradeOptions', 'MPAdvancedTradeOptions', 0, 0, 4903);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTGameplayTradeRangeValues', 'MPT_GAMEPLAY_TRADE_RANGE_MINUS_50', 'LOC_MPT_GAMEPLAY_PCT_MINUS_50_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_MINUS_50_DESC', 10),
        ('MPTGameplayTradeRangeValues', 'MPT_GAMEPLAY_TRADE_RANGE_MINUS_25', 'LOC_MPT_GAMEPLAY_PCT_MINUS_25_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_MINUS_25_DESC', 20),
        ('MPTGameplayTradeRangeValues', 'MPT_GAMEPLAY_TRADE_RANGE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_STANDARD_DESC', 30),
        ('MPTGameplayTradeRangeValues', 'MPT_GAMEPLAY_TRADE_RANGE_PLUS_25', 'LOC_MPT_GAMEPLAY_PCT_PLUS_25_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_PLUS_25_DESC', 40),
        ('MPTGameplayTradeRangeValues', 'MPT_GAMEPLAY_TRADE_RANGE_PLUS_50', 'LOC_MPT_GAMEPLAY_PCT_PLUS_50_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_PLUS_50_DESC', 50),
        ('MPTGameplayTradeRangeValues', 'MPT_GAMEPLAY_TRADE_RANGE_PLUS_100', 'LOC_MPT_GAMEPLAY_PCT_PLUS_100_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_PLUS_100_DESC', 60),
        ('MPTGameplayTradeRangeValues', 'MPT_GAMEPLAY_TRADE_RANGE_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_CUSTOM_DESC', 70),
        ('MPTGameplayTradeRangeAgeValues', 'MPT_GAMEPLAY_TRADE_RANGE_MINUS_50', 'LOC_MPT_GAMEPLAY_PCT_MINUS_50_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_MINUS_50_DESC', 10),
        ('MPTGameplayTradeRangeAgeValues', 'MPT_GAMEPLAY_TRADE_RANGE_MINUS_25', 'LOC_MPT_GAMEPLAY_PCT_MINUS_25_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_MINUS_25_DESC', 20),
        ('MPTGameplayTradeRangeAgeValues', 'MPT_GAMEPLAY_TRADE_RANGE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_STANDARD_DESC', 30),
        ('MPTGameplayTradeRangeAgeValues', 'MPT_GAMEPLAY_TRADE_RANGE_PLUS_25', 'LOC_MPT_GAMEPLAY_PCT_PLUS_25_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_PLUS_25_DESC', 40),
        ('MPTGameplayTradeRangeAgeValues', 'MPT_GAMEPLAY_TRADE_RANGE_PLUS_50', 'LOC_MPT_GAMEPLAY_PCT_PLUS_50_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_PLUS_50_DESC', 50),
        ('MPTGameplayTradeRangeAgeValues', 'MPT_GAMEPLAY_TRADE_RANGE_PLUS_100', 'LOC_MPT_GAMEPLAY_PCT_PLUS_100_NAME', 'LOC_MPT_GAMEPLAY_TRADE_RANGE_PLUS_100_DESC', 60);

--*******************************************************
--***************** DISASTER AND CRISIS SETTINGS *******
--*******************************************************
-- The single-player layout in multiplayer: Disaster and Crisis Settings holds the
-- game's Disaster Intensity, Crises and Crisis Timing; the Crises section holds the
-- game's crisis list. Crises drives that list (gameplay/ui/gameplay-rules.js),
-- which the game applies through its ExcludeCrises key; Crisis Timing moves the
-- crisis stages.
UPDATE Parameters SET GroupIDMultiplayerOverride = 'DisasterCrisisOptions' WHERE ParameterID = 'DisasterIntensity';

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTGameplayCrises', 'LOC_MPT_GAMEPLAY_CRISES_NAME', 'LOC_MPT_GAMEPLAY_CRISES_DESC', 'MPTGameplayCrisesValues', 0, 'MPT_GAMEPLAY_CRISES_ON', 'Game', 'MPTGameplayCrises', 'DisasterCrisisOptions', NULL, 0, 0, 3020),
        ('MPTGameplayCrisisTiming', 'LOC_MPT_GAMEPLAY_CRISIS_TIMING_NAME', 'LOC_MPT_GAMEPLAY_CRISIS_TIMING_DESC', 'MPTGameplayCrisisTimingValues', 0, 'MPT_GAMEPLAY_CRISIS_TIMING_STANDARD', 'Game', 'MPTGameplayCrisisTiming', 'DisasterCrisisOptions', NULL, 0, 0, 3021);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTGameplayCrisesValues', 'MPT_GAMEPLAY_CRISES_ON', 'LOC_ADVANCED_OPTIONS_ON', 'LOC_MPT_GAMEPLAY_CRISES_ON_DESC', 10),
        ('MPTGameplayCrisesValues', 'MPT_GAMEPLAY_CRISES_OFF', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_GAMEPLAY_CRISES_OFF_DESC', 20),
        ('MPTGameplayCrisisTimingValues', 'MPT_GAMEPLAY_CRISIS_TIMING_OFF', 'LOC_ADVANCED_OPTIONS_OFF', 'LOC_MPT_GAMEPLAY_CRISIS_TIMING_OFF_DESC', 10),
        ('MPTGameplayCrisisTimingValues', 'MPT_GAMEPLAY_CRISIS_TIMING_EARLY', 'LOC_MPT_GAMEPLAY_EARLY_NAME', 'LOC_MPT_GAMEPLAY_CRISIS_TIMING_EARLY_DESC', 20),
        ('MPTGameplayCrisisTimingValues', 'MPT_GAMEPLAY_CRISIS_TIMING_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_GAMEPLAY_CRISIS_TIMING_STANDARD_DESC', 30),
        ('MPTGameplayCrisisTimingValues', 'MPT_GAMEPLAY_CRISIS_TIMING_LATE', 'LOC_MPT_GAMEPLAY_LATE_NAME', 'LOC_MPT_GAMEPLAY_CRISIS_TIMING_LATE_DESC', 40);

-- The game's Crises list is split by mode: a multiplayer copy (same ParameterID)
-- fills the Crises section, one flat list as in single player (its domain has no
-- per-Age categories), and the shipped row keeps single player. Both rows are keyed to the standard
-- ruleset (the game's RulesetParameters query), so a single-player copy made
-- from the unkeyed rows later (Advanced Settings Pro) finds none to copy and
-- restyles the single-player row in place instead of adding a second one.
INSERT OR IGNORE INTO Parameters (Key1, Key2, ParameterID, Name, Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, GroupID, GroupIDMultiplayerOverride, Hidden, ReadOnly, SupportsSinglePlayer, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, SortIndex)
SELECT 'Ruleset', 'RULESET_STANDARD', ParameterID, Name, Description, 'MPTCrises', Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, 'CrisesOptions', NULL, Hidden, ReadOnly, 0, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, 3040
FROM Parameters
WHERE ParameterID = 'Crises' AND Key1 IS NULL AND Key2 IS NULL;

UPDATE Parameters SET Key1 = 'Ruleset', Key2 = 'RULESET_STANDARD', SupportsLANMultiplayer = 0, SupportsInternetMultiplayer = 0, SupportsHotseatMultiplayer = 0
WHERE ParameterID = 'Crises' AND Key1 IS NULL AND Key2 IS NULL;

INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('MPTCrises', 'DomainValues', 'SELECT ''MPTCrises'' AS Domain, Name, Description, AgeCrisisEventType AS Value, AgeType, SortIndex FROM Crises');

--*******************************************************
--***************** TRIUMPH SETS ************************
--*******************************************************
-- The game's Triumph Set gains Custom in multiplayer: the engine then reads
-- MPT_LEGACY_SET_CUSTOM, which gameplay/data/triumph-sets/ fills with the set
-- chosen for the Age in play. A row per Age follows the Triumph Set
-- (gameplay/ui/gameplay-rules.js) on the Advanced tab, while the Triumph Set
-- stays on Game Settings. Custom is filtered out whenever the hidden
-- multiplayer-only flag is unset (single-player setup).
INSERT OR IGNORE INTO LegacySets (LegacySetType, Name, Description, SortIndex)
    VALUES ('MPT_LEGACY_SET_CUSTOM', 'LOC_DIFFICULTY_CUSTOM_NAME', 'LOC_MPT_GAMEPLAY_TRIUMPH_SET_CUSTOM_DESC', 5);

INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('MPTSinglePlayerLegacySets', 'DomainValueFilters', 'SELECT ''StandardLegacySets'' AS Domain, ''MPT_LEGACY_SET_CUSTOM'' AS Value, ''Difference'' AS Filter');

INSERT OR IGNORE INTO QueryCriteria (QueryID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('MPTSinglePlayerLegacySets', 'Game', 'MPTMultiplayerSetup', 'NotEquals', 1);

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTGameplayTriumphSetAntiquity', 'LOC_AGE_ANTIQUITY_NAME', 'LOC_MPT_GAMEPLAY_TRIUMPH_SET_AGE_DESC', 'MPTGameplayTriumphSetAgeValues', 0, 'MPT_GAMEPLAY_TRIUMPH_SET_DEFAULT', 'Game', 'MPTGameplayTriumphSetAntiquity', 'TriumphSettings', 'MPAdvancedTriumphSettings', 0, 0, 181),
        ('MPTGameplayTriumphSetExploration', 'LOC_AGE_EXPLORATION_NAME', 'LOC_MPT_GAMEPLAY_TRIUMPH_SET_AGE_DESC', 'MPTGameplayTriumphSetAgeValues', 0, 'MPT_GAMEPLAY_TRIUMPH_SET_DEFAULT', 'Game', 'MPTGameplayTriumphSetExploration', 'TriumphSettings', 'MPAdvancedTriumphSettings', 0, 0, 182),
        ('MPTGameplayTriumphSetModern', 'LOC_AGE_MODERN_NAME', 'LOC_MPT_GAMEPLAY_TRIUMPH_SET_AGE_DESC', 'MPTGameplayTriumphSetAgeValues', 0, 'MPT_GAMEPLAY_TRIUMPH_SET_DEFAULT', 'Game', 'MPTGameplayTriumphSetModern', 'TriumphSettings', 'MPAdvancedTriumphSettings', 0, 0, 183);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTGameplayTriumphSetAgeValues', 'MPT_GAMEPLAY_TRIUMPH_SET_DEFAULT', 'LOC_TRIUMPH_SET_DEFAULT_NAME', 'LOC_TRIUMPH_SET_DEFAULT_DESCRIPTION', 10),
        ('MPTGameplayTriumphSetAgeValues', 'MPT_GAMEPLAY_TRIUMPH_SET_CLASSIC', 'LOC_TRIUMPH_SET_CLASSIC_NAME', 'LOC_TRIUMPH_SET_CLASSIC_DESCRIPTION', 20),
        ('MPTGameplayTriumphSetAgeValues', 'MPT_GAMEPLAY_TRIUMPH_SET_RACE', 'LOC_TRIUMPH_SET_RACE_NAME', 'LOC_TRIUMPH_SET_RACE_DESCRIPTION', 30),
        ('MPTGameplayTriumphSetAgeValues', 'MPT_GAMEPLAY_TRIUMPH_SET_CONQUEROR', 'LOC_TRIUMPH_SET_CONQUEROR_NAME', 'LOC_TRIUMPH_SET_CONQUEROR_DESCRIPTION', 40),
        ('MPTGameplayTriumphSetAgeValues', 'MPT_GAMEPLAY_TRIUMPH_SET_EXPLORER', 'LOC_TRIUMPH_SET_EXPLORER_NAME', 'LOC_TRIUMPH_SET_EXPLORER_DESCRIPTION', 50),
        ('MPTGameplayTriumphSetAgeValues', 'MPT_GAMEPLAY_TRIUMPH_SET_NONE', 'LOC_TRIUMPH_SET_NONE_NAME', 'LOC_TRIUMPH_SET_NONE_DESCRIPTION', 60);
