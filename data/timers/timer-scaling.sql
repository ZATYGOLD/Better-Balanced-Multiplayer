--*******************************************************
--*************** ADDITIONAL TIMER SCALING **************
--*******************************************************
-- Schema and defaults of the Competitive timer (ui/timer); every Age's
-- data/timers/<age>/competitive-timer.sql overrides them (loaded only in that Age).
--   seconds = Base + PerCity * (most cities) + PerUnit * (most units)
--           + PerHuman * (living human players, Observers excluded)
--           + PerTurn  * (current turn number)
-- Decimal values (e.g. 1.25) are supported.
CREATE TABLE IF NOT EXISTS BBM_TimerScaling
    (
        ScalingId TEXT NOT NULL,
        PerHuman REAL NOT NULL DEFAULT 0,
        PerTurn REAL NOT NULL DEFAULT 0,
        PRIMARY KEY(ScalingId)
    );

INSERT OR IGNORE INTO BBM_TimerScaling (ScalingId, PerHuman, PerTurn)
    VALUES
        ('DEFAULT', 2, 1);

--*******************************************************
--************** BBM COMPETITIVE TURN SEGMENT ***********
--*******************************************************
-- Mod-owned Base / PerCity / PerUnit, so the Competitive timer is fully
-- separate from the Dynamic timer (the game's TurnSegments is never modified).
CREATE TABLE IF NOT EXISTS BBM_TurnSegments
    (
        TurnSegmentType TEXT NOT NULL,
        TimeLimit_Base REAL NOT NULL DEFAULT 0,
        TimeLimit_PerCity REAL NOT NULL DEFAULT 0,
        TimeLimit_PerUnit REAL NOT NULL DEFAULT 0,
        PRIMARY KEY(TurnSegmentType)
    );

INSERT OR IGNORE INTO BBM_TurnSegments (TurnSegmentType, TimeLimit_Base, TimeLimit_PerCity, TimeLimit_PerUnit)
    VALUES
        ('TURN_SEGMENT_SINGLEPHASE', 20, 1, 1);
