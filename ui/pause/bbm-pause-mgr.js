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
 * Better Balanced Multiplayer - multiplayer pause manager (singleton).
 *
 * Loaded as an in-game UIScript (scope="game"); active only in multiplayer.
 * Mirrors the base game's manager pattern (see base-standard
 * ui/mp-ingame-mgr/mp-ingame-mgr.js): a class with bound engine listeners,
 * constructed on engine.whenReady, exported as the module default.
 *
 * Responsibilities
 *  - Pause/resume orchestration built on the engine's synchronized multiplayer
 *    pause (Network.toggleMultiplayerPause + GamePauseStateChanged). A held
 *    "want pause" flag means "this player is NOT ready"; the game unpauses when
 *    all flags clear. readyCount = N - wantPauseCount is identical on every
 *    client, giving a synchronized tally for free.
 *  - The game's own Pause / Resume button and Multiplayer Pause key set the
 *    local flag; this manager adds View Map, the ready tally and the host
 *    controls to the pause menu, which stands in for the game's pause curtain.
 *  - Blocks game-advancing input while paused (engine InputFilterManager).
 *  - Keeps the game paused through a synchronized "UNPAUSING..." countdown.
 *  - Pauses immediately on a player disconnect, before the AI can take over.
 *  - Host "Drop Disconnected & Resume" over the chat channel (bbm-pause-net.js).
 */
import InputFilterManager from 'fs://game/core/ui/input/input-filter.js';
import { InterfaceMode, InterfaceModeChangedEventName } from 'fs://game/core/ui/interface-modes/interface-modes.js';
import { Audio } from 'fs://game/core/ui/audio-base/audio-support.js';
import { getPlayerColorVariants } from 'fs://game/core/ui/utilities/utilities-color.js';
import { Icon } from 'fs://game/core/ui/utilities/utilities-image.js';
import MultiplayerIngame from 'fs://game/base-standard/ui/mp-ingame-mgr/mp-ingame-mgr.js';
import { createLogger, isMultiplayerGame, isObserverPlayer, wrapMethod } from '../shared/bbm-util.js';
import { FILTER_SOURCE, PAUSE_MENU_MODE, CONFIG, PROGRESS_ACTIONS, LOC } from './bbm-pause-config.js';
import styles from './bbm-pause.scss.js';
import PauseCountdownOverlay from './bbm-pause-overlay.js';
import BBMNet from './bbm-pause-net.js';

const STATE = { IDLE: "idle", PAUSED: "paused", COUNTDOWN: "countdown" };
const log = createLogger("pause");
const MENU_INJECT_RETRIES = 20;
const MENU_INJECT_INTERVAL_MS = 50;

/** Connection state of a player (assumed connected when the engine cannot say). */
function isConnected(id) {
	try { return Network.isPlayerConnected(id); } catch (e) { return true; }
}

/**
 * Living human major players (engine observer slots excluded). A companion
 * mod's Observer holds a pause flag like everyone else, so it counts toward
 * the ready tally, but its disconnect never pauses the game
 * (includeObservers = false).
 */
function humanParticipantIds(includeObservers = false) {
	try {
		return Players.getAliveMajorIds().filter((id) => {
			const pc = Configuration.getPlayer(id);
			return pc?.isHuman && !pc.isObserver && (includeObservers || !isObserverPlayer(id));
		});
	} catch (e) { return []; }
}

/** A div with the given classes, background image and tint, added to parent when given. */
function layerDiv(className, image = "", tint = "", parent = null) {
	const div = document.createElement("div");
	div.className = className;
	if (image) div.style.backgroundImage = image;
	if (tint) div.style.setProperty("fxs-background-image-tint", tint);
	parent?.appendChild(div);
	return div;
}

