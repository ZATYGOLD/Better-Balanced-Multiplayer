-- data/timers/modern/CompetitiveTimer.sql
-- Author: Zatygold

UPDATE MPT_TurnSegments
SET TimeLimit_Base = 40,
    TimeLimit_PerCity = 3.00,
    TimeLimit_PerUnit = 1.00
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE MPT_TimerScaling
SET PerHuman = 3.00,
    PerTurn = 1.50
WHERE ScalingId = 'DEFAULT';
