/*
 * Multiplayer Toolkit - multiplayer quality-of-life features for Civilization VII.
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
 * Multiplayer Toolkit - Match Type rules (shell scope).
 *
 * Choosing a Match Type (config/match-types.sql) starts the match from Standard:
 * every game setting the Create Game tabs show returns to its multiplayer default
 * from the setup database, Game Speed becomes Online and Turn Timer Competitive.
 * Kept: the settings the Match Type (or the speed and timer) sets through its
 * configuration updates, the Multiplayer Settings section (game name, Hidden
 * Game, Game Balance, Kick Vote), the seeds, the map, the ruleset and
 * starting Age, and hidden settings the Toolkit manages. Player slots, leaders,
 * civilizations and mementos are player settings and stay as they are.
 * Settings a dependency hides reset too, so they are Standard when they show again.
 * Only a change by the host applies it; a setup's first pass (a new setup, a
 * rejoin) and a change seen while not the host only record the Match Type.
 */
import { createLogger } from '../mpt-shared/mpt-util.js';
import { canEditSetup, gameValue, isAgeTransition, onSetupRevision, parameterDefaults, setValue } from '../mpt-shared/mpt-setup.js';

const log = createLogger('match type');
const MATCH_TYPE_ID = "MPTMatchType";
// Every Match Type plays on the multiplayer speed and the Competitive timer.
const MATCH_TYPE_VALUES = [["GameSpeeds", "GAMESPEED_ONLINE"], ["TurnTimerType", "MPT_TURNTIMER_COMPETITIVE"]];
const KEPT_IDS = new Set([MATCH_TYPE_ID, "GameRandomSeed", "MapRandomSeed", "Map", "Ruleset", "Age"]);
// Every setting in these groups is kept.
const KEPT_GROUPS = new Set(["LobbyOptions"]);
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
  const kept = new Set(KEPT_IDS);
  for (const [id, value] of [[MATCH_TYPE_ID, matchType], ...MATCH_TYPE_VALUES]) {
    kept.add(id);
    updatedBy(id, value).forEach((target) => kept.add(target));
  }
  return kept;
}

/** Every shown game setting not kept returns to its default; Game Speed and Turn Timer take the Match Type's values. */
function applyMatchType(matchType) {
  const kept = keptIds(matchType);
  const defaults = parameterDefaults();
  const group = (param) => GameSetup.resolveString(param.groupMultiplayer ? param.groupMultiplayer : param.group) ?? "";
  let written = 0;
  for (const [id, value] of MATCH_TYPE_VALUES) {
    const param = GameSetup.findGameParameter(id);
    if (param && setValue(param, value)) written++;
  }
  for (const param of GameSetup.getGameParameters()) {
    const id = GameSetup.resolveString(param.ID) ?? "";
    const entry = defaults.get(id);
    if (!entry || entry.hidden || kept.has(id) || param.readOnly || KEPT_GROUPS.has(group(param))) continue;
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
