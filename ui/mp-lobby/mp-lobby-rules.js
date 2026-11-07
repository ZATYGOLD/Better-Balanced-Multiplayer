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
 * Multiplayer Toolkit - Lobby rules summary (shell scope).
 *
 * The lobby's own summaries list a fixed set of base rules, so a player who
 * joins cannot see the Toolkit's settings. Both are extended:
 *   Game Rules       a list beside the mods list, scrolling on its own, of every
 *                    Toolkit setting (an "MPT" parameter) changed from its default,
 *                    with the base settings the Toolkit extends or regroups, in
 *                    the setup tabs' order. Per-Age rows (and the per-victory
 *                    thresholds) are listed only while their setting is Custom,
 *                    and the Natural Wonder toggles collapse into one count.
 *   Game Options     Match Type, Game Balance and Pace Set after Game Speed,
 *                    always shown.
 * Both read the live setup, so a change by the host shows the next time the
 * rules open, or within a moment in the Game Options box.
 */
import { Decorator, createLogger } from '../mpt-shared/mpt-util.js';
import { onSetupRevision, parameterDefaults, sameValue } from '../mpt-shared/mpt-setup.js';
import { sectionIndexOfGroup, tabIndexOfGroup } from '../mp-setup/setup-layout.js';

const log = createLogger('lobby rules');
const RULES_SCREEN = "screen-mp-game-rules";
const LOBBY_SCREEN = "screen-mp-lobby";
const MOD_ID = "multiplayer-toolkit";
const PARAM_PREFIX = "MPT";
const SUMMARY_PARAM_IDS = ["MPTMatchType", "MPTBalance", "MPTPacePreset"];
const SUMMARY_ANCHOR = "LOC_UI_MP_LOBBY_GAME_SPEED";
// Base settings the Toolkit extends (Triumph Set) or moves to its groups in multiplayer.
const BASE_PARAM_IDS = new Set(["LegacySets", "IndependentHostility", "MapSeaLevel", "StartPosition"]);
// Shown through another row: the Pace tab's copy of Pace Set.
const SKIPPED_PARAM_IDS = new Set(["MPTPaceSetMirror"]);
const WONDER_PREFIX = "MPTNaturalWonder";
const WONDER_COUNT_ID = "MPTNaturalWonders";
const WONDER_ON = "MPT_MAPS_NATURAL_WONDER_ON";
const AGE_SUFFIX = /(Antiquity|Exploration|Modern)$/;
// A per-Age row's setting, where it is not the row's own id less the Age.
const AGE_PARENTS = { MPTGameplayTriumphSet: "LegacySets" };
// Rows of a set that are not per Age: the victory thresholds of Victory Threshold Set.
const SET_PARENTS = Object.fromEntries(["Culture", "Economic", "Military"].map((victory) => [`MPTPace${victory}VictoryThreshold`, "MPTPaceVictoryThresholdSet"]));
const CUSTOM_MARKER = "CUSTOM";

// ============================ Settings ============================

const resolve = (handle) => GameSetup.resolveString(handle) ?? "";
const idOf = (param) => resolve(param.ID);
// The group the multiplayer screen shows a parameter in, as it resolves it.
const groupOf = (param) => resolve(param.groupMultiplayer ? param.groupMultiplayer : param.group);
const valueOf = (param) => param?.value?.value;
const isWonderToggle = (id) => id.startsWith(WONDER_PREFIX) && id !== WONDER_COUNT_ID;
const ageParentId = (id) => { const stem = id.replace(AGE_SUFFIX, ""); return AGE_PARENTS[stem] ?? stem; };

function valueText(param) {
  const value = valueOf(param);
  if (typeof value === "boolean") return Locale.compose(value ? "LOC_ADVANCED_OPTIONS_ON" : "LOC_ADVANCED_OPTIONS_OFF");
  return Locale.compose(resolve(param.value?.name) || String(value ?? ""));
}

function isListed(param) {
  const id = idOf(param);
  if (param.hidden || param.invalidReason !== GameSetupParameterInvalidReason.Valid) return false;
  const own = id.startsWith(PARAM_PREFIX);
  if (!(own || BASE_PARAM_IDS.has(id)) || SKIPPED_PARAM_IDS.has(id) || isWonderToggle(id)) return false;
  if (param.array || ![GameSetupDomainType.Select, GameSetupDomainType.Boolean].includes(param.domain?.type)) return false;
  const parentId = SET_PARENTS[id] ?? (own && AGE_SUFFIX.test(id) ? ageParentId(id) : null);
  const parent = parentId ? GameSetup.findGameParameter(parentId) : null;
  if (parent) return String(valueOf(parent) ?? "").toUpperCase().includes(CUSTOM_MARKER);
  const fallback = parameterDefaults().get(id)?.value;
  return fallback == null || !sameValue(valueOf(param), fallback);
}

