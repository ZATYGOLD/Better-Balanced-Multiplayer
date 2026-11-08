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
 * Better Balanced Multiplayer - Create Game layout (shell scope).
 *
 * The multiplayer Create Game screen's tabs, the parameter groups each holds and
 * the order of those groups (sections), shared by the setup tabs and the lobby's
 * rules summary. Multiplayer resolves a parameter's group to its
 * GroupIDMultiplayerOverride when it has one ("MPAdvanced" + group for most
 * mod settings), so a section names the base group and stands for both.
 * The screen adds sections in the order of their first setting; each tab then
 * shows its listed sections in the order below, as Advanced Settings Pro lays
 * out single player. Other "MPAdvanced" groups show on Advanced, every other
 * group on Game Settings; a group listed on two tabs (Victory Settings, Triumph
 * Settings) shows its base group on Game Settings and its "MPAdvanced" group on
 * Advanced.
 */

const MP_GROUP_PREFIX = "MPAdvanced";
const baseGroupOf = (groupId) => (groupId.startsWith(MP_GROUP_PREFIX) ? groupId.slice(MP_GROUP_PREFIX.length) : groupId);

/** Every tab in display order; added tabs claim their sections' groups. */
const TABS = [
  { key: "game", sections: ["LobbyOptions", "GameOptions", "VictoryOptions", "TriumphSettings", "DisasterCrisisOptions", "CrisesOptions"] },
  { key: "pace", title: "LOC_BBM_SETUP_TAB_PACE", added: true,
    sections: ["GamePacingOptions", "PacingAntiquityOptions", "PacingExplorationOptions", "PacingModernOptions"] },
  { key: "map", title: "LOC_BBM_SETUP_TAB_MAP", added: true,
    sections: ["SpawnOptions", "MapOptions", "ResourceOptions", "TerrainOptions", "NaturalWonderSelectionOptions"] },
  { key: "advanced", sections: ["PlayerDifficulty", "VictoryOptions", "VictoryThresholdOptions", "TriumphSettings",
    "SettlementOptions", "IndependentPowerOptions", "TradeOptions", "WonderOptions"] }
];

/** The tabs added after Game Settings, in order. */
const SETUP_TABS = TABS.filter((tab) => tab.added);

/** A group's tab index in display order: Game Settings 0, the added tabs, then Advanced. */
function tabIndexOfGroup(groupId) {
  const index = TABS.findIndex((tab) => tab.added && tab.sections.includes(baseGroupOf(groupId)));
  if (index >= 0) return index;
  return groupId.startsWith(MP_GROUP_PREFIX) ? TABS.length - 1 : 0;
}

/** A group's place among its tab's sections (unlisted sections after the listed ones). */
function sectionIndexOfGroup(groupId) {
  const index = TABS[tabIndexOfGroup(groupId)].sections.indexOf(baseGroupOf(groupId));
  return index >= 0 ? index : Number.MAX_SAFE_INTEGER;
}

export { SETUP_TABS, TABS, baseGroupOf, sectionIndexOfGroup, tabIndexOfGroup };