/** A pausing player's leader and civilization icons and name, as the game's pause screen shows them. */
function pausingPlayerDiv(id, name) {
	const player = Players.get(id);
	const leader = player?.leaderType != null ? GameInfo.Leaders.lookup(player.leaderType)?.LeaderType : null;
	const civ = player ? Icon.getCivSymbolFromCivilizationType(player.civilizationType) : "";
	const colors = getPlayerColorVariants(id);
	const primary = colors?.primaryColor.mainColor ?? "";
	const secondary = colors?.secondaryColor.mainColor ?? "";
	const row = layerDiv("relative flex flex-row justify-center mx-3 mt-3");
	const icons = layerDiv("flex flex-row justify-center h-12", "", "", row);
	const hex = layerDiv("relative w-12 flex items-center justify-center", "", "", icons);
	layerDiv("absolute w-14 h-16 bg-no-repeat bg-center bg-contain", "url(blp:lp_hex_bk_128)", "", hex);
	layerDiv("absolute w-14 h-16 bg-no-repeat bg-center bg-contain", "url(blp:lp_hex_color_128)", secondary, hex);
	const leaderSlot = layerDiv("absolute inset-0 flex items-center justify-center", "", "", hex);
	layerDiv("size-14 mb-1 bg-no-repeat bg-center bg-contain", leader ? UI.getIconCSS(leader) : "", "", leaderSlot);
	const circle = layerDiv("relative w-12 flex justify-center items-center", "", "", icons);
	layerDiv("absolute size-11 bg-center bg-cover", "url(blp:final_civ-frame)", "", circle);
	layerDiv("absolute size-12 bg-center bg-cover", "url(blp:lp_circ_color_128)", primary, circle);
	layerDiv("absolute size-9 bg-center bg-cover", civ ? `url(${civ})` : "", secondary, circle);
	const label = layerDiv("bbm-paused-by-name font-title text-accent-1 ml-1 self-center", "", "", row);
	label.textContent = id === GameContext.localPlayerID ? Locale.stylize("LOC_VICTORY_LEADER_NAME_YOU", name) : name;
	return row;
}

function textDiv(className, text) {
	const div = document.createElement("div");
	div.className = className;
	div.textContent = text;
	return div;
}

const STYLE_ELEMENT_ID = "bbm-pause-styles";
const VIEW_MAP_BUTTON_ID = "bbm-viewmap-button";
const DROP_RESUME_BUTTON_ID = "bbm-drop-resume-button";
const HOST_HINT_ID = "bbm-host-hint";
const FOOTER_READY_ID = "bbm-footer-ready";
const PAUSE_MENU_CONTAINER = "#pause-menu-button-container";
const NATIVE_RESUME_BUTTON = "#pause-menu-resume-button";
// The game's multiplayer Pause / Resume button, found by its caption.
const GAME_PAUSE_CAPTIONS = ["LOC_UI_MP_PAUSE", "LOC_UI_MP_RESUME"];

class MultiplayerPauseManager {
	// --- runtime state ---
	state = STATE.IDLE;
	isMultiplayer = false;
	iHoldFlag = false;          // does THIS client hold a want-pause flag?
	finalizing = false;         // countdown finished, releasing our flag
	pauseStart = 0;
	pauseReason = "";           // optional cause shown in the menu (e.g. disconnect)
	pausedBy = [];              // ids of the players who started the pause
	pollTimer = 0;
	countdownTimer = 0;
	backstopTimer = 0;
	statusText = "";            // last rendered hint / tally, to skip unchanged DOM writes
	progressFiltersActive = false;
	menuListenerBound = false;
	connState = {};             // playerId -> last-known connected? (disconnect watchdog)
	watchedHumans = [];         // human player ids monitored for drops
	connectionTimer = 0;
	acknowledged = {};          // disconnected ids the players deliberately resumed past
	disconnectNotices = [];     // { id, name } per currently-disconnected player (menu display)
	viewHiddenForcedEl = null;  // production chooser element we forced "View Hidden" on

	// --- reusable components ---
	overlay = new PauseCountdownOverlay();

	// --- bound engine listeners ---
	gamePauseStateChangedListener = (data) => this.onGamePauseStateChanged(data);
	playerDisconnectedListener = (data) => this.onPlayerDisconnected(data);
	interfaceModeChangedListener = () => this.onInterfaceModeChanged();
	playerTurnActivatedListener = () => this.onTurnActivated();
	playerConnectedListener = (data) => this.onPlayerConnected(data);
	hostMigratedListener = (data) => this.onHostMigrated(data);

	constructor() {
		engine.whenReady.then(() => this.onReady());
	}

