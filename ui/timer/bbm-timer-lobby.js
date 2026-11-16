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
 * Better Balanced Multiplayer - Competitive timer in the lobby's Game Rules (shell scope).
 *
 * The Game Rules screen only names None, Standard and Dynamic; any other timer
 * shows a debug value. With Competitive chosen, its Turn Timer row shows the
 * Competitive name instead.
 */
import { whenDefined, wrapMethod } from '../shared/bbm-util.js';
import { COMPETITIVE_HASH } from './bbm-timer-config.js';

const RULES_TAG = "screen-mp-game-rules";

function isCompetitive() {
	try { return Configuration.getGame().turnTimerType === COMPETITIVE_HASH; } catch (e) { return false; }
}

whenDefined(RULES_TAG, (definition) => {
	const timerLabel = Locale.compose("LOC_UI_MP_GAME_RULE_TURN_TIMER");
	wrapMethod(definition.createInstance.prototype, "addRule", function (base, parent, label, value, ...rest) {
		if (label === timerLabel && isCompetitive()) {
			value = Locale.compose("LOC_BBM_TURNTIMER_COMPETITIVE");
		}
		return base(parent, label, value, ...rest);
	});
});
