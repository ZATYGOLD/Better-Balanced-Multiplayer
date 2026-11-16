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
 * Better Balanced Multiplayer - Lobby tooltips and start countdown (shell scope).
 *
 * The game-setup civilization and leader tooltips show each ability's text
 * but omit its name; the lobby model's two tooltip builders are wrapped to
 * insert the ability title above the text (a runtime patch rather than a
 * replacement of model-mp-staging-new.js, so it survives game patches). With
 * Game Balance Multiplayer they swap the game's text of the civilization's or
 * leader's items for the balanced copies (bbm-lobby-balance-text.js), without
 * relying on Locale, and the model's cached tooltips are dropped whenever the
 * Game Balance text changes. The all-ready start countdown
 * is shortened, and its ring rescaled to match. The lobby is multiplayer only.
 */
import { MPLobbyDataModel } from 'fs://game/core/ui/shell/mp-staging/model-mp-staging-new.js';
import { GetCivilizationData } from 'fs://game/core/ui/shell/create-panels/age-civ-select-model.js';
import { getLeaderData } from 'fs://game/core/ui/shell/create-panels/leader-select-model.js';
import { createLogger, whenDefined, wrapMethod } from '../shared/bbm-util.js';
import { balancedTag, gameText, isBalancedText } from './bbm-lobby-balance-text.js';
import { CONFIG } from './bbm-lobby-config.js';

const log = createLogger('lobby');
const LOBBY_TAG = "screen-mp-lobby";
const STOCK_COUNTDOWN_SECONDS = 10;   // the lobby template's hard-coded ring maximum

// ============================ Start countdown ============================

/** The model reads this static each time the countdown begins. */
function shortenCountdown() {
	MPLobbyDataModel.ALL_READY_COUNTDOWN = CONFIG.startCountdownSeconds * 1000;
	if (CONFIG.startCountdownSeconds === STOCK_COUNTDOWN_SECONDS) return;
	whenDefined(LOBBY_TAG, (definition) => {
		wrapMethod(definition.createInstance.prototype, "onAttach", function (base, ...args) {
			const result = base(...args);
			try {
				for (const ring of this.Root?.querySelectorAll?.(".mp-staging__ring-meter") ?? []) ring.setAttribute("max-value", String(CONFIG.startCountdownSeconds));
			} catch (e) { /* leave the ring as is */ }
			return result;
		});
	});
}

// ============================ Ability titles ============================

/**
 * Inserts the styled ability title above the ability text. Idempotent: the
 * base model caches tooltip fragments, so a tooltip that already carries the
 * title is returned untouched.
 */
function withAbilityTitle(tooltip, abilityTitle, abilityText) {
	if (!tooltip || !abilityTitle || !abilityText) return tooltip;
	const title = Locale.compose(abilityTitle);
	const text = Locale.compose(abilityText);
	if (!title || !text || tooltip.includes(title)) return tooltip;
	return tooltip.replace(text, `[STYLE:${CONFIG.titleStyle}][B]${title}[/B][/S][N]${text}`);
}

/**
 * Ability title and text per civ / leader id from the setup data, which is
 * expensive to build: read once, and again only for an id not seen before.
 */
const abilityCache = { civ: null, leader: null };
const missedIds = new Set();
function readAbilities(kind) {
	const rows = kind === "civ" ? GetCivilizationData(false) : getLeaderData(false);
	abilityCache[kind] = new Map(rows.map((row) => [String(kind === "civ" ? row.civID : row.leaderID), { title: row.abilityTitle, text: row.abilityText }]));
}
function abilityOf(kind, id) {
	const key = String(id);
	if (!abilityCache[kind] || (!abilityCache[kind].has(key) && !missedIds.has(kind + key))) {
		readAbilities(kind);
		if (!abilityCache[kind].has(key)) missedIds.add(kind + key);
	}
	return abilityCache[kind].get(key);
}

// ============================ Game Balance text ============================

/** Name and description tags of each civilization's and leader's items (CivilizationItems, LeaderItems), read once. */
let itemTags = null;
function itemTagsOf(type) {
	if (!itemTags) {
		itemTags = new Map();
		const queries = ["SELECT CivilizationType AS Type, Name, Description FROM CivilizationItems", "SELECT LeaderType AS Type, Name, Description FROM LeaderItems"];
		for (const sql of queries) {
			let rows = [];
			try { rows = Database.query("config", sql) ?? []; } catch (e) { log(`items not read: ${e}`); }
			for (const row of rows) {
				if (!itemTags.has(row.Type)) itemTags.set(row.Type, new Set());
				for (const tag of [row.Name, row.Description]) if (tag) itemTags.get(row.Type).add(tag);
			}
		}
	}
	return itemTags.get(String(type)) ?? [];
}

/** Game text -> balanced text per tag, composed once (the text is fixed for the shell session). */
const textPairs = new Map();
function textPair(tag, copy) {
	if (!textPairs.has(tag)) textPairs.set(tag, [gameText(tag), gameText(copy)]);
	return textPairs.get(tag);
}

/** The tooltip with the game's text of the type's items swapped for their balanced copies (when Game Balance Multiplayer applies). */
function withBalancedText(tooltip, type) {
	if (!tooltip) return tooltip;
	for (const tag of itemTagsOf(type)) {
		const copy = balancedTag(tag);
		if (copy === tag) continue;
		const [from, to] = textPair(tag, copy);
		if (from && from !== to) tooltip = tooltip.split(from).join(to);
	}
	return tooltip;
}

/** Drops the model's cached tooltips when Game Balance switches between the game's and the balanced text. */
function syncBalanceText(model) {
	const balanced = isBalancedText();
	if (model.bbmBalancedText === balanced) return;
	model.bbmBalancedText = balanced;
	model.cachedLeaderTooltips?.clear();
	model.cachedCivilizationTooltipFragments?.clear();
}

function patchTooltips() {
	const proto = MPLobbyDataModel.prototype;
	wrapMethod(proto, "getCivilizationTooltip", function (base, civilizationType, ...rest) {
		syncBalanceText(this);
		const ability = abilityOf("civ", civilizationType);
		const tooltip = withBalancedText(base(civilizationType, ...rest), civilizationType);
		return withAbilityTitle(tooltip, balancedTag(ability?.title), balancedTag(ability?.text));
	});
	wrapMethod(proto, "getLeaderTooltip", function (base, leaderType, ...rest) {
		syncBalanceText(this);
		const ability = abilityOf("leader", leaderType);
		const tooltip = withBalancedText(base(leaderType, ...rest), leaderType);
		return withAbilityTitle(tooltip, balancedTag(ability?.title), balancedTag(ability?.text));
	});
}

try {
	if (CONFIG.startCountdownSeconds > 0) shortenCountdown();
	patchTooltips();
} catch (e) { log(`lobby patches failed: ${e}`); }
