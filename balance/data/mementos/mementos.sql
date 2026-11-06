-- Memento balance changes.

-- Uraeus: +5 Culture per Age in Cities with a Wonder.
UPDATE ModifierArguments
SET Value = '5'
WHERE ModifierId = 'MEMENTO_HATSHEPSUT_URAEUS_MODIFIER'
  AND Name = 'Amount';

-- Note G: Production equal to 10% of the completed Tech/Civic Mastery cost.
UPDATE ModifierArguments
SET Value = '10'
WHERE ModifierId IN (
    'MEMENTO_ADA_LOVELACE_NOTE_G_MODIFIER_1',
    'MEMENTO_ADA_LOVELACE_NOTE_G_MODIFIER_2'
)
  AND Name = 'PercentCost';

-- Flag of Jhansi: +1 Influence per Army Commander promotion.
UPDATE ModifierArguments
SET Value = '1'
WHERE ModifierId = 'MEMENTO_LAKSHMIBAI_FLAG_OF_JHANSI_MODIFIER'
  AND Name = 'Amount';

-- Lion Capital: +25% Commander XP during Celebrations.
UPDATE ModifierArguments
SET Value = '25'
WHERE ModifierId = 'MEMENTO_ASHOKA_CONQUEROR_LION_CAPITAL_MODIFIER'
  AND Name = 'Percent';

-- Warclub: Infantry and Ranged Units receive +1 Combat Strength per 2
-- City-States the player is Suzerain of.
UPDATE RequirementArguments
SET Value = 'UNIT_CLASS_INFANTRY, UNIT_CLASS_RANGED'
WHERE Name = 'Tag'
  AND RequirementId IN (
      SELECT rsr.RequirementId
      FROM Modifiers m
      JOIN RequirementSetRequirements rsr
        ON rsr.RequirementSetId = m.SubjectRequirementSetId
      WHERE m.ModifierId = 'MEMENTO_TECUMSEH_WARCLUB_MODIFIER'
  );

INSERT OR REPLACE INTO ModifierArguments
    (ModifierId, Name, Value)
SELECT
    ModifierId, 'Divisor', '2'
FROM Modifiers
WHERE ModifierId = 'MEMENTO_TECUMSEH_WARCLUB_MODIFIER';

-- Artilleryman's Gloves: +1 Culture per promotion across both Army and
-- Fleet Commanders.
UPDATE RequirementArguments
SET Value = 'UNIT_CLASS_COMMAND'
WHERE Name = 'Tag'
  AND RequirementId IN (
      SELECT rsr.RequirementId
      FROM Modifiers m
      JOIN RequirementSetRequirements rsr
        ON rsr.RequirementSetId = m.SubjectRequirementSetId
      WHERE m.ModifierId = 'MEMENTO_NAPOLEON_REVOLUTIONARY_ARTILLERYMAN_GLOVES_MODIFIER'
  );

UPDATE ModifierArguments
SET Value = '1'
WHERE ModifierId = 'MEMENTO_NAPOLEON_REVOLUTIONARY_ARTILLERYMAN_GLOVES_MODIFIER'
  AND Name = 'Amount';

-- Kiem: +1 Culture per promotion across both Army and Fleet Commanders.
UPDATE RequirementArguments
SET Value = 'UNIT_CLASS_COMMAND'
WHERE Name = 'Tag'
  AND RequirementId IN (
      SELECT rsr.RequirementId
      FROM Modifiers m
      JOIN RequirementSetRequirements rsr
        ON rsr.RequirementSetId = m.SubjectRequirementSetId
      WHERE m.ModifierId = 'MEMENTO_TRUNG_KIEM_MODIFIER'
  );

UPDATE ModifierArguments
SET Value = CASE Name
    WHEN 'YieldType' THEN 'YIELD_CULTURE'
    WHEN 'Amount' THEN '1'
END
WHERE ModifierId = 'MEMENTO_TRUNG_KIEM_MODIFIER'
  AND Name IN ('YieldType', 'Amount');

-- Garuda Statue: replace the base smallest-settlement trigger with the
-- Capital-only celebration trigger defined in mementos-gameeffects.xml.
DELETE FROM MementoModifiers
WHERE MementoType = 'MEMENTO_FOUNDATION_GARUDA_STATUE'
  AND ModifierId = 'MEMENTO_FOUNDATION_GARUDA_STATUE_MODIFIER';

