--*******************************************************
--***************** TURN TIMER SETTINGS *****************
--*******************************************************
INSERT OR IGNORE INTO TurnTimers (Domain, TurnTimerType, Name, Description, SortIndex)
    VALUES
        ('StandardTurnTimers', 'MPT_TURNTIMER_COMPETITIVE', 'LOC_MPT_TURNTIMER_COMPETITIVE', 'LOC_MPT_TURNTIMER_COMPETITIVE_DESC', 15);

-- The engine times a Turn Timer it does not know by Turn Time (TurnTimerTime), which
-- only Standard sets; unset, it ends every turn at once. Competitive sets it to an
-- hour, a backstop the Toolkit's own countdown (ui/mp-timer) always ends first.
-- Standard returns to the game's default.
INSERT OR IGNORE INTO ConfigurationUpdates (SourceGroup, SourceKey, SourceValue, TargetGroup, TargetKey, TargetValue, Hash)
    VALUES
        ('Game', 'TurnTimerType', 'MPT_TURNTIMER_COMPETITIVE', 'Game', 'TurnTimerTime', '3600', 0),
        ('Game', 'TurnTimerType', 'TURNTIMER_STANDARD', 'Game', 'TurnTimerTime', '180', 0);
