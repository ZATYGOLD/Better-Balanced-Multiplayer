-- Independent Aggression: independent powers get no defender units
-- (paired with Calm or Raging per Age).
UPDATE TribeTagSets
SET InitialUnitAmount = 0,
    MaxUnitAmount = 0
WHERE TribeTagName = 'DEFAULT_DEFENDER_TAGS';
