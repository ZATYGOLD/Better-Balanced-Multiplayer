--*******************************************************
--***************** PARAMETER GROUPS ********************
--*******************************************************
-- Multiplayer groups (ui/setup/bbm-setup-layout.js): Disaster and Crisis Settings
-- and Crises on Game Settings, the rest on the Advanced tab with the per-Age
-- Triumph Sets.
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('DisasterCrisisOptions', 'LOC_GROUPID_DISASTER_CRISIS_OPTIONS'),
        ('CrisesOptions', 'LOC_GROUPID_BBM_CRISESOPTIONS'),
        ('MPAdvancedTriumphSettings', 'LOC_GROUPID_TRIUMPH_SETTINGS_NAME'),
        ('SettlementOptions', 'LOC_GROUPID_BBM_SETTLEMENTOPTIONS'),
        ('MPAdvancedSettlementOptions', 'LOC_GROUPID_BBM_SETTLEMENTOPTIONS'),
        ('IndependentPowerOptions', 'LOC_GROUPID_BBM_INDEPENDENTPOWEROPTIONS'),
        ('MPAdvancedIndependentPowerOptions', 'LOC_GROUPID_BBM_INDEPENDENTPOWEROPTIONS'),
        ('WonderOptions', 'LOC_GROUPID_BBM_WONDEROPTIONS'),
        ('MPAdvancedWonderOptions', 'LOC_GROUPID_BBM_WONDEROPTIONS');

--*******************************************************
--***************** SETTLEMENT SETTINGS *****************
--*******************************************************
-- Settlement Distance, and Settlement Limit with a row per Age that follows it
-- (ui/gameplay/bbm-gameplay-rules.js; Custom leaves the rows to the host). The game
-- data reads the rows: a file per limit, none for each Age's own.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMGameplaySettlementDistance', 'LOC_BBM_GAMEPLAY_SETTLEMENT_DISTANCE_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_DISTANCE_DESC', 'BBMGameplaySettlementDistanceValues', 0, 'BBM_GAMEPLAY_SETTLEMENT_DISTANCE_STANDARD', 'Game', 'BBMGameplaySettlementDistance', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4600),
        ('BBMGameplaySettlementLimit', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_DESC', 'BBMGameplaySettlementLimitValues', 0, 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_STANDARD', 'Game', 'BBMGameplaySettlementLimit', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4610),
        ('BBMGameplaySettlementLimitAntiquity', 'LOC_AGE_ANTIQUITY_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_AGE_DESC', 'BBMGameplaySettlementLimitAgeValues', 0, 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_3', 'Game', 'BBMGameplaySettlementLimitAntiquity', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4611),
        ('BBMGameplaySettlementLimitExploration', 'LOC_AGE_EXPLORATION_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_AGE_DESC', 'BBMGameplaySettlementLimitAgeValues', 0, 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_8', 'Game', 'BBMGameplaySettlementLimitExploration', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4612),
        ('BBMGameplaySettlementLimitModern', 'LOC_AGE_MODERN_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_AGE_DESC', 'BBMGameplaySettlementLimitAgeValues', 0, 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_16', 'Game', 'BBMGameplaySettlementLimitModern', 'SettlementOptions', 'MPAdvancedSettlementOptions', 0, 0, 4613);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMGameplaySettlementDistanceValues', 'BBM_GAMEPLAY_SETTLEMENT_DISTANCE_LESS', 'LOC_BBM_GAMEPLAY_LESS_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_DISTANCE_LESS_DESC', 10),
        ('BBMGameplaySettlementDistanceValues', 'BBM_GAMEPLAY_SETTLEMENT_DISTANCE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_GAMEPLAY_SETTLEMENT_DISTANCE_STANDARD_DESC', 20),
        ('BBMGameplaySettlementDistanceValues', 'BBM_GAMEPLAY_SETTLEMENT_DISTANCE_MORE', 'LOC_BBM_GAMEPLAY_MORE_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_DISTANCE_MORE_DESC', 30),
        ('BBMGameplaySettlementLimitValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_LESS', 'LOC_BBM_GAMEPLAY_LESS_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_LESS_DESC', 10),
        ('BBMGameplaySettlementLimitValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_STANDARD_DESC', 20),
        ('BBMGameplaySettlementLimitValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_MORE', 'LOC_BBM_GAMEPLAY_MORE_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_MORE_DESC', 30),
        ('BBMGameplaySettlementLimitValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_CUSTOM_DESC', 40),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_1', 'LOC_BBM_GAMEPLAY_NUM_1', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 10),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_2', 'LOC_BBM_GAMEPLAY_NUM_2', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 20),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_3', 'LOC_BBM_GAMEPLAY_NUM_3', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 30),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_4', 'LOC_BBM_GAMEPLAY_NUM_4', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 40),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_5', 'LOC_BBM_GAMEPLAY_NUM_5', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 50),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_6', 'LOC_BBM_GAMEPLAY_NUM_6', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 60),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_7', 'LOC_BBM_GAMEPLAY_NUM_7', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 70),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_8', 'LOC_BBM_GAMEPLAY_NUM_8', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 80),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_9', 'LOC_BBM_GAMEPLAY_NUM_9', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 90),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_10', 'LOC_BBM_GAMEPLAY_NUM_10', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 100),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_11', 'LOC_BBM_GAMEPLAY_NUM_11', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 110),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_12', 'LOC_BBM_GAMEPLAY_NUM_12', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 120),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_13', 'LOC_BBM_GAMEPLAY_NUM_13', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 130),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_14', 'LOC_BBM_GAMEPLAY_NUM_14', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 140),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_15', 'LOC_BBM_GAMEPLAY_NUM_15', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 150),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_16', 'LOC_BBM_GAMEPLAY_NUM_16', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 160),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_17', 'LOC_BBM_GAMEPLAY_NUM_17', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 170),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_18', 'LOC_BBM_GAMEPLAY_NUM_18', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 180),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_19', 'LOC_BBM_GAMEPLAY_NUM_19', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 190),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_20', 'LOC_BBM_GAMEPLAY_NUM_20', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 200),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_21', 'LOC_BBM_GAMEPLAY_NUM_21', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 210),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_22', 'LOC_BBM_GAMEPLAY_NUM_22', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 220),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_23', 'LOC_BBM_GAMEPLAY_NUM_23', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 230),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_24', 'LOC_BBM_GAMEPLAY_NUM_24', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 240),
        ('BBMGameplaySettlementLimitAgeValues', 'BBM_GAMEPLAY_SETTLEMENT_LIMIT_25', 'LOC_BBM_GAMEPLAY_NUM_25', 'LOC_BBM_GAMEPLAY_SETTLEMENT_LIMIT_VALUE_DESC', 250);

