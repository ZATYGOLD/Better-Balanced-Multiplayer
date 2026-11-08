--*******************************************************
--***************** RESOURCE EFFECTS RESET **************
--*******************************************************
-- Resource List All: the game's own effects of every pooled resource, and
-- Balance's unit-production effects that the Maps effects replace, are removed.
DELETE FROM GameModifiers
WHERE ModifierId IN (
    SELECT ModifierId FROM ModifierMetadatas
    WHERE FieldName = 'ResourceType' AND String IN (
        'RESOURCE_CAMELS', 'RESOURCE_CLAY', 'RESOURCE_COTTON', 'RESOURCE_COWRIE', 'RESOURCE_CRABS',
        'RESOURCE_FISH', 'RESOURCE_LIMESTONE', 'RESOURCE_HARDWOOD', 'RESOURCE_HORSES', 'RESOURCE_IRON',
        'RESOURCE_SALT', 'RESOURCE_HIDES', 'RESOURCE_PEARLS', 'RESOURCE_RICE', 'RESOURCE_TIN',
        'RESOURCE_WHALES', 'RESOURCE_WINE', 'RESOURCE_SILK', 'RESOURCE_TURTLES', 'RESOURCE_WILD_GAME',
        'RESOURCE_WOOL', 'RESOURCE_COAL', 'RESOURCE_DYES', 'RESOURCE_NITER', 'RESOURCE_DATES',
        'RESOURCE_FURS', 'RESOURCE_INCENSE', 'RESOURCE_FLAX', 'RESOURCE_KAOLIN', 'RESOURCE_JADE',
        'RESOURCE_MANGOS', 'RESOURCE_MARBLE', 'RESOURCE_TOBACCO', 'RESOURCE_TRUFFLES', 'RESOURCE_SILVER',
        'RESOURCE_RUBIES', 'RESOURCE_COCOA', 'RESOURCE_PITCH', 'RESOURCE_SPICES', 'RESOURCE_TEA',
        'RESOURCE_CITRUS', 'RESOURCE_COFFEE', 'RESOURCE_QUININE', 'RESOURCE_SUGAR', 'RESOURCE_GOLD',
        'RESOURCE_GYPSUM', 'RESOURCE_IVORY', 'RESOURCE_LLAMAS', 'RESOURCE_OIL', 'RESOURCE_RUBBER'
    )
);

DELETE FROM GameModifiers
WHERE ModifierId IN (
    'BBM_BALANCE_MOD_HORSES_CAVALRY_PRODUCTION',
    'BBM_BALANCE_MOD_IRON_INFANTRY_PRODUCTION',
    'BBM_BALANCE_MOD_NITER_SIEGE_NAVAL_PRODUCTION',
    'BBM_BALANCE_MOD_NITER_RANGED_SIEGE_PRODUCTION',
    'BBM_BALANCE_MOD_OIL_CAVALRY_HEAVY_PRODUCTION',
    'BBM_BALANCE_MOD_RUBBER_INFANTRY_AIR_PRODUCTION'
);

-- Guard against Age databases being updated in place: only the incoming
-- Age's Maps modifier set may remain active.
DELETE FROM GameModifiers
WHERE ModifierId LIKE 'BBM_MAPS_A_%' OR ModifierId LIKE 'BBM_MAPS_E_%' OR ModifierId LIKE 'BBM_MAPS_M_%';

--*******************************************************
--***************** COMMON RESOURCE EFFECTS *************
--*******************************************************
-- Effects shared by every Age (effects-common.xml).
INSERT OR IGNORE INTO GameModifiers (ModifierId)
    VALUES
        ('BBM_MAPS_RES_CLAY_WAREHOUSE_PRODUCTION'),
        ('BBM_MAPS_RES_LIMESTONE_WONDER_PRODUCTION'),
        ('BBM_MAPS_RES_MARBLE_BUILDING_PRODUCTION'),
        ('BBM_MAPS_RES_HARDWOOD_NAVAL_PRODUCTION'),
        ('BBM_MAPS_RES_HARDWOOD_CIVILIAN_PRODUCTION'),
        ('BBM_MAPS_RES_SALT_UNIT_PRODUCTION'),
        ('BBM_MAPS_RES_RICE_FOOD'),
        ('BBM_MAPS_RES_RICE_PRODUCTION'),
        ('BBM_MAPS_RES_TURTLES_WAREHOUSE_CULTURE'),
        ('BBM_MAPS_RES_NITER_RANGED_SIEGE_PRODUCTION'),
        ('BBM_MAPS_RES_JADE_GOLD'),
        ('BBM_MAPS_RES_PITCH_WATER_GOLD');
