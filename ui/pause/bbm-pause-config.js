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
 * Better Balanced Multiplayer - Pause configuration & constants.
 */
import { UNIT_ACTIONS } from '../keybind/bbm-keybind-config.js';

/** Source tag used when registering/removing engine input filters. */
const FILTER_SOURCE = "MultiplayerToolkit";

/** Interface mode that shows the built-in pause menu. */
const PAUSE_MENU_MODE = "INTERFACEMODE_PAUSE_MENU";

/** Tunable timings / thresholds. */
const CONFIG = {
	enabled: true,               // master switch (set false to fully disable the pause feature)
	resumeCountdownSeconds: 5,   // length of the "UNPAUSING..." countdown
	pollMs: 250,                 // tally / condition evaluation interval
	convergenceDelayMs: 2000,    // wait for all clients to flag in before evaluating readiness
	finalizeBackstopMs: 4000,    // fallback idle if the unpause event is missed
	connectionWatchMs: 500       // how often to poll player connections for drops
};

/**
 * Input actions that advance / commit game state, plus the mod's unit
 * keybinds. Blocked while paused. Verified against Base/modules/core/config/Input.xml.
 * Camera, selection, information screens and city/production panels are
 * intentionally NOT listed.
 */
const PROGRESS_ACTIONS = [
	"next-action", "keyboard-enter", "force-end-turn",
	"unit-move", "unit-ranged-attack", "unit-skip-turn", "unit-sleep",
	"unit-fortify", "unit-heal", "unit-alert", "unit-auto-explore",
	"trigger-accept-dip", "quick-load",
	...Object.keys(UNIT_ACTIONS)
];

/** Localization keys (text/en_us/shared.xml; View Map reuses the base game's string). */
const LOC = {
	dropResume: "LOC_BBM_DROP_RESUME",      // host-only: kick disconnected players to break a pause deadlock
	viewMap: "LOC_ADVANCED_START_VIEW_MAP",
	readyTally: "LOC_BBM_PAUSE_READY_TALLY",
	pausedBy: "LOC_ACTION_PANEL_MULTIPLAYER_PAUSE_TT",   // the game's "paused by the following players"
	hintReady: "LOC_BBM_PAUSE_HINT_READY",
	hintWaiting: "LOC_BBM_PAUSE_HINT_WAITING",
	aPlayer: "LOC_BBM_PAUSE_A_PLAYER",
	playerDisconnected: "LOC_BBM_PAUSE_PLAYER_DISCONNECTED",
	playerIsDisconnected: "LOC_BBM_PAUSE_PLAYER_IS_DISCONNECTED",
	playerReconnecting: "LOC_BBM_PAUSE_PLAYER_RECONNECTING",
	hostChanged: "LOC_BBM_PAUSE_HOST_CHANGED",
	unpausing: "LOC_BBM_PAUSE_UNPAUSING"
};

export { FILTER_SOURCE, PAUSE_MENU_MODE, CONFIG, PROGRESS_ACTIONS, LOC };