--*******************************************************
--***************** INDEPENDENT POWER SETTINGS **********
--*******************************************************
-- Amount, spacing and aggression; the game's Initial Independent Hostility joins
-- them in multiplayer.
UPDATE Parameters SET GroupIDMultiplayerOverride = 'MPAdvancedIndependentPowerOptions' WHERE ParameterID = 'IndependentHostility';

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMGameplayIndependentCount', 'LOC_BBM_GAMEPLAY_INDEPENDENT_COUNT_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_COUNT_DESC', 'BBMGameplayIndependentCountValues', 0, 'BBM_GAMEPLAY_INDEPENDENT_COUNT_STANDARD', 'Game', 'BBMGameplayIndependentCount', 'IndependentPowerOptions', 'MPAdvancedIndependentPowerOptions', 0, 0, 4701),
        ('BBMGameplayIndependentSpacing', 'LOC_BBM_GAMEPLAY_INDEPENDENT_SPACING_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_SPACING_DESC', 'BBMGameplayIndependentSpacingValues', 0, 'BBM_GAMEPLAY_INDEPENDENT_SPACING_STANDARD', 'Game', 'BBMGameplayIndependentSpacing', 'IndependentPowerOptions', 'MPAdvancedIndependentPowerOptions', 0, 0, 4702),
        ('BBMGameplayIndependentAggression', 'LOC_BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_DESC', 'BBMGameplayIndependentAggressionValues', 0, 'BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_STANDARD', 'Game', 'BBMGameplayIndependentAggression', 'IndependentPowerOptions', 'MPAdvancedIndependentPowerOptions', 0, 0, 4703);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMGameplayIndependentCountValues', 'BBM_GAMEPLAY_INDEPENDENT_COUNT_NONE', 'LOC_BBM_GAMEPLAY_NONE_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_COUNT_NONE_DESC', 10),
        ('BBMGameplayIndependentCountValues', 'BBM_GAMEPLAY_INDEPENDENT_COUNT_LESS', 'LOC_BBM_GAMEPLAY_LESS_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_COUNT_LESS_DESC', 20),
        ('BBMGameplayIndependentCountValues', 'BBM_GAMEPLAY_INDEPENDENT_COUNT_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_GAMEPLAY_INDEPENDENT_COUNT_STANDARD_DESC', 30),
        ('BBMGameplayIndependentCountValues', 'BBM_GAMEPLAY_INDEPENDENT_COUNT_MORE', 'LOC_BBM_GAMEPLAY_MORE_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_COUNT_MORE_DESC', 40),
        ('BBMGameplayIndependentSpacingValues', 'BBM_GAMEPLAY_INDEPENDENT_SPACING_LESS', 'LOC_BBM_GAMEPLAY_LESS_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_SPACING_LESS_DESC', 10),
        ('BBMGameplayIndependentSpacingValues', 'BBM_GAMEPLAY_INDEPENDENT_SPACING_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_GAMEPLAY_INDEPENDENT_SPACING_STANDARD_DESC', 20),
        ('BBMGameplayIndependentSpacingValues', 'BBM_GAMEPLAY_INDEPENDENT_SPACING_MORE', 'LOC_BBM_GAMEPLAY_MORE_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_SPACING_MORE_DESC', 30),
        ('BBMGameplayIndependentAggressionValues', 'BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_CALM', 'LOC_BBM_GAMEPLAY_CALM_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_CALM_DESC', 10),
        ('BBMGameplayIndependentAggressionValues', 'BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_STANDARD_DESC', 20),
        ('BBMGameplayIndependentAggressionValues', 'BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_RAGING', 'LOC_BBM_GAMEPLAY_RAGING_NAME', 'LOC_BBM_GAMEPLAY_INDEPENDENT_AGGRESSION_RAGING_DESC', 30);

