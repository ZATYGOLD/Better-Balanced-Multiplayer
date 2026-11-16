--*******************************************************
--***************** CHOSEN SIZE: SMALL ******************
--*******************************************************
-- The lobby chose Small with a Spectator slot and launched as Standard to allow it:
-- Standard keeps its rules but is built with Small's land and shows Small's name.
UPDATE Maps
SET (Name, Description, GridWidth, GridHeight, NumNaturalWonders, OceanWidth, LakeSizeCutoff, LakeGenerationFrequency, Continents) =
    (SELECT Name, Description, GridWidth, GridHeight, NumNaturalWonders, OceanWidth, LakeSizeCutoff, LakeGenerationFrequency, Continents
        FROM Maps WHERE MapSizeType = 'MAPSIZE_SMALL')
WHERE MapSizeType = 'MAPSIZE_STANDARD';
