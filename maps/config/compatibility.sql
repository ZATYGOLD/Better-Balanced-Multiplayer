--*******************************************************
--***************** ADVANCED SETTINGS PRO ***************
--*******************************************************
-- Settings Advanced Settings Pro also offers: its own apply in single player, the
-- Toolkit's in multiplayer, so each of its counterparts is taken out of multiplayer
-- setup (and its data, keyed on its setting, is not loaded there). Advanced Settings
-- Pro loads its setup parameters last, so this also runs as a trigger.
CREATE TABLE IF NOT EXISTS MPT_AdvancedSettingsCounterparts
    (
        ParameterID TEXT NOT NULL,
        CounterpartID TEXT NOT NULL,
        PRIMARY KEY(ParameterID)
    );

INSERT OR IGNORE INTO MPT_AdvancedSettingsCounterparts (ParameterID, CounterpartID)
    VALUES
        ('MPTResourceAmount', 'ZG_Resources'),
        ('MPTDisasters', 'ZG_DisasterFrequency'),
        ('MPTDisastersAntiquity', 'ZG_DisastersAntiquity'),
        ('MPTDisastersExploration', 'ZG_DisastersExploration'),
        ('MPTDisastersModern', 'ZG_DisastersModern'),
        ('MPTNaturalWonders', 'ZG_NaturalWondersCount'),
        ('MPTLakes', 'ZG_LakeGeneration'),
        ('MPTNaturalWonderBarrierReef', 'ZG_NW_BarrierReef'),
        ('MPTNaturalWonderBermudaTriangle', 'ZG_NW_BermudaTriangle'),
        ('MPTNaturalWonderGrandCanyon', 'ZG_NW_GrandCanyon'),
        ('MPTNaturalWonderGreatBlueHole', 'ZG_NW_GreatBlueHole'),
        ('MPTNaturalWonderGullfoss', 'ZG_NW_Gullfoss'),
        ('MPTNaturalWonderHoerikwaggo', 'ZG_NW_Hoerikwaggo'),
        ('MPTNaturalWonderIguazuFalls', 'ZG_NW_IguazuFalls'),
        ('MPTNaturalWonderKilimanjaro', 'ZG_NW_Kilimanjaro'),
        ('MPTNaturalWonderMachapuchare', 'ZG_NW_Machapuchare'),
        ('MPTNaturalWonderMapuAVaeaBlowholes', 'ZG_NW_MapuAVaeaBlowholes'),
        ('MPTNaturalWonderMountEverest', 'ZG_NW_MountEverest'),
        ('MPTNaturalWonderMountFuji', 'ZG_NW_MountFuji'),
        ('MPTNaturalWonderNachiFalls', 'ZG_NW_NachiFalls'),
        ('MPTNaturalWonderRedwoodForest', 'ZG_NW_RedwoodForest'),
        ('MPTNaturalWonderSeongsanIlchulbong', 'ZG_NW_SeongsanIlchulbong'),
        ('MPTNaturalWonderThera', 'ZG_NW_Thera'),
        ('MPTNaturalWonderTorresDelPaine', 'ZG_NW_TorresDelPaine'),
        ('MPTNaturalWonderUluru', 'ZG_NW_Uluru'),
        ('MPTNaturalWonderValleyOfFlowers', 'ZG_NW_ValleyOfFlowers'),
        ('MPTNaturalWonderVihren', 'ZG_NW_Vihren'),
        ('MPTNaturalWonderVinicunca', 'ZG_NW_Vinicunca'),
        ('MPTNaturalWonderZhangjiajie', 'ZG_NW_Zhangjiajie');

UPDATE Parameters
    SET SupportsLANMultiplayer = 0, SupportsInternetMultiplayer = 0, SupportsHotseatMultiplayer = 0
    WHERE ParameterID IN (SELECT CounterpartID FROM MPT_AdvancedSettingsCounterparts);

CREATE TRIGGER IF NOT EXISTS MPT_Maps_AdvancedSettingsCounterparts
    AFTER INSERT ON Parameters
    WHEN NEW.ParameterID IN (SELECT CounterpartID FROM MPT_AdvancedSettingsCounterparts)
BEGIN
    UPDATE Parameters
        SET SupportsLANMultiplayer = 0, SupportsInternetMultiplayer = 0, SupportsHotseatMultiplayer = 0
        WHERE rowid = NEW.rowid;
END;
