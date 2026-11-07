-- data/timers/exploration/CompetitiveTimer.sql
-- Author: Zatygold

UPDATE MPT_TurnSegments
SET TimeLimit_Base = 20,
    TimeLimit_PerCity = 1.15,
    TimeLimit_PerUnit = 1.20
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE MPT_TimerScaling
SET PerHuman = 1.20,
    PerTurn = 1.30
WHERE ScalingId = 'DEFAULT';
