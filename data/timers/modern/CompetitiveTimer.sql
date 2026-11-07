-- data/timers/modern/CompetitiveTimer.sql
-- Author: Zatygold

UPDATE MPT_TurnSegments
SET TimeLimit_Base = 30,
    TimeLimit_PerCity = 1.25,
    TimeLimit_PerUnit = 1.25
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE MPT_TimerScaling
SET PerHuman = 1.30,
    PerTurn = 1.40
WHERE ScalingId = 'DEFAULT';