	// ============================ Small helpers ============================
	amHost() {
		try { return GameContext.localPlayerID === Network.getHostPlayerId(); }
		catch (e) { return false; }
	}
	numWantPause() {
		try { return Network.getNumWantPausePlayers() | 0; } catch (e) { return 0; }
	}
	/** True from the start of a pause to the end of its unpause countdown (the turn timer waits for it). */
	isPaused() {
		return this.state === STATE.PAUSED || (this.state === STATE.COUNTDOWN && !this.finalizing);
	}
	/** Whether this client holds a want-pause flag, as the engine has it. */
	localWantsPause() {
		try { return !!Configuration.getPlayer(GameContext.localPlayerID)?.wantsPause; } catch (e) { return this.iHoldFlag; }
	}
	toggleEnginePause() {
		try { Network.toggleMultiplayerPause(); return true; }
		catch (e) { log("toggleMultiplayerPause failed: " + e); return false; }
	}
	/** Connected participants: a dropped player is never part of the "everyone is ready" consensus. */
	totalPlayers() { return Math.max(humanParticipantIds(true).filter(isConnected).length, 1); }
	converged() { return (Date.now() - this.pauseStart) >= CONFIG.convergenceDelayMs; }

	// ============================= Input filtering =============================
	applyProgressFilters() {
		if (this.progressFiltersActive) return;
		for (const name of PROGRESS_ACTIONS) {
			try { InputFilterManager.addInputFilter({ inputName: name, filterSource: FILTER_SOURCE }); } catch (e) {}
		}
		this.progressFiltersActive = true;
	}
	clearProgressFilters() {
		if (!this.progressFiltersActive) return;
		for (const name of PROGRESS_ACTIONS) {
			try { InputFilterManager.removeInputFilter({ inputName: name, filterSource: FILTER_SOURCE }); } catch (e) {}
		}
		this.progressFiltersActive = false;
	}

	// ===================== Interface mode (built-in pause menu) =================
	pauseMenuIsOpen() {
		try { return InterfaceMode.isInInterfaceMode(PAUSE_MENU_MODE); }
		catch (e) { return !!document.querySelector("#screen-pause-menu"); }
	}
	openPauseMenu() {
		if (this.pauseMenuIsOpen()) return;
		try { InterfaceMode.switchTo(PAUSE_MENU_MODE); }
		catch (e) { log("openPauseMenu failed: " + e); }
	}
	closePauseMenu() {
		if (!this.pauseMenuIsOpen()) return;
		try { InterfaceMode.switchToDefault(); }
		catch (e) { log("closePauseMenu failed: " + e); }
	}

	// ================================= Styles ==================================
	injectStyles() {
		if (document.getElementById(STYLE_ELEMENT_ID)) return;
		const el = document.createElement("style");
		el.id = STYLE_ELEMENT_ID;
		el.textContent = styles;
		document.head.appendChild(el);
	}

	// ====================== Pause-menu button injection ========================
	onInterfaceModeChanged() {
		if (this.pauseMenuIsOpen()) this.tryInjectWhenMenuReady(0);
	}
	// Injection runs only when the pause menu opens (interface-mode event, no DOM observer).
	startMenuListener() {
		if (!this.menuListenerBound) {
			window.addEventListener(InterfaceModeChangedEventName, this.interfaceModeChangedListener);
			this.menuListenerBound = true;
		}
		if (this.pauseMenuIsOpen()) this.tryInjectWhenMenuReady(0);
	}
	tryInjectWhenMenuReady(attempt = 0) {
		const container = document.querySelector(PAUSE_MENU_CONTAINER);
		if (container) {
			this.injectMenuButtons(container);
			setTimeout(() => this.raiseGamePauseButton(container), MENU_INJECT_INTERVAL_MS);   // in case it renders after the menu
			return;
		}
		if (attempt < MENU_INJECT_RETRIES) setTimeout(() => this.tryInjectWhenMenuReady(attempt + 1), MENU_INJECT_INTERVAL_MS);
	}
	// fxs-button dispatches "action-activate" for both mouse and controller, just
	// like the base game's own buttons - using only this avoids double-invocation.
	makeButton(id, caption, onActivate) {
		const btn = document.createElement("fxs-button");
		btn.id = id;
		btn.classList.add("pause-menu-button", "bbm-injected");
		btn.setAttribute("caption", caption);
		btn.addEventListener("action-activate", onActivate);
		return btn;
	}
	/** The game's own Pause / Resume button goes under Back to Game, or under the hint while paused (Back to Game is hidden). */
	raiseGamePauseButton(container) {
		const captions = GAME_PAUSE_CAPTIONS.map((tag) => Locale.compose(tag));
		const button = [...container.children].find((el) => !el.classList.contains("bbm-injected") && captions.includes(el.textContent.trim()));
		if (!button) return;
		const nativeResume = container.querySelector(NATIVE_RESUME_BUTTON);
		const hint = document.getElementById(HOST_HINT_ID);
		const above = nativeResume && nativeResume.style.display !== "none" ? nativeResume : (hint?.parentElement === container ? hint : null);
		const anchor = above ? above.nextSibling : container.firstChild;
		if (anchor !== button) container.insertBefore(button, anchor);
	}
	injectMenuButtons(container) {
		const paused = this.state === STATE.PAUSED;
		const nativeResume = container.querySelector(NATIVE_RESUME_BUTTON);
		container.querySelectorAll(".bbm-injected").forEach((el) => el.remove());

		if (paused) {
			// The native ui-next "Resume Game" hero button can't be reliably hooked to
			// unpause (it only closes the menu), so hide it and use our own controls.
			if (nativeResume) nativeResume.style.display = "none";

			const hint = document.createElement("div");
			hint.className = "bbm-host-hint bbm-injected";
			hint.id = HOST_HINT_ID;
			this.statusText = "";
			this.renderHint(hint);

			// Players ready up with the game's own Resume button.
			const isHost = this.amHost();
			const viewBtn = this.makeButton(VIEW_MAP_BUTTON_ID, LOC.viewMap, (ev) => this.onViewMapClick(ev));

			// Top of the menu, in order: hint, then View Map.
			const first = container.firstChild;
			container.insertBefore(hint, first);
			container.insertBefore(viewBtn, first);

			// Host-only recovery: when a player has dropped while paused, their stuck
			// want-pause flag can't be cleared by anyone else, so the game can't reach
			// zero and resume. Offer the host a button to kick the disconnected
			// player(s), which clears the flag and lets the resume complete.
			if (isHost && this.canHostKick() && this.disconnectedIds().length > 0) {
				const dropBtn = this.makeButton(DROP_RESUME_BUTTON_ID, LOC.dropResume, (ev) => this.onDropDisconnectedClick(ev));
				container.insertBefore(dropBtn, first);
			}

			this.injectFooterReady();
		} else {
			// Not paused: the game's own Pause button starts a pause.
			if (nativeResume) nativeResume.style.display = "";
			this.removeFooterReady();
		}
		this.raiseGamePauseButton(container);
	}

