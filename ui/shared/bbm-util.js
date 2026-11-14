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
 * Better Balanced Multiplayer - shared helpers (shell and game scope).
 *
 * Logging, method wrapping, deferred patching and the decorator base used by
 * every feature, plus the multiplayer, Game Balance and Age transition checks and
 * companion-mod detection (Observer, enabled mods).
 */

/** Logger that reaches UI.log (console.log output does not). */
function createLogger(tag) {
	return (message) => { try { console.warn(`BBM ${tag}: ${message}`); } catch (e) { /* ignore */ } };
}

/**
 * Replace target[name] with wrapper(base, ...args). The wrapper runs with the
 * call's receiver as `this`, and base calls the original on that receiver, so
 * it works for singletons and prototypes alike.
 */
function wrapMethod(target, name, wrapper) {
	const base = target?.[name];
	if (typeof base !== "function") return false;
	target[name] = function (...args) { return wrapper.call(this, (...a) => base.apply(this, a), ...args); };
	return true;
}

/**
 * Run callback(value) once probe() returns a value other than null/undefined,
 * retrying a bounded number of times; onGiveUp runs if it never does.
 */
function whenAvailable(probe, callback, { retries = 50, intervalMs = 200, onGiveUp = null } = {}) {
	let value = null;
	try { value = probe(); } catch (e) { value = null; }
	if (value != null) { callback(value); return; }
	if (retries > 0) setTimeout(() => whenAvailable(probe, callback, { retries: retries - 1, intervalMs, onGiveUp }), intervalMs);
	else onGiveUp?.();
}

const pendingDefinitions = new Map();   // tag -> callbacks waiting for the game to define it
let defineWrapped = false;

/**
 * Run callback(definition) once the UI component tag is defined: now, or the
 * moment the game's Controls.define call for it runs (before any element is built).
 */
function whenDefined(tag, callback) {
	if (Controls.isDefined(tag)) {
		callback(Controls.getDefinition(tag));
		return;
	}
	if (!defineWrapped) {
		defineWrapped = true;
		wrapMethod(Controls, "define", (base, name, ...rest) => {
			const result = base(name, ...rest);
			const callbacks = pendingDefinitions.get(name);
			if (callbacks) {
				pendingDefinitions.delete(name);
				callbacks.forEach((fn) => fn(Controls.getDefinition(name)));
			}
			return result;
		});
	}
	if (!pendingDefinitions.has(tag)) pendingDefinitions.set(tag, []);
	pendingDefinitions.get(tag).push(callback);
}

/** True in a multiplayer game or setup (hotseat included); every mod feature acts only then. */
function isMultiplayerGame() {
	try { return !!Configuration.getGame()?.isAnyMultiplayer; } catch (e) { return false; }
}

/** True when Game Balance is Multiplayer (game scope), so the mod's balance data is loaded. */
function isBalanceOn() {
	try { return Configuration.getGame().getValue("BBMBalance") === "BBM_BALANCE_MULTIPLAYER"; } catch (e) { return false; }
}

/** True while an Age transition is in progress. */
function isAgeTransition() {
	try { return Modding.getTransitionInProgress?.() === TransitionType.Age; } catch (e) { return false; }
}

/**
 * True from the moment a non-final Age is complete (its progress is full, the
 * HUD's action turns into the Age transition) until the next Age loads.
 */
function isAgeEnding() {
	try {
		if (isAgeTransition()) return true;
		const ages = Game.AgeProgressManager;
		if (!ages || ages.isFinalAge || ages.isExtendedGame) return false;
		const max = ages.getMaxAgeProgressionPoints();
		return !!ages.isAgeOver || (max > 0 && ages.getCurrentAgeProgressionPoints() >= max);
	} catch (e) { return false; }
}

/**
 * Observer leaders of companion mods (Zatygold's Spectator): real players
 * who watch instead of play, so the timer and the pause treat them apart.
 */
const OBSERVER_LEADERS = new Set(["LEADER_ZOM_OBSERVER"]);

/** True for a companion mod's Observer; cached per player id (a player's leader is fixed for the life of the UI). */
const observerById = new Map();
function isObserverPlayer(playerId) {
	if (observerById.has(playerId)) return observerById.get(playerId);
	try {
		const leader = GameInfo.Leaders.lookup(Players.get(playerId)?.leaderType);
		if (!leader) return false;   // not resolvable yet: ask again next time
		const observer = OBSERVER_LEADERS.has(leader.LeaderType);
		observerById.set(playerId, observer);
		return observer;
	} catch (e) { return false; }
}

const OBSERVER_CIV_PREFIX = "CIVILIZATION_ZOM_OBSERVER_";

/** True for a companion mod's Observer leader or civilization as a setup value. */
function isObserverValue(value) {
	return OBSERVER_LEADERS.has(value) || (typeof value === "string" && value.startsWith(OBSERVER_CIV_PREFIX));
}

/** Base for Controls.decorate decorators: the panel calls all four hooks, so a decorator overrides only those it uses. */
class Decorator {
	beforeAttach() {}
	afterAttach() {}
	beforeDetach() {}
	afterDetach() {}
}

/** Mod ids of companion mods this one adapts to. */
const COMPANION_MODS = { spectator: "zatygolds-observer-mode" };

/** True while the mod with this .modinfo id is enabled (shell scope). */
function isModEnabled(modId) {
	try { return Modding.getInstalledMods().some((mod) => mod.enabled && mod.id === modId); } catch (e) { return false; }
}

export { COMPANION_MODS, Decorator, createLogger, isAgeEnding, isAgeTransition, isBalanceOn, isModEnabled, isMultiplayerGame, isObserverPlayer, isObserverValue, whenAvailable, whenDefined, wrapMethod };
