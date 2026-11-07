--*******************************************************
--***************** PARAMETER GROUPS ********************
--*******************************************************
INSERT OR IGNORE INTO ParameterGroups (GroupId, Name)
    VALUES
        ('BalanceOptions', 'LOC_GROUPID_MPT_BALANCEOPTIONS'),
        ('MPAdvancedBalanceOptions', 'LOC_GROUPID_MPT_BALANCEOPTIONS');

--*******************************************************
--***************** BALANCE SETTINGS ********************
--*******************************************************
-- Multiplayer Balance: On loads every balance change (modinfo criteria balance-*).
-- Every balance setting is multiplayer only; single player keeps the game's balance.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, UxHint, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTBalance', 'LOC_MPT_BALANCE_NAME', 'LOC_MPT_BALANCE_DESC', 'MPTBalanceOptions', 0, 'MPT_BALANCE_ON', 'Game', 'MPTBalance', 'BalanceOptions', 'MPAdvancedBalanceOptions', 'SimpleSelectWindow', 0, 0, 10);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTBalanceOptions', 'MPT_BALANCE_ON', 'LOC_MPT_BALANCE_ON_NAME', 'LOC_MPT_BALANCE_ON_DESC', 10),
        ('MPTBalanceOptions', 'MPT_BALANCE_OFF', 'LOC_MPT_BALANCE_OFF_NAME', 'LOC_MPT_BALANCE_OFF_DESC', 20);

--*******************************************************
--***************** VICTORY SETTINGS ********************
--*******************************************************
-- Victory Threshold Scaling (data/victories/thresholds-*.sql).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, GroupIDMultiplayerOverride, SupportsSinglePlayer, ChangeableAfterGameStart, ChangeableAfterAgeTransition, UxHint, SortIndex)
    VALUES
        ('MPTBalanceVictoryThresholdScale', 'LOC_MPT_BALANCE_VICTORY_THRESHOLD_SCALE_NAME', 'LOC_MPT_BALANCE_VICTORY_THRESHOLD_SCALE_DESCRIPTION', 'MPTBalanceVictoryThresholdScales', 0, 'MPT_BALANCE_VICTORY_THRESHOLD_VERY_LOW', 'Game', 'MPTBalanceVictoryThresholdScale', 'VictoryOptions', 'MPAdvancedVictoryOptions', 0, 0, 0, 'SimpleSelectWindow', 4010);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTBalanceVictoryThresholdScales', 'MPT_BALANCE_VICTORY_THRESHOLD_STANDARD', 'LOC_MPT_BALANCE_VICTORY_THRESHOLD_STANDARD_NAME', 'LOC_MPT_BALANCE_VICTORY_THRESHOLD_STANDARD_DESCRIPTION', 10),
        ('MPTBalanceVictoryThresholdScales', 'MPT_BALANCE_VICTORY_THRESHOLD_LOW', 'LOC_MPT_BALANCE_VICTORY_THRESHOLD_LOW_NAME', 'LOC_MPT_BALANCE_VICTORY_THRESHOLD_LOW_DESCRIPTION', 20),
        ('MPTBalanceVictoryThresholdScales', 'MPT_BALANCE_VICTORY_THRESHOLD_VERY_LOW', 'LOC_MPT_BALANCE_VICTORY_THRESHOLD_VERY_LOW_NAME', 'LOC_MPT_BALANCE_VICTORY_THRESHOLD_VERY_LOW_DESCRIPTION', 30);

--*******************************************************
--***************** MEMENTO SETTINGS ********************
--*******************************************************
-- A second minor memento slot.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, ConfigurationGroup, ConfigurationKey, ValueConfigurationKey, GroupId, SupportsSinglePlayer, SortIndex)
    VALUES
        ('PlayerMementoMinorSlot2', 'LOC_PLAYER_MEMENTOS', 'LOC_MEMENTOS_GENERAL_DESCRIPTION', 'StandardMementos', 0, 'Player', 'MinorMemento2', 'MinorMemento2Value', 'PlayerOptions', 0, 3032);
