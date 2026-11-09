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
 * Better Balanced Multiplayer - Multiplayer defaults (shell scope).
 *
 * New multiplayer games start on these values (the host can change them). The
 * Create Game screen resets the configuration as it attaches, so they are set
 * right after; a parameter the setup lacks is skipped. The screen keeps the
 * previous game's choices over the setup database's defaults, so the multiplayer
 * defaults the mod promises are written here; the Pace and Gameplay rules then
 * bring each setting's rows in line.
 */
import { createLogger, whenDefined, wrapMethod } from '../shared/bbm-util.js';

const log = createLogger('maps defaults');
const SCREEN_TAG = "screen-mp-create-game";
const RETRY_MS = 50;
const MAX_ATTEMPTS = 20;
const REQUIRED_PARAMETERS = ["GameSpeeds", "Map", "MapSize"];
const COMPETITIVE = "BBM_TURNTIMER_COMPETITIVE";
const MULTIPLAYER_DEFAULTS = [
	["TurnTimerType", COMPETITIVE],
	["GameSpeeds", "GAMESPEED_ONLINE"],
	["AgeCountdownTimer", "AGE_COUNTDOWN_LENGTH_STANDARD"],
	["AgeTransitionSetting", "AGE_TRANSITION_SETTING_KEEP_MORE"],
	["BBMPaceVictoryThresholdSet", "BBM_PACE_VICTORY_THRESHOLD_LOW"],
	["BBMGameplayCrises", "BBM_GAMEPLAY_CRISES_OFF"],
	["BBMGameplayCrisisTiming", "BBM_GAMEPLAY_CRISIS_TIMING_OFF"],
	["Map", "{zatygolds-multiplayer-balance}maps/pangaea-ultima.js"],
	["MapSize", "MAPSIZE_STANDARD"]
];

function applyMultiplayerDefaults(attempt = 0) {
	const ready = REQUIRED_PARAMETERS.every((parameterID) => GameSetup.findGameParameter(parameterID) != null);
	if (!ready) {
		if (attempt < MAX_ATTEMPTS) setTimeout(() => applyMultiplayerDefaults(attempt + 1), RETRY_MS);
		return;
	}
	try {
		for (const [parameterID, value] of MULTIPLAYER_DEFAULTS) {
			if (GameSetup.findGameParameter(parameterID) != null) GameSetup.setGameParameterValue(parameterID, value);
		}
		log("applied the multiplayer defaults");
	} catch (error) {
		log(`failed to apply the multiplayer defaults: ${error?.stack ?? error}`);
	}
}

whenDefined(SCREEN_TAG, (definition) => {
	wrapMethod(definition.createInstance.prototype, "onAttach", function (base, ...args) {
		const result = base(...args);
		setTimeout(() => applyMultiplayerDefaults(), 0);
		return result;
	});
}, { log });
