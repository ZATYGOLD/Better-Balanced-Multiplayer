--*******************************************************
--***************** DUEL MAP ****************************
--*******************************************************
-- Duel placement: Tiny (the smallest size multiplayer allows) is built on a
-- 44x28 grid for 1v1 and shows as Duel; other sizes keep their grid.
UPDATE Maps
SET Name = 'LOC_BBM_MAPS_MAPSIZE_DUEL_NAME',
    Description = 'LOC_BBM_MAPS_MAPSIZE_DUEL_DESC',
    DefaultPlayers = 2,
    PlayersLandmass1 = 1,
    PlayersLandmass2 = 1,
    GridWidth = 44,
    GridHeight = 28,
    NumNaturalWonders = 2,
    OceanWidth = 3,
    LakeSizeCutoff = 4,
    Continents = 2
WHERE MapSizeType = 'MAPSIZE_TINY';