INSERT OR REPLACE INTO MementoModifiers
    (MementoType, ModifierId)
SELECT
    'MEMENTO_FOUNDATION_GARUDA_STATUE',
    'MPT_BALANCE_MEMENTO_GARUDA_STATUE_CAPITAL'
WHERE EXISTS (
    SELECT 1
    FROM Mementos
    WHERE MementoType = 'MEMENTO_FOUNDATION_GARUDA_STATUE'
)
  AND EXISTS (
    SELECT 1
    FROM Modifiers
    WHERE ModifierId = 'MPT_BALANCE_MEMENTO_GARUDA_STATUE_CAPITAL'
);

-- Royal Game of Ur: +20% Science/Culture while behind.
UPDATE ModifierArguments
SET Value = '20'
WHERE ModifierId IN (
    'MEMENTO_FOUNDATION_GAME_OF_UR_MODIFIER_1',
    'MEMENTO_FOUNDATION_GAME_OF_UR_MODIFIER_2'
)
  AND Name = 'Percent';

-- Takoba: retain +1 Combat Strength and add +1 Movement in Plains/Desert.
INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_AMINA_TAKOBA', 'MPT_BALANCE_MEMENTO_TAKOBA_MOVEMENT'
WHERE EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_AMINA_TAKOBA')
  AND EXISTS (SELECT 1 FROM Modifiers WHERE ModifierId = 'MPT_BALANCE_MEMENTO_TAKOBA_MOVEMENT');

-- Kwalkwali and Clipeus Virtutis.
UPDATE ModifierArguments SET Value = '2'
WHERE ModifierId IN (
    'MEMENTO_AMINA_KWALKWALI_MODIFIER',
    'MEMENTO_AUGUSTUS_CLIPEUS_VIRTUTIS_MODIFIER'
)
  AND Name = 'Amount';

-- Kite & Key: +30% Science towards Tech Masteries.
UPDATE ModifierArguments SET Value = '30'
WHERE ModifierId = 'MEMENTO_BENJAMIN_FRANKLIN_KITE_MODIFIER'
  AND Name = 'Percent';

-- Great Imperial Crown: remove the Town-only requirement so all Settlements
-- in Tundra receive the Science.
DELETE FROM RequirementSetRequirements
WHERE RequirementSetId = (
    SELECT SubjectRequirementSetId FROM Modifiers
    WHERE ModifierId = 'MEMENTO_CATHERINE_GREAT_IMPERIAL_CROWN_MODIFIER'
)
AND RequirementId IN (
    SELECT RequirementId FROM Requirements
    WHERE RequirementType = 'REQUIREMENT_CITY_IS_TOWN'
);

-- Joyeuse: Cavalry may be stationed on any urban or City Center district.
UPDATE RequirementArguments
SET Value = 'DISTRICT_URBAN, DISTRICT_CITY_CENTER'
WHERE Name = 'DistrictType'
  AND RequirementId IN (
      SELECT rsr.RequirementId
      FROM Modifiers m
      JOIN RequirementSetRequirements rsr
        ON rsr.RequirementSetId = m.SubjectRequirementSetId
      WHERE m.ModifierId = 'MEMENTO_CHARLEMAGNE_JOYEUSE_MODIFIER'
  );

-- Specialist yield mementos.
UPDATE ModifierArguments SET Value = '2'
WHERE ModifierId IN (
    'MEMENTO_CONFUCIUS_ALTAR_SET_MODIFIER',
    'MEMENTO_CONFUCIUS_ANALECTS_MODIFIER'
)
  AND Name = 'Amount';

-- Walking Stick: Science on Production Buildings instead of Military Buildings.
UPDATE ModifierArguments SET Value = 'PRODUCTION'
WHERE ModifierId = 'MEMENTO_FRIEDRICH_OBLIQUE_WALKING_STICK_MODIFIER'
  AND Name = 'Tag';

