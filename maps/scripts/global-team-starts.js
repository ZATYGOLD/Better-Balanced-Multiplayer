import { assignAdvancedStartRegions } from '../maps/assign-advanced-start-region.js';
import { adjustScoreByStartBias, buildEastWestTeamRegions, pickStrictStartPlotByTile } from '../maps/assign-starting-plots.js';
import { g_CoastTerrain, g_OceanTerrain } from '../maps/map-globals.js';
import { generateGlobalResources } from '../maps/global-resource-system.js';
import {
  clearStrictStartBiasFailure,
  clearStrictStartBiasFailures,
  getPlayerStrictStartBias,
  isStrictStartBiasEnabled,
  matchesPlayerStrictStartBias,
  matchesPlayerStrictStartBiasWithLakeFallback,
  recordStrictStartBiasFailure
} from '../maps/strict-start-biases.js';

let teamStartHandlerArmed = false;
const JOINT_START_MINIMUM_DISTANCE = 12;
const JOINT_START_SEARCH_NODE_LIMIT = 750000;
const JOINT_START_SEARCH_RESTARTS = 3;

function addCoastalStartReefs() {
  const reef = GameInfo.Features.lookup("FEATURE_REEF");
  const coldReef = GameInfo.Features.lookup("FEATURE_COLD_REEF");
  const marine = GameInfo.Biomes.lookup("BIOME_MARINE");
  if (reef == null || marine == null) {
    console.log("EVW COASTAL REEFS: Reef or Marine definition unavailable; skipping");
    return;
  }

  const width = GameplayMap.getGridWidth();
  const height = GameplayMap.getGridHeight();
  let totalPlaced = 0;
  for (const playerId of Players.getAliveMajorIds()) {
    const bias = getPlayerStrictStartBias(playerId);
    if (bias == null || !bias.rules.some((rule) => rule.id === "ocean-coast")) continue;

    const startIndex = StartPositioner.getStartPosition(playerId);
    if (startIndex < 0) continue;
    const start = GameplayMap.getLocationFromIndex(startIndex);
    const candidates = [];
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        if (GameplayMap.getTerrainType(x, y) !== g_CoastTerrain || GameplayMap.isLake(x, y)) continue;
        const tileBiome = GameInfo.Biomes.lookup(GameplayMap.getBiomeType(x, y));
        if (tileBiome?.BiomeType !== marine.BiomeType || GameplayMap.isNaturalWonder(x, y)) continue;
        candidates.push({
          x,
          y,
          index: GameplayMap.getIndexFromXY(x, y),
          distance: GameplayMap.getPlotDistance(start.x, start.y, x, y)
        });
      }
    }
    candidates.sort((a, b) => a.distance - b.distance || a.index - b.index);

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
      if (reefCount === 3) break;
    }
    console.log(
      `EVW COASTAL REEFS: player=${playerId} candidates=${candidates.length} ` +
      `nearest reef tiles=${reefCount} rejected=${rejectedCount}`
    );
  }

  if (totalPlaced > 0) {
    FertilityBuilder.recalculate();
    assignAdvancedStartRegions();
  }
  console.log(`EVW COASTAL REEFS: placed ${totalPlaced} new Reef tile(s)`);
}

