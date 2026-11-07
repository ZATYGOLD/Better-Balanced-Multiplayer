-- Independent Aggression: independent powers start with 2 defender units, and keep at most 2
-- (paired with Calm or Raging per Age).
UPDATE TribeTagSets
SET InitialUnitAmount = 2,
    MaxUnitAmount = 2
WHERE TribeTagName = 'DEFAULT_DEFENDER_TAGS';
