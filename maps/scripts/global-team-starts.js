import { assignAdvancedStartRegions } from '../../../base-standard/maps/assign-advanced-start-region.js';
import { g_CoastTerrain, g_OceanTerrain } from '../../../base-standard/maps/map-globals.js';
import { generateGlobalResources } from '../maps/global-resource-system.js';
import { adjustScoreByStartBias, resetStartBiasScores } from '../maps/start-bias-score.js';
import {
  getPlayerStrictStartBias,
  isStrictStartBiasEnabled,
  matchesPlayerStrictStartBias,
  matchesPlayerStrictStartBiasWithLakeFallback,
  recordStrictStartBiasFailure,
  resetStrictStartBiases
} from '../maps/strict-start-biases.js';

// Multiplayer Player Placement: a post-process of every map that places every
// major player on a Fresh Water start at least JOINT_START_MINIMUM_DISTANCE
// apart, within East vs West team regions when chosen, honouring strict start
// biases; Reefs are then added near coast-biased starts.
const JOINT_START_MINIMUM_DISTANCE = 12;
const JOINT_START_SEARCH_NODE_LIMIT = 750000;
const JOINT_START_SEARCH_RESTARTS = 3;
const SOLVE_TIME_BUDGET_MS = 4000;
const PLACEMENT_TIME_BUDGET_MS = 20000;
const COASTAL_REEFS_PER_START = 3;

// ============================ Reefs ============================

function addCoastalStartReefs() {
  const reef = GameInfo.Features.lookup("FEATURE_REEF");
  const coldReef = GameInfo.Features.lookup("FEATURE_COLD_REEF");
  const marine = GameInfo.Biomes.lookup("BIOME_MARINE");
  if (reef == null || marine == null) {
    console.log("MPT MAPS COASTAL REEFS: Reef or Marine definition unavailable; skipping");
    return;
  }

  const coastPlayers = Players.getAliveMajorIds().filter((playerId) =>
    getPlayerStrictStartBias(playerId)?.rules.some((rule) => rule.id === "ocean-coast"));
  if (coastPlayers.length === 0) return;

  // Marine coast tiles, collected once for every coast-biased player.
  const width = GameplayMap.getGridWidth();
  const height = GameplayMap.getGridHeight();
  const coastTiles = [];
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (GameplayMap.getTerrainType(x, y) !== g_CoastTerrain || GameplayMap.isLake(x, y)) continue;
      if (GameplayMap.getBiomeType(x, y) !== marine.$index || GameplayMap.isNaturalWonder(x, y)) continue;
      coastTiles.push({ x, y, index: GameplayMap.getIndexFromXY(x, y) });
    }
  }

  let totalPlaced = 0;
  for (const playerId of coastPlayers) {
    const startIndex = StartPositioner.getStartPosition(playerId);
    if (startIndex < 0) continue;
    const start = GameplayMap.getLocationFromIndex(startIndex);
    const candidates = coastTiles
      .map((tile) => ({ ...tile, distance: GameplayMap.getPlotDistance(start.x, start.y, tile.x, tile.y) }))
      .sort((a, b) => a.distance - b.distance || a.index - b.index);

    let reefCount = 0;
    let rejectedCount = 0;
    for (const tile of candidates) {
      const existingFeature = GameplayMap.getFeatureType(tile.x, tile.y);
      if (existingFeature === reef.$index || existingFeature === coldReef?.$index) {
        reefCount++;
      } else if (existingFeature === FeatureTypes.NO_FEATURE) {
        let feature = reef;
        if (!TerrainBuilder.canHaveFeature(tile.x, tile.y, feature.$index)) {
          feature = coldReef;
        }
        if (feature == null || !TerrainBuilder.canHaveFeature(tile.x, tile.y, feature.$index)) continue;
        TerrainBuilder.setFeatureType(tile.x, tile.y, {
          Feature: feature.$index,
          Direction: -1,
          Elevation: 0
        });
        const placedFeature = GameplayMap.getFeatureType(tile.x, tile.y);
        if (placedFeature === reef.$index || placedFeature === coldReef?.$index) {
          reefCount++;
          totalPlaced++;
        } else {
          rejectedCount++;
        }
      }
      if (reefCount === COASTAL_REEFS_PER_START) break;
    }
    console.log(
      `MPT MAPS COASTAL REEFS: player=${playerId} candidates=${candidates.length} ` +
      `nearest reef tiles=${reefCount} rejected=${rejectedCount}`
    );
  }

  if (totalPlaced > 0) {
    FertilityBuilder.recalculate();
    assignAdvancedStartRegions();
  }
  console.log(`MPT MAPS COASTAL REEFS: placed ${totalPlaced} new Reef tile(s)`);
}