/** Per-Age rows read "Setting (Age)", whether a row is named for its setting or for its Age. */
function rowLabel(param, id) {
  const age = id.match(AGE_SUFFIX)?.[1];
  const parent = age && id.startsWith(PARAM_PREFIX) ? GameSetup.findGameParameter(ageParentId(id)) : null;
  if (!parent) return Locale.compose(resolve(param.name) || id);
  return `${Locale.compose(resolve(parent.name))} (${Locale.compose(`LOC_AGE_${age.toUpperCase()}_NAME`)})`;
}

/** "N / M" after the Natural Wonders count when any wonder is switched off. */
function wonderRow(parameters) {
  const toggles = parameters.filter((param) => isWonderToggle(idOf(param)) && !param.hidden);
  const on = toggles.filter((param) => valueOf(param) === WONDER_ON).length;
  const count = GameSetup.findGameParameter(WONDER_COUNT_ID);
  if (!count || toggles.length === 0 || on === toggles.length) return null;
  return { id: WONDER_COUNT_ID, group: groupOf(count), label: `${Locale.compose(resolve(count.name))}:`, value: `${on} / ${toggles.length}`, after: true };
}

/** The changed settings as [{ label, value }], in the setup tabs' order. */
function changedSettings() {
  const defaults = parameterDefaults();
  const parameters = [...GameSetup.getGameParameters()];
  const rows = parameters.filter(isListed).map((param) => {
    const id = idOf(param);
    return { id, group: groupOf(param), label: `${rowLabel(param, id)}:`, value: valueText(param) };
  });
  const wonders = wonderRow(parameters);
  if (wonders) rows.push(wonders);
  const key = (row) => [tabIndexOfGroup(row.group), sectionIndexOfGroup(row.group), defaults.get(row.id)?.sortIndex ?? 0, row.after ? 1 : 0];
  return rows.sort((a, b) => {
    const [ka, kb] = [key(a), key(b)];
    return ka.reduce((order, value, i) => order || value - kb[i], 0);
  });
}

// ============================ Game Rules ============================

// The window grows past the base 64rem to fit the lists side by side, each a
// fixed width so the window, not the rules above, sets their size.
const FRAME_MAX_WIDTH = { 2: "80rem", 3: "90rem" };
const LIST_WIDTH = "23rem";
const LIST_BORDER = "0.0833rem solid rgba(140, 126, 98, 0.6)";
const LIST_GAP = "2rem";

function modTitle() {
  const game = Configuration.getGame();
  for (let index = 0; index < game.enabledModCount; index++) {
    if (game.getEnabledModId(index) === MOD_ID) return Locale.unpack(game.getEnabledModTitle(index));
  }
  return "";
}

/** The screen's own mods header: a title over a pair of dividers. */
function sectionHeader() {
  const header = document.createElement("div");
  header.className = "mb-2";
  header.innerHTML = '<div class="font-title-base text-center text-gradient-secondary -mb-3 uppercase whitespace-nowrap"></div><div class="flow-row justify-center"><div class="img-unit-panel-divider -scale-y-100"></div><div class="img-unit-panel-divider -scale-100"></div></div>';
  header.firstChild.textContent = modTitle();
  return header;
}

/** A list's scroll area inside a thin frame, so the lists read as separate. */
function frameList(scrollable) {
  const frame = document.createElement("div");
  frame.className = "flex-auto flow-column p-2";
  Object.assign(frame.style, { minHeight: "0", border: LIST_BORDER });
  scrollable.insertAdjacentElement("beforebegin", frame);
  frame.appendChild(scrollable);
}

/** One of the lists: the same width whatever each holds. */
function asColumn(el) {
  el.classList.remove("flex-auto");
  Object.assign(el.style, { flex: `0 0 ${LIST_WIDTH}`, width: LIST_WIDTH, minHeight: "0" });
}

