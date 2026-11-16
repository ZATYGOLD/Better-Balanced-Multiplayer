--*******************************************************
--***************** ANTIQUITY COMPETITIVE TIMER *********
--*******************************************************
-- The Competitive timer's Antiquity numbers over the defaults (data/timers/timer-scaling.sql).
UPDATE BBM_TurnSegments
SET TimeLimit_Base = 20,
    TimeLimit_PerCity = 1.30,
    TimeLimit_PerUnit = 1.30
WHERE TurnSegmentType = 'TURN_SEGMENT_SINGLEPHASE';

UPDATE BBM_TimerScaling
SET PerPlayer = 1.30,
    PerTurn = 1.30
WHERE ScalingId = 'DEFAULT';