// ============================ Regions ============================

function getSelectedPlayerCount() {
  const value = Configuration.getMapValue("MPTPlayerPlacement");
  switch (value) {
    case "MPT_MAPS_PLACEMENT_DUEL":
      return 2;
    case "MPT_MAPS_PLACEMENT_2V2":
      return 4;
    case "MPT_MAPS_PLACEMENT_3V3":
      return 6;
    case "MPT_MAPS_PLACEMENT_4V4":
      return 8;
    default:
      return 0;
  }
}

function buildEastWestTeamRegions(playerCount, primaryLandmass) {
  if (playerCount !== 2 && playerCount !== 4 && playerCount !== 6 && playerCount !== 8) {
    return null;
  }

  const west = primaryLandmass.west;
  const east = primaryLandmass.east;
  const south = primaryLandmass.south;
  const north = primaryLandmass.north;
  const width = Math.max(4, east - west);
  const height = Math.max(4, north - south);

  // These are the established East vs West bands used by every placement mode.
  const farWestEnd = Math.floor(west + width * 0.24);
  const innerWestStart = Math.floor(west + width * 0.34);
  const innerWestEnd = Math.floor(west + width * 0.44);
  const innerEastStart = Math.floor(west + width * 0.56);
  const innerEastEnd = Math.floor(west + width * 0.66);
  const farEastStart = Math.floor(west + width * 0.76);
  const lowerNorth = Math.floor(south + height * 0.45);
  const upperSouth = Math.ceil(south + height * 0.55);
  const makeRegion = (regionWest, regionEast, regionSouth, regionNorth, role) => ({
    west: regionWest,
    east: regionEast,
    south: regionSouth,
    north: regionNorth,
    continent: -1,
    _eastWestRole: role
  });

  const westBackFull = makeRegion(west, farWestEnd, south, north, "west-backline");
  const eastBackFull = makeRegion(farEastStart, east, south, north, "east-backline");
  const westFrontFull = makeRegion(innerWestStart, innerWestEnd, south, north, "west-frontline");
  const eastFrontFull = makeRegion(innerEastStart, innerEastEnd, south, north, "east-frontline");
  const westBackLower = makeRegion(west, farWestEnd, south, lowerNorth, "west-backline-lower");
  const eastBackLower = makeRegion(farEastStart, east, south, lowerNorth, "east-backline-lower");
  const westBackUpper = makeRegion(west, farWestEnd, upperSouth, north, "west-backline-upper");
  const eastBackUpper = makeRegion(farEastStart, east, upperSouth, north, "east-backline-upper");
  const westFrontLower = makeRegion(innerWestStart, innerWestEnd, south, lowerNorth, "west-frontline-lower");
  const eastFrontLower = makeRegion(innerEastStart, innerEastEnd, south, lowerNorth, "east-frontline-lower");
  const westFrontUpper = makeRegion(innerWestStart, innerWestEnd, upperSouth, north, "west-frontline-upper");
  const eastFrontUpper = makeRegion(innerEastStart, innerEastEnd, upperSouth, north, "east-frontline-upper");

  if (playerCount === 2) {
    // Duel combines each side's backline and frontline territory into one
    // broad region. A slightly wider 18% center gap keeps both capitals out
    // of the exact middle without forcing them to the extreme map edges.
    const duelWestEnd = Math.floor(west + width * 0.41);
    const duelEastStart = Math.ceil(west + width * 0.59);
    return [
      makeRegion(west, duelWestEnd, south, north, "duel-west"),
      makeRegion(duelEastStart, east, south, north, "duel-east")
    ];
  }
  if (playerCount === 4) {
    return [westBackFull, eastBackFull, westFrontFull, eastFrontFull];
  }
  if (playerCount === 6) {
    return [
      westBackLower, eastBackLower,
      westBackUpper, eastBackUpper,
      westFrontFull, eastFrontFull
    ];
  }
  return [
    westBackLower, eastBackLower,
    westBackUpper, eastBackUpper,
    westFrontLower, eastFrontLower,
    westFrontUpper, eastFrontUpper
  ];
}

function isLand(x, y) {
  const terrain = GameplayMap.getTerrainType(x, y);
  return terrain !== g_OceanTerrain && terrain !== g_CoastTerrain;
}