/** Rows as the base rules draw them, left-aligned, label and value each wrapping in its own space. */
function addRow(component, list, label, value) {
  const row = component.addRule(list, label, value);
  if (!row) return;
  row.classList.remove("max-w-96", "min-w-60", "px-2", "items-center");
  row.classList.add("w-full", "items-start", "mb-1");
  const [labelEl, valueEl] = [row.firstChild, row.lastChild];
  for (const part of [labelEl, valueEl]) {
    part.classList.remove("font-fit-shrink", "flex-auto", "whitespace-nowrap");
    part.style.minWidth = "0";
  }
  labelEl.style.flex = "0 1 auto";
  valueEl.style.flex = "1 1 auto";
}

function createSection(component) {
  const rows = changedSettings();
  if (rows.length === 0) return null;
  const section = document.createElement("div");
  section.className = "flow-column";
  section.appendChild(sectionHeader());
  const scrollable = document.createElement("fxs-scrollable");
  scrollable.className = "flex-auto";
  scrollable.setAttribute("handle-gamepad-pan", "true");
  const list = document.createElement("div");
  list.className = "flow-column items-start px-2";
  rows.forEach(({ label, value }) => addRow(component, list, label, value));
  scrollable.appendChild(list);
  section.appendChild(scrollable);
  frameList(scrollable);
  return section;
}

class RulesSection extends Decorator {
  constructor(component) {
    super();
    this.component = component;
  }

  afterAttach() {
    this.place();
  }

  place() {
    try {
      const root = this.component.Root;
      const mods = root.querySelector(".mods-container");
      const section = mods ? createSection(this.component) : null;
      if (!section) return;
      let row = mods.parentElement;
      if (!row.classList.contains("flow-row")) {
        const modsScroll = mods.querySelector(".mp-game-rules__mods-scrollable");
        if (modsScroll) frameList(modsScroll);
        mods.querySelector(".mp-game-rules__mods")?.classList.replace("items-center", "items-start");
        row = document.createElement("div");
        row.className = "flex-auto flow-row justify-center";
        row.style.minHeight = "0";
        mods.insertAdjacentElement("beforebegin", row);
        row.appendChild(mods);
        asColumn(mods);
      }
      const columns = row.childElementCount + 1;
      if (row.lastElementChild && !row.lastElementChild.classList.contains("hidden")) row.lastElementChild.style.marginRight = LIST_GAP;
      row.appendChild(section);
      asColumn(section);
      const frame = root.querySelector(".mp-game-rules-frame-container");
      if (frame) frame.style.maxWidth = FRAME_MAX_WIDTH[Math.min(columns, 3)] ?? FRAME_MAX_WIDTH[2];
    } catch (error) {
      log(`rules list not added: ${error?.stack ?? error}`);
    }
  }
}

// ============================ Game Options box ============================

function summaryRow(template) {
  const row = template.cloneNode(true);
  const [label, valueWrap] = row.children;
  label.removeAttribute("data-l10n-id");
  label.removeAttribute("data-bind-attributes");
  const value = valueWrap.querySelector("[data-bind-attributes]") ?? valueWrap.firstElementChild;
  value.removeAttribute("data-bind-attributes");
  value.removeAttribute("data-l10n-id");
  return { row, label, value };
}

class LobbySummary extends Decorator {
  constructor(component) {
    super();
    this.component = component;
    this.rows = [];
    this.unsubscribe = null;
  }

  afterAttach() {
    const anchor = this.component.Root.querySelector(`[data-l10n-id="${SUMMARY_ANCHOR}"]`)?.parentElement;
    if (!anchor || this.rows.length > 0) return;
    let after = anchor;
    for (const id of SUMMARY_PARAM_IDS) {
      const entry = { id, ...summaryRow(anchor) };
      after.insertAdjacentElement("afterend", entry.row);
      after = entry.row;
      this.rows.push(entry);
    }
    this.refresh();
    this.unsubscribe = onSetupRevision("lobby summary", () => this.refresh());
  }

  refresh() {
    for (const entry of this.rows) {
      const param = GameSetup.findGameParameter(entry.id);
      entry.row.classList.toggle("hidden", !param);
      if (!param) continue;
      entry.label.textContent = `${Locale.compose(resolve(param.name))}:`;
      entry.value.textContent = valueText(param);
    }
  }

  beforeDetach() {
    this.unsubscribe?.();
    this.unsubscribe = null;
    this.rows.forEach((entry) => entry.row.remove());
    this.rows = [];
  }
}

Controls.decorate(RULES_SCREEN, (component) => new RulesSection(component));
Controls.decorate(LOBBY_SCREEN, (component) => new LobbySummary(component));
