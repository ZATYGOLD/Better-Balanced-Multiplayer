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
 * Better Balanced Multiplayer - Lens, unit and city hotkeys (game scope).
 *
 * Lens keys switch the map lens like the mini-map's lens panel (pressing the
 * key of the active lens returns to the default lens). Unit keys (Found Settlement,
 * Commander actions) run the same operations and commands as the unit action
 * buttons, through the game's own target selection when one needs a plot.
 * City keys select the previous, next or capital settlement, as the city
 * screen's arrows do. Multiplayer games only.
 */
import { InterfaceMode } from 'fs://game/core/ui/interface-modes/interface-modes.js';
import LensManager from 'fs://game/core/ui/lenses/lens-manager.js';
import { ComponentID } from 'fs://game/core/ui/utilities/utilities-component-id.js';
import { UnitActionHandlers } from 'fs://game/base-standard/ui/unit-interact/unit-action-handlers.js';
import { GetNextCityID, GetPrevCityID } from 'fs://game/base-standard/ui/production-chooser/production-chooser-helpers.js';
import { createLogger, isMultiplayerGame } from '../shared/mpt-util.js';
import { CITY_ACTIONS, DEFAULT_LENS, LENS_ACTIONS, UNIT_ACTIONS } from './mp-keybind-config.js';

const log = createLogger('keybind hotkeys');

function toggleLens(lens) {
  LensManager.setActiveLens(LensManager.activeLens === lens ? DEFAULT_LENS : lens);
}

/** Ability-less first, then each ability that grants the action (Search and the like require one); cached per action. */
const abilityChoicesByAction = new Map();
function abilityChoices(actionType) {
  if (!abilityChoicesByAction.has(actionType)) {
    const abilities = [...GameInfo.UnitAbilities].filter((a) => a.OperationType === actionType || a.CommandType === actionType);
    abilityChoicesByAction.set(actionType, [-1, ...abilities.map((a) => a.$index)]);
  }
  return abilityChoicesByAction.get(actionType);
}

/** The selected unit's operation (UNITOPERATION_*) or command (UNITCOMMAND_*), as its action button would run it. */
function runUnitAction(actionType) {
  const unitId = UI.Player.getHeadSelectedUnit();
  if (!ComponentID.isValid(unitId)) return;
  const requests = actionType.startsWith('UNITOPERATION_') ? Game.UnitOperations : Game.UnitCommands;
  const args = abilityChoices(actionType)
    .map((ability) => ({ X: -9999, Y: -9999, UnitAbilityType: ability }))   // no target plot
    .find((choice) => requests.canStart(unitId, actionType, choice, false)?.Success);
  if (!args) return;
  if (UnitActionHandlers.doesActionHaveHandler(actionType) && UnitActionHandlers.doesActionRequireTargetPlot(actionType)) {
    UnitActionHandlers.switchToActionInterfaceMode(actionType, { UnitID: unitId, CommandArguments: args });
  } else {
    requests.sendRequest(unitId, actionType, args);
  }
}

/** Select the previous, next or capital settlement; from no selected settlement, previous/next start at the capital. */
function selectCity(which) {
  const capital = Players.get(GameContext.localPlayerID)?.Cities?.getCapital()?.id;
  const current = UI.Player.getHeadSelectedCity();
  let target = capital;
  if (which !== 'capital' && ComponentID.isValid(current)) target = which === 'next' ? GetNextCityID(current) : GetPrevCityID(current);
  if (!ComponentID.isValid(target)) return;
  UI.Player.lookAtID(target, 0);
  UI.Player.selectCity(target);
}

/**
 * The context manager dispatches one key press's event to the focused element,
 * the current screen and then the window, and this window capture listener sees
 * every dispatch: one press can arrive two or three times (an even count turned
 * the lens off and on again). Act once per event, and once per action within REPEAT_MS.
 */
const REPEAT_MS = 150;
const seenEvents = new WeakSet();
const lastActionAt = new Map();
function isRepeat(event, name) {
  if (seenEvents.has(event)) return true;
  seenEvents.add(event);
  const now = Date.now();
  if (now - (lastActionAt.get(name) ?? 0) < REPEAT_MS) return true;
  lastActionAt.set(name, now);
  return false;
}

function onEngineInput(event) {
  const detail = event?.detail;
  if (!detail || detail.status !== InputActionStatuses.FINISH) return;
  const lens = LENS_ACTIONS[detail.name];
  const unitAction = UNIT_ACTIONS[detail.name];
  const city = CITY_ACTIONS[detail.name];
  if (!lens && !unitAction && !city) return;
  if (isRepeat(event, detail.name)) return;
  if (!InterfaceMode.allowsHotKeys()) return;
  try {
    if (lens) toggleLens(lens);
    else if (unitAction) runUnitAction(unitAction);
    else selectCity(city);
  } catch (e) { log(`${detail.name} failed: ${e}`); }
}

engine.whenReady.then(() => { if (isMultiplayerGame()) window.addEventListener("engine-input", onEngineInput, true); });