function getPlayerLandBounds() {
  const width = GameplayMap.getGridWidth();
  const height = GameplayMap.getGridHeight();
  const aliveMajorIds = Players.getAliveMajorIds();
  const startIndices = [];

  for (const playerId of aliveMajorIds) {
    const plotIndex = StartPositioner.getStartPosition(playerId);
    if (plotIndex < 0) {
      return null;
    }
    startIndices.push(plotIndex);
  }

  // Use every connected land area that the chosen map selected for a major
  // player. This excludes unused distant islands while preserving maps that
  // intentionally spread players over two continents or several islands.
  const requiredComponents = new Set();
  const componentByPlot = new Map();
  const components = [];

  for (const startIndex of startIndices) {
    if (componentByPlot.has(startIndex)) {
      requiredComponents.add(componentByPlot.get(startIndex));
      continue;
    }

    const componentId = components.length;
    const plots = [];
    const queue = [startIndex];
    componentByPlot.set(startIndex, componentId);

    for (let cursor = 0; cursor < queue.length; cursor++) {
      const plotIndex = queue[cursor];
      const location = GameplayMap.getLocationFromIndex(plotIndex);
      plots.push(location);

      for (let direction = 0; direction < 6; direction++) {
        const adjacent = GameplayMap.getAdjacentPlotLocation(location, direction);
        if (adjacent == null || adjacent.x < 0 || adjacent.x >= width || adjacent.y < 0 || adjacent.y >= height) {
          continue;
        }
        const adjacentIndex = GameplayMap.getIndexFromXY(adjacent.x, adjacent.y);
        if (!componentByPlot.has(adjacentIndex) && isLand(adjacent.x, adjacent.y)) {
          componentByPlot.set(adjacentIndex, componentId);
          queue.push(adjacentIndex);
        }
      }
    }

    components.push(plots);
    requiredComponents.add(componentId);
  }

  let west = width - 1;
  let east = 0;
  let south = height - 1;
  let north = 0;
  let tileCount = 0;
  for (const componentId of requiredComponents) {
    const component = components[componentId];
    if (component == null) {
      continue;
    }
    for (const location of component) {
      west = Math.min(west, location.x);
      east = Math.max(east, location.x);
      south = Math.min(south, location.y);
      north = Math.max(north, location.y);
      tileCount++;
    }
  }

  if (tileCount === 0 || east - west < 8 || north - south < 6) {
    return null;
  }
  return { west, east, south, north };
}

function getRegionTiles(region) {
  const tiles = [];
  for (let y = region.south; y <= region.north; y++) {
    for (let x = region.west; x <= region.east; x++) tiles.push({ x, y });
  }
  return tiles;
}

function getWholeMapTiles() {
  const tiles = [];
  const width = GameplayMap.getGridWidth();
  const height = GameplayMap.getGridHeight();
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) tiles.push({ x, y });
  }
  return tiles;
}

// ============================ Scoring ============================

/** Per-pass caches: tile validity and scores are fixed while starts are being solved. */
function createPlacementContext() {
  return {
    deadline: Date.now() + PLACEMENT_TIME_BUDGET_MS,
    usable: new Map(),
    plotScores: new Map(),
    playerScores: new Map(),
    exact: new Map(),
    lake: new Map()
  };
}

const passExpired = (ctx) => Date.now() > ctx.deadline;

function memo(map, key, compute) {
  let value = map.get(key);
  if (value === undefined) {
    value = compute();
    map.set(key, value);
  }
  return value;
}

const plotKey = (tile) => GameplayMap.getIndexFromXY(tile.x, tile.y);
const playerPlotKey = (playerId, plotIndex) => playerId * 1048576 + plotIndex;

/** Land, passable, not a Natural Wonder, with Fresh Water. */
function isUsableStart(ctx, tile) {
  return memo(ctx.usable, plotKey(tile), () =>
    !GameplayMap.isWater(tile.x, tile.y) && !GameplayMap.isMountain(tile.x, tile.y) &&
    !GameplayMap.isNaturalWonder(tile.x, tile.y) && GameplayMap.isFreshWater(tile.x, tile.y));
}

function matchesExact(ctx, playerId, tile) {
  return memo(ctx.exact, playerPlotKey(playerId, plotKey(tile)), () => matchesPlayerStrictStartBias(tile.x, tile.y, playerId));
}

function matchesLakeFallback(ctx, playerId, tile) {
  return memo(ctx.lake, playerPlotKey(playerId, plotKey(tile)), () => matchesPlayerStrictStartBiasWithLakeFallback(tile.x, tile.y, playerId));
}

const hasStrictBias = (playerId) => isStrictStartBiasEnabled() && getPlayerStrictStartBias(playerId) != null;

