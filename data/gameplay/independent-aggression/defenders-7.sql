-- Independent Aggression: independent powers start with 7 defender units, and keep at most 7
-- (paired with Calm or Raging per Age).
UPDATE TribeTagSets
SET InitialUnitAmount = 7,
    MaxUnitAmount = 7
WHERE TribeTagName = 'DEFAULT_DEFENDER_TAGS';
