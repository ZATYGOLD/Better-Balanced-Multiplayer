--*******************************************************
--***************** MULTIPLAYER ONLY MAPS ***************
--*******************************************************
-- The map list is shared with single player, so this hidden multiplayer-only
-- flag picks each mode's scripts: Pangaea Ultima and the copies of the standard
-- maps are filtered out whenever it is unset (single-player setup), and the base
-- scripts that have a copy whenever it is set (multiplayer setup).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupID, Hidden, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTMultiplayerSetup', 'LOC_MPT_MAPS_MULTIPLAYER_SETUP', 'LOC_MPT_MAPS_MULTIPLAYER_SETUP', 'bool', 0, 1, 'Game', 'MPTMultiplayerSetup', 'GameOptions', 1, 0, 0, 9001);

INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('MPTMultiplayerOnlyMaps', 'DomainValueFilters', 'SELECT Domain, File AS Value, ''Difference'' AS Filter FROM Maps WHERE File LIKE ''{multiplayer-toolkit}maps/maps/%'''),
        ('MPTSinglePlayerOnlyMaps', 'DomainValueFilters', 'SELECT Domain, REPLACE(File, ''{multiplayer-toolkit}maps/maps/standard/'', ''{base-standard}maps/'') AS Value, ''Difference'' AS Filter FROM Maps WHERE File LIKE ''{multiplayer-toolkit}maps/maps/standard/%''');

INSERT OR IGNORE INTO QueryCriteria (QueryID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('MPTMultiplayerOnlyMaps', 'Game', 'MPTMultiplayerSetup', 'NotEquals', 1),
        ('MPTSinglePlayerOnlyMaps', 'Game', 'MPTMultiplayerSetup', 'Equals', 1);
