--*******************************************************
--***************** ADVANCED SETTINGS RESOURCES *********
--*******************************************************
-- Advanced Settings' Resources setting (ZG_Resources) replaces the Custom Resource
-- System: with it present the option is removed, and an absent option counts as Off
-- (modinfo criteria, maps/scripts/global-team-starts.js). Advanced Settings loads its
-- setup parameters last, so the removal also runs as a trigger.
DELETE FROM Parameters
    WHERE ParameterID = 'MPTResourceSystem'
    AND EXISTS (SELECT 1 FROM Parameters WHERE ParameterID = 'ZG_Resources');

CREATE TRIGGER IF NOT EXISTS MPT_Maps_AdvancedSettingsResources
    AFTER INSERT ON Parameters
    WHEN NEW.ParameterID = 'ZG_Resources'
BEGIN
    DELETE FROM Parameters WHERE ParameterID = 'MPTResourceSystem';
END;