	// ===================== Status hint & footer ready tally ====================
	footerContainer() {
		const gi = document.querySelector(".pause-menu-game-info");
		return gi ? gi.parentElement : null;
	}
	/** "Ready: r / n" and whether every connected player is ready (tally held at 0 until clients converge). */
	footerTally() {
		const total = this.totalPlayers();
		const ready = this.converged() ? Math.max(0, total - this.numWantPause()) : 0;
		return { text: Locale.compose(LOC.readyTally, ready, total), enough: ready >= total };
	}
	/** The tally, then who paused (left out when the pause has a stated reason, such as a disconnect). */
	renderFooter(el) {
		const tally = this.footerTally();
		const pausedBy = !this.disconnectNotices.length && !this.pauseReason ? this.pausedBy : [];
		const key = tally.text + "\n" + pausedBy.join(",");
		if (el.dataset.bbmKey !== key) {
			el.dataset.bbmKey = key;
			el.textContent = tally.text;
			if (pausedBy.length) {
				el.appendChild(textDiv("bbm-paused-by", Locale.compose(LOC.pausedBy)));
				const players = layerDiv("flex flex-row flex-wrap justify-center", "", "", el);
				for (const id of pausedBy) players.appendChild(pausingPlayerDiv(id, this.playerNameById(id) || Locale.compose(LOC.aPlayer)));
			}
		}
		el.classList.toggle("bbm-enough", tally.enough);
		el.classList.toggle("bbm-not-enough", !tally.enough);
	}
	injectFooterReady() {
		let el = document.getElementById(FOOTER_READY_ID);
		if (!el) {
			const fc = this.footerContainer();
			if (!fc) return;
			el = document.createElement("div");
			el.id = FOOTER_READY_ID;
			el.className = "bbm-footer-ready";
			fc.appendChild(el);
		}
		this.renderFooter(el);
	}
	removeFooterReady() {
		const el = document.getElementById(FOOTER_READY_ID);
		if (el) el.remove();
	}
	/** A player name field, composed when it is a LOC key. */
	composePlayerName(raw) {
		if (!raw) return "";
		try { return Locale.compose(raw); } catch (e) { return String(raw); }
	}
	/** Player display name like "Name#12345": gamertag fields first. */
	playerNameById(id) {
		try {
			const pc = Configuration.getPlayer(id);
			return this.composePlayerName(pc && (pc.nickName_T2GP || pc.nickName || pc.slotName));
		} catch (e) { return ""; }
	}
	addDisconnectNotice(id, name) {
		if (id !== null && this.disconnectNotices.some((n) => n.id === id)) return;
		if (name && this.disconnectNotices.some((n) => n.name === name)) return;
		this.disconnectNotices.push({ id, name: name || Locale.compose(LOC.aPlayer) });
		this.refreshStatus();
	}
	removeDisconnectNotice(id) {
		this.disconnectNotices = this.disconnectNotices.filter((n) => n.id !== id);
		this.refreshStatus();
	}
	/** Hint lines: one per disconnected player and the pause reason (red, see .bbm-reason), then the status line. */
	hintLines() {
		const reasons = this.disconnectNotices.map((n) => Locale.compose(LOC.playerDisconnected, n.name));
		if (this.pauseReason) reasons.push(this.pauseReason);
		const status = this.iHoldFlag ? LOC.hintWaiting : LOC.hintReady;
		return { reasons, status: Locale.compose(status) };
	}
	/** Rebuild the hint only when its text changed (player names are set as text, never markup). */
	renderHint(hint) {
		const { reasons, status } = this.hintLines();
		const key = reasons.join("\n") + "\n" + status;
		if (key === this.statusText) return;
		this.statusText = key;
		hint.textContent = "";
		for (const reason of reasons) hint.appendChild(textDiv("bbm-reason", reason));
		hint.appendChild(document.createTextNode(status));
	}
	refreshStatus() {
		const hint = document.getElementById(HOST_HINT_ID);
		if (hint) this.renderHint(hint);
		const footer = document.getElementById(FOOTER_READY_ID);
		if (footer) this.renderFooter(footer);
		else if (this.state === STATE.PAUSED) this.injectFooterReady();
	}

