--*******************************************************
--***************** KEYBINDS ****************************
--*******************************************************
-- Toolkit actions in Options -> keyboard mapping (ui/mp-keybind). They act in
-- multiplayer games only, and their default keys are ones the game leaves free,
-- so the game's own keys stay as they are.
INSERT OR REPLACE INTO InputActions (ActionId, DeviceType, Name, Description, SortIndex)
    VALUES
        ('mpt-pause-game', 'Keyboard', 'LOC_MPT_PAUSE_KEYBIND', 'LOC_MPT_PAUSE_KEYBIND_TT', 100),
        ('mpt-lens-trade', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_TRADE', 'LOC_MPT_KEYBIND_LENS_TRADE_TT', 101),
        ('mpt-lens-continent', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_CONTINENT', 'LOC_MPT_KEYBIND_LENS_CONTINENT_TT', 102),
        ('mpt-lens-appeal', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_APPEAL', 'LOC_MPT_KEYBIND_LENS_APPEAL_TT', 103),
        ('mpt-lens-settler', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_SETTLER', 'LOC_MPT_KEYBIND_LENS_SETTLER_TT', 104),
        ('mpt-lens-discovery', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_DISCOVERY', 'LOC_MPT_KEYBIND_LENS_DISCOVERY_TT', 105),
        ('mpt-unit-found-city', 'Keyboard', 'LOC_MPT_KEYBIND_FOUND_CITY', 'LOC_MPT_KEYBIND_FOUND_CITY_TT', 106),
        ('mpt-unit-join-commander', 'Keyboard', 'LOC_MPT_KEYBIND_JOIN_COMMANDER', 'LOC_MPT_KEYBIND_JOIN_COMMANDER_TT', 107),
        ('mpt-unit-leave-commander', 'Keyboard', 'LOC_MPT_KEYBIND_LEAVE_COMMANDER', 'LOC_MPT_KEYBIND_LEAVE_COMMANDER_TT', 108),
        ('mpt-commander-pack', 'Keyboard', 'LOC_MPT_KEYBIND_PACK_UNITS', 'LOC_MPT_KEYBIND_PACK_UNITS_TT', 109),
        ('mpt-commander-unpack', 'Keyboard', 'LOC_MPT_KEYBIND_UNPACK_UNITS', 'LOC_MPT_KEYBIND_UNPACK_UNITS_TT', 110),
        ('mpt-city-previous', 'Keyboard', 'LOC_MPT_KEYBIND_CITY_PREVIOUS', 'LOC_MPT_KEYBIND_CITY_PREVIOUS_TT', 111),
        ('mpt-city-next', 'Keyboard', 'LOC_MPT_KEYBIND_CITY_NEXT', 'LOC_MPT_KEYBIND_CITY_NEXT_TT', 112),
        ('mpt-city-capital', 'Keyboard', 'LOC_MPT_KEYBIND_CITY_CAPITAL', 'LOC_MPT_KEYBIND_CITY_CAPITAL_TT', 113),
        ('mpt-unit-search', 'Keyboard', 'LOC_MPT_KEYBIND_SEARCH', 'LOC_MPT_KEYBIND_SEARCH_TT', 114);

-- Number keys for the lenses, brackets and backslash for settlements, Ctrl with a
-- letter for Pause and the unit actions (Ctrl+P and Ctrl+B after Civilization VI's
-- P and B, whose plain keys the game uses).
INSERT OR REPLACE INTO InputActionDefaultGestures (ActionId, "Index", GestureType, GestureData)
    VALUES
        ('mpt-pause-game', 0, 'KBMouse', 'KEY_P+KEY_CONTROL'),
        ('mpt-lens-trade', 0, 'KBMouse', 'KEY_1'),
        ('mpt-lens-continent', 0, 'KBMouse', 'KEY_2'),
        ('mpt-lens-appeal', 0, 'KBMouse', 'KEY_3'),
        ('mpt-lens-settler', 0, 'KBMouse', 'KEY_4'),
        ('mpt-lens-discovery', 0, 'KBMouse', 'KEY_5'),
        ('mpt-unit-found-city', 0, 'KBMouse', 'KEY_B+KEY_CONTROL'),
        ('mpt-unit-join-commander', 0, 'KBMouse', 'KEY_Z+KEY_CONTROL'),
        ('mpt-unit-leave-commander', 0, 'KBMouse', 'KEY_X+KEY_CONTROL'),
        ('mpt-commander-pack', 0, 'KBMouse', 'KEY_Q+KEY_CONTROL'),
        ('mpt-commander-unpack', 0, 'KBMouse', 'KEY_W+KEY_CONTROL'),
        ('mpt-city-previous', 0, 'KBMouse', 'KEY_LBRACKET'),
        ('mpt-city-next', 0, 'KBMouse', 'KEY_RBRACKET'),
        ('mpt-city-capital', 0, 'KBMouse', 'KEY_BACKSLASH'),
        ('mpt-unit-search', 0, 'KBMouse', 'KEY_J+KEY_CONTROL');
