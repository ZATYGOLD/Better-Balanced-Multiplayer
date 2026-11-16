--*******************************************************
--***************** TURN TIMER SETTINGS *****************
--*******************************************************
INSERT OR IGNORE INTO TurnTimers (Domain, TurnTimerType, Name, Description, SortIndex)
    VALUES
        ('StandardTurnTimers', 'BBM_TURNTIMER_COMPETITIVE', 'LOC_BBM_TURNTIMER_COMPETITIVE', 'LOC_BBM_TURNTIMER_COMPETITIVE_DESC', 15);

-- Turn Timer (multiplayer only) takes a description that fits Competitive too,
-- and Competitive is its default.
UPDATE Parameters SET Description = 'LOC_BBM_TURNTIMER_DESC', DefaultValue = 'BBM_TURNTIMER_COMPETITIVE' WHERE ParameterID = 'TurnTimerType' AND SupportsSinglePlayer = 0;

-- The engine times a Turn Timer it does not know by Turn Time (TurnTimerTime), which
-- only Standard shows; unset, it ends every turn at once. It times the first turn of
-- each Age by Extended Turn Time (TurnTimerExtendedTime) instead. Under Competitive
-- hidden parameters hold both at an hour, a backstop the mod's own countdown (ui/timer)
-- always ends first (the first turn is untimed), so every setup refresh restores them.
-- Choosing Competitive sets them too, and Standard returns them to the game's
-- defaults (180 and 480).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupID, Hidden, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('BBMCompetitiveTurnTime', 'LOC_GAME_TURN_TIMER_TIME', 'LOC_GAME_TURN_TIMER_TIME_TOOLTIP', 'uint', 0, 3600, 'Game', 'TurnTimerTime', 'GameOptions', 1, 0, 1, 80),
        ('BBMCompetitiveExtendedTurnTime', 'LOC_GAME_TURN_TIMER_TIME_EXTENDED', 'LOC_GAME_TURN_TIMER_TIME_EXTENDED_TOOLTIP', 'uint', 0, 3600, 'Game', 'TurnTimerExtendedTime', 'GameOptions', 1, 0, 1, 81);

INSERT OR IGNORE INTO ParameterCriteria (ParameterID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('BBMCompetitiveTurnTime', 'Game', 'TurnTimerType', 'Equals', 'BBM_TURNTIMER_COMPETITIVE'),
        ('BBMCompetitiveExtendedTurnTime', 'Game', 'TurnTimerType', 'Equals', 'BBM_TURNTIMER_COMPETITIVE');

INSERT OR IGNORE INTO ConfigurationUpdates (SourceGroup, SourceKey, SourceValue, TargetGroup, TargetKey, TargetValue, Hash)
    VALUES
        ('Game', 'TurnTimerType', 'BBM_TURNTIMER_COMPETITIVE', 'Game', 'TurnTimerTime', '3600', 0),
        ('Game', 'TurnTimerType', 'TURNTIMER_STANDARD', 'Game', 'TurnTimerTime', '180', 0),
        ('Game', 'TurnTimerType', 'BBM_TURNTIMER_COMPETITIVE', 'Game', 'TurnTimerExtendedTime', '3600', 0),
        ('Game', 'TurnTimerType', 'TURNTIMER_STANDARD', 'Game', 'TurnTimerExtendedTime', '480', 0);

--*******************************************************
--***************** GAME SPEEDS AND AGE LENGTH **********
--*******************************************************
-- Multiplayer offers no setting longer than Standard: Epic and Marathon speeds
-- and the Long Age Length are filtered out whenever the hidden multiplayer-only
-- flag (config/maps.sql) is set. Single player keeps them.
INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('BBMMultiplayerGameSpeeds', 'DomainValueFilters', 'SELECT ''StandardGameSpeeds'' AS Domain, GameSpeedType AS Value, ''Difference'' AS Filter FROM GameSpeeds WHERE GameSpeedType IN (''GAMESPEED_EPIC'', ''GAMESPEED_MARATHON'')'),
        ('BBMMultiplayerAgeLengths', 'DomainValueFilters', 'SELECT ''StandardAgeLengths'' AS Domain, ''AGE_LENGTH_LONG'' AS Value, ''Difference'' AS Filter');

INSERT OR IGNORE INTO QueryCriteria (QueryID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('BBMMultiplayerGameSpeeds', 'Game', 'BBMMultiplayerSetup', 'Equals', 1),
        ('BBMMultiplayerAgeLengths', 'Game', 'BBMMultiplayerSetup', 'Equals', 1);