	// ============================== Button handlers ============================
	/** A trusted RESUME arrived from the host (or we issued one): clear our own flag. */
	onRemoteResume() {
		if (this.state !== STATE.PAUSED && this.state !== STATE.COUNTDOWN) return;
		if (this.iHoldFlag) { this.iHoldFlag = false; this.toggleEnginePause(); }
		this.refreshStatus();
	}
	onViewMapClick(ev) {
		ev?.stopPropagation?.();
		if (this.state !== STATE.PAUSED) return;
		this.closePauseMenu();              // return to the world; Esc re-opens the menu
	}

	// ===================== Disconnect deadlock recovery (host) ==================
	/** Currently-disconnected watched human ids. */
	disconnectedIds() {
		return (this.watchedHumans.length ? this.watchedHumans : humanParticipantIds()).filter((id) => !isConnected(id));
	}
	/** True when this client is allowed to direct-kick (i.e. is the host with the privilege). */
	canHostKick() {
		try { return !!Network.canPlayerEverDirectKick(GameContext.localPlayerID); } catch (e) { return false; }
	}
	/**
	 * Host presses "Drop Disconnected & Resume": kick each dropped player to clear
	 * their stuck want-pause flag, then release our own flag. Once every remaining
	 * (connected) player is ready, the want-pause count reaches zero and the game
	 * resumes - breaking the deadlock a mid-pause disconnect would otherwise cause.
	 */
	onDropDisconnectedClick(ev) {
		ev?.stopPropagation?.();
		if (this.state !== STATE.PAUSED) return;
		let kicked = 0;
		for (const id of this.disconnectedIds()) {
			try {
				let allowed = true;
				try { allowed = Network.canDirectKickPlayerNow(id); } catch (e) { allowed = true; }
				if (allowed) { Network.directKickPlayer(id); kicked++; }
			} catch (e) { log("directKickPlayer failed for " + id + ": " + e); }
		}
		log("Host dropped " + kicked + " disconnected player(s) to break the pause deadlock.");
		// Clear every remaining connected player's flag too, so the game resumes the
		// moment the kicked slots free up (kick alone only clears the dropped flags).
		this.onRemoteResume();
		BBMNet.send("RESUME");
		this.refreshStatus();
	}

