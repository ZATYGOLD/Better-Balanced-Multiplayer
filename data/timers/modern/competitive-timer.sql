--*******************************************************
--***************** MODERN COMPETITIVE TIMER ************
--*******************************************************
-- The Competitive timer's Modern numbers over the defaults (data/timers/timer-scaling.sql).
UPDATE BBM_TurnSegments
SET TimeLimit_Base = 60,
    TimeLimit_PerCity = 3.30,
    TimeLimit_PerUnit = 1.50
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE BBM_TimerScaling
SET PerPlayer = 3.30,
    PerTurn = 1.50
WHERE ScalingId = 'DEFAULT';
