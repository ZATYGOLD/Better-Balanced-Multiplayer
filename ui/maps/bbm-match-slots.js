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
 * Better Balanced Multiplayer - Lobby match slots (shell scope).
 *
 * Host, new games: team placements open exactly their players (Duel 2, 2v2 4,
 * 3v3 6, 4v4 8) on alternating teams 1-2-1-2 (Player Placement gives even slots
 * the West, odd slots the East), plus a last slot for Zatygold's Spectator
 * when its Spectator Slot setting is on (published as BBMSpectatorSlot; the
 * Spectator makes its player the Observer).
 * Slots past the count are closed. A Spectator on Tiny or Small needs one slot
 * more than the size allows, so the host launches the next size up and records
 * the chosen size (BBMChosenMapSize); the game data then builds the map at that
 * size (data/maps/chosen-size-*.sql).
 */
import { MPLobbyDataModel } from 'fs://game/core/ui/shell/mp-staging/model-mp-staging-new.js';
import { COMPANION_MODS, createLogger, isModEnabled, wrapMethod } from '../shared/bbm-util.js';
import { gameValue, sameValue } from '../shared/bbm-setup.js';
import { PLACEMENT_SETTING_KEY, PLAYERS_BY_PLACEMENT } from '../../maps/bbm-placement.js';

const log = createLogger('match slots');
const SIZE_PARAMETER = "MapSize";
const CHOSEN_SIZE_PARAMETER = "BBMChosenMapSize";
const NO_CHOSEN_SIZE = "BBM_MAPS_CHOSEN_SIZE_NONE";
const SPECTATOR_SLOT_PARAMETER = "BBMSpectatorSlot";
const SPECTATOR_SLOT_SETTING = "ZOMSpectatorSlot";   // the Spectator's own setup setting
const NO_SLOT = -1;
const NO_TEAM = -1;
const TEAM_COUNT = 2;
const SLOT_SWEEP_END = 16;   // past any lobby's slots: every player id that can hold a configuration
/** Map size -> the size launched when it holds one player more than it allows. */
const LAUNCH_SIZE = { MAPSIZE_TINY: "MAPSIZE_SMALL", MAPSIZE_SMALL: "MAPSIZE_STANDARD" };
const LAUNCH_DELAY_MS = 1000;    // lets the switched size reach every client before the load
const RELAUNCH_RESET_MS = 30000; // back in the lobby this long after a launch: the load did not happen
const spectatorEnabled = isModEnabled(COMPANION_MODS.spectator);
/** 1 while the Spectator is enabled and its Spectator Slot setting is on. */
const spectatorSlots = () => (spectatorEnabled && !sameValue(false, gameValue(SPECTATOR_SLOT_SETTING)) ? 1 : 0);

let managed = false;
let launching = false;

/** The Match Type's Player Placement (a hidden setting, read from the map configuration). */
function placement() {
	try {
		const raw = Configuration.getMap().getValue(PLACEMENT_SETTING_KEY);
		return typeof raw === "number" ? GameSetup.resolveString(raw) : raw;
	} catch (e) { return undefined; }
}

/** The map size's own player limit from the setup database, cached once found (each lobby update reads it). */
const sizeLimits = new Map();
function sizeLimit(mapSize) {
	if (sizeLimits.has(mapSize)) return sizeLimits.get(mapSize);
	let limit = 0;
	try {
		const rows = Database.query("config", "SELECT MaxPlayers FROM MapSizes WHERE MapSizeType = ?1 ORDER BY MaxPlayers DESC LIMIT 1", mapSize) ?? [];
		limit = rows[0]?.MaxPlayers ?? rows[0]?.[0] ?? 0;
	} catch (e) { limit = 0; }
	if (limit > 0) sizeLimits.set(mapSize, limit);
	return limit;
}

function participants() {
	try { return Configuration.getGame().getParticipatingPlayerCount(true, false, false, true); } catch (e) { return 0; }
}

const hostOfNewGame = () => MPLobbyDataModel.isNewGame && MPLobbyDataModel.isLocalHostPlayer();

/** Slots for the size and placement; 0 leaves the game's own count. */
function targetSlots(mapSize) {
	const limit = sizeLimit(mapSize);
	const launchLimit = sizeLimit(LAUNCH_SIZE[mapSize] ?? mapSize);
	const players = PLAYERS_BY_PLACEMENT[placement()] ?? 0;
	const extra = spectatorSlots();
	if (players > 0) return Math.min(players + extra, launchLimit);
	if (extra && LAUNCH_SIZE[mapSize]) return limit + extra;
	return managed ? limit : 0;   // back to the size's own count once a placement no longer sets it
}

