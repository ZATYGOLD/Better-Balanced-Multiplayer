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
 * Better Balanced Multiplayer - setup helpers (shell scope).
 *
 * Reading and writing setup parameters, their multiplayer defaults, one shared
 * poll of the setup (multiplayer setups only), and the rule that keeps a
 * setting's rows on its value (Pace and Gameplay).
 */
import { createLogger, isAgeTransition, isMultiplayerGame } from './mpt-util.js';

const log = createLogger('setup');
const POLL_MS = 250;
const AGES = ["Antiquity", "Exploration", "Modern"];
const CUSTOM = "CUSTOM";

/** Only the host writes the setup; a joined client sees the host's writes arrive. */
function canEditSetup() {
  const host = Network.getHostPlayerId();
  return !Configuration.getGame()?.isNetworkMultiplayer || !(host >= 0) || host === GameContext.localPlayerID;
}

/** A setup string handle as text ("" if absent). */
const resolveString = (handle) => GameSetup.resolveString(handle) ?? "";

/** The group the multiplayer Create Game screen shows a parameter in: its multiplayer group when it has one. */
const groupOf = (param) => resolveString(param.groupMultiplayer ? param.groupMultiplayer : param.group);

/** A game parameter's value (null if absent). */
const gameValue = (id) => GameSetup.findGameParameter(id)?.value?.value ?? null;

const offers = (id, value) => (GameSetup.findGameParameter(id)?.domain?.possibleValues ?? []).some((entry) => entry.value === value);

/** The option a parameter holds, without its prefix (null if absent). */
function optionOf(id, prefix = "") {
  const value = gameValue(id);
  return typeof value === "string" && value.startsWith(prefix) ? value.slice(prefix.length) : null;
}

/** Sets a parameter to prefix + option when it exists, offers that value and holds another. */
function setOption(id, prefix, option) {
  const value = prefix + option;
  if (gameValue(id) === value || !offers(id, value)) return;
  GameSetup.setGameParameterValue(id, value);
}

// ============================ Defaults ============================

const MULTIPLAYER_ROWS = "SELECT ParameterID, DefaultValue, SortIndex, Hidden, Key1, SupportsSinglePlayer FROM Parameters"
  + " WHERE SupportsLANMultiplayer = 1 OR SupportsInternetMultiplayer = 1 OR SupportsHotseatMultiplayer = 1";
let defaults = null;

/**
 * Each parameter's multiplayer default, sort index and Hidden flag from the setup database,
 * read once per shell session: a multiplayer-only row wins over a shared one,
 * and an unkeyed row over one keyed to a map or ruleset.
 */
function parameterDefaults() {
  if (defaults) return defaults;
  defaults = new Map();
  const rank = (row) => (row.Key1 == null ? 2 : 0) + (row.SupportsSinglePlayer ? 0 : 1);
  let rows = [];
  try { rows = Database.query("config", MULTIPLAYER_ROWS) ?? []; } catch (e) { log(`defaults not read: ${e}`); }
  for (const row of rows) {
    const known = defaults.get(row.ParameterID);
    if (known && known.rank >= rank(row)) continue;
    defaults.set(row.ParameterID, { value: row.DefaultValue, sortIndex: row.SortIndex ?? 0, hidden: !!row.Hidden, rank: rank(row) });
  }
  return defaults;
}

/** A parameter's value matches a database value (case, and booleans as 0 / 1, aside). */
const sameValue = (a, b) => String(a).toLowerCase() === String(b).toLowerCase() || (a === true && b == 1) || (a === false && b == 0);

/**
 * Sets a game parameter to a database value in its own type (select, boolean,
 * number, or an empty list for a list without one); text and values the
 * parameter does not offer are left alone. Returns true when it wrote.
 */
