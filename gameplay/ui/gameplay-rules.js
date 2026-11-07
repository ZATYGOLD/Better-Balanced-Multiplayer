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
 * Multiplayer Toolkit - Gameplay settings rules (shell scope).
 *
 * Keeps the multiplayer Gameplay settings (gameplay/config/gameplay-settings.sql)
 * consistent, as Advanced Settings Pro does in single player:
 *   Settlement Limit, Trade Range and Triumph Set (shared per-Age rule):
 *     1. A setting changes             -> its per-Age rows take that option's values.
 *     2. A per-Age row leaves them     -> the setting switches to Custom.
 *   Crises:
 *     3. Crises set to Off             -> every crisis in the Crises list is excluded
 *                                         and Crisis Timing shows Off.
 *     4. Crises leaves Off             -> every crisis is included; a timing on Off
 *                                         returns to Standard.
 *     5. Crisis Timing set to Off      -> Crises becomes Off; leaving Off turns it On.
 *     6. Every crisis excluded         -> Crises becomes Off; any crisis included
 *                                         while it says Off turns it On.
 *     7. On a setup's first pass       -> Crises wins: the selection and timing follow it.
 * The game data reads the per-Age rows, so they always hold the values in effect.
 * Each rule compares against the last pass; only the host writes the setup.
 */
import { createLogger } from '../../ui/mpt-shared/mpt-util.js';
import { AGES, ageSetting, canEditSetup, isAgeTransition, onSetupRevision, optionOf, setOption, syncAgeRows } from '../../ui/mpt-shared/mpt-setup.js';

const log = createLogger('gameplay');
const TRIUMPH_SETS = ["DEFAULT", "CLASSIC", "RACE", "CONQUEROR", "EXPLORER", "NONE"];

const AGE_SETTINGS = [
  // Each tier as the limits its Age rows hold.
  ageSetting("MPTGameplaySettlementLimit", "MPT_GAMEPLAY_SETTLEMENT_LIMIT_", {
    LESS: ["1", "4", "10"], STANDARD: ["3", "8", "16"], MORE: ["5", "12", "20"] }),
  ageSetting("MPTGameplayTradeRange", "MPT_GAMEPLAY_TRADE_RANGE_"),
  // The game's Triumph Set, with the Toolkit's Custom; its rows name each set.
  ageSetting("LegacySets", "", Object.fromEntries(TRIUMPH_SETS.map((set) => [`LEGACY_SET_${set}`, set])), {
    ageIds: AGES.map((age) => `MPTGameplayTriumphSet${age}`), agePrefix: "MPT_GAMEPLAY_TRIUMPH_SET_", custom: "MPT_LEGACY_SET_CUSTOM" })
];

// ============================ Crises ============================

const CRISES_ID = "MPTGameplayCrises";
const CRISES_PREFIX = "MPT_GAMEPLAY_CRISES_";
const TIMING_ID = "MPTGameplayCrisisTiming";
const TIMING_PREFIX = "MPT_GAMEPLAY_CRISIS_TIMING_";
// The game's Crises list holds the excluded crises (UxHint InvertSelection).
const SELECTION_ID = "Crises";
const ON = "ON";
const OFF = "OFF";
const STANDARD = "STANDARD";

const crises = { toggle: null, timing: null };
const setToggle = (option) => setOption(CRISES_ID, CRISES_PREFIX, option);
const setTiming = (option) => setOption(TIMING_ID, TIMING_PREFIX, option);
const timingFor = (toggle) => (toggle === OFF ? OFF : STANDARD);

function syncCrises() {
  const selection = GameSetup.findGameParameter(SELECTION_ID);
  const toggle = optionOf(CRISES_ID, CRISES_PREFIX);
  const possible = (selection?.domain?.possibleValues ?? []).map((entry) => entry.value);
  if (toggle == null || possible.length === 0) return;
  const excluded = (selection.values ?? []).map((entry) => entry.value);
  const allExcluded = possible.every((value) => excluded.includes(value));
  const timing = optionOf(TIMING_ID, TIMING_PREFIX);
  const timingMismatch = timing != null && (timing === OFF) !== (toggle === OFF);

  // 3 & 4: Crises changed.
  if (crises.toggle != null && toggle !== crises.toggle) {
    if (toggle === OFF) {
      GameSetup.setGameParameterValue(SELECTION_ID, possible);
      setTiming(OFF);
    } else if (crises.toggle === OFF) {
      GameSetup.setGameParameterValue(SELECTION_ID, []);
      if (timing === OFF) setTiming(STANDARD);
    }
    crises.toggle = toggle;
    crises.timing = null;
    return;
  }
  const firstPass = crises.toggle == null;
  crises.toggle = toggle;
  // 7: the first pass keeps Crises and brings the rest in line.
  if (firstPass) {
    if (toggle === OFF && !allExcluded) GameSetup.setGameParameterValue(SELECTION_ID, possible);
    else if (toggle !== OFF && allExcluded) GameSetup.setGameParameterValue(SELECTION_ID, []);
    if (timingMismatch) setTiming(timingFor(toggle));
    return;
  }
  // 5: Crisis Timing changed to or from Off.
  if (timing != null && crises.timing != null && timing !== crises.timing) {
    if (timing === OFF && toggle !== OFF) setToggle(OFF);
    else if (crises.timing === OFF && toggle === OFF) setToggle(ON);
    crises.timing = timing;
    return;
  }
  crises.timing = timing;
  // 6: Crises tells the truth about the list, and the timing about Crises.
  if (allExcluded && toggle !== OFF) {
    setToggle(OFF);
    setTiming(OFF);
    crises.toggle = OFF;
    crises.timing = null;
  } else if (!allExcluded && toggle === OFF) {
    setToggle(ON);
    if (timing === OFF) setTiming(STANDARD);
    crises.toggle = ON;
    crises.timing = null;
  } else if (timingMismatch) {
    setTiming(timingFor(toggle));
    crises.timing = null;
  }
}

// ============================ Poll ============================

function resetBaselines() {
  crises.toggle = crises.timing = null;
  AGE_SETTINGS.forEach((entry) => { entry.last = null; });
}

/** Runs one rule, logging rather than letting a failure stop the others. */
function run(name, rule) {
  try { rule(); } catch (error) { log(`${name} failed: ${error?.stack ?? error}`); }
}

onSetupRevision("gameplay", (restarted) => {
  if (restarted) resetBaselines();   // a new setup starts its revisions over
  AGE_SETTINGS.forEach((entry) => run(entry.id, () => syncAgeRows(entry)));
  run("crises", syncCrises);
}, () => !isAgeTransition() && canEditSetup());