--*******************************************************
--***************** WONDER SETTINGS *********************
--*******************************************************
-- World Wonders: Carry Over keeps an earlier Age's unbuilt World Wonders
-- buildable by everyone, until built (data/gameplay/world-wonders/).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMGameplayWorldWonders', 'LOC_BBM_GAMEPLAY_WORLD_WONDERS_NAME', 'LOC_BBM_GAMEPLAY_WORLD_WONDERS_DESC', 'BBMGameplayWorldWondersValues', 0, 'BBM_GAMEPLAY_WORLD_WONDERS_STANDARD', 'Game', 'BBMGameplayWorldWonders', 'WonderOptions', 'MPAdvancedWonderOptions', 0, 0, 5000);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMGameplayWorldWondersValues', 'BBM_GAMEPLAY_WORLD_WONDERS_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_GAMEPLAY_WORLD_WONDERS_STANDARD_DESC', 10),
        ('BBMGameplayWorldWondersValues', 'BBM_GAMEPLAY_WORLD_WONDERS_CARRY_OVER', 'LOC_BBM_GAMEPLAY_CARRY_OVER_NAME', 'LOC_BBM_GAMEPLAY_WORLD_WONDERS_CARRY_OVER_DESC', 20);

--*******************************************************
--***************** DISASTER AND CRISIS SETTINGS ********
--*******************************************************
-- Disaster and Crisis Settings holds the game's Disaster Intensity, Crises and
-- Crisis Timing; the Crises section holds the game's crisis list. Crises drives
-- that list (ui/gameplay/bbm-gameplay-rules.js), which the game applies through its
-- ExcludeCrises key; Crisis Timing moves the crisis stages. Both start Disabled.
UPDATE Parameters SET GroupIDMultiplayerOverride = 'DisasterCrisisOptions' WHERE ParameterID = 'DisasterIntensity';

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMGameplayCrises', 'LOC_BBM_GAMEPLAY_CRISES_NAME', 'LOC_BBM_GAMEPLAY_CRISES_DESC', 'BBMGameplayCrisesValues', 0, 'BBM_GAMEPLAY_CRISES_OFF', 'Game', 'BBMGameplayCrises', 'DisasterCrisisOptions', NULL, 0, 0, 3020),
        ('BBMGameplayCrisisTiming', 'LOC_BBM_GAMEPLAY_CRISIS_TIMING_NAME', 'LOC_BBM_GAMEPLAY_CRISIS_TIMING_DESC', 'BBMGameplayCrisisTimingValues', 0, 'BBM_GAMEPLAY_CRISIS_TIMING_OFF', 'Game', 'BBMGameplayCrisisTiming', 'DisasterCrisisOptions', NULL, 0, 0, 3021);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMGameplayCrisesValues', 'BBM_GAMEPLAY_CRISES_ON', 'LOC_BBM_ENABLED_NAME', 'LOC_BBM_GAMEPLAY_CRISES_ON_DESC', 10),
        ('BBMGameplayCrisesValues', 'BBM_GAMEPLAY_CRISES_OFF', 'LOC_BBM_DISABLED_NAME', 'LOC_BBM_GAMEPLAY_CRISES_OFF_DESC', 20),
        ('BBMGameplayCrisisTimingValues', 'BBM_GAMEPLAY_CRISIS_TIMING_OFF', 'LOC_BBM_DISABLED_NAME', 'LOC_BBM_GAMEPLAY_CRISIS_TIMING_OFF_DESC', 10),
        ('BBMGameplayCrisisTimingValues', 'BBM_GAMEPLAY_CRISIS_TIMING_EARLY', 'LOC_BBM_GAMEPLAY_EARLY_NAME', 'LOC_BBM_GAMEPLAY_CRISIS_TIMING_EARLY_DESC', 20),
        ('BBMGameplayCrisisTimingValues', 'BBM_GAMEPLAY_CRISIS_TIMING_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_GAMEPLAY_CRISIS_TIMING_STANDARD_DESC', 30),
        ('BBMGameplayCrisisTimingValues', 'BBM_GAMEPLAY_CRISIS_TIMING_LATE', 'LOC_BBM_GAMEPLAY_LATE_NAME', 'LOC_BBM_GAMEPLAY_CRISIS_TIMING_LATE_DESC', 40);

