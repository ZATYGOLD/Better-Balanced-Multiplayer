--*******************************************************
--***************** BALANCE SETTINGS ********************
--*******************************************************
-- Game Balance: Multiplayer loads every balance change (modinfo criteria balance-*).
-- Multiplayer only, in Multiplayer Settings on Game Settings, directly above Kick
-- Vote; single player keeps the game's balance.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTBalance', 'LOC_MPT_BALANCE_NAME', 'LOC_MPT_BALANCE_DESC', 'MPTBalanceOptions', 0, 'MPT_BALANCE_MULTIPLAYER', 'Game', 'MPTBalance', 'LobbyOptions', 'SimpleSelectWindow', 0, 0, 28);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('MPTBalanceOptions', 'MPT_BALANCE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_MPT_BALANCE_STANDARD_DESC', 10),
        ('MPTBalanceOptions', 'MPT_BALANCE_MULTIPLAYER', 'LOC_MPT_BALANCE_MULTIPLAYER_NAME', 'LOC_MPT_BALANCE_MULTIPLAYER_DESC', 20);
