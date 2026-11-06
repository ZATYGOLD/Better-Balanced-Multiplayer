-- Exploration
-- Thanh Hue
UPDATE Wonders
SET RequiredConstructibleInSettlementCount='3'
WHERE ConstructibleType='WONDER_THANH_HUE';

-- Modern
-- Hermitage
UPDATE Constructibles
SET Cost='1300'
WHERE ConstructibleType='WONDER_HERMITAGE';
-- Muzibu Azaala Mpanga
UPDATE Constructibles
SET Cost='1100'
WHERE ConstructibleType='WONDER_MUZIBU_AZAALA_MPANGA';
-- Doi Suthep
UPDATE Constructibles
SET Cost='1100'
WHERE ConstructibleType='WONDER_DOI_SUTHEP';
UPDATE ModifierArguments
SET Value='10'
WHERE Name='Amount' AND ModifierId='MOD_DOI_SUTHEP_SUZERAIN_CULTURE';
UPDATE ModifierArguments
SET Value='10'
WHERE Name='Amount' AND ModifierId='MOD_DOI_SUTHEP_SUZERAIN_GOLD';
-- Boudhanath
UPDATE Constructibles
SET Cost='1100'
WHERE ConstructibleType='WONDER_BOUDHANATH';
UPDATE ModifierArguments
SET value='50'
WHERE name='FavorsAmount' AND ModifierId='MOD_BOUDHANATH_INCREASED_RELATIONSHIP';
-- Taj Mahal
UPDATE Constructibles
SET Cost='1100'
WHERE ConstructibleType='WONDER_TAJ_MAHAL';
-- Palacio De Bellas Artes
UPDATE Constructibles
SET Cost='1100'
WHERE ConstructibleType='WONDER_PALACIO_DE_BELLAS_ARTES';
-- Brandenburg Gate
UPDATE Constructibles
SET Cost='1400'
WHERE ConstructibleType='WONDER_BRANDENBURG_GATE';
-- Eram Garden
UPDATE Constructibles
SET Cost='1200'
WHERE ConstructibleType='WONDER_ERAM_GARDEN';
-- Statue of Liberty
UPDATE Constructibles
SET Cost='1200'
WHERE ConstructibleType='WONDER_STATUE_OF_LIBERTY';
-- Red Fort
UPDATE Constructibles
SET Cost='1200'
WHERE ConstructibleType='WONDER_RED_FORT';
-- Eiffel Tower
UPDATE Constructibles
SET Cost='1400'
WHERE ConstructibleType='WONDER_EIFFEL_TOWER';
-- Nirayama Reverberatory Furnace
UPDATE Constructibles
SET Cost='1200'
WHERE ConstructibleType='WONDER_NIRAYAMA_REVERBERATORY_FURNACE';
-- Manhattan Project
UPDATE Constructibles
SET Cost='1400'
WHERE ConstructibleType='WONDER_MANHATTAN_PROJECT';