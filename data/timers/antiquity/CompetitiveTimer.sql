-- data/timers/antiquity/CompetitiveTimer.sql
-- Author: Zatygold

UPDATE MPT_TurnSegments
SET TimeLimit_Base = 10,
    TimeLimit_PerCity = 1.00,
    TimeLimit_PerUnit = 1.15
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE MPT_TimerScaling
SET PerHuman = 1.15,
    PerTurn = 1.20
WHERE ScalingId = 'DEFAULT';