/** The game's start score plus the player's start biases. */
function startScore(ctx, playerId, tile) {
  const plotIndex = plotKey(tile);
  const base = memo(ctx.plotScores, plotIndex, () => StartPositioner.getStartPositionScore(tile.x, tile.y));
  const bias = memo(ctx.playerScores, playerPlotKey(playerId, plotIndex), () => adjustScoreByStartBias(tile.x, tile.y, playerId));
  return { base, bias };
}

function isValidJointStartTile(ctx, tile, playerId, allowLakeFallback, enforcedStrictPlayerIds) {
  if (!isUsableStart(ctx, tile)) return false;
  if (!hasStrictBias(playerId) || (enforcedStrictPlayerIds != null && !enforcedStrictPlayerIds.has(playerId))) return true;
  if (matchesExact(ctx, playerId, tile)) return true;
  return allowLakeFallback && matchesLakeFallback(ctx, playerId, tile);
}

function buildJointStartCandidates(ctx, playerId, tiles, originalStart, allowLakeFallback, enforcedStrictPlayerIds, orderingSeed) {
  const original = originalStart >= 0 ? GameplayMap.getLocationFromIndex(originalStart) : null;
  const strict = hasStrictBias(playerId);
  const candidates = [];
  for (const tile of tiles) {
    if (!isValidJointStartTile(ctx, tile, playerId, allowLakeFallback, enforcedStrictPlayerIds)) continue;
    const { base, bias } = startScore(ctx, playerId, tile);
    // A non-positive game score marks a poor start, not an invalid one: it may be the only way to meet a requirement.
    let score = (!Number.isFinite(base) || base <= 0 ? 1 : base) + bias;
    // Lake matches are the coastal fallback: true ocean-coast matches stay ahead whenever both solve.
    if (strict && !matchesExact(ctx, playerId, tile)) score -= 1000000;
    if (original != null) score /= 1 + GameplayMap.getPlotDistance(tile.x, tile.y, original.x, original.y) * 0.02;
    const plotIndex = plotKey(tile);
    candidates.push({ plotIndex, x: tile.x, y: tile.y, score, order: ((plotIndex * 1103515245 + orderingSeed * 12345) >>> 0) });
  }
  candidates.sort((a, b) => {
    if (orderingSeed === 0) return b.score - a.score || a.plotIndex - b.plotIndex;
    // Restarts keep broad quality bands but explore a different branch order.
    return Math.floor(b.score / 25) - Math.floor(a.score / 25) || a.order - b.order || a.plotIndex - b.plotIndex;
  });
  return candidates;
}

// ============================ Solver ============================

const farEnough = (a, b) => GameplayMap.getPlotDistance(a.x, a.y, b.x, b.y) >= JOINT_START_MINIMUM_DISTANCE;

/**
 * Backtracking with forward checking: every remaining player keeps the
 * candidates still compatible with the starts chosen so far, so each choice
 * only filters against the start just placed. The most constrained player is
 * placed first; a node limit and a time budget bound the search.
 */
function solveJointStartPositions(ctx, playerIds, tileSets, originalStarts, allowLakeFallback = false, enforcedStrictPlayerIds = null, orderingSeed = 0) {
  const domains = new Map();
  for (let i = 0; i < playerIds.length; i++) {
    const playerId = playerIds[i];
    const candidates = buildJointStartCandidates(ctx, playerId, tileSets[i], originalStarts.get(playerId), allowLakeFallback, enforcedStrictPlayerIds, orderingSeed);
    console.log(`MPT MAPS JOINT STARTS: player=${playerId} candidates=${candidates.length} lakeFallback=${allowLakeFallback} seed=${orderingSeed}`);
    if (candidates.length === 0) return { solution: null, exhausted: false };
    domains.set(playerId, candidates);
  }

  const deadline = Math.min(ctx.deadline, Date.now() + SOLVE_TIME_BUDGET_MS);
  const assigned = new Map();
  let visitedNodes = 0;
  let stopped = false;
  const search = (remaining) => {
    if (remaining.size === 0) return true;
    let chosenPlayer = -1;
    let chosenDomain = null;
    for (const [playerId, domain] of remaining) {
      if (chosenDomain == null || domain.length < chosenDomain.length) {
        chosenPlayer = playerId;
        chosenDomain = domain;
      }
    }
    for (const candidate of chosenDomain) {
      if (++visitedNodes >= JOINT_START_SEARCH_NODE_LIMIT || Date.now() > deadline) {
        stopped = true;
        return false;
      }
      const next = new Map();
      let deadEnd = false;
      for (const [playerId, domain] of remaining) {
        if (playerId === chosenPlayer) continue;
        const compatible = domain.filter((other) => farEnough(other, candidate));
        if (compatible.length === 0) { deadEnd = true; break; }
        next.set(playerId, compatible);
      }
      if (deadEnd) continue;
      assigned.set(chosenPlayer, candidate);
      if (search(next)) return true;
      assigned.delete(chosenPlayer);
      if (stopped) return false;
    }
    return false;
  };

  const solved = search(domains);
  console.log(`MPT MAPS JOINT STARTS: solved=${solved} visitedNodes=${visitedNodes} stopped=${stopped}`);
  return { solution: solved ? new Map(assigned) : null, exhausted: !solved && stopped };
}

