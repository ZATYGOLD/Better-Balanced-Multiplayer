-- Base victory scoring.
UPDATE VictoryScorings
SET Points = 1
WHERE ScoringId = 'VICTORY_TRACKER_GOLD_BUILDINGS_ANTIQUITY';

-- Gwlad y Cestyll: +1 Tourism from Fortifications.
UPDATE VictoryScorings
SET Points = 1
WHERE ScoringId = 'VICTORY_TRACKER_LEGACY_EX_MILITARISTIC_5';

-- Abundance: activate +1 GDP per turn from assigned Bonus Resources in Towns.
-- The all-settlement tracker supplies the Town portion that the normal
-- city-only Bonus Resource tracker does not count.
INSERT OR REPLACE INTO VictoryScorings
    (ScoringId, VictoryType, TrackerType, Name, Points, Data, RequiresActivation)
VALUES
    ('MBM_VICTORY_TRACKER_ABUNDANCE_TOWNS',
     'VICTORY_ECONOMIC_MODERN',
     'VICTORY_TRACKER_SLOTTED_RESOURCE_CLASS',
     'LOC_MBM_VICTORY_TRACKER_ABUNDANCE_TOWNS_NAME',
     1,
     'RESOURCECLASS_BONUS',
     1);

-- Khan el-Khalili: use the same Town-only Bonus Resource GDP effect in Modern.
INSERT OR IGNORE INTO AdvancedStartCardEffects
    (Age, EffectID, EffectType, Amount)
VALUES
    ('AGE_MODERN',
     'MBM_CARD_EFFECT_AT_MO_ECONOMIC_1_TOWN_GDP',
     'MBM_CARD_MOD_AT_EX_ECONOMIC_1_TOWN_GDP',
     1),
    ('AGE_MODERN',
     'MBM_CARD_EFFECT_AT_MO_ECONOMIC_1_CITY_OFFSET',
     'MBM_CARD_MOD_AT_EX_ECONOMIC_1_CITY_OFFSET',
     1);

UPDATE AdvancedStartCards
SET CardEffectType2 = 'MBM_CARD_EFFECT_AT_MO_ECONOMIC_1_TOWN_GDP',
    CardEffectType3 = 'MBM_CARD_EFFECT_AT_MO_ECONOMIC_1_CITY_OFFSET'
WHERE Age = 'AGE_MODERN'
  AND CardID = 'CARD_AT_MO_ECONOMIC_1';
  
-- The all-settlement tracker also sees Cities. Cancel that additional City
-- point so Abundance changes Town scoring without increasing normal City GDP.
INSERT OR REPLACE INTO VictoryScorings
    (ScoringId, VictoryType, TrackerType, Name, Points, Data, RequiresActivation)
VALUES
    ('MBM_VICTORY_TRACKER_ABUNDANCE_CITY_OFFSET',
     'VICTORY_ECONOMIC_MODERN',
     'VICTORY_TRACKER_SLOTTED_RESOURCE_CITY_CLASS',
     'LOC_MBM_VICTORY_TRACKER_ABUNDANCE_CITY_OFFSET_NAME',
     -1,
     'RESOURCECLASS_BONUS',
     1);

INSERT OR IGNORE INTO AdvancedStartCardEffects
    (Age, EffectID, EffectType, Amount)
VALUES
    ('AGE_EXPLORATION',
     'MBM_CARD_EFFECT_AT_EX_ECONOMIC_1_TOWN_GDP',
     'MBM_CARD_MOD_AT_EX_ECONOMIC_1_TOWN_GDP',
     1);

INSERT OR IGNORE INTO AdvancedStartCardEffects
    (Age, EffectID, EffectType, Amount)
VALUES
    ('AGE_EXPLORATION',
     'MBM_CARD_EFFECT_AT_EX_ECONOMIC_1_CITY_OFFSET',
     'MBM_CARD_MOD_AT_EX_ECONOMIC_1_CITY_OFFSET',
     1);

UPDATE AdvancedStartCards
SET CardEffectType2 = 'MBM_CARD_EFFECT_AT_EX_ECONOMIC_1_TOWN_GDP',
    CardEffectType3 = 'MBM_CARD_EFFECT_AT_EX_ECONOMIC_1_CITY_OFFSET'
WHERE Age = 'AGE_EXPLORATION'
  AND CardID = 'CARD_AT_EX_ECONOMIC_1';

-- To Fell a Giant: retain +1 War Support, but remove the Influence bonus.
UPDATE AdvancedStartCards
SET CardEffectType2 = NULL
WHERE Age = 'AGE_EXPLORATION'
  AND CardID = 'CARD_AT_EX_MILITARISTIC_2';
