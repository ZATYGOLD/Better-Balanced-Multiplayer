-- data/timers/exploration/CompetitiveTimer.sql
-- Author: Zatygold

UPDATE MPT_TurnSegments
SET TimeLimit_Base = 35,
    TimeLimit_PerCity = 2.00,
    TimeLimit_PerUnit = 1.00
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE MPT_TimerScaling
SET PerHuman = 2.50,
    PerTurn = 1.25
WHERE ScalingId = 'DEFAULT';
