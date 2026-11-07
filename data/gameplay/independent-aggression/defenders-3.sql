-- Independent Aggression: independent powers start with 3 defender units, and keep at most 3
-- (paired with Calm or Raging per Age).
UPDATE TribeTagSets
SET InitialUnitAmount = 3,
    MaxUnitAmount = 3
WHERE TribeTagName = 'DEFAULT_DEFENDER_TAGS';
