-- World Wonders: Carry Over. Loaded in every Age. Each Age records the World
-- Wonders a player unlocks in its tech and civic trees as narrative tags, player
-- state the game keeps across Ages. Later Ages grant those wonders' unlocks back
-- to the tag holders and lift the wonders' Age restriction; the game still
-- allows one of each wonder per world.

--*******************************************************
--***************** WONDERS *****************************
--*******************************************************
-- Unlocks: World Wonder unlocks in this Age's trees (Test of Time unlocks keep
-- their trait). Carried: World Wonders of Ages earlier than those unlocks' Age.
CREATE TEMP TABLE BBM_WorldWonderUnlocks AS
SELECT u.TargetType AS ConstructibleType, u.ProgressionTreeNodeType AS NodeType, u.UnlockDepth AS Depth, u.RequiredTraitType AS TraitType,
    u.ProgressionTreeNodeType || '_' || u.TargetType AS Id
FROM ProgressionTreeNodeUnlocks u
JOIN Constructibles c ON c.ConstructibleType = u.TargetType
WHERE c.ConstructibleClass = 'WONDER' AND u.NotTraitType IS NULL AND u.RequiredGovernmentType IS NULL;

CREATE TEMP TABLE BBM_WorldWonderCarried AS
SELECT c.ConstructibleType
FROM Constructibles c
JOIN Ages a ON a.AgeType = c.Age
WHERE c.ConstructibleClass = 'WONDER' AND a.ChronologyIndex < (
    SELECT MAX(a2.ChronologyIndex)
    FROM BBM_WorldWonderUnlocks w
    JOIN Constructibles c2 ON c2.ConstructibleType = w.ConstructibleType
    JOIN Ages a2 ON a2.AgeType = c2.Age);

--*******************************************************
--***************** TYPES *******************************
--*******************************************************
INSERT OR IGNORE INTO Types (Type, Kind)
    VALUES
        ('BBM_GAMEPLAY_MODIFIER_RECORD_WONDER', 'KIND_MODIFIER'),
        ('BBM_GAMEPLAY_MODIFIER_CARRY_WONDER', 'KIND_MODIFIER');

INSERT OR IGNORE INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
    VALUES
        ('BBM_GAMEPLAY_MODIFIER_RECORD_WONDER', 'COLLECTION_OWNER', 'EFFECT_PLAYER_GRANT_NARRATIVE_TAG'),
        ('BBM_GAMEPLAY_MODIFIER_CARRY_WONDER', 'COLLECTION_OWNER', 'EFFECT_PLAYER_GRANT_CONSTRUCTIBLE_UNLOCK');

-- A tag per World Wonder, defined in every Age so later Ages can read it.
INSERT OR IGNORE INTO Types (Type, Kind)
SELECT 'BBM_GAMEPLAY_NARRATIVE_TAG_' || ConstructibleType, 'KIND_NARRATIVE_TAG'
FROM Constructibles
WHERE ConstructibleClass = 'WONDER';

INSERT OR IGNORE INTO NarrativeTags (NarrativeTagType)
SELECT 'BBM_GAMEPLAY_NARRATIVE_TAG_' || ConstructibleType
FROM Constructibles
WHERE ConstructibleClass = 'WONDER';

--*******************************************************
--***************** RECORD ******************************
--*******************************************************
-- A permanent modifier per unlock grants the wonder's tag once the player has
-- completed the tech or civic (and holds its trait).
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'BBM_GAMEPLAY_REQ_' || NodeType || '_' || Depth, 'REQUIREMENT_PLAYER_HAS_COMPLETED_PROGRESSION_TREE_NODE' FROM BBM_WorldWonderUnlocks
UNION SELECT 'BBM_GAMEPLAY_REQ_' || TraitType, 'REQUIREMENT_PLAYER_HAS_CIVILIZATION_OR_LEADER_TRAIT' FROM BBM_WorldWonderUnlocks WHERE TraitType IS NOT NULL;

INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'BBM_GAMEPLAY_REQ_' || NodeType || '_' || Depth, 'ProgressionTreeNodeType', NodeType FROM BBM_WorldWonderUnlocks
UNION SELECT 'BBM_GAMEPLAY_REQ_' || NodeType || '_' || Depth, 'MinDepth', Depth FROM BBM_WorldWonderUnlocks
UNION SELECT 'BBM_GAMEPLAY_REQ_' || TraitType, 'TraitType', TraitType FROM BBM_WorldWonderUnlocks WHERE TraitType IS NOT NULL;

INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'BBM_GAMEPLAY_REQSET_RECORD_' || Id, 'REQUIREMENTSET_TEST_ALL' FROM BBM_WorldWonderUnlocks;

INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'BBM_GAMEPLAY_REQSET_RECORD_' || Id, 'BBM_GAMEPLAY_REQ_' || NodeType || '_' || Depth FROM BBM_WorldWonderUnlocks
UNION SELECT 'BBM_GAMEPLAY_REQSET_RECORD_' || Id, 'BBM_GAMEPLAY_REQ_' || TraitType FROM BBM_WorldWonderUnlocks WHERE TraitType IS NOT NULL;

INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, Permanent, SubjectRequirementSetId)
SELECT 'BBM_GAMEPLAY_RECORD_' || Id, 'BBM_GAMEPLAY_MODIFIER_RECORD_WONDER', 1, 'BBM_GAMEPLAY_REQSET_RECORD_' || Id FROM BBM_WorldWonderUnlocks;

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'BBM_GAMEPLAY_RECORD_' || Id, 'NarrativeTagType', 'BBM_GAMEPLAY_NARRATIVE_TAG_' || ConstructibleType FROM BBM_WorldWonderUnlocks
UNION SELECT 'BBM_GAMEPLAY_RECORD_' || Id, 'Amount', 1 FROM BBM_WorldWonderUnlocks;

INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_MAJOR_CIV', 'BBM_GAMEPLAY_RECORD_' || Id FROM BBM_WorldWonderUnlocks;

--*******************************************************
--***************** CARRY *******************************
--*******************************************************
-- An earlier Age's wonder is unlocked for the players holding its tag, and its
-- Age is cleared as for the game's buildings that stay buildable in every Age.
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'BBM_GAMEPLAY_REQ_TAG_' || ConstructibleType, 'REQUIREMENT_PLAYER_HAS_AT_LEAST_NUM_NARRATIVE_TAGS' FROM BBM_WorldWonderCarried;

INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'BBM_GAMEPLAY_REQ_TAG_' || ConstructibleType, 'NarrativeTagType', 'BBM_GAMEPLAY_NARRATIVE_TAG_' || ConstructibleType FROM BBM_WorldWonderCarried
UNION SELECT 'BBM_GAMEPLAY_REQ_TAG_' || ConstructibleType, 'Amount', 1 FROM BBM_WorldWonderCarried;

INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'BBM_GAMEPLAY_REQSET_CARRY_' || ConstructibleType, 'REQUIREMENTSET_TEST_ALL' FROM BBM_WorldWonderCarried;

INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'BBM_GAMEPLAY_REQSET_CARRY_' || ConstructibleType, 'BBM_GAMEPLAY_REQ_TAG_' || ConstructibleType FROM BBM_WorldWonderCarried;

INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'BBM_GAMEPLAY_CARRY_' || ConstructibleType, 'BBM_GAMEPLAY_MODIFIER_CARRY_WONDER', 'BBM_GAMEPLAY_REQSET_CARRY_' || ConstructibleType FROM BBM_WorldWonderCarried;

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'BBM_GAMEPLAY_CARRY_' || ConstructibleType, 'ConstructibleType', ConstructibleType FROM BBM_WorldWonderCarried;

INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_MAJOR_CIV', 'BBM_GAMEPLAY_CARRY_' || ConstructibleType FROM BBM_WorldWonderCarried;

UPDATE Constructibles SET Age = NULL
WHERE ConstructibleType IN (SELECT ConstructibleType FROM BBM_WorldWonderCarried);

DROP TABLE BBM_WorldWonderUnlocks;
DROP TABLE BBM_WorldWonderCarried;
