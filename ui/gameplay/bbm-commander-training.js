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
 * Better Balanced Multiplayer - Commander training (game scope).
 *
 * At the start of each turn, every Commander standing on a completed Military
 * Building in one of its owner's own Settlements gains 2 XP. Modifiers can grant XP
 * only once, so the host (the local player outside multiplayer) awards it through
 * Units.changeExperience. Game Balance Multiplayer only.
 */
import { createLogger } from '../shared/bbm-util.js';

const log = createLogger('commander training');
const TRAINING_XP = 2;   // once per Commander per turn, however many Military Buildings share its tile
const MILITARY_TAG = "MILITARY";
const BALANCE_MULTIPLAYER = "BBM_BALANCE_MULTIPLAYER";

let lastTurn = -1;   // one award per turn, even if TurnBegin repeats
let militaryTypes = null;

function isBalanceOn() {
	try { return Configuration.getGame().getValue("BBMBalance") === BALANCE_MULTIPLAYER; } catch (e) { return false; }
}

function isAuthority() {
	if (!Configuration.getGame().isAnyMultiplayer) return true;
	return Network.getHostPlayerId() === GameContext.localPlayerID;
}

/** Constructible types tagged MILITARY (Military Buildings of every Age), read once. */
function militaryConstructibleTypes() {
	if (!militaryTypes) {
		militaryTypes = new Set();
		for (const row of GameInfo.TypeTags) if (row.Tag === MILITARY_TAG) militaryTypes.add(row.Type);
	}
	return militaryTypes;
}

function isOnOwnMilitaryBuilding(unit) {
	if (!unit?.isOnMap || !unit.location) return false;
	const { x, y } = unit.location;
	if (GameplayMap.getOwner(x, y) !== unit.owner) return false;
	const types = militaryConstructibleTypes();
	return MapConstructibles.getHiddenFilteredConstructibles(x, y).some((id) => {
		const constructible = Constructibles.getByComponentID(id);
		if (!constructible?.complete || constructible.owner !== unit.owner) return false;
		return types.has(GameInfo.Constructibles.lookup(constructible.type)?.ConstructibleType);
	});
}

function awardTrainingXp() {
	if (Game.turn === lastTurn || !isAuthority()) return;
	lastTurn = Game.turn;
	for (const playerId of Players.getAliveMajorIds()) {
		for (const unit of Players.get(playerId)?.Units?.getUnits() ?? []) {
			if (!unit.isCommanderUnit || !isOnOwnMilitaryBuilding(unit)) continue;
			Units.changeExperience(unit.id, TRAINING_XP);
			log(`turn ${Game.turn}: +${TRAINING_XP} XP to Commander ${unit.id.id} of player ${playerId}`);
		}
	}
}

engine.whenReady.then(() => {
	if (!isBalanceOn()) return;
	engine.on("TurnBegin", awardTrainingXp);
});
