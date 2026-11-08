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
 * Better Balanced Multiplayer - Lobby leader and civilization picker (shell scope).
 *
 * The lobby's Browse button opens the game's single-player leader,
 * civilization and civilization details screens over the multiplayer lobby,
 * hosted as the Create Game screen hosts them (create-game-screen.js): Leader,
 * Civilization, then Details, whose Select closes it. Close, Back from Leader
 * and Random close it too. While open, the lobby and main menu are hidden and
 * the main menu's 3D scene is cleared (as single player does on opening Create
 * Game), so the screens' 3D leader shows; closing restores them. The game's
 * audio is handed the same panels as single player, so the leader speaks.
 * It closes when you can no longer change your row. The screens fetch the
 * game's shared leader and civ models themselves, so the picker creates them
 * first, adjusted for the lobby: their lists leave out the Observer of
 * Zatygold's Spectator, and a locked or unowned leader is not picked (the
 * game's leader screen would pick one; its civ screens already do not). Your
 * row's leader and civilization dropdowns stay as in the base game. Hotseat
 * and the live-event fixed pairings have no Browse; a loaded game, a ready
 * player and the Spectator see it disabled.
 */
import { createComponent, onCleanup, onMount } from 'fs://game/core/vendor/solid-js/dist/solid.js';
import { ContextManager } from 'fs://game/core/ui/context-manager/context-manager.js';
import LiveEventManager from 'fs://game/core/ui/shell/live-event-logic/live-event-logic.js';
import { LobbyUpdateEventName } from 'fs://game/core/ui/shell/mp-staging/model-mp-staging-new.js';
import { Button } from 'fs://game/core/ui-next/components/button.js';
import { defineLegacyComponent } from 'fs://game/core/ui-next/components/fxs-solid-component.js';
import { Panel } from 'fs://game/core/ui-next/components/panel.js';
import { Popup } from 'fs://game/core/ui-next/components/popup.js';
import { ScreenFlowStepType, ScreenFlowTab } from 'fs://game/core/ui-next/components/screen-flow.js';
import { Tab } from 'fs://game/core/ui-next/components/tab.js';
import { NestedTooltipContext } from 'fs://game/core/ui-next/components/tooltip-nested.js';
import { AgeSelectModel, AgeSelectModelContext } from 'fs://game/core/ui-next/screens/create-game/age-select-model.js';
import { CivDetails } from 'fs://game/core/ui-next/screens/create-game/civ-details.js';
import { CivSelectModel, CivSelectModelContext } from 'fs://game/core/ui-next/screens/create-game/civ-select-model.js';
import { CivSelectScreen } from 'fs://game/core/ui-next/screens/create-game/civ-select-screen.js';
import { PlayerSetupParametersModel, SetupParametersModel } from 'fs://game/core/ui-next/screens/create-game/game-parameters-model.js';
import { LeaderSelectModel, LeaderSelectModelContext } from 'fs://game/core/ui-next/screens/create-game/leader-select-model.js';
import { LeaderSelectScreen } from 'fs://game/core/ui-next/screens/create-game/leader-select-screen.js';
import { RecommendedChoiceModel, RecommendedChoiceModelContext } from 'fs://game/core/ui-next/screens/create-game/recommended-choice-model.js';
import { useAudio } from 'fs://game/core/ui-next/services/audio-support.js';
import { Decorator, createLogger, isObserverValue } from '../shared/bbm-util.js';
import { onSetupRevision } from '../shared/bbm-setup.js';
import { canEditOwnSlot, closeScreen, usesLobbyPickers } from './bbm-memento-select.js';

