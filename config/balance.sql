--*******************************************************
--***************** BALANCE SETTINGS ********************
--*******************************************************
-- Game Balance: Multiplayer loads every balance change (modinfo criteria balance-*).
-- Multiplayer only, in Multiplayer Settings on Game Settings, directly above Kick
-- Vote; single player keeps the game's balance.
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupId, UxHint, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMBalance', 'LOC_BBM_BALANCE_NAME', 'LOC_BBM_BALANCE_DESC', 'BBMBalanceOptions', 0, 'BBM_BALANCE_MULTIPLAYER', 'Game', 'BBMBalance', 'LobbyOptions', 'SimpleSelectWindow', 0, 0, 28);

INSERT OR IGNORE INTO DomainValues (Domain, Value, Name, Description, SortIndex)
    VALUES
        ('BBMBalanceOptions', 'BBM_BALANCE_STANDARD', 'LOC_ADVANCED_OPTIONS_STANDARD', 'LOC_BBM_BALANCE_STANDARD_DESC', 10),
        ('BBMBalanceOptions', 'BBM_BALANCE_MULTIPLAYER', 'LOC_BBM_BALANCE_MULTIPLAYER_NAME', 'LOC_BBM_BALANCE_MULTIPLAYER_DESC', 20);

--*******************************************************
--***************** MEMENTOS ****************************
--*******************************************************
-- Mementos (the game's multiplayer-only row) sorts directly above Game Random
-- Seed in Game Options; single player keeps its own row.
UPDATE Parameters SET SortIndex = 169 WHERE ParameterID = 'MementosEnabled' AND SupportsSinglePlayer = 0;
