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
 * Better Balanced Multiplayer - Lobby memento picker (shell scope).
 *
 * The game's single-player memento picker, with its search bar and attribute
 * filter, opened over the multiplayer lobby for the local player (as Advanced
 * Settings Pro opens it in single player, under its own screen name). The
 * create-game flow supplies what surrounds the picker there; here a backdrop
 * stands in for its 3D stage, a panel takes focus and Escape, a flow whose Back,
 * Confirm and Continue all close it, and the model of
 * ui/lobby/bbm-memento-select-model.js. It closes when the setup no longer
 * lets you change mementos. Hotseat, where the game skips this picker, and any
 * other setup keep the game's Choose Mementos.
 */
import { createComponent, onCleanup } from 'fs://game/core/vendor/solid-js/dist/solid.js';
import { ContextManager } from 'fs://game/core/ui/context-manager/context-manager.js';
import { MPLobbyDataModel } from 'fs://game/core/ui/shell/mp-staging/model-mp-staging-new.js';
import { defineLegacyComponent } from 'fs://game/core/ui-next/components/fxs-solid-component.js';
import { Panel } from 'fs://game/core/ui-next/components/panel.js';
import { ScreenFlowContext } from 'fs://game/core/ui-next/components/screen-flow.js';
import { MementoSelect, MementoSelectClosedEvent } from 'fs://game/core/ui-next/screens/create-game/memento-select.js';
import { MementoSelectModelContext } from 'fs://game/core/ui-next/screens/create-game/memento-select-model.js';
import { createLogger, isMultiplayerGame } from '../shared/bbm-util.js';
import { onSetupRevision } from '../shared/bbm-setup.js';
import { createLobbyMementoModel } from './bbm-memento-select-model.js';

const log = createLogger('memento picker');
const SCREEN_NAME = "bbm-memento-select";
const GAME_EDITOR = "memento-editor";
const BACKDROP_COLOR = "rgba(10, 11, 15, 0.96)";
let openingSlot = null;

/** The lobby pickers stand in for the game's own in an online or LAN lobby; hotseat keeps the game's. */
function usesLobbyPickers() {
	return isMultiplayerGame() && !Configuration.getGame()?.isHotseat;
}

/** Your own row is still yours to change: a new game's lobby while you are not ready. */
function canEditOwnSlot() {
	return MPLobbyDataModel.isNewGame && !Network.isPlayerStartReady(GameContext.localPlayerID);
}

/** As the lobby's Choose Mementos: only in a new game, while mementos are on and you are not ready. */
function canEditMementos() {
	return !!Configuration.getGame()?.isMementosEnabled && canEditOwnSlot();
}

function closeScreen(name) {
	if (ContextManager.hasInstanceOf(name)) ContextManager.pop(name);
}
/** Closes the picker and tells the lobby, which hides itself while Mementos is open (as the game's picker does). */
function close() {
	if (!ContextManager.hasInstanceOf(SCREEN_NAME)) return;
	ContextManager.pop(SCREEN_NAME);
	window.dispatchEvent(new MementoSelectClosedEvent());
}

// Only what the picker and its stage header read from a flow.
const standaloneFlow = {
	activateNext: close,
	activatePrev: close,
	activate: close,
	close,
	start: close,
	clearHub: () => {},
	active: () => ({ name: "memento-select" }),
	currentStep: () => 0,
	numSteps: () => 0,
	isStartActive: () => false,
	isHubActive: () => false,
	wasHubVisited: () => false
};

function backdrop() {
	const element = document.createElement("div");
	element.className = "absolute inset-0 pointer-events-auto";
	element.style.backgroundColor = BACKDROP_COLOR;
	return element;
}

const MementoPicker = () => {
	log(`opening on slot ${openingSlot?.ID ? GameSetup.resolveString(openingSlot.ID) : "none"}`);
	const model = createLobbyMementoModel(openingSlot);
	log(`${model.slots.length} slots, ${model.mementos.length} mementos`);
	onCleanup(onSetupRevision("memento picker", () => (canEditMementos() ? model.refresh() : close())));
	return [backdrop(), createComponent(Panel, {
		id: SCREEN_NAME,
		name: SCREEN_NAME,
		class: "fullscreen",
		onCancelInput: close,
		get children() {
			return createComponent(ScreenFlowContext.Provider, {
				value: standaloneFlow,
				get children() {
					return createComponent(MementoSelectModelContext.Provider, {
						value: model,
						get children() { return createComponent(MementoSelect, {}); }
					});
				}
			});
		}
	})];
};

// The adapter renders inside a tracked scope; createComponent runs the picker untracked.
defineLegacyComponent(SCREEN_NAME, { classNames: ["fullscreen"] }, () => createComponent(MementoPicker, {}));

/** Opens the local player's mementos, on the slot of a slot parameter when given. */
function openMementoPicker(slotParam = null) {
	if (!usesLobbyPickers()) {
		ContextManager.push(GAME_EDITOR, { singleton: true, createMouseGuard: true, attributes: { blackOut: true } });
		return;
	}
	openingSlot = slotParam;
	ContextManager.push(SCREEN_NAME, { singleton: true, createMouseGuard: true });
}

export { canEditMementos, canEditOwnSlot, closeScreen, openMementoPicker, usesLobbyPickers };
