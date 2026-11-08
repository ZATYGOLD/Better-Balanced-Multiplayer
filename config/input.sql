--*******************************************************
--***************** KEYBINDS ****************************
--*******************************************************
-- The mod's actions in Options -> keyboard mapping (ui/keybind). They act in
-- multiplayer games only. Their default keys are ones the game leaves free,
-- except B (Found Settlement), taken from the Advisors Council (now Ctrl+B).
INSERT OR IGNORE INTO InputActions (ActionId, DeviceType, Name, Description, SortIndex)
    VALUES
        ('bbm-pause-game', 'Keyboard', 'LOC_BBM_PAUSE_KEYBIND', 'LOC_BBM_PAUSE_KEYBIND_TT', 100),
        ('bbm-lens-trade', 'Keyboard', 'LOC_BBM_KEYBIND_LENS_TRADE', 'LOC_BBM_KEYBIND_LENS_TRADE_TT', 101),
        ('bbm-lens-continent', 'Keyboard', 'LOC_BBM_KEYBIND_LENS_CONTINENT', 'LOC_BBM_KEYBIND_LENS_CONTINENT_TT', 102),
        ('bbm-lens-appeal', 'Keyboard', 'LOC_BBM_KEYBIND_LENS_APPEAL', 'LOC_BBM_KEYBIND_LENS_APPEAL_TT', 103),
        ('bbm-lens-settler', 'Keyboard', 'LOC_BBM_KEYBIND_LENS_SETTLER', 'LOC_BBM_KEYBIND_LENS_SETTLER_TT', 104),
        ('bbm-lens-discovery', 'Keyboard', 'LOC_BBM_KEYBIND_LENS_DISCOVERY', 'LOC_BBM_KEYBIND_LENS_DISCOVERY_TT', 105),
        ('bbm-unit-found-city', 'Keyboard', 'LOC_BBM_KEYBIND_FOUND_CITY', 'LOC_BBM_KEYBIND_FOUND_CITY_TT', 106),
        ('bbm-unit-join-commander', 'Keyboard', 'LOC_BBM_KEYBIND_JOIN_COMMANDER', 'LOC_BBM_KEYBIND_JOIN_COMMANDER_TT', 107),
        ('bbm-unit-leave-commander', 'Keyboard', 'LOC_BBM_KEYBIND_LEAVE_COMMANDER', 'LOC_BBM_KEYBIND_LEAVE_COMMANDER_TT', 108),
        ('bbm-commander-pack', 'Keyboard', 'LOC_BBM_KEYBIND_PACK_UNITS', 'LOC_BBM_KEYBIND_PACK_UNITS_TT', 109),
        ('bbm-commander-unpack', 'Keyboard', 'LOC_BBM_KEYBIND_UNPACK_UNITS', 'LOC_BBM_KEYBIND_UNPACK_UNITS_TT', 110),
        ('bbm-city-previous', 'Keyboard', 'LOC_BBM_KEYBIND_CITY_PREVIOUS', 'LOC_BBM_KEYBIND_CITY_PREVIOUS_TT', 111),
        ('bbm-city-next', 'Keyboard', 'LOC_BBM_KEYBIND_CITY_NEXT', 'LOC_BBM_KEYBIND_CITY_NEXT_TT', 112),
        ('bbm-city-capital', 'Keyboard', 'LOC_BBM_KEYBIND_CITY_CAPITAL', 'LOC_BBM_KEYBIND_CITY_CAPITAL_TT', 113),
        ('bbm-unit-search', 'Keyboard', 'LOC_BBM_KEYBIND_SEARCH', 'LOC_BBM_KEYBIND_SEARCH_TT', 114);

-- Number keys for the lenses, brackets and backslash for settlements, B for Found
-- Settlement (as in Civilization VI), Ctrl with a letter for Pause and the other
-- unit actions (Ctrl+P after Civilization VI's P, which the game uses).
INSERT OR IGNORE INTO InputActionDefaultGestures (ActionId, "Index", GestureType, GestureData)
    VALUES
        ('bbm-pause-game', 0, 'KBMouse', 'KEY_P+KEY_CONTROL'),
        ('bbm-lens-trade', 0, 'KBMouse', 'KEY_1'),
        ('bbm-lens-continent', 0, 'KBMouse', 'KEY_2'),
        ('bbm-lens-appeal', 0, 'KBMouse', 'KEY_3'),
        ('bbm-lens-settler', 0, 'KBMouse', 'KEY_4'),
        ('bbm-lens-discovery', 0, 'KBMouse', 'KEY_5'),
        ('bbm-unit-found-city', 0, 'KBMouse', 'KEY_B'),
        ('bbm-unit-join-commander', 0, 'KBMouse', 'KEY_Z+KEY_CONTROL'),
        ('bbm-unit-leave-commander', 0, 'KBMouse', 'KEY_X+KEY_CONTROL'),
        ('bbm-commander-pack', 0, 'KBMouse', 'KEY_Q+KEY_CONTROL'),
        ('bbm-commander-unpack', 0, 'KBMouse', 'KEY_W+KEY_CONTROL'),
        ('bbm-city-previous', 0, 'KBMouse', 'KEY_LBRACKET'),
        ('bbm-city-next', 0, 'KBMouse', 'KEY_RBRACKET'),
        ('bbm-city-capital', 0, 'KBMouse', 'KEY_BACKSLASH'),
        ('bbm-unit-search', 0, 'KBMouse', 'KEY_J+KEY_CONTROL');

-- The Advisors Council moves from B to Ctrl+B. Default keys are global (the
-- keyboard-mapping data has no game modes), so this applies in single player too.
-- Bindings a player saved earlier may still take precedence until reset to defaults.
UPDATE InputActionDefaultGestures SET GestureData = 'KEY_B+KEY_CONTROL'
    WHERE ActionId = 'open-advisors' AND GestureType = 'KBMouse' AND GestureData = 'KEY_B';
