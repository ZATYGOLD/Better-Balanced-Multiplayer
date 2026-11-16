--*******************************************************
--***************** 2V2 MAP *****************************
--*******************************************************
-- 2v2 placement: Tiny is built on a 66x42 grid, between Tiny (60x38) and
-- Small (74x46); other sizes keep their grid.
UPDATE Maps
SET GridWidth = 66,
    GridHeight = 42
WHERE MapSizeType = 'MAPSIZE_TINY';
