-- Give the Custom Triumph Set this Age's Conqueror triumphs.
INSERT OR IGNORE INTO Legacy_LegacySets (LegacySetType, LegacyType)
SELECT 'MPT_LEGACY_SET_CUSTOM', LegacyType
FROM Legacy_LegacySets
WHERE LegacySetType = 'LEGACY_SET_CONQUEROR';