-- The game's Crises list is split by mode: a multiplayer copy (same ParameterID;
-- BBMCrises, one flat list without per-Age categories) fills the Crises section,
-- and the shipped row keeps single player. Both rows are keyed to the standard
-- ruleset (the game's RulesetParameters query), so a single-player copy made
-- from the unkeyed rows later (Advanced Settings Pro) finds none to copy and
-- restyles the single-player row in place instead of adding a second one.
INSERT OR IGNORE INTO Parameters (Key1, Key2, ParameterID, Name, Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, GroupID, GroupIDMultiplayerOverride, Hidden, ReadOnly, SupportsSinglePlayer, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, SortIndex)
SELECT 'Ruleset', 'RULESET_STANDARD', ParameterID, Name, Description, 'BBMCrises', Hash, Array, DefaultValue, ConfigurationGroup, ConfigurationKey, DomainConfigurationKey, PossibleValuesConfigurationKey, ValueConfigurationKey, ValueNameConfigurationKey, ValueHashConfigurationKey, ValueDomainConfigurationKey, NameArrayConfigurationKey, 'CrisesOptions', NULL, Hidden, ReadOnly, 0, SupportsLANMultiplayer, SupportsInternetMultiplayer, SupportsHotseatMultiplayer, IsUGC, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, 3040
FROM Parameters
WHERE ParameterID = 'Crises' AND Key1 IS NULL AND Key2 IS NULL;

UPDATE Parameters SET Key1 = 'Ruleset', Key2 = 'RULESET_STANDARD', SupportsLANMultiplayer = 0, SupportsInternetMultiplayer = 0, SupportsHotseatMultiplayer = 0
WHERE ParameterID = 'Crises' AND Key1 IS NULL AND Key2 IS NULL;

INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('BBMCrises', 'DomainValues', 'SELECT ''BBMCrises'' AS Domain, Name, Description, AgeCrisisEventType AS Value, AgeType, SortIndex FROM Crises');

--*******************************************************
--***************** TRIUMPH SETS ************************
--*******************************************************
-- The game's Triumph Set gains Custom in multiplayer: the engine then reads
-- BBM_LEGACY_SET_CUSTOM, which data/gameplay/triumph-sets/ fills with the set
-- chosen for the Age in play. A row per Age follows the Triumph Set
-- (ui/gameplay/bbm-gameplay-rules.js) on the Advanced tab, while the Triumph Set
-- stays on Game Settings. Custom is filtered out whenever the hidden
-- multiplayer-only flag is unset (single-player setup).
INSERT OR IGNORE INTO LegacySets (LegacySetType, Name, Description, SortIndex)
    VALUES
        ('BBM_LEGACY_SET_CUSTOM', 'LOC_BBM_CUSTOM_NAME', 'LOC_BBM_GAMEPLAY_TRIUMPH_SET_CUSTOM_DESC', 5);

INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('BBMSinglePlayerLegacySets', 'DomainValueFilters', 'SELECT ''StandardLegacySets'' AS Domain, ''BBM_LEGACY_SET_CUSTOM'' AS Value, ''Difference'' AS Filter');

INSERT OR IGNORE INTO QueryCriteria (QueryID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('BBMSinglePlayerLegacySets', 'Game', 'BBMMultiplayerSetup', 'NotEquals', 1);

INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMGameplayTriumphSetAntiquity', 'LOC_AGE_ANTIQUITY_NAME', 'LOC_BBM_GAMEPLAY_TRIUMPH_SET_AGE_DESC', 'BBMGameplayTriumphSetAgeValues', 0, 'BBM_GAMEPLAY_TRIUMPH_SET_DEFAULT', 'Game', 'BBMGameplayTriumphSetAntiquity', 'TriumphSettings', 'MPAdvancedTriumphSettings', 0, 0, 181),
        ('BBMGameplayTriumphSetExploration', 'LOC_AGE_EXPLORATION_NAME', 'LOC_BBM_GAMEPLAY_TRIUMPH_SET_AGE_DESC', 'BBMGameplayTriumphSetAgeValues', 0, 'BBM_GAMEPLAY_TRIUMPH_SET_DEFAULT', 'Game', 'BBMGameplayTriumphSetExploration', 'TriumphSettings', 'MPAdvancedTriumphSettings', 0, 0, 182),
        ('BBMGameplayTriumphSetModern', 'LOC_AGE_MODERN_NAME', 'LOC_BBM_GAMEPLAY_TRIUMPH_SET_AGE_DESC', 'BBMGameplayTriumphSetAgeValues', 0, 'BBM_GAMEPLAY_TRIUMPH_SET_DEFAULT', 'Game', 'BBMGameplayTriumphSetModern', 'TriumphSettings', 'MPAdvancedTriumphSettings', 0, 0, 183);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMGameplayTriumphSetAgeValues', 'BBM_GAMEPLAY_TRIUMPH_SET_DEFAULT', 'LOC_TRIUMPH_SET_DEFAULT_NAME', 'LOC_TRIUMPH_SET_DEFAULT_DESCRIPTION', 10),
        ('BBMGameplayTriumphSetAgeValues', 'BBM_GAMEPLAY_TRIUMPH_SET_CLASSIC', 'LOC_TRIUMPH_SET_CLASSIC_NAME', 'LOC_TRIUMPH_SET_CLASSIC_DESCRIPTION', 20),
        ('BBMGameplayTriumphSetAgeValues', 'BBM_GAMEPLAY_TRIUMPH_SET_RACE', 'LOC_TRIUMPH_SET_RACE_NAME', 'LOC_TRIUMPH_SET_RACE_DESCRIPTION', 30),
        ('BBMGameplayTriumphSetAgeValues', 'BBM_GAMEPLAY_TRIUMPH_SET_CONQUEROR', 'LOC_TRIUMPH_SET_CONQUEROR_NAME', 'LOC_TRIUMPH_SET_CONQUEROR_DESCRIPTION', 40),
        ('BBMGameplayTriumphSetAgeValues', 'BBM_GAMEPLAY_TRIUMPH_SET_EXPLORER', 'LOC_TRIUMPH_SET_EXPLORER_NAME', 'LOC_TRIUMPH_SET_EXPLORER_DESCRIPTION', 50),
        ('BBMGameplayTriumphSetAgeValues', 'BBM_GAMEPLAY_TRIUMPH_SET_NONE', 'LOC_TRIUMPH_SET_NONE_NAME', 'LOC_TRIUMPH_SET_NONE_DESCRIPTION', 60);
