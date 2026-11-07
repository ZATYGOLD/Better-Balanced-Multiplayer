/*
 * Better Balanced Multiplayer - multiplayer quality-of-life features for Civilization VII.
 * Copyright (C) 2026  Zatygold
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/**
 * Better Balanced Multiplayer - Keybind actions (config/input.sql registers them and their default keys).
 */

const PAUSE_ACTION_ID = 'mpt-pause-game';

/** Lens toggles: action id -> lens (pressing it again returns to the default lens). */
const LENS_ACTIONS = {
  'mpt-lens-trade': 'fxs-trade-lens',
  'mpt-lens-continent': 'fxs-continent-lens',
  'mpt-lens-appeal': 'fxs-general-appeal-lens',
  'mpt-lens-settler': 'fxs-settler-lens',
  'mpt-lens-discovery': 'fxs-discovery-lens'
};
const DEFAULT_LENS = 'fxs-default-lens';

/** Unit actions: action id -> unit operation or command for the selected unit. */
const UNIT_ACTIONS = {
  'mpt-unit-found-city': 'UNITOPERATION_FOUND_CITY',
  'mpt-unit-search': 'UNITOPERATION_SEARCH',
  'mpt-unit-join-commander': 'UNITCOMMAND_ADD_TO_ARMY',
  'mpt-unit-leave-commander': 'UNITCOMMAND_REMOVE_FROM_ARMY',
  'mpt-commander-pack': 'UNITCOMMAND_PACK_ARMY',
  'mpt-commander-unpack': 'UNITCOMMAND_UNPACK_ARMY'
};

/** City actions: action id -> which settlement to select (its screen opens). */
const CITY_ACTIONS = {
  'mpt-city-previous': 'previous',
  'mpt-city-next': 'next',
  'mpt-city-capital': 'capital'
};

/** Every mod action listed in the keyboard-mapping options. */
const KEYBIND_ACTIONS = [PAUSE_ACTION_ID, ...Object.keys(LENS_ACTIONS), ...Object.keys(UNIT_ACTIONS), ...Object.keys(CITY_ACTIONS)];

export { CITY_ACTIONS, DEFAULT_LENS, KEYBIND_ACTIONS, LENS_ACTIONS, PAUSE_ACTION_ID, UNIT_ACTIONS };
