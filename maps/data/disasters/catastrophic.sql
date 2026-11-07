-- Disasters Catastrophic: the Catastrophic frequencies and active volcanoes on every intensity tier,
-- so they hold whatever Disaster Intensity is (Plagues are crisis-driven and left alone).
UPDATE RandomEventFrequencies
SET OccurrencesPerAge = (
    SELECT src.OccurrencesPerAge
    FROM RandomEventFrequencies src
    WHERE src.RandomEventType = RandomEventFrequencies.RandomEventType
    AND src.RealismSettingType = 'REALISM_SETTING_HEAVY'
)
WHERE RandomEventType NOT LIKE 'RANDOM_EVENT_PLAGUE%'
AND EXISTS (
    SELECT 1
    FROM RandomEventFrequencies src
    WHERE src.RandomEventType = RandomEventFrequencies.RandomEventType
    AND src.RealismSettingType = 'REALISM_SETTING_HEAVY'
);

UPDATE RealismSettings
SET PercentVolcanoesActive = (
    SELECT src.PercentVolcanoesActive
    FROM RealismSettings src
    WHERE src.RealismSettingType = 'REALISM_SETTING_HEAVY'
);