	// ======================= Synchronized state machine ========================
	onGamePauseStateChanged(data) {
		if (!this.isMultiplayer) return;
		this.iHoldFlag = this.localWantsPause();   // the game's Pause / Resume button may have toggled it
		const paused = !!data && Number(data.data) === 1;
		if (paused) {
			if (this.state === STATE.IDLE) this.enterPaused();
			else if (this.state === STATE.PAUSED) this.refreshStatus();
			// COUNTDOWN: our own re-pause during the countdown -> ignore
		} else {
			if (this.state === STATE.PAUSED) this.beginCountdown();
			else if (this.state === STATE.COUNTDOWN) { if (this.finalizing) this.enterIdle(); }
			else this.enterIdle();
		}
	}
	enterPaused() {
		this.state = STATE.PAUSED;
		this.pauseStart = Date.now();
		this.statusText = "";
		// Before anyone else takes a flag, only the players who paused hold one.
		this.pausedBy = humanParticipantIds(true).filter((id) => Configuration.getPlayer(id)?.wantsPause);
		if (!this.iHoldFlag) { this.iHoldFlag = true; this.toggleEnginePause(); }
		this.applyProgressFilters();
		this.openPauseMenu();
		this.startMenuListener();
		this.startPoll();
	}
	startPoll() {
		this.stopPoll();
		this.pollTimer = setInterval(() => this.onPoll(), CONFIG.pollMs);
	}
	stopPoll() {
		if (this.pollTimer) { clearInterval(this.pollTimer); this.pollTimer = 0; }
	}
	/**
	 * While paused every city operation fails, so with "View Hidden" off the
	 * production chooser renders empty categories. Force it on through the
	 * chooser's own setter (items appear, disabled) once per chooser-open, and
	 * restore it on unpause. The user can still toggle it manually meanwhile.
	 */
	syncProductionChooser() {
		const el = document.querySelector("panel-production-chooser");
		const chooser = el?.maybeComponent;
		if (!el || !chooser) { this.viewHiddenForcedEl = null; return; }
		if (this.viewHiddenForcedEl === el) return;   // already handled this open
		try {
			if (chooser.viewHidden === false) {
				chooser.viewHidden = true;
				log("Production chooser: 'View Hidden' forced on while paused.");
			}
			this.viewHiddenForcedEl = el;
		} catch (e) { /* chooser internals changed; leave it alone */ }
	}
	restoreProductionChooser() {
		const chooser = document.querySelector("panel-production-chooser")?.maybeComponent;
		if (chooser && this.viewHiddenForcedEl) {
			try { chooser.viewHidden = false; } catch (e) { /* ignore */ }
		}
		this.viewHiddenForcedEl = null;
	}

	onPoll() {
		if (this.state !== STATE.PAUSED) return;
		this.syncProductionChooser();

		// The pause menu is a reactive (SolidJS) screen; if a re-render dropped our
		// injected buttons while it is open, put them back. Also re-inject when the
		// "Drop Disconnected & Resume" button needs to appear/disappear (a player
		// dropped or reconnected while the menu was already open).
		if (this.pauseMenuIsOpen()) {
			const needDrop = this.amHost() && this.canHostKick() && this.disconnectedIds().length > 0;
			const haveDrop = !!document.getElementById(DROP_RESUME_BUTTON_ID);
			const c = document.querySelector(PAUSE_MENU_CONTAINER);
			if (c && (!document.getElementById(VIEW_MAP_BUTTON_ID) || needDrop !== haveDrop)) this.injectMenuButtons(c);
			else if (c) this.raiseGamePauseButton(c);
		}
		this.refreshStatus();
	}
	beginCountdown() {
		if (this.state === STATE.COUNTDOWN) return;
		this.state = STATE.COUNTDOWN;
		this.finalizing = false;
		this.stopPoll();
		this.closePauseMenu();
		// Keep the game PAUSED during the countdown: re-assert our flag immediately
		// (the last flag-clear briefly unpaused the engine to fire this event). The
		// real unpause only happens in finalizeResume().
		if (!this.iHoldFlag) { this.iHoldFlag = true; this.toggleEnginePause(); }
		this.applyProgressFilters();

		this.overlay.show(true);
		let remaining = CONFIG.resumeCountdownSeconds;
		const tick = () => {
			if (remaining <= 0) { this.finalizeResume(); return; }
			this.overlay.setValue(remaining);
			remaining -= 1;
			this.countdownTimer = setTimeout(tick, 1000);
		};
		tick();
	}
	// Countdown hit zero: release our flag. The game truly resumes only once every
	// client's countdown has finished and all flags are cleared.
	finalizeResume() {
		if (this.countdownTimer) { clearTimeout(this.countdownTimer); this.countdownTimer = 0; }
		this.finalizing = true;
		// The players chose to resume; accept AI control of anyone still absent so we
		// don't instantly re-pause them. A NEW disconnect later still pauses.
		for (const id of this.watchedHumans) {
			if (!isConnected(id)) this.acknowledged[id] = true;
		}
		this.overlay.show(false);
		if (this.iHoldFlag) { this.iHoldFlag = false; this.toggleEnginePause(); }
		this.backstopTimer = setTimeout(() => this.settleCountdown(), CONFIG.finalizeBackstopMs);
	}
	/**
	 * The unpause event was missed, or someone paused again during the countdown
	 * (such as a player rejoining): settle on the engine's own state.
	 */
	settleCountdown() {
		if (this.state !== STATE.COUNTDOWN) return;
		const pausedAgain = this.numWantPause() > 0;
		this.enterIdle();
		if (pausedAgain) this.enterPaused();
	}
	enterIdle() {
		this.state = STATE.IDLE;
		this.stopPoll();
		if (this.countdownTimer) { clearTimeout(this.countdownTimer); this.countdownTimer = 0; }
		if (this.backstopTimer) { clearTimeout(this.backstopTimer); this.backstopTimer = 0; }
		this.overlay.show(false);
		this.clearProgressFilters();
		const nativeResume = document.querySelector(NATIVE_RESUME_BUTTON);
		if (nativeResume) nativeResume.style.display = "";
		this.iHoldFlag = false;
		this.finalizing = false;
		this.pauseReason = "";
		this.pausedBy = [];
		this.disconnectNotices = [];
		this.restoreProductionChooser();
		this.removeFooterReady();
		this.startMenuListener();
	}

