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
 * Multiplayer Toolkit - Lens and Commander hotkeys (game scope).
 *
 * Lens keys switch the map lens like the mini-map's lens panel (pressing the
 * key of the active lens returns to the default lens). Commander keys run the
 * same unit commands as the unit action buttons, through the game's own target
 * selection when the command needs a plot.
 */
import { InterfaceMode } from 'fs://game/core/ui/interface-modes/interface-modes.js';
import LensManager from 'fs://game/core/ui/lenses/lens-manager.js';
import { ComponentID } from 'fs://game/core/ui/utilities/utilities-component-id.js';
import { UnitActionHandlers } from 'fs://game/base-standard/ui/unit-interact/unit-action-handlers.js';
import { createLogger } from '../mpt-shared/mpt-util.js';
import { COMMAND_ACTIONS, DEFAULT_LENS, LENS_ACTIONS } from './mp-keybind-config.js';

const log = createLogger('hotkeys');

function toggleLens(lens) {
  const target = LensManager.getActiveLens() === lens ? DEFAULT_LENS : lens;
  LensManager.setActiveLens(target);
}

function runUnitCommand(commandType) {
  const unitId = UI.Player.getHeadSelectedUnit();
  if (!ComponentID.isValid(unitId)) return;
  const args = {};
  if (!Game.UnitCommands.canStart(unitId, commandType, args, false)?.Success) return;
  if (UnitActionHandlers.doesActionHaveHandler(commandType) && UnitActionHandlers.doesActionRequireTargetPlot(commandType)) {
    UnitActionHandlers.switchToActionInterfaceMode(commandType, { UnitID: unitId, CommandArguments: args });
  } else {
    Game.UnitCommands.sendRequest(unitId, commandType, args);
  }
}

function onEngineInput(event) {
  const detail = event?.detail;
  if (!detail || detail.status !== InputActionStatuses.FINISH) return;
  const lens = LENS_ACTIONS[detail.name];
  const command = COMMAND_ACTIONS[detail.name];
  if (!lens && !command) return;
  if (!InterfaceMode.allowsHotKeys()) return;
  try {
    if (lens) toggleLens(lens);
    else runUnitCommand(command);
  } catch (e) { log(`${detail.name} failed: ${e}`); }
}

engine.whenReady.then(() => window.addEventListener("engine-input", onEngineInput, true));
