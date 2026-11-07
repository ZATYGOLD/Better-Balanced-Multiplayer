-- Natural Wonders Half: 50% fewer, never below one on a map that has any.
UPDATE Maps
SET NumNaturalWonders = MAX(1, NumNaturalWonders / 2)
WHERE NumNaturalWonders IS NOT NULL;