function getSelectedPlayerCount() {
  const value = Configuration.getMapValue("EvWPlayerPlacement");
  switch (value) {
    case "EVW_PLACEMENT_DUEL":
      return 2;
    case "EVW_PLACEMENT_2V2":
      return 4;
    case "EVW_PLACEMENT_3V3":
      return 6;
    case "EVW_PLACEMENT_4V4":
      return 8;
    default:
      return 0;
  }
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

function getConnectedStartLandTiles(startIndex) {
  const width = GameplayMap.getGridWidth();
  const height = GameplayMap.getGridHeight();
  const tiles = [];
  const visited = new Set([startIndex]);
  const queue = [startIndex];
  for (let cursor = 0; cursor < queue.length; cursor++) {
    const plotIndex = queue[cursor];
    const location = GameplayMap.getLocationFromIndex(plotIndex);
    tiles.push(location);
    for (let direction = 0; direction < 6; direction++) {
      const adjacent = GameplayMap.getAdjacentPlotLocation(location, direction);
      if (adjacent == null || adjacent.x < 0 || adjacent.x >= width || adjacent.y < 0 || adjacent.y >= height) continue;
      const adjacentIndex = GameplayMap.getIndexFromXY(adjacent.x, adjacent.y);
      if (!visited.has(adjacentIndex) && isLand(adjacent.x, adjacent.y)) {
        visited.add(adjacentIndex);
        queue.push(adjacentIndex);
      }
    }
  }
  return tiles;
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

function isValidJointStartTile(tile, playerId, allowLakeFallback, enforcedStrictPlayerIds) {
  if (GameplayMap.isWater(tile.x, tile.y) || GameplayMap.isMountain(tile.x, tile.y)) return false;
  if (GameplayMap.isNaturalWonder(tile.x, tile.y)) return false;
  if (!GameplayMap.isFreshWater(tile.x, tile.y)) return false;
  if (
    !isStrictStartBiasEnabled() ||
    getPlayerStrictStartBias(playerId) == null ||
    (enforcedStrictPlayerIds != null && !enforcedStrictPlayerIds.has(playerId))
  ) return true;
  if (matchesPlayerStrictStartBias(tile.x, tile.y, playerId)) return true;
  return allowLakeFallback && matchesPlayerStrictStartBiasWithLakeFallback(tile.x, tile.y, playerId);
}

function buildJointStartCandidates(
  playerId,
  tiles,
  originalStart,
  allowLakeFallback,
  enforcedStrictPlayerIds,
  orderingSeed
) {
  const original = originalStart >= 0 ? GameplayMap.getLocationFromIndex(originalStart) : null;
  const strictBias = isStrictStartBiasEnabled() ? getPlayerStrictStartBias(playerId) : null;
  const candidates = [];
  for (const tile of tiles) {
    if (!isValidJointStartTile(tile, playerId, allowLakeFallback, enforcedStrictPlayerIds)) continue;
    let score = StartPositioner.getStartPositionScore(tile.x, tile.y);
    // Once terrain, Fresh Water, and impassability have been checked above,
    // a non-positive vanilla score means a poor start rather than a reason to
    // ignore a tile that may be the only way to satisfy a hard requirement.
    if (!Number.isFinite(score) || score <= 0) score = 1;
    score += adjustScoreByStartBias(tile.x, tile.y, playerId);
    // A lake is valid only as the established coastal fallback. Keep true
    // ocean-coast matches ahead of lake matches whenever both can solve the
    // complete placement arrangement.
    if (strictBias != null && !matchesPlayerStrictStartBias(tile.x, tile.y, playerId)) {
      score -= 1000000;
    }
    if (original != null) {
      const distanceFromOriginal = GameplayMap.getPlotDistance(tile.x, tile.y, original.x, original.y);
      score /= 1 + distanceFromOriginal * 0.02;
    }
    candidates.push({
      plotIndex: GameplayMap.getIndexFromXY(tile.x, tile.y),
      x: tile.x,
      y: tile.y,
      score,
      order: ((GameplayMap.getIndexFromXY(tile.x, tile.y) * 1103515245 + orderingSeed * 12345) >>> 0)
    });
  }
  candidates.sort((a, b) => {
    if (orderingSeed === 0) return b.score - a.score || a.plotIndex - b.plotIndex;
    // Restarts retain broad quality bands while exploring a different branch
    // order when the first bounded backtracking search reaches its node cap.
    const scoreBandA = Math.floor(a.score / 25);
    const scoreBandB = Math.floor(b.score / 25);
    return scoreBandB - scoreBandA || a.order - b.order || a.plotIndex - b.plotIndex;
  });
  return candidates;
}

function solveJointStartPositions(
  playerIds,
  tileSets,
  originalStarts,
  allowLakeFallback = false,
  enforcedStrictPlayerIds = null,
  orderingSeed = 0
) {
  const candidatesByPlayer = new Map();
  for (let i = 0; i < playerIds.length; i++) {
    const playerId = playerIds[i];
    const candidates = buildJointStartCandidates(
      playerId,
      tileSets[i],
      originalStarts.get(playerId),
      allowLakeFallback,
      enforcedStrictPlayerIds,
      orderingSeed
    );
    candidatesByPlayer.set(playerId, candidates);
    console.log(
      `EVW JOINT STARTS: player=${playerId} candidates=${candidates.length} ` +
      `lakeFallback=${allowLakeFallback} seed=${orderingSeed}`
    );
    if (candidates.length === 0) return { solution: null, exhausted: false };
  }

  const assigned = new Map();
  let visitedNodes = 0;
  const isCompatible = (candidate) => {
    for (const other of assigned.values()) {
      if (GameplayMap.getPlotDistance(candidate.x, candidate.y, other.x, other.y) < JOINT_START_MINIMUM_DISTANCE) {
        return false;
      }
    }
    return true;
  };
  const search = (remainingPlayers) => {
    if (remainingPlayers.length === 0) return true;
    if (visitedNodes >= JOINT_START_SEARCH_NODE_LIMIT) return false;

    let chosenPlayer = -1;
    let compatibleCandidates = null;
    for (const playerId of remainingPlayers) {
      const compatible = candidatesByPlayer.get(playerId).filter(isCompatible);
      if (compatible.length === 0) return false;
      if (compatibleCandidates == null || compatible.length < compatibleCandidates.length) {
        chosenPlayer = playerId;
        compatibleCandidates = compatible;
      }
    }

    const nextPlayers = remainingPlayers.filter((playerId) => playerId !== chosenPlayer);
    for (const candidate of compatibleCandidates) {
      visitedNodes++;
      assigned.set(chosenPlayer, candidate);
      if (search(nextPlayers)) return true;
      assigned.delete(chosenPlayer);
      if (visitedNodes >= JOINT_START_SEARCH_NODE_LIMIT) break;
    }
    return false;
  };

  const solved = search([...playerIds]);
  console.log(`EVW JOINT STARTS: solved=${solved} visitedNodes=${visitedNodes}`);
  return {
    solution: solved ? new Map(assigned) : null,
    exhausted: !solved && visitedNodes >= JOINT_START_SEARCH_NODE_LIMIT
  };
}

function solveJointStartPositionsWithRestarts(
  playerIds,
  tileSets,
  originalStarts,
  allowLakeFallback,
  enforcedStrictPlayerIds
) {
  for (let orderingSeed = 0; orderingSeed < JOINT_START_SEARCH_RESTARTS; orderingSeed++) {
    const result = solveJointStartPositions(
      playerIds,
      tileSets,
      originalStarts,
      allowLakeFallback,
      enforcedStrictPlayerIds,
      orderingSeed
    );
    if (result.solution != null) return result.solution;
    if (!result.exhausted) break;
    console.log(`EVW JOINT STARTS: restarting bounded search with ordering seed ${orderingSeed + 1}`);
  }
  return null;
}

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

function buildHardRegionEmergencySolution(playerIds, tileSets) {
  const solution = new Map();
  const usedPlots = new Set();
  for (let i = 0; i < playerIds.length; i++) {
    const playerId = playerIds[i];
    let bestCandidate = null;
    let bestScore = Number.NEGATIVE_INFINITY;
    for (const tile of tileSets[i]) {
      if (GameplayMap.isWater(tile.x, tile.y) || GameplayMap.isMountain(tile.x, tile.y)) continue;
      if (GameplayMap.isNaturalWonder(tile.x, tile.y)) continue;
      const plotIndex = GameplayMap.getIndexFromXY(tile.x, tile.y);
      if (usedPlots.has(plotIndex)) continue;
      const exact = matchesPlayerStrictStartBias(tile.x, tile.y, playerId);
      const lakeFallback = matchesPlayerStrictStartBiasWithLakeFallback(tile.x, tile.y, playerId);
      const freshWater = GameplayMap.isFreshWater(tile.x, tile.y);
      let minimumDistance = 999;
      for (const other of solution.values()) {
        minimumDistance = Math.min(
          minimumDistance,
          GameplayMap.getPlotDistance(tile.x, tile.y, other.x, other.y)
        );
      }
      let score = Math.max(0, StartPositioner.getStartPositionScore(tile.x, tile.y));
      score += adjustScoreByStartBias(tile.x, tile.y, playerId);
      if (exact) score += 1000000000;
      else if (lakeFallback) score += 500000000;
      if (freshWater) score += 100000000;
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

function applyGlobalStrictStartBiases() {
  if (!isStrictStartBiasEnabled()) {
    console.log("EVW STRICT START BIASES: disabled; keeping the selected map's starts");
    return;
  }
  const aliveMajorIds = Players.getAliveMajorIds();
  const starts = new Map();
  for (const playerId of aliveMajorIds) {
    starts.set(playerId, StartPositioner.getStartPosition(playerId));
  }
  let movedStarts = 0;
  for (const playerId of aliveMajorIds) {
    const bias = getPlayerStrictStartBias(playerId);
    const originalStart = starts.get(playerId);
    if (bias == null || originalStart == null || originalStart < 0) continue;
    const originalLocation = GameplayMap.getLocationFromIndex(originalStart);
    if (matchesPlayerStrictStartBias(originalLocation.x, originalLocation.y, playerId)) continue;

    const componentTiles = getConnectedStartLandTiles(originalStart);
    const otherStarts = aliveMajorIds
      .filter((otherPlayerId) => otherPlayerId !== playerId)
      .map((otherPlayerId) => starts.get(otherPlayerId))
      .filter((plotIndex) => plotIndex != null && plotIndex >= 0);
    const replacement = pickStrictStartPlotByTile(componentTiles, playerId, otherStarts, originalStart);
    if (replacement >= 0) {
      StartPositioner.setStartPosition(replacement, playerId);
      starts.set(playerId, replacement);
      movedStarts++;
      const location = GameplayMap.getLocationFromIndex(replacement);
      console.log(`EVW STRICT START BIASES: relocated player=${playerId} x=${location.x} y=${location.y}`);
    } else if (
      bias.rules.some((rule) => rule.id === "ocean-coast") &&
      matchesPlayerStrictStartBiasWithLakeFallback(originalLocation.x, originalLocation.y, playerId)
    ) {
      console.log(`EVW STRICT START BIASES: player=${playerId} kept valid lake-fallback start`);
    } else {
      recordStrictStartBiasFailure(
        playerId,
        "no qualifying tile on the connected landmass containing the map's original start"
      );
    }
  }
  if (movedStarts > 0) {
    assignAdvancedStartRegions();
  }
  console.log(`EVW STRICT START BIASES: globally relocated ${movedStarts} start(s)`);
}

function applyGlobalTeamStarts() {
  // Earlier map-assignment passes may have tested narrower provisional regions.
  // Only failures from this final placement pass should reach the notification.
  clearStrictStartBiasFailures();
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
          `EVW PLAYER PLACEMENT: selected ${playerCount / 2}v${playerCount / 2}, but detected ` +
          `${aliveMajorIds.length} major players; no valid competitive region layout exists`
        );
        return;
      }
      regionPlayerCount = aliveMajorIds.length;
      console.log(
        `EVW PLAYER PLACEMENT: selected ${playerCount / 2}v${playerCount / 2}, but detected ` +
        `${aliveMajorIds.length} major players; hard-forcing regions for the detected player count`
      );
    }
    const bounds = getPlayerLandBounds();
    const regions = bounds == null ? null : buildEastWestTeamRegions(regionPlayerCount, bounds);
    if (regions == null || regions.length !== aliveMajorIds.length) {
      console.log("EVW PLAYER PLACEMENT: could not determine designated team regions; retaining original starts");
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
    console.log(`EVW PLAYER PLACEMENT: attempting ${attempt.label}`);
    const candidateSolution = solveJointStartPositionsWithRestarts(
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
    console.log(`EVW PLAYER PLACEMENT: rejected ${attempt.label}: ${failures.join("; ")}`);
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
  while (solution == null && enforcedStrictPlayerIds.size > 0) {
    let playerToRelax = -1;
    let fewestCandidates = Number.POSITIVE_INFINITY;
    for (const playerId of enforcedStrictPlayerIds) {
      const playerIndex = aliveMajorIds.indexOf(playerId);
      const candidateCount = buildJointStartCandidates(
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
      `EVW PLAYER PLACEMENT: restarting after isolating player=${playerToRelax} ` +
      `with only ${fewestCandidates} strict candidate(s)`
    );
    const candidateSolution = solveJointStartPositionsWithRestarts(
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
      "EVW PLAYER PLACEMENT: strict regional restarts exhausted; applying hard-region emergency placement"
    );
    solution = buildHardRegionEmergencySolution(aliveMajorIds, tileSets);
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
      `EVW PLAYER PLACEMENT: every ${playerCount !== 0 ? "designated-region" : "whole-map"} ` +
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
    console.log(`EVW PLAYER PLACEMENT: player=${playerId} x=${candidate.x} y=${candidate.y}`);
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
      `EVW PLAYER PLACEMENT: committed layout failed verification (${committedFailures.join("; ")}); ` +
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
    if (exact || lakeFallback) {
      clearStrictStartBiasFailure(playerId);
    } else {
      recordStrictStartBiasFailure(
        playerId,
        "the player's requirement was isolated only after every complete strict placement restart failed"
      );
    }
  }
  console.log(
    `EVW PLAYER PLACEMENT: applied ${chosenAttempt.label} with Fresh Water and ` +
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
      console.error(`EVW PLAYER PLACEMENT: original advanced regions could not be rebuilt: ${regionError?.stack ?? regionError}`);
    }
    console.error(
      `EVW PLAYER PLACEMENT: unexpected solver error; restored every original start: ${error?.stack ?? error}`
    );
  }
}

function armGlobalTeamStartHandler() {
  if (teamStartHandlerArmed) {
    return;
  }
  teamStartHandlerArmed = true;

  // Arming during RequestMapInitData registers this listener after the chosen
  // map's GenerateMap listener, so the selected placement is a post-process.
  // The map-generation event does not reliably dispatch more than one handler
  // from the same script. Keep placement and Reef creation in one ordered pass.
  engine.on("GenerateMap", () => {
    // MPT: the Map Options exist only in multiplayer setup; without them (single
    // player) the map is left exactly as its own script made it.
    if (Configuration.getMapValue("EvWPlayerPlacement") == null) {
      console.log("EVW PLAYER PLACEMENT: not a multiplayer setup; map left unchanged");
      return;
    }
    // MPT: a missing option means Off (removed when Advanced Settings Pro supplies resources).
    const resourceSetting = Configuration.getMapValue("EvWResourceSystem") ?? "EVW_RESOURCE_SYSTEM_OFF";
    if (resourceSetting === "EVW_RESOURCE_SYSTEM_ON") {
      generateGlobalResources();
    } else {
      console.log("EVW RESOURCES: custom resource system disabled; retaining normal map resources");
    }
    applyGlobalTeamStartsSafely();
    try {
      addCoastalStartReefs();
    } catch (error) {
      console.error(`EVW COASTAL REEFS: skipped after unexpected error: ${error?.stack ?? error}`);
    }
  });
  console.log("EVW PLAYER PLACEMENT: post-process armed");
}

engine.on("RequestMapInitData", armGlobalTeamStartHandler);
console.log("EVW PLAYER PLACEMENT: loaded");

export { addCoastalStartReefs, applyGlobalTeamStarts };
