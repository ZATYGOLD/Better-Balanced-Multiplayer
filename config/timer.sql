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
-- only Standard sets; unset, it ends every turn at once. Competitive sets it to an
-- hour, a backstop the mod's own countdown (ui/timer) always ends first.
-- Standard returns it to the game's default (180).
INSERT OR IGNORE INTO ConfigurationUpdates (SourceGroup, SourceKey, SourceValue, TargetGroup, TargetKey, TargetValue, Hash)
    VALUES
        ('Game', 'TurnTimerType', 'BBM_TURNTIMER_COMPETITIVE', 'Game', 'TurnTimerTime', '3600', 0),
        ('Game', 'TurnTimerType', 'TURNTIMER_STANDARD', 'Game', 'TurnTimerTime', '180', 0);

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