/** Open the closed slots within the count and close the computer slots past it, so no hidden computer player starts. */
function fitSlots(count) {
	for (let id = 0; id < SLOT_SWEEP_END; id++) {
		const player = Configuration.getPlayer(id);
		if (!player || player.isHuman) continue;
		const closed = player.slotStatus === SlotStatus.SS_CLOSED;
		if (id < count && closed) Configuration.editPlayer(id)?.setSlotStatus(SlotStatus.SS_OPEN);
		else if (id >= count && !closed) Configuration.editPlayer(id)?.setSlotStatus(SlotStatus.SS_CLOSED);
	}
}

function setTeam(id, team) {
	if (Configuration.getPlayer(id)?.team !== team) Configuration.editPlayer(id)?.setTeam(team);
}

let teamsManaged = false;
let publishedSpectatorSlot;
/** Publish the Spectator's slot; a newly kept slot opens for a human to join. */
function publishSpectatorSlot(slot) {
	if (slot === publishedSpectatorSlot) return;
	publishedSpectatorSlot = slot;
	GameSetup.setGameParameterValue(SPECTATOR_SLOT_PARAMETER, slot);
	if (slot !== NO_SLOT && Configuration.getPlayer(slot)?.slotStatus === SlotStatus.SS_COMPUTER) {
		Configuration.editPlayer(slot)?.setSlotStatus(SlotStatus.SS_OPEN);
	}
}

/** Team placements: alternating teams by slot, the Spectator's slot last without a team. */
function syncTeams(slots) {
	const players = PLAYERS_BY_PLACEMENT[placement()] ?? 0;
	const spectatorSlot = players > 0 && spectatorSlots() && slots > players ? players : NO_SLOT;
	publishSpectatorSlot(spectatorSlot);
	if (players === 0) {
		if (teamsManaged) for (let id = 0; id < slots; id++) setTeam(id, NO_TEAM);
		teamsManaged = false;
		return;
	}
	teamsManaged = true;
	for (let id = 0; id < Math.min(players, slots); id++) setTeam(id, id % TEAM_COUNT);
	if (spectatorSlot !== NO_SLOT) setTeam(spectatorSlot, NO_TEAM);
}

function syncSlots() {
	if (launching || !hostOfNewGame()) return;
	const map = Configuration.getMap();
	const mapSize = map.mapSizeTypeName ?? "";
	const current = map.maxMajorPlayers ?? 0;
	const target = targetSlots(mapSize);
	managed = target > 0 && target !== sizeLimit(mapSize);
	if (target > 0 && current !== target) {
		Configuration.editMap()?.setMaxMajorPlayers?.(target);
		log(`${mapSize}: ${target} slots`);
	}
	if (target > 0) fitSlots(target);
	syncTeams(Configuration.getMap().maxMajorPlayers ?? 0);
}

/** When more players than the size allows will start, launch the next size up and remember the chosen one. */
function prepareLaunch() {
	const chosen = Configuration.getMap().mapSizeTypeName ?? "";
	const players = participants();
	const launchSize = LAUNCH_SIZE[chosen];
	GameSetup.setGameParameterValue(CHOSEN_SIZE_PARAMETER, NO_CHOSEN_SIZE);
	if (!launchSize || players <= sizeLimit(chosen)) return false;
	GameSetup.setGameParameterValue(CHOSEN_SIZE_PARAMETER, chosen);
	GameSetup.setGameParameterValue(SIZE_PARAMETER, launchSize);
	Configuration.editMap()?.setMaxMajorPlayers?.(players);   // no new open slot from the bigger size
	log(`${players} players on ${chosen}: launching as ${launchSize}`);
	return true;
}

wrapMethod(MPLobbyDataModel.prototype, "update", function (base, ...args) {
	try { syncSlots(); } catch (e) { log(`slot sync failed: ${e}`); }
	return base(...args);
});

const engineStartGame = Network.startGame;
wrapMethod(Network, "startGame", (base, ...args) => {
	if (launching || !hostOfNewGame()) return base(...args);
	let switched = false;
	try { switched = prepareLaunch(); } catch (e) { log(`launch size unchanged: ${e}`); }
	if (!switched) return base(...args);
	launching = true;   // the launch size must not get the extra slot back
	setTimeout(() => base(...args), LAUNCH_DELAY_MS);
	setTimeout(() => { if (MPLobbyDataModel.isNewGame) launching = false; }, RELAUNCH_RESET_MS);
	return undefined;
});
if (Network.startGame === engineStartGame) log("Network.startGame could not be wrapped; an extra Spectator slot cannot launch");
