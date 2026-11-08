// Player Placement rules shared by the placement pass (maps/scripts/global-team-starts.js),
// the lobby slots (ui/maps/bbm-match-slots.js) and the turn-1 check (ui/maps/bbm-start-bias-warning.js).

// The hidden Player Placement setting, set by the Match Type.
export const PLACEMENT_SETTING_KEY = "BBMPlayerPlacement";
// Players of each team placement; any other value places on the whole map.
export const PLAYERS_BY_PLACEMENT = { BBM_MAPS_PLACEMENT_DUEL: 2, BBM_MAPS_PLACEMENT_2V2: 4, BBM_MAPS_PLACEMENT_3V3: 6, BBM_MAPS_PLACEMENT_4V4: 8 };
// Fewest tiles between two starts.
export const START_MINIMUM_DISTANCE = 12;