const log = createLogger('leader civ picker');
const SCREEN_NAME = "bbm-leader-civ-select";
const LOBBY_TAG = "screen-mp-lobby";
const PARAM_LEADER = "PlayerLeader";
const PARAM_CIV = "PlayerCivilization";
const SPECTATOR_SLOT_SETTING = "BBMSpectatorSlot";
const SCREENS = [
	{ name: "leader-select", step: "leader-select", type: ScreenFlowStepType.Start },
	{ name: "civ-select", step: "civ-select" },
	{ name: "civ-details", step: "civ-select", next: "CLOSE" }
];
const STEP_SCREENS = { "leader-select": LeaderSelectScreen, "civ-select": CivSelectScreen, "civ-details": CivDetails };
// Where the screens go after a pick in single player; here the pick is made.
const FLOW_END_STEPS = ["game-setup", "create-game-hub", "memento-select"];
const SHELL_TAGS = [LOBBY_TAG, "main-menu"];
const MOUSE_GUARD_TAG = "mouse-guard";
// Panels the game's audio keeps while single player's Create Game is up (it opens over the main menu).
const AUDIO_KEPT_PANELS = ["main-menu", MOUSE_GUARD_TAG];
const CREATE_GAME_PANEL = "create-game-sp";
const BROWSE_CLASS = "bbm-browse-button";
const BROWSE_CAPTION = "LOC_BBM_LOBBY_BROWSE";
const CLOSE_CAPTION = "LOC_GENERIC_CLOSE";
// The Close button takes the header's right button area, where the profile badge sits.
const STYLES = `${SCREEN_NAME} .create-game-badge-container-outer { display: none; }`;

const ownParameter = (paramId) => GameSetup.findPlayerParameter(GameContext.localPlayerID, paramId);
const ownValue = (paramId) => ownParameter(paramId)?.value?.value;

/** The local player watches: the Observer, or the slot Better Balanced Multiplayer keeps for the Spectator. */
function isLocalObserver() {
	let slot = -1;
	try { slot = Number(Configuration.getGame().getValue(SPECTATOR_SLOT_SETTING) ?? -1); } catch (e) { /* none */ }
	return slot === GameContext.localPlayerID || isObserverValue(ownValue(PARAM_LEADER)) || isObserverValue(ownValue(PARAM_CIV));
}

/** The parameter takes edits from the local player (not read-only). */
function canEditOwnParameter(paramId) {
	const param = ownParameter(paramId);
	return !!param && !param.readOnly;
}

/** The game's setup models know the local player's leader and civ parameters (the models read them on creation). */
function hasOwnParameters() {
	SetupParametersModel.get().forceRefresh();
	const own = PlayerSetupParametersModel.get().players[GameContext.localPlayerID];
	return !!own?.[PARAM_LEADER] && !!own?.[PARAM_CIV];
}

/**
 * Fetches a shared model for the calling component's lifetime, adapted by
 * adapt(model) when this call creates it; the screens' own fetches then share it.
 */
function getAdapted(registered, adapt) {
	const factory = registered.factory;
	let adapted = false;
	registered.factory = (...args) => { adapted = true; return adapt(factory(...args)); };
	try {
		const model = registered.get();
		if (!adapted) log(`${registered.name} was already in use; the picker shows it unchanged`);
		return model;
	} finally {
		registered.factory = factory;
	}
}

const withoutObserver = (model, listName, idName) => {
	const list = model[listName];
	Object.defineProperty(model, listName, { get: () => list.filter((item) => !isObserverValue(item[idName])), enumerable: true, configurable: true });
};

function adaptLeaderModel(model) {
	withoutObserver(model, "leaders", "leaderID");
	const setSelectedLeader = model.setSelectedLeader;
	model.setSelectedLeader = (leader) => {
		if (leader?.isLocked) log(`${leader.leaderID} is locked`);
		else setSelectedLeader(leader);
	};
	return model;
}

function adaptCivModel(model) {
	withoutObserver(model, "civs", "civID");
	return model;
}

/** The models the picker's screens read, held for the calling component's lifetime. */
function createLobbyLeaderCivModels() {
	const ageModel = AgeSelectModel.get();
	const leaderModel = getAdapted(LeaderSelectModel, adaptLeaderModel);
	const civModel = getAdapted(CivSelectModel, adaptCivModel);
	const choiceModel = RecommendedChoiceModel.get();   // after the leader and civ models, so it shares them
	return { ageModel, leaderModel, civModel, choiceModel };
}

/** The picker has a place in this lobby: online or LAN, without the live event's fixed pairings. */
function offersPicker() {
	return usesLobbyPickers() && !LiveEventManager.restrictToPreferredCivs();
}

/** You may browse now: a new game's lobby, not ready, your leader and civ editable, and not watching. */
function canBrowse() {
	return offersPicker() && canEditOwnSlot() && !isLocalObserver() && canEditOwnParameter(PARAM_LEADER) && canEditOwnParameter(PARAM_CIV);
}