function solveJointStartPositionsWithRestarts(ctx, playerIds, tileSets, originalStarts, allowLakeFallback, enforcedStrictPlayerIds) {
  for (let orderingSeed = 0; orderingSeed < JOINT_START_SEARCH_RESTARTS && !passExpired(ctx); orderingSeed++) {
    const result = solveJointStartPositions(ctx, playerIds, tileSets, originalStarts, allowLakeFallback, enforcedStrictPlayerIds, orderingSeed);
    if (result.solution != null) return result.solution;
    if (!result.exhausted) break;
    console.log(`MPT MAPS JOINT STARTS: restarting bounded search with ordering seed ${orderingSeed + 1}`);
  }
  return null;
}

// ============================ Validation ============================

function validateStartSolution(
  playerIds,
  solution,
  allowLakeFallback,
  enforcedStrictPlayerIds = null,
  requiredTileSets = null
) {
  const failures = [];
  const locations = new Map();
  for (const playerId of playerIds) {
    const candidate = solution.get(playerId);
    if (candidate == null) {
      failures.push(`player ${playerId}: no assigned tile`);
      continue;
    }
    if (
      requiredTileSets != null &&
      !requiredTileSets[playerIds.indexOf(playerId)].some((tile) => tile.x === candidate.x && tile.y === candidate.y)
    ) {
      failures.push(`player ${playerId}: outside the assigned competitive region`);
    }
    if (GameplayMap.isWater(candidate.x, candidate.y) || GameplayMap.isMountain(candidate.x, candidate.y)) {
      failures.push(`player ${playerId}: assigned an impassable tile`);
    } else if (!GameplayMap.isFreshWater(candidate.x, candidate.y)) {
      failures.push(`player ${playerId}: assigned without Fresh Water`);
    }
    const strictIsEnforced = enforcedStrictPlayerIds == null || enforcedStrictPlayerIds.has(playerId);
    if (strictIsEnforced && isStrictStartBiasEnabled() && getPlayerStrictStartBias(playerId) != null) {
      const exact = matchesPlayerStrictStartBias(candidate.x, candidate.y, playerId);
      const fallback = allowLakeFallback && matchesPlayerStrictStartBiasWithLakeFallback(candidate.x, candidate.y, playerId);
      if (!exact && !fallback) failures.push(`player ${playerId}: strict requirement not met`);
    }
    locations.set(playerId, candidate);
  }
  for (let i = 0; i < playerIds.length; i++) {
    const a = locations.get(playerIds[i]);
    if (a == null) continue;
    for (let j = i + 1; j < playerIds.length; j++) {
      const b = locations.get(playerIds[j]);
      if (b != null && GameplayMap.getPlotDistance(a.x, a.y, b.x, b.y) < JOINT_START_MINIMUM_DISTANCE) {
        failures.push(`players ${playerIds[i]} and ${playerIds[j]}: less than ${JOINT_START_MINIMUM_DISTANCE} tiles apart`);
      }
    }
  }
  return failures;
}

function getCommittedStartSolution(playerIds) {
  const solution = new Map();
  for (const playerId of playerIds) {
    const plotIndex = StartPositioner.getStartPosition(playerId);
    if (plotIndex < 0) continue;
    const location = GameplayMap.getLocationFromIndex(plotIndex);
    solution.set(playerId, { plotIndex, x: location.x, y: location.y, score: 0 });
  }
  return solution;
}

