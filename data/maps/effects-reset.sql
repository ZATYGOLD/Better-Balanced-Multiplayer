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
    'MPT_BALANCE_MOD_HORSES_CAVALRY_PRODUCTION',
    'MPT_BALANCE_MOD_IRON_INFANTRY_PRODUCTION',
    'MPT_BALANCE_MOD_NITER_SIEGE_NAVAL_PRODUCTION',
    'MPT_BALANCE_MOD_NITER_RANGED_SIEGE_PRODUCTION',
    'MPT_BALANCE_MOD_OIL_CAVALRY_HEAVY_PRODUCTION',
    'MPT_BALANCE_MOD_RUBBER_INFANTRY_AIR_PRODUCTION'
);

-- Guard against Age databases being updated in place: only the incoming
-- Age's Maps modifier set may remain active.
DELETE FROM GameModifiers
WHERE ModifierId LIKE 'MPT_MAPS_A_%' OR ModifierId LIKE 'MPT_MAPS_E_%' OR ModifierId LIKE 'MPT_MAPS_M_%';

--*******************************************************
--***************** COMMON RESOURCE EFFECTS *************
--*******************************************************
-- Effects shared by every Age (effects-common.xml).
INSERT OR IGNORE INTO GameModifiers (ModifierId)
    VALUES
        ('MPT_MAPS_RES_CLAY_WAREHOUSE_PRODUCTION'),
        ('MPT_MAPS_RES_LIMESTONE_WONDER_PRODUCTION'),
        ('MPT_MAPS_RES_MARBLE_BUILDING_PRODUCTION'),
        ('MPT_MAPS_RES_HARDWOOD_NAVAL_PRODUCTION'),
        ('MPT_MAPS_RES_HARDWOOD_CIVILIAN_PRODUCTION'),
        ('MPT_MAPS_RES_SALT_UNIT_PRODUCTION'),
        ('MPT_MAPS_RES_RICE_FOOD'),
        ('MPT_MAPS_RES_RICE_PRODUCTION'),
        ('MPT_MAPS_RES_TURTLES_WAREHOUSE_CULTURE'),
        ('MPT_MAPS_RES_NITER_RANGED_SIEGE_PRODUCTION'),
        ('MPT_MAPS_RES_JADE_GOLD'),
        ('MPT_MAPS_RES_PITCH_WATER_GOLD');
