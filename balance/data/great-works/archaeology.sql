-- Artifact site counts used when an Explorer researches a continent.
-- Load this globally so the values exist before the Modern Age transition.
INSERT OR REPLACE INTO GlobalParameters (Name, Value)
VALUES
    ('ARCHAEOLOGY_SITES_PER_CONTINENT_ANTIQUITY', '22'),
    ('ARCHAEOLOGY_SITES_PER_CONTINENT_EXPLORATION', '16'),
    ('ARCHAEOLOGY_SITES_PER_CIV_SEA', '16'),
    ('ARCHAEOLOGY_SITES_BONUS_URBAN', '2');
