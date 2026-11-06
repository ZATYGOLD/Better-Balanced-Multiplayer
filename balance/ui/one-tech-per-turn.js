/*
 * Multiplayer Toolkit - multiplayer quality-of-life features for Civilization VII.
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
 * Multiplayer Toolkit - Multiplayer Balance: one technology per turn (in-game scope).
 *
 * Normal research completes at most one technology per turn; leftover science
 * waits for the next turn. The engine resolves a queued target, and spends all
 * overflow on it, before any UI event fires, so the queue lives here instead:
 *   - the target the player queues is kept by this module (shown on the tech
 *     tree through the player's getTargetNode) and never handed to the engine;
 *   - the engine only ever researches the next node toward that target;
 *   - once a node completes, nothing else starts until the next turn.
 * Free technologies (a notification arrives with the completion) do not count.
 * Each client applies it to its own (local, human) player only.
 */
import { createLogger, wrapMethod } from '../../ui/mpt-shared/mpt-util.js';
import { BALANCE_CONFIG } from './balance-config.js';

const log = createLogger('one-tech-per-turn');
const debug = BALANCE_CONFIG.debug ? log : () => {};
const FREE_TECH_NOTIFICATION = 'NOTIFICATION_FREE_TECH_AWARDED';
const BLOCKED_REASON = 'LOC_MPT_BALANCE_ONE_TECH_PER_TURN';

/** The local player's research state. */
const state = {
  limitTurn: -1,       // turn on which a normal research completed
  pendingTurn: -1,     // a completion is being classified (normal or free)
  startedTurn: -1,     // turn on which this module started the next queued node
  researching: undefined,
  target: undefined,   // the queued target, kept here rather than by the engine
  freeTechAt: { turn: -1, time: 0 }
};

const engineOps = {};   // the unwrapped PlayerOperations calls, for this module's own requests
const localId = () => GameContext.localPlayerID;
const currentTurn = () => Game.turn ?? -1;
const limitReached = () => state.limitTurn === currentTurn() || state.pendingTurn === currentTurn();
const techs = () => Players.get(localId())?.Techs;

function activeNode() {
  const treeType = techs()?.getTreeType();
  if (treeType === undefined) return undefined;
  const tree = Game.ProgressionTrees.getTree(localId(), treeType);
  return tree?.nodes?.[tree.activeNodeIndex]?.nodeType;
}

const availableNodes = () => new Set(techs()?.getAllAvailableNodeTypes?.() ?? []);

let prerequisites = null;   // node hash -> prerequisite node hashes
function prerequisitesOf(node) {
  if (!prerequisites) {
    prerequisites = new Map();
    const hashOf = (type) => GameInfo.ProgressionTreeNodes.lookup(type)?.$hash;
    for (const row of GameInfo.ProgressionTreePrereqs) {
      const node = hashOf(row.Node);
      const prereq = hashOf(row.PrereqNode);
      if (node === undefined || prereq === undefined) continue;
      if (!prerequisites.has(node)) prerequisites.set(node, []);
      prerequisites.get(node).push(prereq);
    }
  }
  return prerequisites.get(node) ?? [];
}

/** The nearest node toward target that can be researched now (breadth-first over prerequisites). */
function nextNodeToward(target) {
  const available = availableNodes();
  const queue = [target];
  const seen = new Set();
  while (queue.length > 0) {
    const node = queue.shift();
    if (node === undefined || seen.has(node)) continue;
    seen.add(node);
    if (available.has(node)) return node;
    queue.push(...prerequisitesOf(node));
  }
  return undefined;
}

const clearEngineTarget = () => engineOps.sendRequest(localId(), PlayerOperationTypes.SET_TECH_TREE_TARGET_NODE,
  { ProgressionTreeNodeType: ProgressionTreeNodeTypes.NO_NODE });

// ============================ Tech tree display ============================

const displayPatched = new WeakSet();

/** The tech tree reads the queued target from getTargetNode; it reports this module's target. */
function patchTargetDisplay() {
  const component = techs();
  if (!component || displayPatched.has(component)) return;
  const engineTarget = component.getTargetNode.bind(component);
  const getTargetNode = () => (state.target !== undefined ? state.target : engineTarget());
  try {
    Object.defineProperty(component, 'getTargetNode', { configurable: true, value: getTargetNode });
    displayPatched.add(component);
  } catch (e) { log(`tech tree queue display unavailable: ${e}`); }
}

const refreshTargetDisplay = () => engine.trigger('TechTargetChanged', { player: localId() });

// ============================ Queue ============================

/** Start the next node toward the queued target, at most once a turn and never past the limit. */
function advanceQueue() {
  if (state.target === undefined || limitReached() || state.startedTurn === currentTurn()) return;
  const active = activeNode();
  if (active !== undefined && availableNodes().has(active)) { state.researching = active; return; }
  const next = nextNodeToward(state.target);
  if (next === undefined) {
    state.target = undefined;
    refreshTargetDisplay();
    return;
  }
  const args = { ProgressionTreeNodeType: next };
  if (!engineOps.canStart(localId(), PlayerOperationTypes.SET_TECH_TREE_NODE, args, false)?.Success) return;
  state.startedTurn = currentTurn();
  state.researching = next;
  engineOps.sendRequest(localId(), PlayerOperationTypes.SET_TECH_TREE_NODE, args);
  debug(`turn ${currentTurn()}: started the next queued technology`);
}

