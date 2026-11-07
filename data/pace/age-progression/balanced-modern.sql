-- Age Progression Balanced: milestone and future tech/civic points for Modern.
UPDATE AgeProgressionEvents
SET Points = CASE AgeProgressionEventType
        WHEN 'AGE_PROGRESSION_PLAYER_MILESTONE_1' THEN 4
        WHEN 'AGE_PROGRESSION_PLAYER_MILESTONE_2' THEN 8
        WHEN 'AGE_PROGRESSION_PLAYER_MILESTONE_3' THEN 0
        WHEN 'AGE_PROGRESSION_FUTURE_CIVIC' THEN 7
        WHEN 'AGE_PROGRESSION_FUTURE_TECH' THEN 7
        ELSE Points
    END
WHERE AgeProgressionType = 'AGE_PROGRESSION_MODERN_AGE_TIMER';
