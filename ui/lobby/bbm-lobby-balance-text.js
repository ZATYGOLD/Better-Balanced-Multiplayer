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
 * Better Balanced Multiplayer - Game Balance text in the multiplayer setup (shell scope).
 *
 * The balance text replaces the game's text in game only: replacing it in the
 * shell would change single player too. The shell instead holds a copy of each
 * replaced tag under LOC_BBM_LOBBY_ (text/en_us/balance-lobby.xml, built by
 * tools/build-lobby-text.py). While a multiplayer setup has Game Balance
 * Multiplayer, balancedTag maps a replaced tag to its copy. The lobby tooltips
 * and memento slots use it directly (bbm-lobby-tooltips.js, bbm-lobby-mementos.js),
 * so they never depend on the engine's Locale; Locale.compose, stylize and
 * plainText are wrapped with it too where the engine lets them be replaced,
 * which covers the leader, civilization and memento pickers.
 */
import { createLogger, isMultiplayerGame } from '../shared/bbm-util.js';
import { gameValue } from '../shared/bbm-setup.js';

const log = createLogger('balance text');
const PARAM_BALANCE = "BBMBalance";
const BALANCE_MULTIPLAYER = "BBM_BALANCE_MULTIPLAYER";
const COPY_PREFIX = "LOC_BBM_LOBBY_";
const TAG = /^LOC_[A-Z0-9_]+$/;
const CHECK_MS = 250;
// Locale methods that take a tag (and tag arguments).
const LOCALE_METHODS = ["compose", "stylize", "plainText"];

/** The game's Locale methods, kept before they are wrapped. */
const gameLocale = Object.fromEntries(LOCALE_METHODS.map((name) => [name, Locale[name]]));

/** A tag in the game's text, whichever Game Balance is set. */
const gameText = (tag, ...args) => gameLocale.compose.call(Locale, tag, ...args);

const hasKey = typeof Locale.keyExists === "function" ? (tag) => Locale.keyExists(tag) : (tag) => gameText(tag) !== tag;

let active = null;   // null until first read, so the first read logs
let nextCheck = 0;
const copies = new Map();   // tag -> its copy's tag, or null

/** Reads whether the balanced text applies (a multiplayer setup with Game Balance Multiplayer); logs each change. */
function isBalancedText() {
	nextCheck = Date.now() + CHECK_MS;
	let value = null;
	let balanced = false;
	try { value = gameValue(PARAM_BALANCE); balanced = isMultiplayerGame() && value === BALANCE_MULTIPLAYER; } catch (e) { balanced = false; }
	if (balanced !== active) log(`${balanced ? "showing the balanced text" : "showing the game's text"} (multiplayer ${isMultiplayerGame()}, Game Balance ${value})`);
	active = balanced;
	return balanced;
}

/** isBalancedText, read again at most every CHECK_MS (Locale runs it on every call). */
const balancedNow = () => (Date.now() >= nextCheck ? isBalancedText() : active);

/** A tag's copy when it has one; anything else unchanged. Each tag is looked up once. */
function copyOf(value) {
	if (typeof value !== "string" || !TAG.test(value) || value.startsWith(COPY_PREFIX)) return value;
	let copy = copies.get(value);
	if (copy === undefined) {
		const candidate = COPY_PREFIX + value.slice(4);
		copy = hasKey(candidate) ? candidate : null;
		copies.set(value, copy);
	}
	return copy ?? value;
}

/** The tag to show: its copy while the balanced text applies, else the tag itself. */
const balancedTag = (value) => (balancedNow() ? copyOf(value) : value);

/** Wraps the Locale methods; returns what took, for the load log. */
function wrapLocale() {
	return LOCALE_METHODS.map((name) => {
		const base = gameLocale[name];
		if (typeof base !== "function") return `${name} missing`;
		const wrapper = (text, ...args) => (balancedNow() ? base.call(Locale, copyOf(text), ...args.map(copyOf)) : base.call(Locale, text, ...args));
		try { Locale[name] = wrapper; } catch (e) { /* read-only */ }
		const descriptor = Object.getOwnPropertyDescriptor(Locale, name);
		if (Locale[name] !== wrapper && descriptor?.configurable) {
			try { Object.defineProperty(Locale, name, { value: wrapper, writable: true, configurable: true, enumerable: descriptor.enumerable }); } catch (e) { /* keep the game's */ }
		}
		if (Locale[name] === wrapper) return `${name} wrapped`;
		return `${name} not wrapped (${descriptor ? `own, writable ${descriptor.writable}, configurable ${descriptor.configurable}` : "inherited"})`;
	}).join(", ");
}

try {
	log(`loaded: Locale ${wrapLocale()}; keyExists ${typeof Locale.keyExists === "function" ? "native" : "by compose"}`);
} catch (e) { log(`Locale not wrapped: ${e}`); }

export { balancedTag, gameText, isBalancedText };