-- False Beard: scale its Culture by Age and add matching Happiness.
UPDATE ModifierArguments
SET Value = '2', Type = 'ScaleByGameAge', Extra = '100'
WHERE ModifierId = 'MEMENTO_HATSHEPSUT_FALSE_BEARD_MODIFIER'
  AND Name = 'Amount';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_HATSHEPSUT_FALSE_BEARD', 'MPT_BALANCE_MEMENTO_FALSE_BEARD_HAPPINESS'
WHERE EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_HATSHEPSUT_FALSE_BEARD')
  AND EXISTS (SELECT 1 FROM Modifiers WHERE ModifierId = 'MPT_BALANCE_MEMENTO_FALSE_BEARD_HAPPINESS');

-- Yasakani no Magatama: replace the player-wide yield with +1 Science per Age
-- per completed Tech Mastery in every City.
DELETE FROM MementoModifiers
WHERE MementoType = 'MEMENTO_HIMIKO_QUEEN_YASAKANI_NO_MAGATAMA'
  AND ModifierId = 'MEMENTO_HIMIKO_QUEEN_YASAKANI_NO_MAGATAMA_MODIFIER';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_HIMIKO_QUEEN_YASAKANI_NO_MAGATAMA', 'MPT_BALANCE_MEMENTO_YASAKANI_CITY_SCIENCE'
WHERE EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_HIMIKO_QUEEN_YASAKANI_NO_MAGATAMA')
  AND EXISTS (SELECT 1 FROM Modifiers WHERE ModifierId = 'MPT_BALANCE_MEMENTO_YASAKANI_CITY_SCIENCE');

-- Merchant's Saddle: retain its four original +1 Movement modifiers and add
-- terrain-penalty immunity for Scouts, Settlers, and Explorers.
INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_BATTUTA_MERCHANTS_SADDLE', ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MEMENTO_MERCHANTS_SADDLE_IGNORE_ROUGH_RIVERS',
    'MPT_BALANCE_MEMENTO_MERCHANTS_SADDLE_IGNORE_VEGETATION'
)
AND EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_BATTUTA_MERCHANTS_SADDLE');

-- Ophthalmoscope: +50% Celebration duration.
UPDATE ModifierArguments SET Value = '50'
WHERE ModifierId = 'MEMENTO_RIZAL_OPHTHALMOSCOPE_MODIFIER'
  AND Name = 'Percent';

-- Letter to Adrienne: replace the player-wide Tradition/Policy effects with
-- +1 Happiness per Age in every City per Social Policy.
DELETE FROM MementoModifiers
WHERE MementoType = 'MEMENTO_LAFAYETTE_LETTER_ADRIENNE';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_LAFAYETTE_LETTER_ADRIENNE', 'MPT_BALANCE_MEMENTO_LETTER_ADRIENNE_CITY_HAPPINESS'
WHERE EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_LAFAYETTE_LETTER_ADRIENNE')
  AND EXISTS (SELECT 1 FROM Modifiers WHERE ModifierId = 'MPT_BALANCE_MEMENTO_LETTER_ADRIENNE_CITY_HAPPINESS');

-- Tricolor Cockade: +4 Culture and Happiness per Age per Tradition.
UPDATE ModifierArguments SET Value = '4'
WHERE ModifierId IN (
    'MEMENTO_LAFAYETTE_TRICOLOUR_COCKADE_MODIFIER_1',
    'MEMENTO_LAFAYETTE_TRICOLOUR_COCKADE_MODIFIER_2'
)
  AND Name = 'Amount';

-- Topayauri: +2 Food per Age.
UPDATE ModifierArguments SET Value = '2'
WHERE ModifierId = 'MEMENTO_PACHACUTI_TOPAYAURI_MODIFIER'
  AND Name = 'Amount';

-- All-T'oqapu Tunic: replace the adjacent-Mountain Scout sight modifier.
DELETE FROM MementoModifiers
WHERE MementoType = 'MEMENTO_PACHACUTI_ALL_TOQAPU_TUNIC';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_PACHACUTI_ALL_TOQAPU_TUNIC', ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MEMENTO_ALL_TOQAPU_SCOUT_SETTLER_SIGHT',
    'MPT_BALANCE_MEMENTO_ALL_TOQAPU_SCOUT_SETTLER_MOUNTAINS'
)
AND EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_PACHACUTI_ALL_TOQAPU_TUNIC');

