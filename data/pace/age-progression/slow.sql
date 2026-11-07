-- Age Progression Slow: milestones and future techs/civics add half their age progress.
--
-- The floor keeps a small award from rounding away to nothing, but it must not
-- apply to an award the base game has already set to zero: Modern's third
-- milestone is 0 there, and flooring it to 1 would hand out age progress the
-- base game never gives.
UPDATE AgeProgressionEvents
SET Points = CASE WHEN Points > 0 THEN MAX(1, CAST(ROUND(Points * 0.5) AS INTEGER)) ELSE 0 END
WHERE AgeProgressionEventType IN ('AGE_PROGRESSION_PLAYER_MILESTONE_1', 'AGE_PROGRESSION_PLAYER_MILESTONE_2', 'AGE_PROGRESSION_PLAYER_MILESTONE_3', 'AGE_PROGRESSION_FUTURE_CIVIC', 'AGE_PROGRESSION_FUTURE_TECH');