const close = () => closeScreen(SCREEN_NAME);
const closeLater = () => setTimeout(close);   // never pop mid-render

let stylesAdded = false;
function addStyles() {
	if (stylesAdded) return;
	const style = document.createElement("style");
	style.textContent = STYLES;
	document.head.appendChild(style);
	stylesAdded = true;
}

/** The lobby, the main menu and the dimming mouse guards of the screens under the picker (they darken the 3D stage). */
function shellElements() {
	const screens = SHELL_TAGS.map((tag) => document.querySelector(tag)).filter(Boolean);
	const dimmers = [...document.querySelectorAll(MOUSE_GUARD_TAG)].filter((guard) => !guard.classList.contains("invisible"));
	return [...screens, ...dimmers];
}

/** Hides the shell under the picker and clears the main menu's 3D scene (as its Create Game does); returns the restore. */
function clearShellStage() {
	const restores = shellElements().map((element) => {
		const visibility = element.style.visibility;
		element.style.visibility = "hidden";
		return () => { element.style.visibility = visibility; };
	});
	const mainMenu = document.querySelector("main-menu")?.maybeComponent;
	const hadScene = !!mainMenu?.MainMenuSceneModels;
	if (hadScene) mainMenu.clear3DScene();
	return () => {
		for (const restore of restores) restore();
		try {
			WorldUI.clearBackground();   // the screens' stage layers outlive their disposed background
			if (hadScene && mainMenu.Root?.isConnected) mainMenu.build3DScene();
		} catch (error) {
			log(`main menu scene not rebuilt: ${error?.stack ?? error}`);   // never block the other cleanups
		}
	};
}

/**
 * The game's audio mutes the leader's voice while the lobby's panels are up, so
 * the panels under the picker are reported ended and Create Game started, as in
 * single player; closing reports them back in their order. Returns the restore.
 */
function handOffAudioPanels() {
	const ended = [];
	const timer = setTimeout(() => {   // after ContextManager reports the picker's own panel
		const below = ContextManager.screens.map((element) => element.tagName.toLowerCase())
			.filter((name) => name !== SCREEN_NAME && !AUDIO_KEPT_PANELS.includes(name));
		try {
			for (const name of below) {
				UI.panelEnd(name, "", UIViewChangeMethod.Unknown, false);
				ended.unshift(name);
			}
			UI.panelStart(CREATE_GAME_PANEL, "", UIViewChangeMethod.Unknown, true);
		} catch (error) {
			log(`audio panels not handed off: ${error?.stack ?? error}`);
		}
	});
	return () => {
		clearTimeout(timer);
		try {
			UI.panelEnd(CREATE_GAME_PANEL, "", UIViewChangeMethod.Unknown, false);
			for (const name of ended) UI.panelStart(name, "", UIViewChangeMethod.Unknown, true);
		} catch (error) {
			log(`audio panels not restored: ${error?.stack ?? error}`);
		}
	};
}

const FlowEnd = () => {
	onMount(closeLater);
	return null;
};

/** The game's Button in the stage header's right button area: closes the picker without a further change. */
function closeButton() {
	const area = document.createElement("div");
	area.className = "create-game-header-right-button-area flex flex-row items-center justify-center absolute";
	area.appendChild(createComponent(Button, {
		class: "pointer-events-auto",
		disableFocus: true,
		onActivate: closeLater,
		get children() { return Locale.compose(CLOSE_CAPTION); }
	}));
	return area;
}

const provide = (context, value, children) => createComponent(context.Provider, { value, get children() { return children(); } });