-- Mascapaycha: +2 Gold from Specialists and +2 additional beside Mountains.
UPDATE ModifierArguments SET Value = '2'
WHERE ModifierId IN (
    'MEMENTO_PACHACUTI_MASCAPAYCHA_MODIFIER_1',
    'MEMENTO_PACHACUTI_MASCAPAYCHA_MODIFIER_2'
)
  AND Name = 'Amount';

-- The Iliad: allow the Capital while retaining the City-with-Wonder condition.
DELETE FROM RequirementSetRequirements
WHERE RequirementSetId = (
    SELECT SubjectRequirementSetId FROM Modifiers
    WHERE ModifierId = 'MEMENTO_ALEXANDER_ILIAD_MODIFIER'
)
AND RequirementId IN (
    SELECT RequirementId FROM Requirements
    WHERE RequirementType = 'REQUIREMENT_CITY_IS_CAPITAL'
);

-- Pukku and Mikku: make their exactly-one-Ally settlement yields scale by Age.
UPDATE ModifierArguments
SET Value = '4', Type = 'ScaleByGameAge', Extra = '100'
WHERE ModifierId = 'MEMENTO_GILGAMESH_PUKKU_MODIFIER'
  AND Name = 'Amount';

UPDATE ModifierArguments
SET Value = '1', Type = 'ScaleByGameAge', Extra = '100'
WHERE ModifierId = 'MEMENTO_GILGAMESH_MIKKU_MODIFIER'
  AND Name = 'Amount';

-- Ada Lovelace mementos.
UPDATE ModifierArguments SET Value = '30'
WHERE ModifierId = 'MEMENTO_ADA_LOVELACE_PUNCH_CARDS_MODIFIER'
  AND Name = 'Amount';

UPDATE ModifierArguments SET Value = '30'
WHERE ModifierId = 'MEMENTO_ADA_LOVELACE_PIANO_MODIFIER'
  AND Name = 'Percent';

-- Sakaki Branch: replace its construction bonus with Happiness on Happiness
-- Buildings.
DELETE FROM MementoModifiers
WHERE MementoType = 'MEMENTO_HIMIKO_SHAMAN_SAKAKI_BRANCH'
  AND ModifierId = 'MEMENTO_HIMIKO_SHAMAN_SAKAKI_BRANCH_MODIFIER';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_HIMIKO_SHAMAN_SAKAKI_BRANCH', 'MPT_BALANCE_MEMENTO_SAKAKI_BRANCH_HAPPINESS'
WHERE EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_HIMIKO_SHAMAN_SAKAKI_BRANCH')
  AND EXISTS (SELECT 1 FROM Modifiers WHERE ModifierId = 'MPT_BALANCE_MEMENTO_SAKAKI_BRANCH_HAPPINESS');

-- Davalos Medal: Happiness on Production and Production Warehouse Buildings.
UPDATE ModifierArguments SET Value = 'PRODUCTION'
WHERE ModifierId = 'MEMENTO_BOLIVAR_DAVALOS_MEDAL_MODIFIER'
  AND Name = 'Tag';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_BOLIVAR_DAVALOS_MEDAL', 'MPT_BALANCE_MEMENTO_DAVALOS_PRODUCTION_WAREHOUSE_HAPPINESS'
WHERE EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_BOLIVAR_DAVALOS_MEDAL')
  AND EXISTS (SELECT 1 FROM Modifiers WHERE ModifierId = 'MPT_BALANCE_MEMENTO_DAVALOS_PRODUCTION_WAREHOUSE_HAPPINESS');

-- Flute: Culture on Production Buildings.
UPDATE ModifierArguments SET Value = 'PRODUCTION'
WHERE ModifierId = 'MEMENTO_FRIEDRICH_BAROQUE_FLUTE_MODIFIER'
  AND Name = 'Tag';

-- Trade-route yields.
UPDATE ModifierArguments SET Value = '3'
WHERE ModifierId = 'MEMENTO_XERXES_ACHAEMENID_INCENSE_CENSER_MODIFIER'
  AND Name = 'Amount';

UPDATE ModifierArguments SET Value = '3'
WHERE ModifierId IN (
    'MEMENTO_NAPOLEON_EMPEROR_GREEN_COLONEL_JACKET_MODIFIER_1',
    'MEMENTO_NAPOLEON_EMPEROR_GREEN_COLONEL_JACKET_MODIFIER_2'
)
  AND Name = 'Amount';

