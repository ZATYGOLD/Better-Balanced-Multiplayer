-- Attribute-tree balance changes.

-- Cultural: +2 Culture per Age from displayed Great Works.
UPDATE ModifierArguments
SET Value = 2
WHERE ModifierId = 'MOD_ATTRIBUTE_CULTURAL_06'
  AND Name = 'Amount';

-- Grant one current-Age Great Work when the Attribute is completed (game-level
-- modifiers: completed node unlocks are not re-fired during an Age transition).
INSERT OR IGNORE INTO GameModifiers (ModifierId)
SELECT ModifierId
FROM Modifiers
WHERE ModifierId IN (
    'MPT_BALANCE_MOD_ATTRIBUTE_CULTURAL_FREE_GREAT_WORK_ANTIQUITY',
    'MPT_BALANCE_MOD_ATTRIBUTE_CULTURAL_FREE_GREAT_WORK_EXPLORATION',
    'MPT_BALANCE_MOD_ATTRIBUTE_CULTURAL_FREE_GREAT_WORK_MODERN'
);

-- Diplomatic: replace the Palace-only Influence bonus with a city bonus.
DELETE FROM ProgressionTreeNodeUnlocks
WHERE ProgressionTreeNodeType = 'NODE_ATTRIBUTE_POLITICAL_02'
  AND TargetKind = 'KIND_MODIFIER'
  AND TargetType = 'MOD_ATTRIBUTE_POLITICAL_02';

INSERT OR IGNORE INTO ProgressionTreeNodeUnlocks (ProgressionTreeNodeType, TargetKind, TargetType, UnlockDepth)
    VALUES
        ('NODE_ATTRIBUTE_POLITICAL_02', 'KIND_MODIFIER', 'MPT_BALANCE_MOD_ATTRIBUTE_POLITICAL_CITY_INFLUENCE', 1),
        ('NODE_ATTRIBUTE_POLITICAL_05', 'KIND_MODIFIER', 'MPT_BALANCE_MOD_ATTRIBUTE_POLITICAL_SEND_EFFICIENCY', 1);

UPDATE ModifierArguments
SET Value = 4
WHERE ModifierId IN ('MOD_ATTRIBUTE_POLITICAL_07_A', 'MOD_ATTRIBUTE_POLITICAL_07_B')
  AND Name = 'Amount';

-- Militaristic: retain the original +5 Combat Strength against Independent
-- Powers and City-States, and add Gold for defeating their units.
INSERT OR IGNORE INTO ProgressionTreeNodeUnlocks (ProgressionTreeNodeType, TargetKind, TargetType, UnlockDepth)
    VALUES ('NODE_ATTRIBUTE_MILITARISTIC_01', 'KIND_MODIFIER', 'MPT_BALANCE_MOD_ATTRIBUTE_MILITARISTIC_MINOR_KILL_GOLD', 1);

-- Militaristic: garrisoned Commanders give Culture and Science per level.
DELETE FROM ProgressionTreeNodeUnlocks
WHERE ProgressionTreeNodeType = 'NODE_ATTRIBUTE_MILITARISTIC_06'
  AND TargetKind = 'KIND_MODIFIER'
  AND TargetType = 'MOD_ATTRIBUTE_MILITARISTIC_06';

INSERT OR IGNORE INTO ProgressionTreeNodeUnlocks (ProgressionTreeNodeType, TargetKind, TargetType, UnlockDepth)
    VALUES
        ('NODE_ATTRIBUTE_MILITARISTIC_06', 'KIND_MODIFIER', 'MPT_BALANCE_MOD_ATTRIBUTE_MILITARISTIC_GARRISON_CULTURE', 1),
        ('NODE_ATTRIBUTE_MILITARISTIC_06', 'KIND_MODIFIER', 'MPT_BALANCE_MOD_ATTRIBUTE_MILITARISTIC_GARRISON_SCIENCE', 1);

UPDATE ModifierArguments
SET Value = 100
WHERE ModifierId = 'MOD_ATTRIBUTE_MILITARISTIC_03'
  AND Name = 'Percent';
