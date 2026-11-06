--*******************************************************
--***************** MULTIPLAYER ONLY MAPS ***************
--*******************************************************
-- Pangaea Ultima shares the map list with single player, so it is filtered out
-- whenever this hidden multiplayer-only flag is unset (single-player setup).
INSERT OR IGNORE INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupID, Hidden, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES
        ('MPTMultiplayerSetup', 'LOC_MPT_MAPS_MULTIPLAYER_SETUP', 'LOC_MPT_MAPS_MULTIPLAYER_SETUP', 'bool', 0, 1, 'Game', 'MPTMultiplayerSetup', 'GameOptions', 1, 0, 0, 9001);

INSERT OR IGNORE INTO Queries (QueryID, Type, SQL)
    VALUES
        ('MPTMultiplayerOnlyMaps', 'DomainValueFilters', 'SELECT ''StandardMaps'' AS Domain, ''{multiplayer-toolkit}maps/maps/pangaea-ultima.js'' AS Value, ''Difference'' AS Filter');

INSERT OR IGNORE INTO QueryCriteria (QueryID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES
        ('MPTMultiplayerOnlyMaps', 'Game', 'MPTMultiplayerSetup', 'NotEquals', 1);