const isResearchRequest = (operation, args) => operation === PlayerOperationTypes.SET_TECH_TREE_NODE
  && args?.ProgressionTreeNodeType !== ProgressionTreeNodeTypes.NO_NODE;

function patchOperations() {
  const operations = Game.PlayerOperations;
  engineOps.canStart = operations.canStart.bind(operations);
  engineOps.sendRequest = operations.sendRequest.bind(operations);
  wrapMethod(operations, 'canStart', (base, playerId, operation, args, ...rest) => {
    if (playerId === localId() && isResearchRequest(operation, args) && limitReached()) {
      return { Success: false, InvalidReasons: [BLOCKED_REASON] };
    }
    return base(playerId, operation, args, ...rest);
  });
  wrapMethod(operations, 'sendRequest', (base, playerId, operation, args, ...rest) => {
    if (playerId !== localId()) return base(playerId, operation, args, ...rest);
    if (operation === PlayerOperationTypes.SET_TECH_TREE_TARGET_NODE) {
      const node = args?.ProgressionTreeNodeType;
      if (node === ProgressionTreeNodeTypes.NO_NODE) {
        state.target = undefined;
        const result = base(playerId, operation, args, ...rest);
        refreshTargetDisplay();
        return result;
      }
      if (node !== undefined) {
        state.target = node;
        state.startedTurn = -1;
        clearEngineTarget();
        advanceQueue();
        refreshTargetDisplay();
        return undefined;
      }
    }
    if (isResearchRequest(operation, args)) {
      if (limitReached()) { debug(`turn ${currentTurn()}: research blocked`); return undefined; }
      state.researching = args.ProgressionTreeNodeType;
    }
    return base(playerId, operation, args, ...rest);
  });
}

// ============================ Events ============================

function onTurnBegin() {
  state.pendingTurn = -1;
  state.startedTurn = -1;
  patchTargetDisplay();
  const active = activeNode();
  if (active !== undefined) state.researching = active;
  advanceQueue();
}

function onTechNodeCompleted(data) {
  if (data.player !== localId() || data.activeNode !== state.researching) return;   // granted directly, not researched
  const turn = currentTurn();
  state.pendingTurn = turn;
  clearEngineTarget();
  if (state.target === data.activeNode) {
    state.target = undefined;
    refreshTargetDisplay();
  }
  // The free-technology notification, if any, arrives right after the completion.
  setTimeout(() => {
    if (state.pendingTurn !== turn) return;
    state.pendingTurn = -1;
    state.researching = undefined;
    const free = state.freeTechAt.turn === turn && Date.now() - state.freeTechAt.time < BALANCE_CONFIG.freeTechWindowMs;
    if (free) {
      state.startedTurn = -1;
      advanceQueue();
      debug(`turn ${turn}: free technology, not counted`);
      return;
    }
    state.limitTurn = turn;
    debug(`turn ${turn}: technology limit reached`);
  }, 0);
}

function onNotificationAdded(data) {
  if (data.id?.owner !== localId()) return;
  const type = Game.Notifications.getType(data.id);
  if (type !== undefined && Game.Notifications.getTypeName(type) === FREE_TECH_NOTIFICATION) {
    state.freeTechAt = { turn: currentTurn(), time: Date.now() };
  }
}

function onTechTreeChanged(data) {
  if (data.player !== localId() || limitReached()) return;
  const active = activeNode();
  if (active !== undefined) state.researching = active;
}

/** A target the engine already holds (a loaded game) is taken over by this module. */
function adoptEngineTarget() {
  const target = techs()?.getTargetNode();
  if (target === undefined || target === ProgressionTreeNodeTypes.NO_NODE) return;
  state.target = target;
  clearEngineTarget();
}

if (BALANCE_CONFIG.oneTechPerTurn && !globalThis.MPTOneTechPerTurn) {
  globalThis.MPTOneTechPerTurn = true;
  try {
    patchOperations();
    engine.on('LocalPlayerTurnBegin', onTurnBegin);
    engine.on('PlayerTurnActivated', (data) => { if (data.player === localId()) onTurnBegin(); });
    engine.on('TechNodeCompleted', onTechNodeCompleted);
    engine.on('NotificationAdded', onNotificationAdded);
    engine.on('TechTreeChanged', onTechTreeChanged);
    const active = activeNode();
    if (active !== undefined) state.researching = active;
    adoptEngineTarget();
    patchTargetDisplay();
    refreshTargetDisplay();
    log('one technology per turn active');
  } catch (e) { log(`one technology per turn unavailable: ${e}`); }
}
