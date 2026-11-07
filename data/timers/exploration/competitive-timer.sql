--*******************************************************
--***************** EXPLORATION COMPETITIVE TIMER *******
--*******************************************************
-- The Competitive timer's Exploration numbers over the defaults (data/timers/timer-scaling.sql).
UPDATE MPT_TurnSegments
SET TimeLimit_Base = 35,
    TimeLimit_PerCity = 2.00,
    TimeLimit_PerUnit = 1.00
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE MPT_TimerScaling
SET PerHuman = 2.50,
    PerTurn = 1.25
WHERE ScalingId = 'DEFAULT';
