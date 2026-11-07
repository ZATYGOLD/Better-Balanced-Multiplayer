-- Natural Wonders Double: twice as many.
UPDATE Maps
SET NumNaturalWonders = NumNaturalWonders * 2
WHERE NumNaturalWonders IS NOT NULL;
