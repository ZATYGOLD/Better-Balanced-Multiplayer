--*******************************************************
--***************** ANTIQUITY COMPETITIVE TIMER *********
--*******************************************************
-- The Competitive timer's Antiquity numbers over the defaults (data/timers/timer-scaling.sql).
UPDATE MPT_TurnSegments
SET TimeLimit_Base = 30,
    TimeLimit_PerCity = 1.00,
    TimeLimit_PerUnit = 1.00
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE MPT_TimerScaling
SET PerHuman = 1.00,
    PerTurn = 1.00
WHERE ScalingId = 'DEFAULT';
