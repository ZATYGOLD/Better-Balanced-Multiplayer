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
 * Better Balanced Multiplayer - Pace Set and Pace Settings rules (shell scope).
 *
 * Keeps the multiplayer Pace settings (config/pace.sql) consistent,
 * as Advanced Settings Pro does in single player:
 *   1. A setting changes             -> its per-Age rows take that option's values.
 *   2. A per-Age row leaves them     -> the setting switches to Custom.
 *   3. A Pace Set preset is chosen   -> every setting takes the preset's value.
 *   4. A setting leaves the preset   -> Pace Set switches to Custom.
 *   5. Age Length leaves Custom      -> every other setting returns to the Standard Pace Set's.
 *   6. Pace Set on Game Settings and on the Pace tab mirror each other.
 *   7. Victory Threshold sets the three victory thresholds; a threshold
 *      that leaves it switches it to Custom (rules 1 and 2, one row per victory).
 * On a setup's first pass the settings win over their rows, so values set by
 * script (ui/maps/multiplayer-defaults.js) reach the rows.
 * The game data reads the per-Age rows, so they always hold the values in effect.
 * Each rule compares against the last pass; only the host writes the setup.
 */
import { CUSTOM, ageSetting, canEditSetup, isAgeTransition, onSetupRevision, optionOf, setOption, syncAgeRows } from '../shared/bbm-setup.js';

const STANDARD = "STANDARD";
const PRESET_ID = "BBMPacePreset";
const MIRROR_ID = "BBMPaceSetMirror";
const PRESET_PREFIX = "BBM_PACE_PRESET_";

/** Each Pace Setting: its parameter, value prefix and each option's per-Age values. */
const COST = { LOW: "MINUS_25", MEDIUM: "PLUS_25", HIGH: "PLUS_50", DOUBLE: "PLUS_100" };
const SPEED = { SLOW: "PLUS_25", QUICK: "MINUS_25", FAST: "MINUS_50" };
const SETTINGS = {
  AgeLength: ageSetting("BBMPaceAgeLength", "BBM_PACE_AGE_LENGTH_", {
    SWIFT: ["90", "100", "110"], ABBREVIATED: "120", STANDARD: "140" }),
  AgeProgression: ageSetting("BBMPaceAgeProgression", "BBM_PACE_AGE_PROGRESSION_"),
  TechnologyCost: ageSetting("BBMPaceTechnologyCost", "BBM_PACE_TECHNOLOGY_COST_", { ...COST,
    BALANCED: ["PLUS_25", STANDARD, "MINUS_25"], SWIFT: ["MINUS_25", "MINUS_25", STANDARD] }),
  CivicCost: ageSetting("BBMPaceCivicCost", "BBM_PACE_CIVIC_COST_", { ...COST,
    BALANCED: [STANDARD, "PLUS_25", "PLUS_25"], SWIFT: ["MINUS_25", "MINUS_25", STANDARD] }),
  BuildingCost: ageSetting("BBMPaceBuildingCost", "BBM_PACE_BUILDING_COST_", { ...COST,
    BALANCED: ["PLUS_25", STANDARD, STANDARD], SWIFT: "MINUS_25" }),
  VictoryProjectCost: ageSetting("BBMPaceVictoryProjectCost", "BBM_PACE_VICTORY_PROJECT_COST_", { ...COST,
    BALANCED: [STANDARD, "MINUS_25", "MINUS_25"], SWIFT: "MINUS_25" }),
  SettlementGrowth: ageSetting("BBMPaceSettlementGrowth", "BBM_PACE_SETTLEMENT_GROWTH_", { ...SPEED,
    BALANCED: ["MINUS_25", "MINUS_25", STANDARD], SWIFT: "MINUS_25" }),
  RoadSpeed: ageSetting("BBMPaceRoadSpeed", "BBM_PACE_ROAD_SPEED_", { ...SPEED,
    BALANCED: [STANDARD, STANDARD, "MINUS_25"], SWIFT: ["MINUS_25", "MINUS_50", "MINUS_50"] }),
  // Standard is the game's own: Merchants travel in Antiquity and Exploration, Modern routes start from a distance.
  TradeSpeed: ageSetting("BBMPaceTradeSpeed", "BBM_PACE_TRADE_SPEED_", {
    SLOW: "MINUS_25", STANDARD: [STANDARD, STANDARD, "INSTANT"], QUICK: "PLUS_25", FAST: "PLUS_50",
    SWIFT: "INSTANT", BALANCED: [STANDARD, STANDARD, "INSTANT"] }),
  RazeSpeed: ageSetting("BBMPaceRazeSpeed", "BBM_PACE_RAZE_SPEED_", {
    FAST: "PLUS_100", SWIFT: "INSTANT", BALANCED: STANDARD })
};

