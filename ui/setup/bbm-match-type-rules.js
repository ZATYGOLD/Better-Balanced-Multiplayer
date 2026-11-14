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
 * Better Balanced Multiplayer - Match Type rules (shell scope).
 *
 * Choosing a Match Type (config/match-types.sql) sets up the map and the lobby
 * slots (ui/lobby/bbm-match-slots.js): every setting on the Map tab returns to its
 * multiplayer default from the setup database. Kept: the settings the Match Type
 * sets through its configuration updates, the map, the seeds, hidden settings the
 * mod manages, and the settings Game Balance sets (ui/setup/bbm-balance-rules.js).
 * Every other tab is left alone. Settings a dependency hides reset too, so they
 * are Standard when they show again.
 * Only a change by the host applies it; a setup's first pass (a new setup, a
 * rejoin) and a change seen while not the host only record the Match Type.
 */
import { createLogger, isAgeTransition } from '../shared/bbm-util.js';
import { canEditSetup, gameValue, groupOf, onSetupRevision, parameterDefaults, resolveString, setValue } from '../shared/bbm-setup.js';
import { BALANCE_SETTING_IDS } from './bbm-balance-rules.js';
import { TABS, tabIndexOfGroup } from './bbm-setup-layout.js';

const log = createLogger('match type');
const MATCH_TYPE_ID = "BBMMatchType";
const MAP_TAB = "map";
const KEPT_IDS = new Set([MATCH_TYPE_ID, "GameRandomSeed", "MapRandomSeed", "Map", ...BALANCE_SETTING_IDS]);
// The parameters a parameter's value sets through the setup's configuration updates.
const UPDATED_PARAMETERS = "SELECT DISTINCT T.ParameterID FROM Parameters S"
	+ " JOIN ConfigurationUpdates U ON U.SourceGroup = S.ConfigurationGroup AND U.SourceKey = S.ConfigurationKey"
	+ " JOIN Parameters T ON T.ConfigurationGroup = U.TargetGroup AND T.ConfigurationKey = U.TargetKey"
	+ " WHERE S.ParameterID = ?1 AND U.SourceValue = ?2";

function updatedBy(id, value) {
	try { return (Database.query("config", UPDATED_PARAMETERS, id, value) ?? []).map((row) => row.ParameterID); } catch (e) { log(`updates not read: ${e}`); return []; }
}

/** The parameters the Match Type leaves alone: its own values and the kept settings. */
function keptIds(matchType) {
	return new Set([...KEPT_IDS, ...updatedBy(MATCH_TYPE_ID, matchType)]);
}

const onMapTab = (param) => TABS[tabIndexOfGroup(groupOf(param))]?.key === MAP_TAB;

/** Every Map tab setting not kept returns to its default. */
function applyMatchType(matchType) {
	const kept = keptIds(matchType);
	const defaults = parameterDefaults();
	let written = 0;
	for (const param of GameSetup.getGameParameters()) {
		const id = resolveString(param.ID);
		const entry = defaults.get(id);
		if (!entry || entry.hidden || kept.has(id) || param.readOnly || !onMapTab(param)) continue;
		if (setValue(param, entry.value)) written++;
	}
	log(`${matchType}: ${written} settings reset`);
}

let last = null;

onSetupRevision("match type", (restarted) => {
	if (restarted) last = null;   // a new setup starts its revisions over
	const matchType = gameValue(MATCH_TYPE_ID);
	if (matchType == null) return;   // single player: no Match Type
	const changed = last != null && matchType !== last;
	last = matchType;
	if (changed && canEditSetup()) applyMatchType(matchType);
}, () => !isAgeTransition());