-- Nimcha and Paiza: maintenance reductions now scale by Age.
UPDATE ModifierArguments
SET Value = '1', Type = 'ScaleByGameAge', Extra = '100'
WHERE ModifierId IN (
    'MEMENTO_SAYYIDA_AL_HURRA_NIMCHA_MODIFIER',
    'MEMENTO_GENGHIS_KHAN_PAIZA_MODIFIER'
)
  AND Name = 'Amount';

-- Tea Ceremony Kit: retain the existing +20% Production and add +20% Gold
-- purchase efficiency for each listed Building.
INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_TOYOTOMI_HIDEYOSHI_TEA_CEREMONY_KIT', ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MEMENTO_TEA_CEREMONY_ALTAR_PURCHASE',
    'MPT_BALANCE_MEMENTO_TEA_CEREMONY_TEMPLE_PURCHASE',
    'MPT_BALANCE_MEMENTO_TEA_CEREMONY_MUSEUM_PURCHASE'
)
AND EXISTS (
    SELECT 1 FROM Mementos
    WHERE MementoType = 'MEMENTO_TOYOTOMI_HIDEYOSHI_TEA_CEREMONY_KIT'
);

-- Juelles of Golde: +5 Gold per Age on displayed Great Works.
UPDATE ModifierArguments
SET Value = '5'
WHERE ModifierId = 'MEMENTO_ELIZABETH_JUELLES_OF_GOLDE_MODIFIER'
  AND Name = 'Amount';

-- Mithqal already uses Sayyida's occupied-District naval pattern in the
-- current game data. Saddle and Sulde need the same all-District scope.
UPDATE RequirementArguments
SET Value = 'DISTRICT_URBAN, DISTRICT_CITY_CENTER'
WHERE RequirementId IN (
    SELECT rsr.RequirementId
    FROM Modifiers m
    JOIN RequirementSetRequirements rsr
      ON rsr.RequirementSetId = m.SubjectRequirementSetId
    JOIN Requirements r
      ON r.RequirementId = rsr.RequirementId
    WHERE m.ModifierId IN (
        'MEMENTO_GENGHIS_KHAN_SADDLE_MODIFIER',
        'MEMENTO_GENGHIS_KHAN_SULDE_MODIFIER'
    )
      AND r.RequirementType = 'REQUIREMENT_UNIT_IS_STATIONED_ON_DISTRICT'
)
  AND Name = 'DistrictType';

-- Silk Uttariya: cumulative Happiness tiers produce +2/+4/+6 Production.
INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_ASHOKA_CONQUEROR_SILK_UTTARIYA', ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MEMENTO_SILK_UTTARIYA_JOYOUS_PRODUCTION',
    'MPT_BALANCE_MEMENTO_SILK_UTTARIYA_ECSTATIC_PRODUCTION'
)
  AND EXISTS (
      SELECT 1 FROM Mementos
      WHERE MementoType = 'MEMENTO_ASHOKA_CONQUEROR_SILK_UTTARIYA'
  );

-- Golden Sceptre: +10 Gold, Science, and Culture per Age per conquered
-- Settlement belonging to another Civilization.
UPDATE ModifierArguments
SET Value = '10'
WHERE ModifierId = 'MEMENTO_XERXES_KING_GOLDEN_SCEPTRE_MODIFIER'
  AND Name = 'Amount';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_XERXES_KING_GOLDEN_SCEPTRE', ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MEMENTO_GOLDEN_SCEPTRE_SCIENCE',
    'MPT_BALANCE_MEMENTO_GOLDEN_SCEPTRE_CULTURE'
)
  AND EXISTS (
      SELECT 1 FROM Mementos
      WHERE MementoType = 'MEMENTO_XERXES_KING_GOLDEN_SCEPTRE'
  );

