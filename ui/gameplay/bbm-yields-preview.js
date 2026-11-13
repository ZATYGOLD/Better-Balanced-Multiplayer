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
 * Better Balanced Multiplayer - Policy Yield Previews support (game scope).
 *
 * The Policy Yield Previews mod can't evaluate Commander Promotion counts, so it
 * shows +0 for the Militaristic garrison node. When that mod is enabled, the node's
 * card shows BBM's own preview instead, drawn with the mod's public API
 * (globalThis.LfYieldsPreview). Game Balance Multiplayer only.
 */
import { Decorator, createLogger, isBalanceOn, wrapMethod } from '../shared/bbm-util.js';

const log = createLogger('yields preview');
const GARRISON_NODE = "NODE_ATTRIBUTE_MILITARISTIC_06";
const GARRISON_MODIFIER_PREFIX = "BBM_BALANCE_MOD_ATTRIBUTE_MILITARISTIC_GARRISON_";
const GARRISON_DISTRICTS = new Set(["DISTRICT_CITY_CENTER", "DISTRICT_URBAN"]);
const GARRISON_YIELDS = ["YIELD_SCIENCE", "YIELD_CULTURE"];

const patchedProtos = new WeakSet();
let promotionCap = null;

/** Promotions that count per Commander: one node unlock per Promotion tier. */
function garrisonPromotionCap() {
	if (promotionCap === null) {
		promotionCap = 0;
		for (const row of GameInfo.ProgressionTreeNodeUnlocks) {
			if (row.ProgressionTreeNodeType === GARRISON_NODE && row.TargetType.startsWith(GARRISON_MODIFIER_PREFIX)) promotionCap++;
		}
	}
	return promotionCap;
}

/** True for a unit stationed on one of its owner's City Centers or urban districts. */
function isGarrisoned(unit) {
	if (!unit?.isOnMap || !unit.location) return false;
	const { x, y } = unit.location;
	if (GameplayMap.getOwner(x, y) !== unit.owner) return false;
	const districtId = MapCities.getDistrict(x, y);
	const district = districtId ? Districts.get(districtId) : null;
	return !!district && GARRISON_DISTRICTS.has(GameInfo.Districts.lookup(district.type)?.DistrictType);
}

/** +1 of each garrison yield per Promotion of every garrisoned Commander, as a YieldsPreviewResult. */
function garrisonPreview() {
	const cap = garrisonPromotionCap();
	let amount = 0;
	for (const unit of Players.get(GameContext.localPlayerID)?.Units?.getUnits() ?? []) {
		if (unit.isCommanderUnit && isGarrisoned(unit)) amount += Math.min(unit.Experience?.getNumPromotions ?? 0, cap);
	}
	log(`garrison node preview: +${amount} per yield`);
	const yields = {};
	for (const yieldType of GARRISON_YIELDS) yields[yieldType] = amount;
	return { yields, modifiers: [], isValid: true };
}

/** Replace the preview box the Policy Yield Previews mod built for the garrison node. */
function showGarrisonPreview(card, api) {
	const box = api.renderYieldsPreviewBox(garrisonPreview());
	card.yieldsContainer?.parentNode?.replaceChild(box, card.yieldsContainer);
	card.yieldsContainer = box;
}

/** Redraw the garrison card's preview after each type change, deferred so it lands after the Policy Yield Previews mod's own. */
function patchCardClass(proto, api) {
	if (patchedProtos.has(proto)) return;
	patchedProtos.add(proto);
	wrapMethod(proto, 'onAttributeChanged', function (base, name, ...rest) {
		base(name, ...rest);
		if (name === 'type' && isGarrisonCard(this)) queueMicrotask(() => refreshPreview(this, api));
	});
	log('attribute cards patched');
}

/** The card's type attribute may hold the node's hash, so resolve it as the Policy Yield Previews mod does. */
function isGarrisonCard(card) {
	return GameInfo.ProgressionTreeNodes.lookup(card.type)?.ProgressionTreeNodeType === GARRISON_NODE;
}

function refreshPreview(card, api) {
	try { showGarrisonPreview(card, api); } catch (e) { log(`preview failed: ${e}`); }
}

class GarrisonPreview extends Decorator {
	constructor(card) {
		super();
		this.card = card;
		this.api = isBalanceOn() ? globalThis.LfYieldsPreview : null;
		if (this.api) patchCardClass(Object.getPrototypeOf(card), this.api);
	}

	afterAttach() {
		if (this.api && isGarrisonCard(this.card)) refreshPreview(this.card, this.api);
	}
}

Controls.decorate('attribute-card', (card) => new GarrisonPreview(card));
