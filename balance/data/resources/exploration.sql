-- Spices: replace Influence with Food in Homelands and Distant Lands.
UPDATE ModifierArguments
SET Value = 'YIELD_FOOD'
WHERE Name = 'YieldType'
  AND ModifierId IN (
      'MOD_SPICES_HOMELAND_INFLUENCE',
      'MOD_SPICES_DISTANT_LANDS_INFLUENCE'
  );

-- Tea: replace Production with Food in Homelands and Distant Lands.
UPDATE ModifierArguments
SET Value = 'YIELD_FOOD'
WHERE Name = 'YieldType'
  AND ModifierId IN (
      'MOD_TEA_HOMELAND_PRODUCTION',
      'MOD_TEA_DISTANT_LANDS_PRODUCTION'
  );

-- Keep Tea's resource yield category consistent with its changed bonus.
DELETE FROM TypeTags
WHERE Type = 'RESOURCE_TEA'
  AND Tag = 'PRODUCTION';

INSERT OR IGNORE INTO TypeTags (Type, Tag)
VALUES ('RESOURCE_TEA', 'FOOD');
