-- Multiplayer Toolkit - Maps: multiplayer setup only.
--
-- The Map Options (Player Placement, Strict Start Biases, Custom Resource
-- System) are multiplayer parameters (map-options.xml). Pangaea Ultima shares
-- the game's map list with single player, so it is filtered out of that list
-- whenever this hidden multiplayer-only flag is unset (single-player setup).

INSERT INTO Parameters (ParameterID, Name, Description, Domain, Hash, DefaultValue, ConfigurationGroup, ConfigurationKey, GroupID, Hidden, SupportsSinglePlayer, ChangeableAfterGameStart, SortIndex)
    VALUES ('MPTMultiplayerSetup', 'LOC_MPT_MAPS_MULTIPLAYER_SETUP', 'LOC_MPT_MAPS_MULTIPLAYER_SETUP', 'bool', 0, 1, 'Game', 'MPTMultiplayerSetup', 'GameOptions', 1, 0, 0, 9001);

INSERT INTO Queries (QueryID, Type, SQL)
    VALUES ('MPTMultiplayerOnlyMaps', 'DomainValueFilters',
            'SELECT ''StandardMaps'' AS Domain, ''{multiplayer-toolkit}maps/maps/balanced-ffa-pangaea.js'' AS Value, ''Difference'' AS Filter');

INSERT INTO QueryCriteria (QueryID, ConfigurationGroup, ConfigurationKey, Operator, ConfigurationValue)
    VALUES ('MPTMultiplayerOnlyMaps', 'Game', 'MPTMultiplayerSetup', 'NotEquals', 1);
