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
 * Better Balanced Multiplayer - Game Balance rules (shell scope).
 *
 * Switching Game Balance applies its set of settings: Multiplayer the competitive
 * defaults, Standard the game's own. The host can change any of them afterwards.
 * Pace Set, Victory Threshold and Crises then bring their own rows in line
 * (ui/pace/bbm-pace-rules.js, ui/gameplay/bbm-gameplay-rules.js). The multiplayer
 * defaults apply the set too, after their own values; Match Type leaves these
 * settings alone.
 */
import { createLogger, isAgeTransition } from '../shared/bbm-util.js';
import { canEditSetup, gameValue, onSetupRevision, setOption } from '../shared/bbm-setup.js';

const log = createLogger('game balance');
const BALANCE_ID = "BBMBalance";
const BALANCE_SETS = {
	BBM_BALANCE_MULTIPLAYER: [
		["TurnTimerType", "BBM_TURNTIMER_COMPETITIVE"],
		["BBMPacePreset", "BBM_PACE_PRESET_MULTIPLAYER"],
		["BBMPaceVictoryThresholdSet", "BBM_PACE_VICTORY_THRESHOLD_LOW"],
		["BBMGameplayCrises", "BBM_GAMEPLAY_CRISES_OFF"],
		["BBMResourceList", "BBM_MAPS_RESOURCE_LIST_ALL"],
		["BBMResourceAmount", "BBM_MAPS_RESOURCE_AMOUNT_MULTIPLAYER"],
		["BBMResourceClusters", "BBM_MAPS_RESOURCE_CLUSTERS_OFF"]
	],
	BBM_BALANCE_STANDARD: [
		["TurnTimerType", "TURNTIMER_DYNAMIC"],
		["BBMPacePreset", "BBM_PACE_PRESET_STANDARD"],
		["BBMPaceVictoryThresholdSet", "BBM_PACE_VICTORY_THRESHOLD_STANDARD"],
		["BBMGameplayCrises", "BBM_GAMEPLAY_CRISES_ON"],
		["BBMResourceList", "BBM_MAPS_RESOURCE_LIST_STANDARD"],
		["BBMResourceAmount", "BBM_MAPS_RESOURCE_AMOUNT_STANDARD"]
	]
};

/** Every setting a Game Balance set holds (Match Type leaves them to Game Balance). */
const BALANCE_SETTING_IDS = new Set(Object.values(BALANCE_SETS).flatMap((set) => set.map(([id]) => id)));

/** Sets each setting of the current Game Balance's set that the setup has and offers. */
function applyBalanceSet() {
	const balance = gameValue(BALANCE_ID);
	const set = BALANCE_SETS[balance];
	if (!set) return;
	for (const [id, value] of set) setOption(id, "", value);
	log(`applied the ${balance} settings`);
}

let last = null;

onSetupRevision("game balance", (restarted) => {
	if (restarted) last = null;   // a new setup starts its revisions over
	const balance = gameValue(BALANCE_ID);
	if (balance == null) return;   // single player: no Game Balance
	const changed = last != null && balance !== last;
	last = balance;
	if (changed && canEditSetup()) applyBalanceSet();
}, () => !isAgeTransition());

export { BALANCE_SETTING_IDS, applyBalanceSet };