function buildHardRegionEmergencySolution(ctx, playerIds, tileSets) {
  const solution = new Map();
  const usedPlots = new Set();
  for (let i = 0; i < playerIds.length; i++) {
    const playerId = playerIds[i];
    let bestCandidate = null;
    let bestScore = Number.NEGATIVE_INFINITY;
    for (const tile of tileSets[i]) {
      if (GameplayMap.isWater(tile.x, tile.y) || GameplayMap.isMountain(tile.x, tile.y)) continue;
      if (GameplayMap.isNaturalWonder(tile.x, tile.y)) continue;
      const plotIndex = plotKey(tile);
      if (usedPlots.has(plotIndex)) continue;
      let minimumDistance = 999;
      for (const other of solution.values()) {
        minimumDistance = Math.min(minimumDistance, GameplayMap.getPlotDistance(tile.x, tile.y, other.x, other.y));
      }
      const { base, bias } = startScore(ctx, playerId, tile);
      let score = Math.max(0, base) + bias;
      if (matchesExact(ctx, playerId, tile)) score += 1000000000;
      else if (matchesLakeFallback(ctx, playerId, tile)) score += 500000000;
      if (GameplayMap.isFreshWater(tile.x, tile.y)) score += 100000000;
      score += Math.min(minimumDistance, JOINT_START_MINIMUM_DISTANCE) * 1000000;
      if (score > bestScore) {
        bestScore = score;
        bestCandidate = { plotIndex, x: tile.x, y: tile.y, score };
      }
    }
    if (bestCandidate == null) return null;
    solution.set(playerId, bestCandidate);
    usedPlots.add(bestCandidate.plotIndex);
  }
  return solution;
}

function validateHardRegionMembership(playerIds, solution, tileSets) {
  const failures = [];
  for (let i = 0; i < playerIds.length; i++) {
    const playerId = playerIds[i];
    const candidate = solution.get(playerId);
    if (
      candidate == null ||
      !tileSets[i].some((tile) => tile.x === candidate.x && tile.y === candidate.y)
    ) {
      failures.push(`player ${playerId}: outside the assigned competitive region`);
    }
  }
  return failures;
}

// ============================ Placement ============================

