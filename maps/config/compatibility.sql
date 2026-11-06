-- Multiplayer Toolkit - Maps: compatibility with other mods (setup database).
--
-- Zatygold's Advanced Settings Pro supplies its own resources (its Resources
-- setting, ZG_Resources). With it enabled the Custom Resource System option is
-- removed: an option that is absent counts as Off for the resource data
-- (modinfo criteria) and for map generation (global-team-starts.js).
-- Advanced Settings Pro loads its setup parameters last, so the removal also
-- runs as a trigger when its parameter is added.

DELETE FROM Parameters
    WHERE ParameterID = 'EvWResourceSystem'
    AND EXISTS (SELECT 1 FROM Parameters WHERE ParameterID = 'ZG_Resources');

CREATE TRIGGER IF NOT EXISTS MPT_Maps_AdvancedSettingsProResources
    AFTER INSERT ON Parameters
    WHEN NEW.ParameterID = 'ZG_Resources'
BEGIN
    DELETE FROM Parameters WHERE ParameterID = 'EvWResourceSystem';
END;