-- Portrait of Josephine: +5 Gold and +2 Influence per Age for each
-- unfriendly or hostile Civilization.
UPDATE ModifierArguments
SET Value = '5'
WHERE ModifierId IN (
    'MEMENTO_NAPOLEON_EMPEROR_PORTRAIT_JOSEPHINE_MODIFIER_1',
    'MEMENTO_NAPOLEON_EMPEROR_PORTRAIT_JOSEPHINE_MODIFIER_2'
)
  AND Name = 'Amount';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_NAPOLEON_EMPEROR_PORTRAIT_JOSEPHINE', ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MEMENTO_JOSEPHINE_UNFRIENDLY_INFLUENCE',
    'MPT_BALANCE_MEMENTO_JOSEPHINE_HOSTILE_INFLUENCE'
)
  AND EXISTS (
      SELECT 1 FROM Mementos
      WHERE MementoType = 'MEMENTO_NAPOLEON_EMPEROR_PORTRAIT_JOSEPHINE'
  );

-- Queen's Jewelry and Padron Real: replace the Age-scaled Natural Wonder
-- effects with +1 on Breathtaking tiles and +2 on Natural Wonders.
DELETE FROM MementoModifiers
WHERE (MementoType = 'MEMENTO_ISABELLA_QUEENS_JEWELRY'
       AND ModifierId = 'MEMENTO_ISABELLA_QUEENS_JEWELRY_MODIFIER')
   OR (MementoType = 'MEMENTO_ISABELLA_PADRON_REAL'
       AND ModifierId = 'MEMENTO_ISABELLA_PADRON_REAL_MODIFIER');

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_ISABELLA_QUEENS_JEWELRY', ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MEMENTO_QUEENS_JEWELRY_BREATHTAKING',
    'MPT_BALANCE_MEMENTO_QUEENS_JEWELRY_NATURAL_WONDER'
)
  AND EXISTS (
      SELECT 1 FROM Mementos
      WHERE MementoType = 'MEMENTO_ISABELLA_QUEENS_JEWELRY'
  );

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_ISABELLA_PADRON_REAL', ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MEMENTO_PADRON_REAL_BREATHTAKING',
    'MPT_BALANCE_MEMENTO_PADRON_REAL_NATURAL_WONDER'
)
  AND EXISTS (
      SELECT 1 FROM Mementos
      WHERE MementoType = 'MEMENTO_ISABELLA_PADRON_REAL'
  );

-- Royal Mace: add Happiness per imported Resource.
INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_HATSHEPSUT_ROYAL_MACE', 'MPT_BALANCE_MEMENTO_ROYAL_MACE_HAPPINESS'
WHERE EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_HATSHEPSUT_ROYAL_MACE')
  AND EXISTS (SELECT 1 FROM Modifiers WHERE ModifierId = 'MPT_BALANCE_MEMENTO_ROYAL_MACE_HAPPINESS');

-- Diamond Throne: remove the Celebration requirement, leaving +1 Happiness
-- per Age on every Quarter.
DELETE FROM RequirementSetRequirements
WHERE RequirementSetId = (
    SELECT SubjectRequirementSetId
    FROM Modifiers
    WHERE ModifierId = 'MEMENTO_ASHOKA_RENOUNCER_DIAMOND_THRONE_MODIFIER'
)
  AND RequirementId IN (
      SELECT RequirementId
      FROM Requirements
      WHERE RequirementType = 'REQUIREMENT_PLAYER_IS_IN_GOLDEN_AGE'
  );

-- Pochteca Backpack: +10 Trade Route range and a Merchant from each newly
-- created Settlement.
UPDATE ModifierArguments
SET Value = '10'
WHERE ModifierId IN (
    'MEMENTO_FOUNDATION_POCHTECA_BACKPACK_MODIFIER_1',
    'MEMENTO_FOUNDATION_POCHTECA_BACKPACK_MODIFIER_2'
)
  AND Name = 'Amount';

INSERT OR REPLACE INTO MementoModifiers (MementoType, ModifierId)
SELECT 'MEMENTO_FOUNDATION_POCHTECA_BACKPACK', 'MPT_BALANCE_MEMENTO_POCHTECA_FREE_MERCHANT'
WHERE EXISTS (SELECT 1 FROM Mementos WHERE MementoType = 'MEMENTO_FOUNDATION_POCHTECA_BACKPACK')
  AND EXISTS (SELECT 1 FROM Modifiers WHERE ModifierId = 'MPT_BALANCE_MEMENTO_POCHTECA_FREE_MERCHANT');