function applyGlobalTeamStarts() {
  const ctx = createPlacementContext();
  const playerCount = getSelectedPlayerCount();
  const aliveMajorIds = Players.getAliveMajorIds();
  const originalStarts = new Map();
  for (const playerId of aliveMajorIds) {
    originalStarts.set(playerId, StartPositioner.getStartPosition(playerId));
  }

  const wholeMapTiles = getWholeMapTiles();
  let tileSets;
  let placementLabel = "Base whole-map";
  if (playerCount === 0) {
    tileSets = aliveMajorIds.map(() => wholeMapTiles);
  } else {
    let regionPlayerCount = playerCount;
    if (aliveMajorIds.length !== playerCount) {
      const supportedActualCount = [2, 4, 6, 8].includes(aliveMajorIds.length);
      if (!supportedActualCount) {
        console.log(
          `MPT MAPS PLAYER PLACEMENT: selected ${playerCount / 2}v${playerCount / 2}, but detected ` +
          `${aliveMajorIds.length} major players; no valid competitive region layout exists`
        );
        return;
      }
      regionPlayerCount = aliveMajorIds.length;
      console.log(
        `MPT MAPS PLAYER PLACEMENT: selected ${playerCount / 2}v${playerCount / 2}, but detected ` +
        `${aliveMajorIds.length} major players; hard-forcing regions for the detected player count`
      );
    }
    const bounds = getPlayerLandBounds();
    const regions = bounds == null ? null : buildEastWestTeamRegions(regionPlayerCount, bounds);
    if (regions == null || regions.length !== aliveMajorIds.length) {
      console.log("MPT MAPS PLAYER PLACEMENT: could not determine designated team regions; retaining original starts");
      return;
    }
    tileSets = regions.map(getRegionTiles);
    placementLabel = regionPlayerCount === 2
      ? "Duel designated regions"
      : `${regionPlayerCount / 2}v${regionPlayerCount / 2} designated regions`;
  }

  const wholeMapTileSets = aliveMajorIds.map(() => wholeMapTiles);
  const allStrictPlayerIds = new Set(
    aliveMajorIds.filter((playerId) => isStrictStartBiasEnabled() && getPlayerStrictStartBias(playerId) != null)
  );
  const attempts = [];
  if (playerCount !== 0) {
    attempts.push({ label: placementLabel + " exact", tileSets, allowLakeFallback: false });
    attempts.push({
      label: placementLabel + " with lake fallback",
      tileSets,
      allowLakeFallback: true
    });
  } else {
    attempts.push({ label: "whole-map exact", tileSets: wholeMapTileSets, allowLakeFallback: false });
    attempts.push({ label: "whole-map with lake fallback", tileSets: wholeMapTileSets, allowLakeFallback: true });
  }

  let solution = null;
  let chosenAttempt = null;
  for (const attempt of attempts) {
    if (passExpired(ctx)) break;
    console.log(`MPT MAPS PLAYER PLACEMENT: attempting ${attempt.label}`);
    const candidateSolution = solveJointStartPositionsWithRestarts(
      ctx,
      aliveMajorIds,
      attempt.tileSets,
      originalStarts,
      attempt.allowLakeFallback,
      allStrictPlayerIds
    );
    if (candidateSolution == null) continue;
    const failures = validateStartSolution(
      aliveMajorIds,
      candidateSolution,
      attempt.allowLakeFallback,
      allStrictPlayerIds,
      playerCount !== 0 ? attempt.tileSets : null
    );
    if (failures.length === 0) {
      solution = candidateSolution;
      chosenAttempt = attempt;
      break;
    }
    console.log(`MPT MAPS PLAYER PLACEMENT: rejected ${attempt.label}: ${failures.join("; ")}`);
  }

  // If a genuinely impossible leader/civilization combination blocks the
  // complete arrangement, isolate only the smallest-candidate strict player
  // and restart the entire placement. Other strict players remain mandatory.
  // Competitive modes always reuse their designated tile sets here: region
  // membership is a hard constraint and is never widened by recovery.
  const recoveryTileSets = playerCount !== 0 ? tileSets : wholeMapTileSets;
  // This prevents one contradiction from reverting every civilization to an
  // invalid vanilla start.
  let enforcedStrictPlayerIds = new Set(allStrictPlayerIds);
  const relaxedStrictPlayerIds = new Set();
  while (solution == null && enforcedStrictPlayerIds.size > 0 && !passExpired(ctx)) {
    let playerToRelax = -1;
    let fewestCandidates = Number.POSITIVE_INFINITY;
    for (const playerId of enforcedStrictPlayerIds) {
      const playerIndex = aliveMajorIds.indexOf(playerId);
      const candidateCount = buildJointStartCandidates(
        ctx,
        playerId,
        recoveryTileSets[playerIndex],
        originalStarts.get(playerId),
        true,
        enforcedStrictPlayerIds,
        0
      ).length;
      if (candidateCount < fewestCandidates) {
        fewestCandidates = candidateCount;
        playerToRelax = playerId;
      }
    }
    if (playerToRelax < 0) break;
    enforcedStrictPlayerIds.delete(playerToRelax);
    relaxedStrictPlayerIds.add(playerToRelax);
    console.log(
      `MPT MAPS PLAYER PLACEMENT: restarting after isolating player=${playerToRelax} ` +
      `with only ${fewestCandidates} strict candidate(s)`
    );
    const candidateSolution = solveJointStartPositionsWithRestarts(
      ctx,
      aliveMajorIds,
      recoveryTileSets,
      originalStarts,
      true,
      enforcedStrictPlayerIds
    );
    if (candidateSolution == null) continue;
    const failures = validateStartSolution(
      aliveMajorIds,
      candidateSolution,
      true,
      enforcedStrictPlayerIds,
      playerCount !== 0 ? recoveryTileSets : null
    );
    if (failures.length === 0) {
      solution = candidateSolution;
      chosenAttempt = {
        label: `${playerCount !== 0 ? "designated-region" : "whole-map"} best-effort recovery ` +
          `(${relaxedStrictPlayerIds.size} isolated)`,
        allowLakeFallback: true
      };
    }
  }

  if (solution == null && playerCount !== 0) {
    console.log(
      "MPT MAPS PLAYER PLACEMENT: strict regional restarts exhausted; applying hard-region emergency placement"
    );
    solution = buildHardRegionEmergencySolution(ctx, aliveMajorIds, tileSets);
    if (solution != null) {
      enforcedStrictPlayerIds = new Set();
      for (const playerId of allStrictPlayerIds) relaxedStrictPlayerIds.add(playerId);
      chosenAttempt = {
        label: "hard-region emergency placement",
        allowLakeFallback: true,
        regionEmergency: true
      };
    }
  }

  if (solution == null || chosenAttempt == null) {
    console.log(
      `MPT MAPS PLAYER PLACEMENT: every ${playerCount !== 0 ? "designated-region" : "whole-map"} ` +
      "and isolated-player restart failed; " +
      "retaining original starts"
    );
    for (const playerId of allStrictPlayerIds) {
      const plotIndex = originalStarts.get(playerId);
      if (plotIndex == null || plotIndex < 0) continue;
      const location = GameplayMap.getLocationFromIndex(plotIndex);
      if (
        !matchesPlayerStrictStartBias(location.x, location.y, playerId) &&
        !matchesPlayerStrictStartBiasWithLakeFallback(location.x, location.y, playerId)
      ) {
        recordStrictStartBiasFailure(playerId, "all complete placement restarts were exhausted");
      }
    }
    return;
  }

  for (const playerId of aliveMajorIds) {
    const candidate = solution.get(playerId);
    StartPositioner.setStartPosition(candidate.plotIndex, playerId);
    console.log(`MPT MAPS PLAYER PLACEMENT: player=${playerId} x=${candidate.x} y=${candidate.y}`);
  }
  assignAdvancedStartRegions();

  const committedSolution = getCommittedStartSolution(aliveMajorIds);
  const committedFailures = chosenAttempt.regionEmergency
    ? validateHardRegionMembership(aliveMajorIds, committedSolution, tileSets)
    : validateStartSolution(
      aliveMajorIds,
      committedSolution,
      chosenAttempt.allowLakeFallback,
      enforcedStrictPlayerIds,
      playerCount !== 0 ? recoveryTileSets : null
    );
  if (committedFailures.length > 0) {
    console.log(
      `MPT MAPS PLAYER PLACEMENT: committed layout failed verification (${committedFailures.join("; ")}); ` +
      "restoring original starts"
    );
    for (const [playerId, plotIndex] of originalStarts) {
      if (plotIndex >= 0) StartPositioner.setStartPosition(plotIndex, playerId);
    }
    assignAdvancedStartRegions();
    for (const playerId of allStrictPlayerIds) {
      recordStrictStartBiasFailure(playerId, "post-placement verification failed");
    }
    return;
  }

  for (const playerId of allStrictPlayerIds) {
    const candidate = committedSolution.get(playerId);
    const exact = candidate != null && matchesPlayerStrictStartBias(candidate.x, candidate.y, playerId);
    const lakeFallback = candidate != null && matchesPlayerStrictStartBiasWithLakeFallback(candidate.x, candidate.y, playerId);
    if (!exact && !lakeFallback) {
      recordStrictStartBiasFailure(
        playerId,
        "the player's requirement was isolated only after every complete strict placement restart failed"
      );
    }
  }
  console.log(
    `MPT MAPS PLAYER PLACEMENT: applied ${chosenAttempt.label} with Fresh Water and ` +
    `${JOINT_START_MINIMUM_DISTANCE}-tile minimum spacing`
  );
}

