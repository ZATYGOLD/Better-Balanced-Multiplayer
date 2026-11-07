-- Crisis Timing: Early. Crisis stages begin at 50%, 65% and 85% Age progress.
UPDATE AgeCrisisStages
SET AgeProgressTriggerPercent = CASE Stage
        WHEN 1 THEN 50
        WHEN 2 THEN 65
        WHEN 3 THEN 85
        WHEN 4 THEN 100
        ELSE AgeProgressTriggerPercent
    END,
    AgeProgressEndPercent = CASE Stage
        WHEN 1 THEN 65
        WHEN 2 THEN 85
        WHEN 3 THEN 100
        WHEN 4 THEN 100
        ELSE AgeProgressEndPercent
    END
WHERE Stage IN (1, 2, 3, 4);
