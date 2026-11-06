--*******************************************************
--***************** PAUSE KEYBIND ***********************
--*******************************************************
-- A rebindable Pause Game action in Options -> keyboard mapping, default P.
-- P is also the base "open-attributes" key; either can be rebound there.
INSERT OR REPLACE INTO InputActions (ActionId, DeviceType, Name, Description, SortIndex)
    VALUES
        ('mpt-pause-game', 'Keyboard', 'LOC_MPT_PAUSE_KEYBIND', 'LOC_MPT_PAUSE_KEYBIND_TT', 100);

INSERT OR REPLACE INTO InputActionDefaultGestures (ActionId, "Index", GestureType, GestureData)
    VALUES
        ('mpt-pause-game', 0, 'KBMouse', 'KEY_P');
