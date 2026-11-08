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
 * Better Balanced Multiplayer - no automatic Advisor Council popup (game scope).
 *
 * The base advice manager (base-standard ui/advice/advice-manager.js) queues
 * the "Choose your advisors" popup (advisor-council-popup) on turn 4 when the
 * tutorial is on or the difficulty is King or lower. In multiplayer that
 * request is dropped from the popup queue; the Advisors button and its key
 * still open the council. Multiplayer games only.
 */
import PopupSequencer from 'fs://game/base-standard/ui/popup-sequencer/popup-sequencer.js';
import { createLogger, isMultiplayerGame, wrapMethod } from '../shared/mpt-util.js';

const log = createLogger('advisor');
const ADVISOR_POPUP_ID = 'advisor-council-popup';

engine.whenReady.then(() => {
  if (!isMultiplayerGame()) return;
  wrapMethod(PopupSequencer, 'addDisplayRequest', function (base, request, ...rest) {
    if (request?.popupId === ADVISOR_POPUP_ID || request?.screenId === ADVISOR_POPUP_ID) {
      log('Advisor Council popup skipped');
      return request;
    }
    return base(request, ...rest);
  });
});