	// ============ Disconnect protection (no AI takeover) - THREE LAYERS =========
	// The single most important guarantee: when a human drops, the game must be
	// paused BEFORE the AI takes their turn. A UI mod cannot run code inside the
	// engine's AI turn-processing, so we defend at every UI hook the engine gives
	// us, all funnelling into requestDisconnectPause():
	//   1. The "MultiplayerPostPlayerDisconnected" event (reactive).
	//   2. A connection watchdog that polls Network.isPlayerConnected (proactive,
	//      catches drops even if the event is late or missed).
	//   3. A turn-activation guard: at the instant ANY turn begins, if a human is
	//      disconnected we pause first - this is the exact moment the engine would
	//      otherwise hand the absent player's turn to the AI.

	/**
	 * True if any monitored human slot is disconnected AND has not been
	 * deliberately resumed past. The initial drop always trips this; once the
	 * players consciously resume with someone absent we "acknowledge" them so the
	 * turn guard does not fight that choice (a fresh drop later still trips it).
	 */
	disconnectedHumanExists() {
		const ids = this.watchedHumans.length ? this.watchedHumans : humanParticipantIds();
		return ids.some((id) => !this.acknowledged[id] && !isConnected(id));
	}

	/** Shared entry point: pause now (before AI) if we are idle and not at endgame. */
	requestDisconnectPause(reason) {
		if (this.state !== STATE.COUNTDOWN) this.pauseReason = reason;   // record on every client
		if (this.state !== STATE.IDLE) { this.refreshStatus(); return; }
		if (this.numWantPause() > 0) { this.refreshStatus(); return; }
		try { if (document.querySelector("#screen-endgame")) return; } catch (e) {}
		this.iHoldFlag = true;
		this.toggleEnginePause();
		log("Auto-paused before AI takeover: " + reason);
	}

	// Layer 1 - engine disconnect event.
	onPlayerDisconnected(data) {
		if (!this.isMultiplayer) return;
		let id = null;
		try { id = data && (data.player ?? data.playerID ?? data.data ?? null); } catch (e) {}
		let name = "";
		try { name = this.composePlayerName(data && (data.playerNameT2gp || data.playerName1Pgp)); } catch (e) {}
		if (!name && id !== null) name = this.playerNameById(id);
		this.addDisconnectNotice(id, name);
		this.requestDisconnectPause("");
	}

