--*******************************************************
--***************** EXPLORATION COMPETITIVE TIMER *******
--*******************************************************
-- The Competitive timer's Exploration numbers over the defaults (data/timers/timer-scaling.sql).
UPDATE BBM_TurnSegments
SET TimeLimit_Base = 50,
    TimeLimit_PerCity = 3.00,
    TimeLimit_PerUnit = 2.00,
    TimeLimit_Max = 150
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE BBM_TimerScaling
SET PerPlayer = 3.00,
    PerTurn = 1.40
WHERE ScalingId = 'DEFAULT';