function setValue(param, value) {
  const id = GameSetup.resolveString(param.ID);
  if (param.array) {
    if (value != null || (param.values?.length ?? 0) === 0) return false;
    GameSetup.setGameParameterValue(id, []);
    return true;
  }
  const current = param.value?.value;
  if (value == null || sameValue(current, value)) return false;
  switch (param.domain?.type) {
    case GameSetupDomainType.Select:
      if (!offers(id, String(value))) return false;
      GameSetup.setGameParameterValue(id, String(value));
      return true;
    case GameSetupDomainType.Boolean:
      GameSetup.setGameParameterValue(id, value == 1 || value === "true");
      return true;
    case GameSetupDomainType.Integer:
    case GameSetupDomainType.UnsignedInteger:
      if (!Number.isFinite(Number(value))) return false;
      GameSetup.setGameParameterValue(id, Number(value));
      return true;
    default:
      return false;
  }
}

// ============================ Setup poll ============================

const listeners = new Set();
let timer = null;

function poll() {
  if (!isMultiplayerGame()) return;
  let revision;
  try { revision = GameSetup.currentRevision; } catch (e) { return; }
  for (const entry of listeners) {
    if (revision === entry.last) continue;
    try {
      if (!entry.ready()) continue;
      const restarted = revision < entry.last;
      entry.last = revision;
      entry.listener(restarted);
    } catch (error) {
      log(`${entry.name} failed: ${error?.stack ?? error}`);
    }
  }
}

/**
 * Calls listener(restarted) each time the setup's revision moves while ready()
 * allows (a revision passed while it does not is held over); restarted is true
 * when a new setup started its revisions over. Returns the unsubscribe.
 */
function onSetupRevision(name, listener, ready = () => true) {
  const entry = { name, listener, ready, last: -1 };
  listeners.add(entry);
  timer ??= setInterval(poll, POLL_MS);
  return () => {
    listeners.delete(entry);
    if (listeners.size === 0) { clearInterval(timer); timer = null; }
  };
}

// ============================ Per-Age rows ============================

/**
 * A setting with a row per Age (or other rows it sets, such as one per victory):
 * its parameter and value prefix, each option's row options (one for every row
 * or one per row; an option not listed uses itself), and where they differ, the
 * rows, their prefix and the Custom option.
 */
function ageSetting(id, prefix, ageValues = {}, { ageIds = AGES.map((age) => id + age), agePrefix = prefix, custom = CUSTOM } = {}) {
  return { id, prefix, ageValues, ageIds, agePrefix, custom, last: null };
}

/** The row options of a setting's option; null for Custom. */
function ageOptions(entry, option) {
  if (option === entry.custom) return null;
  const mapped = entry.ageValues[option] ?? option;
  return Array.isArray(mapped) ? mapped : entry.ageIds.map(() => mapped);
}

/**
 * A setting that changes sets its rows to that option's values; a row that
 * leaves them switches the setting to Custom. The first pass counts as a
 * change, so values set by script reach the rows. An option the rows cannot
 * hold is left alone.
 */
function syncAgeRows(entry) {
  const option = optionOf(entry.id, entry.prefix);
  if (option == null || entry.ageIds.some((id) => GameSetup.findGameParameter(id) == null)) return;
  const expected = ageOptions(entry, option);
  const changed = option !== entry.last;
  entry.last = option;
  if (!expected || !expected.every((ageOption, i) => offers(entry.ageIds[i], entry.agePrefix + ageOption))) return;
  if (changed) {
    expected.forEach((ageOption, i) => setOption(entry.ageIds[i], entry.agePrefix, ageOption));
  } else if (entry.ageIds.some((id, i) => optionOf(id, entry.agePrefix) !== expected[i])) {
    setOption(entry.id, entry.prefix, entry.custom);
    entry.last = entry.custom;
  }
}

export { AGES, CUSTOM, ageSetting, canEditSetup, gameValue, groupOf, isAgeTransition, onSetupRevision, optionOf, parameterDefaults, resolveString, sameValue, setOption, setValue, syncAgeRows };
