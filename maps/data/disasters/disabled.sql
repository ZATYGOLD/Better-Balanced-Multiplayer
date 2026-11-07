-- Disasters Off: every random disaster at zero (Plagues are crisis-driven and left alone).
UPDATE RandomEventFrequencies
SET OccurrencesPerAge = 0
WHERE RandomEventType NOT LIKE 'RANDOM_EVENT_PLAGUE%';
