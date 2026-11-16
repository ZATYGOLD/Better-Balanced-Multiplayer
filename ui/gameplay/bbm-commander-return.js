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
 * Better Balanced Multiplayer - Commander return at the end of an Age (game scope).
 *
 * A defeated Commander still waiting to return when an Age ends never comes back:
 * the Age transition only places Commanders that are on the map. While an Age is
 * ending, the host (in hotseat, the one machine) returns each waiting Commander to
 * its owner's Capital, or a Fleet Commander to open ocean, with Units.setLocation
 * as the base Age transition places Commanders. Multiplayer only.
 */
import { createLogger, isAgeEnding, isGameAuthority, isMultiplayerGame } from '../shared/bbm-util.js';

const log = createLogger('commander return');

/** Open ocean for a Fleet Commander when the game finds some, else the Capital (null without one). */
function returnLocation(player, unit) {
	if (unit.isFleetCommander) {
		let index = -1;
		try { index = Game.PlacementRules.getValidOceanNavalLocation(player.id); } catch (e) { index = -1; }
		if (index >= 0) return GameplayMap.getLocationFromIndex(index);
	}
	return player.Cities?.getCapital()?.location ?? null;
}

function returnWaitingCommanders() {
	if (!isAgeEnding() || !isGameAuthority()) return;
	for (const playerId of Players.getAliveMajorIds()) {
		const player = Players.get(playerId);
		for (const unit of player?.Units?.getUnits() ?? []) {
			if (!unit.isCommanderUnit || unit.isOnMap || !(unit.getTimeoutReturn > 0)) continue;
			const location = returnLocation(player, unit);
			if (!location) continue;
			const turnsLeft = unit.getTimeoutReturn;
			Units.setLocation(unit.id, location);
			log(`turn ${Game.turn}: Commander ${unit.id.id} of player ${playerId} returned to ${location.x},${location.y} (${turnsLeft} turns early)`);
		}
	}
}

engine.whenReady.then(() => {
	if (!isMultiplayerGame()) return;
	engine.on("TurnBegin", returnWaitingCommanders);
	engine.on("AgeProgressionChanged", returnWaitingCommanders);
	engine.on("GameAgeEnded", returnWaitingCommanders);
});