	// Layer 2 - connection watchdog (polled).
	/** Add newly present participants to the watch set (covers hot-join). */
	watchParticipants() {
		for (const id of humanParticipantIds()) {
			if (this.watchedHumans.includes(id)) continue;
			this.watchedHumans.push(id);
			this.connState[id] = isConnected(id);
		}
	}
	startConnectionWatch() {
		if (this.connectionTimer) return;
		this.watchParticipants();
		this.connectionTimer = setInterval(() => this.checkConnections(), CONFIG.connectionWatchMs);
	}
	/** Polled: connection edges of the watched players (the set is refreshed each turn and on reconnects). */
	checkConnections() {
		for (const id of this.watchedHumans) {
			const connected = isConnected(id);
			const was = this.connState[id];
			this.connState[id] = connected;
			if (was === true && connected === false) {   // newly dropped (edge) -> pause once
				this.addDisconnectNotice(id, this.playerNameById(id));
				this.requestDisconnectPause("");
			}
		}
	}
	onPlayerConnected(payload) {
		let id = null;
		try { id = payload && (payload.data !== undefined ? payload.data : payload.player); } catch (e) {}
		if (id === undefined || id === null) return;
		if (!this.watchedHumans.includes(id)) this.watchedHumans.push(id);
		this.connState[id] = true;       // reconnected -> a later drop is a fresh edge
		delete this.acknowledged[id];    // and is eligible to pause again if it drops
		this.removeDisconnectNotice(id);
		// A rejoin forces every client through a resync/reload; make sure the game
		// is paused and the pause menu is up on everyone's screen for its duration.
		const reason = Locale.compose(LOC.playerReconnecting, this.playerNameById(id) || Locale.compose(LOC.aPlayer));
		if (this.state === STATE.IDLE) {
			this.requestDisconnectPause(reason);
		} else {
			this.pauseReason = reason;
			this.openPauseMenu();
			this.refreshStatus();
		}
	}

	/**
	 * Host migration: when the host drops or changes, the pause guarantee must
	 * survive the switch. Pause (if running), re-render the menu so the new
	 * host's controls appear, and refresh every client's hint text.
	 */
	onHostMigrated(data) {
		if (!this.isMultiplayer) return;
		const reason = Locale.compose(LOC.hostChanged);
		if (this.state === STATE.IDLE) this.requestDisconnectPause(reason);
		else this.pauseReason = reason;
		// Captions depend on amHost(): rebuild the injected buttons now if the menu is open.
		document.querySelectorAll(".bbm-injected").forEach((el) => el.remove());
		if (this.pauseMenuIsOpen()) this.tryInjectWhenMenuReady(0);
		this.refreshStatus();
	}

	// Layer 3 - turn-activation guard (the moment of AI takeover).
	onTurnActivated() {
		if (!this.isMultiplayer) return;
		this.watchParticipants();
		if (this.state !== STATE.IDLE) return;
		if (this.disconnectedHumanExists()) {
			this.requestDisconnectPause(Locale.compose(LOC.playerIsDisconnected));
		}
	}

	// ================================ Lifecycle ================================
	/**
	 * The pause menu stands in for the game's pause curtain, which would cover
	 * the map and close the menu on every flag change; its pause sound stays.
	 */
	suppressGameCurtain() {
		wrapMethod(MultiplayerIngame, "attachMultiplayerPauseCurtain", () => {});
		wrapMethod(MultiplayerIngame, "onMultiplayerPause", () => {
			Audio.playSound(Configuration.getGame().isPaused ? "data-audio-resume" : "data-audio-pause", "multiplayer-pause");
		});
	}
	onReady() {
		if (CONFIG.enabled === false) return;
		this.isMultiplayer = isMultiplayerGame();
		if (!this.isMultiplayer) return;
		InputFilterManager.allowFilters = true;
		this.injectStyles();
		this.overlay.build();
		engine.on("GamePauseStateChanged", this.gamePauseStateChangedListener);
		// Disconnect protection layers (see "Disconnect protection" section).
		engine.on("MultiplayerPostPlayerDisconnected", this.playerDisconnectedListener);
		engine.on("MultiplayerPlayerConnected", this.playerConnectedListener);
		engine.on("MultiplayerHostMigrated", this.hostMigratedListener);
		engine.on("PlayerTurnActivated", this.playerTurnActivatedListener);
		engine.on("RemotePlayerTurnBegin", this.playerTurnActivatedListener);
		this.suppressGameCurtain();
		// Host-authoritative resume: honor a RESUME command only when it came from
		// the host, then clear our own flag so the game unpauses in sync.
		BBMNet.on("RESUME", (d) => { if (BBMNet.isFromHost(d.from)) this.onRemoteResume(); });
		this.startConnectionWatch();
		if (this.numWantPause() > 0) this.onGamePauseStateChanged({ data: 1 });
		else this.enterIdle();
	}
}

const MultiplayerPause = new MultiplayerPauseManager();
export { MultiplayerPause as default };
