--*******************************************************
--***************** KEYBINDS ****************************
--*******************************************************
-- Toolkit actions in Options -> keyboard mapping (ui/mp-keybind), with Civilization
-- VI's keys where it had the same action. P is also the base "open-attributes" key;
-- either can be rebound there.
INSERT OR REPLACE INTO InputActions (ActionId, DeviceType, Name, Description, SortIndex)
    VALUES
        ('mpt-pause-game', 'Keyboard', 'LOC_MPT_PAUSE_KEYBIND', 'LOC_MPT_PAUSE_KEYBIND_TT', 100),
        ('mpt-lens-trade', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_TRADE', 'LOC_MPT_KEYBIND_LENS_TRADE_TT', 101),
        ('mpt-lens-continent', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_CONTINENT', 'LOC_MPT_KEYBIND_LENS_CONTINENT_TT', 102),
        ('mpt-lens-appeal', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_APPEAL', 'LOC_MPT_KEYBIND_LENS_APPEAL_TT', 103),
        ('mpt-lens-settler', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_SETTLER', 'LOC_MPT_KEYBIND_LENS_SETTLER_TT', 104),
        ('mpt-lens-discovery', 'Keyboard', 'LOC_MPT_KEYBIND_LENS_DISCOVERY', 'LOC_MPT_KEYBIND_LENS_DISCOVERY_TT', 105),
        ('mpt-unit-join-commander', 'Keyboard', 'LOC_MPT_KEYBIND_JOIN_COMMANDER', 'LOC_MPT_KEYBIND_JOIN_COMMANDER_TT', 106),
        ('mpt-unit-leave-commander', 'Keyboard', 'LOC_MPT_KEYBIND_LEAVE_COMMANDER', 'LOC_MPT_KEYBIND_LEAVE_COMMANDER_TT', 107),
        ('mpt-commander-pack', 'Keyboard', 'LOC_MPT_KEYBIND_PACK_UNITS', 'LOC_MPT_KEYBIND_PACK_UNITS_TT', 108),
        ('mpt-commander-unpack', 'Keyboard', 'LOC_MPT_KEYBIND_UNPACK_UNITS', 'LOC_MPT_KEYBIND_UNPACK_UNITS_TT', 109);

-- Lenses 2 (Continent), 3 (Appeal) and 4 (Settler) as in Civilization VI; Trade and
-- Discovery take the free 1 and 5.
INSERT OR REPLACE INTO InputActionDefaultGestures (ActionId, "Index", GestureType, GestureData)
    VALUES
        ('mpt-pause-game', 0, 'KBMouse', 'KEY_P'),
        ('mpt-lens-trade', 0, 'KBMouse', 'KEY_1'),
        ('mpt-lens-continent', 0, 'KBMouse', 'KEY_2'),
        ('mpt-lens-appeal', 0, 'KBMouse', 'KEY_3'),
        ('mpt-lens-settler', 0, 'KBMouse', 'KEY_4'),
        ('mpt-lens-discovery', 0, 'KBMouse', 'KEY_5'),
        ('mpt-unit-join-commander', 0, 'KBMouse', 'KEY_Z+KEY_CONTROL'),
        ('mpt-unit-leave-commander', 0, 'KBMouse', 'KEY_X+KEY_CONTROL'),
        ('mpt-commander-pack', 0, 'KBMouse', 'KEY_Q+KEY_CONTROL'),
        ('mpt-commander-unpack', 0, 'KBMouse', 'KEY_W+KEY_CONTROL');

-- Government on F7, as in Civilization VI (the game's default is L).
UPDATE InputActionDefaultGestures SET GestureData = 'KEY_F7'
WHERE ActionId = 'open-traditions' AND "Index" = 0 AND GestureType = 'KBMouse';