function applyGlobalTeamStartsSafely() {
  const originalStarts = new Map();
  for (const playerId of Players.getAliveMajorIds()) {
    originalStarts.set(playerId, StartPositioner.getStartPosition(playerId));
  }
  try {
    applyGlobalTeamStarts();
  } catch (error) {
    for (const [playerId, plotIndex] of originalStarts) {
      if (plotIndex >= 0) StartPositioner.setStartPosition(plotIndex, playerId);
    }
    try {
      assignAdvancedStartRegions();
    } catch (regionError) {
      console.error(`MPT MAPS PLAYER PLACEMENT: original advanced regions could not be rebuilt: ${regionError?.stack ?? regionError}`);
    }
    console.error(
      `MPT MAPS PLAYER PLACEMENT: unexpected solver error; restored every original start: ${error?.stack ?? error}`
    );
  }
}

function armGlobalTeamStartHandler() {
  resetStrictStartBiases();   // a new map: re-read the option and the players
  resetStartBiasScores();
  // One handler per generation even if this script is loaded through more than one path.
  if (globalThis.MPTPlayerPlacementArmed) return;
  globalThis.MPTPlayerPlacementArmed = true;

  // Arming during RequestMapInitData registers this listener after the chosen
  // map's GenerateMap listener, so placement is a post-process of every map.
  // Resources, placement and Reefs run in one ordered pass.
  engine.on("GenerateMap", () => {
    // The Map Options exist only in multiplayer setup; single-player maps are left unchanged.
    if (Configuration.getMapValue("MPTPlayerPlacement") == null) {
      console.log("MPT MAPS PLAYER PLACEMENT: not a multiplayer setup; map left unchanged");
      return;
    }
    // A missing option means Off (removed when Advanced Settings supplies resources).
    const resourceSetting = Configuration.getMapValue("MPTResourceSystem") ?? "MPT_MAPS_RESOURCE_SYSTEM_OFF";
    if (resourceSetting === "MPT_MAPS_RESOURCE_SYSTEM_ON") {
      generateGlobalResources();
      FertilityBuilder.recalculate();   // start scoring reads fertility from the new resources
    } else {
      console.log("MPT MAPS RESOURCES: custom resource system disabled; retaining normal map resources");
    }
    applyGlobalTeamStartsSafely();
    try {
      addCoastalStartReefs();
    } catch (error) {
      console.error(`MPT MAPS COASTAL REEFS: skipped after unexpected error: ${error?.stack ?? error}`);
    }
  });
  console.log("MPT MAPS PLAYER PLACEMENT: post-process armed");
}

engine.on("RequestMapInitData", armGlobalTeamStartHandler);
console.log("MPT MAPS PLAYER PLACEMENT: loaded");

export { addCoastalStartReefs };
