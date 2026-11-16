--*******************************************************
--***************** EXPLORATION COMPETITIVE TIMER *******
--*******************************************************
-- The Competitive timer's Exploration numbers over the defaults (data/timers/timer-scaling.sql).
UPDATE BBM_TurnSegments
SET TimeLimit_Base = 40,
    TimeLimit_PerCity = 2.30,
    TimeLimit_PerUnit = 1.40
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE BBM_TimerScaling
SET PerHuman = 2.30,
    PerTurn = 1.40
WHERE ScalingId = 'DEFAULT';
