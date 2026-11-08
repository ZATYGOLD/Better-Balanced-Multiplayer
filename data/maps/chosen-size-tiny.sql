--*******************************************************
--***************** CHOSEN SIZE: TINY *******************
--*******************************************************
-- The lobby chose Tiny with a Spectator slot and launched as Small to allow it:
-- Small keeps its rules but is built with Tiny's land and shows Tiny's name.
UPDATE Maps
SET (Name, Description, GridWidth, GridHeight, NumNaturalWonders, OceanWidth, LakeSizeCutoff, LakeGenerationFrequency, Continents) =
    (SELECT Name, Description, GridWidth, GridHeight, NumNaturalWonders, OceanWidth, LakeSizeCutoff, LakeGenerationFrequency, Continents
     FROM Maps WHERE MapSizeType = 'MAPSIZE_TINY')
WHERE MapSizeType = 'MAPSIZE_SMALL';