const LeaderCivPicker = () => {
	const closeIfLocked = () => { if (!canBrowse()) closeLater(); };
	onCleanup(onSetupRevision("leader civ picker", closeIfLocked));
	window.addEventListener(LobbyUpdateEventName, closeIfLocked);
	onCleanup(() => window.removeEventListener(LobbyUpdateEventName, closeIfLocked));
	let models;
	try {
		models = createLobbyLeaderCivModels();
	} catch (error) {
		log(`models not created: ${error?.stack ?? error}`);
		closeLater();
		return null;
	}
	const { ageModel, leaderModel, civModel, choiceModel } = models;
	addStyles();
	onCleanup(clearShellStage());
	onCleanup(handOffAudioPanels());
	const backAudio = useAudio("CreateGameBackButton");
	let flow;
	let popup;
	function handleCancelInput() {
		if (popup?.active()) popup.close();
		else flow?.activatePrev();
		backAudio("activate");
	}
	return createComponent(Panel, {
		id: SCREEN_NAME,
		name: SCREEN_NAME,
		class: "fullscreen",
		onCancelInput: handleCancelInput,
		get children() {
			return [provide(NestedTooltipContext, { disabled: true }, () =>
				provide(AgeSelectModelContext, ageModel, () =>
					provide(CivSelectModelContext, civModel, () =>
						provide(LeaderSelectModelContext, leaderModel, () =>
							provide(RecommendedChoiceModelContext, choiceModel, () =>
								createComponent(Popup, {
									setPopupContext: (context) => {
										popup = context;
										context.onTrigger = () => {};   // no popups hosted: the Age is the host's game setting
									},
									get children() {
										return [createComponent(ScreenFlowTab, {
											class: "fullscreen",
											defaultTab: SCREENS[0].name,
											screens: SCREENS,
											onClose: closeLater,
											onStart: closeLater,
											contextRef: (ref) => { flow = ref; },
											get children() {
												return [
													createComponent(Tab.Output, {}),
													...SCREENS.map(({ name }) => createComponent(Tab.Item, { name, title: () => null, body: () => createComponent(STEP_SCREENS[name], {}) })),
													...FLOW_END_STEPS.map((name) => createComponent(Tab.Item, { name, title: () => null, body: FlowEnd }))
												];
											}
										}), createComponent(Popup.Output, { class: "fullscreen child-fullscreen" })];
									}
								})))))), closeButton()];
		}
	});
};

// The adapter renders inside a tracked scope; createComponent runs the picker untracked.
defineLegacyComponent(SCREEN_NAME, { classNames: ["fullscreen"] }, () => createComponent(LeaderCivPicker, {}));

/** Opens the picker on Leader, then Civilization and Details. */
function openLeaderCivPicker() {
	if (!canBrowse() || !hasOwnParameters()) return false;
	ContextManager.push(SCREEN_NAME, { singleton: true, createMouseGuard: true, attributes: { shouldDarken: false } });
	return true;
}

/** The lobby's Browse button, before Mementos: open while you may browse, absent where the picker has no place. */
class LobbyBrowseButton extends Decorator {
	constructor(component) {
		super();
		this.component = component;
		this.button = null;
		this.refresh = this.refresh.bind(this);
		this.unsubscribe = null;
	}

	afterAttach() {
		try {
			if (this.button || !offersPicker()) return;
			const root = this.component.Root;
			const mementos = root.querySelector(".memento-button");
			const row = mementos?.parentElement ?? root.querySelector(".mp-staging__bot-section2");
			if (!row) {
				log("Browse not added: no lobby button row");
				return;
			}
			this.button = document.createElement("fxs-button");
			this.button.classList.add(BROWSE_CLASS, "mr-3", "mt-3");
			this.button.setAttribute("caption", BROWSE_CAPTION);
			this.button.addEventListener("action-activate", () => {
				try {
					if (!openLeaderCivPicker()) log("picker not opened: browsing not allowed");
				} catch (error) {
					log(`picker not opened: ${error?.stack ?? error}`);
				}
			});
			row.insertBefore(this.button, mementos ?? null);
			window.addEventListener(LobbyUpdateEventName, this.refresh);
			this.unsubscribe = onSetupRevision("lobby browse", this.refresh);
			this.refresh();
		} catch (error) {
			log(`Browse not added: ${error?.stack ?? error}`);
		}
	}

	refresh() {
		if (!this.button) return;
		try {
			this.button.classList.toggle("hidden", !offersPicker());
			this.button.setAttribute("disabled", canBrowse() ? "false" : "true");
		} catch (error) {
			log(`Browse not refreshed: ${error?.stack ?? error}`);
		}
	}

	beforeDetach() {
		window.removeEventListener(LobbyUpdateEventName, this.refresh);
		this.unsubscribe?.();
		this.unsubscribe = null;
		this.button?.remove();
		this.button = null;
	}
}

Controls.decorate(LOBBY_TAG, (component) => new LobbyBrowseButton(component));