/** Victory Threshold: Low, Standard or High for each victory's threshold. */
const VICTORY_THRESHOLDS = ageSetting("BBMPaceVictoryThresholdSet", "BBM_PACE_VICTORY_THRESHOLD_", {}, {
  ageIds: ["Culture", "Economic", "Military"].map((victory) => `BBMPace${victory}VictoryThreshold`) });

/**
 * Pace Set presets: each setting's option, or per-Age values (which put it on Custom).
 * Standard and Multiplayer start trade routes from a distance (Trade Speed Instant, its default).
 */
const STANDARD_PACE = { ...Object.fromEntries(Object.keys(SETTINGS).map((key) => [key, STANDARD])), TradeSpeed: "INSTANT" };
const allOf = (option, except = []) => Object.fromEntries(Object.keys(SETTINGS).map((key) => [key, except.includes(key) ? STANDARD : option]));
const PRESETS = {
  STANDARD: STANDARD_PACE,
  BALANCED: allOf("BALANCED", ["AgeLength"]),
  MULTIPLAYER: {
    ...STANDARD_PACE,
    AgeProgression: "BALANCED",
    TechnologyCost: ["PLUS_25", "PLUS_50", "PLUS_100"],
    CivicCost: ["PLUS_50", "PLUS_50", "PLUS_100"],
    SettlementGrowth: "SLOW",
    RoadSpeed: ["MINUS_25", "MINUS_25", "MINUS_50"],
    VictoryProjectCost: [STANDARD, STANDARD, "PLUS_25"]
  }
};

// ============================ Rules ============================

/** Sets each setting to its option, or to Custom with per-Age values. */
function applyPreset(preset) {
  for (const [key, option] of Object.entries(preset)) {
    const entry = SETTINGS[key];
    if (Array.isArray(option)) {
      setOption(entry.id, entry.prefix, CUSTOM);
      entry.ageIds.forEach((id, i) => setOption(id, entry.agePrefix, option[i]));
    } else {
      setOption(entry.id, entry.prefix, option);
    }
  }
}

function matchesPreset(preset) {
  return Object.entries(preset).every(([key, option]) => {
    const entry = SETTINGS[key];
    const current = optionOf(entry.id, entry.prefix);
    if (!Array.isArray(option)) return current === option;
    return current === CUSTOM && entry.ageIds.every((id, i) => optionOf(id, entry.agePrefix) === option[i]);
  });
}

const pace = { preset: null, mirror: null, ageLength: null };

/** 6: whichever Pace Set changed wins. */
function syncMirror() {
  const preset = optionOf(PRESET_ID, PRESET_PREFIX);
  const mirror = optionOf(MIRROR_ID, PRESET_PREFIX);
  const presetChanged = pace.preset != null && preset !== pace.preset;
  const mirrorChanged = pace.mirror != null && mirror !== pace.mirror;
  if (mirrorChanged && !presetChanged) setOption(PRESET_ID, PRESET_PREFIX, mirror);
  else if (preset !== mirror) setOption(MIRROR_ID, PRESET_PREFIX, preset);
  pace.mirror = optionOf(MIRROR_ID, PRESET_PREFIX);
}

/** 3, 4 & 5. */
function syncPreset() {
  const option = optionOf(PRESET_ID, PRESET_PREFIX);
  const preset = PRESETS[option];
  const ageLength = optionOf(SETTINGS.AgeLength.id, SETTINGS.AgeLength.prefix);
  const leftCustomAgeLength = pace.ageLength === CUSTOM && ageLength !== CUSTOM;
  pace.ageLength = ageLength;
  if (pace.preset != null && option !== pace.preset) {
    if (preset) {
      applyPreset(preset);
      pace.ageLength = null;
    }
    pace.preset = option;
    return;
  }
  pace.preset = option;
  if (leftCustomAgeLength) {
    const { AgeLength, ...others } = STANDARD_PACE;
    applyPreset(others);
  }
  if (preset && !matchesPreset(preset)) {
    setOption(PRESET_ID, PRESET_PREFIX, CUSTOM);
    pace.preset = CUSTOM;
  }
}

function resetBaselines() {
  pace.preset = pace.mirror = pace.ageLength = null;
  [...Object.values(SETTINGS), VICTORY_THRESHOLDS].forEach((entry) => { entry.last = null; });
}

// ============================ Poll ============================

onSetupRevision("pace", (restarted) => {
  if (restarted) resetBaselines();   // a new setup starts its revisions over
  if (GameSetup.findGameParameter(PRESET_ID) == null) return;   // the setup has no Pace settings
  syncMirror();
  syncPreset();
  Object.values(SETTINGS).forEach(syncAgeRows);
  syncAgeRows(VICTORY_THRESHOLDS);
}, () => !isAgeTransition() && canEditSetup());
