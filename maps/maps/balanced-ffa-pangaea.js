import { assignAdvancedStartRegions } from './assign-advanced-start-region.js';
import { PlayerRegion, assignStartPositionsFromTiles } from './assign-starting-plots.js';
import { generateDiscoveries } from './discovery-generator.js';
import { generateLakes, addHills, buildRainfallMap } from './elevation-terrain-generator.js';
import { designateBiomes, addFeatures } from './feature-biome-generator.js';
import { dumpContinents, dumpTerrain, dumpElevation, dumpRainfall, dumpBiomes, dumpFeatures, dumpResources } from './map-debug-helpers.js';
import { g_FlatTerrain, g_CoastTerrain, g_OceanTerrain, g_HillTerrain, g_MountainTerrain, g_VolcanoFeature, g_NavigableRiverTerrain, g_PolarWaterRows } from './map-globals.js';
// Use the installed game's resource pipeline (rewritten in Civ VII 1.5).
// Keep terrain and player placement local, but do not use the pre-1.5 resource helpers.
import { replaceIslandResources } from '../../../base-standard/maps/map-utilities.js';
import { addNaturalWonders } from './natural-wonder-generator.js';
import { generateResources } from '../../../base-standard/maps/resource-generator.js';
import { generateSnow, dumpPermanentSnow } from './snow-generator.js';
import { TerrainType } from '../scripts/voronoi-types.js';
import { VoronoiFfaPangaea } from '../scripts/voronoi_maps/ffa-pangaea.js';
import { addCoastalStartReefs } from '../scripts/global-team-starts.js';

function solidifyPrimaryContinentCore(tiles, primaryPlayerLandmassId, primaryLandmassId) {
  const height = tiles.length;
  const width = height > 0 ? tiles[0].length : 0;
  if (width === 0 || primaryPlayerLandmassId < 0 || primaryLandmassId < 0) return 0;

  let west = width;
  let east = -1;
  let south = height;
  let north = -1;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const tile = tiles[y][x];
      const isLand = tile.terrainType !== TerrainType.Ocean &&
                     tile.terrainType !== TerrainType.Coast;
      if (isLand && tile.playerLandmassId === primaryPlayerLandmassId) {
        west = Math.min(west, x);
        east = Math.max(east, x);
        south = Math.min(south, y);
        north = Math.max(north, y);
      }
    }
  }
  if (east < west || north < south) return 0;

  const centerX = (west + east) * 0.5;
  const centerY = (south + north) * 0.5;
  const radiusX = Math.max(2, (east - west) * 0.43);
  const radiusY = Math.max(2, (north - south) * 0.38);
  let filledTileCount = 0;

  // A fourth-power superellipse forms a broad rounded rectangle. Voronoi
  // terrain still controls the outer coastline, but ocean cannot carve deep
  // channels through the continent's competitive expansion core.
  for (let y = south; y <= north; y++) {
    for (let x = west; x <= east; x++) {
      const normalizedX = Math.abs((x - centerX) / radiusX);
      const normalizedY = Math.abs((y - centerY) / radiusY);
      const insideCore = Math.pow(normalizedX, 4) + Math.pow(normalizedY, 4) <= 1;
      const tile = tiles[y][x];
      const isWater = tile.terrainType === TerrainType.Ocean ||
                      tile.terrainType === TerrainType.Coast;
      if (insideCore && isWater) {
        tile.terrainType = TerrainType.Flat;
        tile.landmassId = primaryLandmassId;
        tile.playerLandmassId = primaryPlayerLandmassId;
        tile.majorPlayerRegionId = -1;
        filledTileCount++;
      }
    }
  }
  return filledTileCount;
}

function fillEnclosedPrimarySeas(tiles, primaryPlayerLandmassId, primaryLandmassId) {
  const height = tiles.length;
  const width = height > 0 ? tiles[0].length : 0;
  if (width === 0 || primaryPlayerLandmassId < 0 || primaryLandmassId < 0) return 0;

  const isWater = (tile) => tile.terrainType === TerrainType.Ocean ||
                            tile.terrainType === TerrainType.Coast;
  const neighbors = (x, y) => {
    const diagonalOffset = y % 2 === 0 ? -1 : 1;
    const coords = [
      [x - 1, y], [x + 1, y],
      [x, y - 1], [x + diagonalOffset, y - 1],
      [x, y + 1], [x + diagonalOffset, y + 1]
    ];
    return coords.filter(([nx, ny]) => nx >= 0 && nx < width && ny >= 0 && ny < height);
  };
  const exterior = Array.from({ length: height }, () => new Array(width).fill(false));
  const queue = [];
  const enqueueExterior = (x, y) => {
    if (!exterior[y][x] && isWater(tiles[y][x])) {
      exterior[y][x] = true;
      queue.push([x, y]);
    }
  };

  for (let x = 0; x < width; x++) {
    enqueueExterior(x, 0);
    enqueueExterior(x, height - 1);
  }
  for (let y = 0; y < height; y++) {
    enqueueExterior(0, y);
    enqueueExterior(width - 1, y);
  }
  for (let index = 0; index < queue.length; index++) {
    const [x, y] = queue[index];
    for (const [nx, ny] of neighbors(x, y)) {
      enqueueExterior(nx, ny);
    }
  }

  const inspected = Array.from({ length: height }, () => new Array(width).fill(false));
  let filledTileCount = 0;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (exterior[y][x] || inspected[y][x] || !isWater(tiles[y][x])) continue;

      const component = [];
      const componentQueue = [[x, y]];
      inspected[y][x] = true;
      let primaryBorderCount = 0;
      let foreignBorderCount = 0;
      for (let index = 0; index < componentQueue.length; index++) {
        const [cx, cy] = componentQueue[index];
        component.push([cx, cy]);
        for (const [nx, ny] of neighbors(cx, cy)) {
          const neighbor = tiles[ny][nx];
          if (isWater(neighbor)) {
            if (!exterior[ny][nx] && !inspected[ny][nx]) {
              inspected[ny][nx] = true;
              componentQueue.push([nx, ny]);
            }
          } else if (neighbor.playerLandmassId === primaryPlayerLandmassId ||
                     neighbor.landmassId === primaryLandmassId) {
            primaryBorderCount++;
          } else {
            foreignBorderCount++;
          }
        }
      }

      if (primaryBorderCount > 0 && primaryBorderCount >= foreignBorderCount * 2) {
        for (const [fillX, fillY] of component) {
          const tile = tiles[fillY][fillX];
          tile.terrainType = TerrainType.Flat;
          tile.landmassId = primaryLandmassId;
          tile.playerLandmassId = primaryPlayerLandmassId;
          tile.majorPlayerRegionId = -1;
          filledTileCount++;
        }
      }
    }
  }
  return filledTileCount;
}

function reclassifyAttachedDistantLand(tiles, primaryPlayerLandmassId, primaryLandmassId) {
  const height = tiles.length;
  const width = height > 0 ? tiles[0].length : 0;
  if (width === 0 || primaryPlayerLandmassId < 0 || primaryLandmassId < 0) return 0;

  const isLand = (tile) => tile.terrainType !== TerrainType.Ocean &&
                           tile.terrainType !== TerrainType.Coast;
  const neighbors = (x, y) => {
    const diagonalOffset = y % 2 === 0 ? -1 : 1;
    const coords = [
      [x - 1, y], [x + 1, y],
      [x, y - 1], [x + diagonalOffset, y - 1],
      [x, y + 1], [x + diagonalOffset, y + 1]
    ];
    return coords.filter(([nx, ny]) => nx >= 0 && nx < width && ny >= 0 && ny < height);
  };

  // The central Pangaea always contains primary-player land. Starting from
  // the primary tile nearest the map center identifies its final connected
  // component after core and enclosed-sea filling have finished.
  const centerX = (width - 1) * 0.5;
  const centerY = (height - 1) * 0.5;
  let seed = null;
  let seedDistance = Number.MAX_SAFE_INTEGER;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const tile = tiles[y][x];
      if (!isLand(tile) || tile.playerLandmassId !== primaryPlayerLandmassId) continue;
      const dx = x - centerX;
      const dy = y - centerY;
      const distance = dx * dx + dy * dy;
      if (distance < seedDistance) {
        seedDistance = distance;
        seed = [x, y];
      }
    }
  }
  if (seed == null) return 0;

  const visited = Array.from({ length: height }, () => new Array(width).fill(false));
  const queue = [seed];
  visited[seed[1]][seed[0]] = true;
  let reclassifiedTileCount = 0;

  for (let index = 0; index < queue.length; index++) {
    const [x, y] = queue[index];
    const tile = tiles[y][x];
    if (tile.playerLandmassId !== primaryPlayerLandmassId ||
        tile.landmassId !== primaryLandmassId) {
      tile.playerLandmassId = primaryPlayerLandmassId;
      tile.landmassId = primaryLandmassId;
      tile.majorPlayerRegionId = -1;
      reclassifiedTileCount++;
    }

    for (const [nx, ny] of neighbors(x, y)) {
      if (!visited[ny][nx] && isLand(tiles[ny][nx])) {
        visited[ny][nx] = true;
        queue.push([nx, ny]);
      }
    }
  }
  return reclassifiedTileCount;
}

function enforceDistantLandOceanGap(tiles, primaryPlayerLandmassId) {
  const height = tiles.length;
  const width = height > 0 ? tiles[0].length : 0;
  if (width === 0 || primaryPlayerLandmassId < 0) {
    return { trimmedTiles: 0, rebuiltCoastTiles: 0 };
  }

  const isLand = (tile) => tile.terrainType !== TerrainType.Ocean &&
                           tile.terrainType !== TerrainType.Coast;
  const neighbors = (x, y) => {
    const diagonalOffset = y % 2 === 0 ? -1 : 1;
    const coords = [
      [x - 1, y], [x + 1, y],
      [x, y - 1], [x + diagonalOffset, y - 1],
      [x, y + 1], [x + diagonalOffset, y + 1]
    ];
    return coords.filter(([nx, ny]) => nx >= 0 && nx < width && ny >= 0 && ny < height);
  };

  // Measure final shoreline distance, not just the original Voronoi seed
  // distance. A distance of four leaves coast on both shores with a genuine
  // ocean tile between the two coastal bands.
  const distanceFromPrimary = Array.from(
    { length: height },
    () => new Array(width).fill(Number.MAX_SAFE_INTEGER)
  );
  const queue = [];
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const tile = tiles[y][x];
      if (isLand(tile) && tile.playerLandmassId === primaryPlayerLandmassId) {
        distanceFromPrimary[y][x] = 0;
        queue.push([x, y]);
      }
    }
  }
  for (let index = 0; index < queue.length; index++) {
    const [x, y] = queue[index];
    const nextDistance = distanceFromPrimary[y][x] + 1;
    for (const [nx, ny] of neighbors(x, y)) {
      if (nextDistance < distanceFromPrimary[ny][nx]) {
        distanceFromPrimary[ny][nx] = nextDistance;
        queue.push([nx, ny]);
      }
    }
  }

  let trimmedTileCount = 0;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const tile = tiles[y][x];
      if (isLand(tile) &&
          tile.playerLandmassId !== primaryPlayerLandmassId &&
          distanceFromPrimary[y][x] < 4) {
        tile.terrainType = TerrainType.Ocean;
        tile.landmassId = 0;
        tile.playerLandmassId = 0;
        tile.majorPlayerRegionId = -1;
        trimmedTileCount++;
      }
    }
  }

  // The original coast was calculated before the trim. Rebuild every coast
  // from the final land shape so removed island tiles cannot remain as stale
  // coastal-water bridges.
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const tile = tiles[y][x];
      if (!isLand(tile)) {
        tile.terrainType = TerrainType.Ocean;
        tile.landmassId = 0;
        tile.playerLandmassId = 0;
        tile.majorPlayerRegionId = -1;
      }
    }
  }
  let rebuiltCoastTileCount = 0;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const landTile = tiles[y][x];
      if (!isLand(landTile)) continue;
      for (const [nx, ny] of neighbors(x, y)) {
        const waterTile = tiles[ny][nx];
        if (waterTile.terrainType === TerrainType.Ocean) {
          waterTile.terrainType = TerrainType.Coast;
          waterTile.landmassId = landTile.landmassId;
          waterTile.playerLandmassId = landTile.playerLandmassId;
          rebuiltCoastTileCount++;
        }
      }
    }
  }
  return { trimmedTiles: trimmedTileCount, rebuiltCoastTiles: rebuiltCoastTileCount };
}

function enforceFinalPrimaryLandConnectivity(tiles, primaryPlayerLandmassId, primaryLandmassId) {
  const height = GameplayMap.getGridHeight();
  const width = GameplayMap.getGridWidth();
  if (width === 0 || height === 0) return 0;

  const isGameplayLand = (x, y) => {
    const terrain = GameplayMap.getTerrainType(x, y);
    return terrain !== g_OceanTerrain && terrain !== g_CoastTerrain;
  };
  const neighbors = (location) => {
    const result = [];
    for (let direction = 0; direction < 6; direction++) {
      const adjacent = GameplayMap.getAdjacentPlotLocation(location, direction);
      if (adjacent != null && adjacent.x >= 0 && adjacent.x < width && adjacent.y >= 0 && adjacent.y < height) {
        result.push(adjacent);
      }
    }
    return result;
  };

  const centerX = (width - 1) * 0.5;
  const centerY = (height - 1) * 0.5;
  let seed = null;
  let seedDistance = Number.MAX_SAFE_INTEGER;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (!isGameplayLand(x, y) || tiles[y][x].playerLandmassId !== primaryPlayerLandmassId) continue;
      const dx = x - centerX;
      const dy = y - centerY;
      const distance = dx * dx + dy * dy;
      if (distance < seedDistance) {
        seedDistance = distance;
        seed = { x, y };
      }
    }
  }
  if (seed == null) return 0;

  const visited = new Set();
  const queue = [seed];
  visited.add(GameplayMap.getIndexFromXY(seed.x, seed.y));
  let correctedTileCount = 0;
  for (let index = 0; index < queue.length; index++) {
    const location = queue[index];
    const tile = tiles[location.y][location.x];
    const currentRegionId = GameplayMap.getLandmassRegionId(location.x, location.y);
    if (tile.playerLandmassId !== primaryPlayerLandmassId ||
        tile.landmassId !== primaryLandmassId ||
        currentRegionId !== primaryPlayerLandmassId) {
      tile.playerLandmassId = primaryPlayerLandmassId;
      tile.landmassId = primaryLandmassId;
      tile.majorPlayerRegionId = -1;
      TerrainBuilder.setLandmassRegionId(location.x, location.y, primaryPlayerLandmassId);
      correctedTileCount++;
    }
    TerrainBuilder.removePlotTag(location.x, location.y, PlotTags.PLOT_TAG_ISLAND);

    for (const adjacent of neighbors(location)) {
      const adjacentIndex = GameplayMap.getIndexFromXY(adjacent.x, adjacent.y);
      if (!visited.has(adjacentIndex) && isGameplayLand(adjacent.x, adjacent.y)) {
        visited.add(adjacentIndex);
        queue.push(adjacent);
      }
    }
  }
  return correctedTileCount;
}

console.log("Generating EvW Balanced FFA Pangaea");
function requestMapData(initParams) {
  console.log(initParams.width);
  console.log(initParams.height);
  console.log(initParams.topLatitude);
  console.log(initParams.bottomLatitude);
  console.log(initParams.wrapX);
  console.log(initParams.wrapY);
  console.log(initParams.mapSize);
  engine.call("SetMapInitData", initParams);
}
function generateMap() {
  console.log("Generating a map!");
  console.log(`Age - ${GameInfo.Ages.lookup(Game.age).AgeType}`);
  const iWidth = GameplayMap.getGridWidth();
  const iHeight = GameplayMap.getGridHeight();
  const uiMapSize = GameplayMap.getMapSize();
  const mapInfo = GameInfo.Maps.lookup(uiMapSize);
  if (mapInfo == null) return;
  const iNumNaturalWonders = mapInfo.NumNaturalWonders;
  const iTilesPerLake = mapInfo.LakeGenerationFrequency;
  const iTotalPlayers = Players.getAliveMajorIds().length;
  const startTime = Date.now();
  const voronoiMap = new VoronoiFfaPangaea();
  const seaLevelType = Configuration.getMapValue("SeaLevel");
  console.log(`Sea Level - ${seaLevelType}`);
  switch (seaLevelType) {
    case "SEA_LEVEL_LOW":
      voronoiMap.setSelectedVariantKey("Sea Level", "Low");
      break;
    case "SEA_LEVEL_HIGH":
      voronoiMap.setSelectedVariantKey("Sea Level", "High");
      break;
  }
  voronoiMap.init({ x: iWidth, y: iHeight });
  voronoiMap.setPrimaryMapSetting(["totalPlayers"], iTotalPlayers);
  voronoiMap.simulate();
  const tiles = voronoiMap.getHexTiles().getTiles();
  const playerLandmassCounts = new Map();
  for (const row of tiles) {
    for (const tile of row) {
      const isLand = tile.terrainType !== TerrainType.Ocean &&
                     tile.terrainType !== TerrainType.Coast;
      if (isLand && tile.playerLandmassId > 0) {
        playerLandmassCounts.set(
          tile.playerLandmassId,
          (playerLandmassCounts.get(tile.playerLandmassId) || 0) + 1
        );
      }
    }
  }
  let primaryPlayerLandmassId = -1;
  let largestPlayerLandmassSize = -1;
  for (const [landmassId, tileCount] of playerLandmassCounts) {
    if (tileCount > largestPlayerLandmassSize) {
      primaryPlayerLandmassId = landmassId;
      largestPlayerLandmassSize = tileCount;
    }
  }
  const primaryLandmassCounts = new Map();
  for (const row of tiles) {
    for (const tile of row) {
      const isLand = tile.terrainType !== TerrainType.Ocean &&
                     tile.terrainType !== TerrainType.Coast;
      if (isLand && tile.playerLandmassId === primaryPlayerLandmassId) {
        primaryLandmassCounts.set(
          tile.landmassId,
          (primaryLandmassCounts.get(tile.landmassId) || 0) + 1
        );
      }
    }
  }
  let primaryLandmassId = -1;
  let primaryLandmassTileCount = -1;
  for (const [landmassId, tileCount] of primaryLandmassCounts) {
    if (tileCount > primaryLandmassTileCount) {
      primaryLandmassId = landmassId;
      primaryLandmassTileCount = tileCount;
    }
  }
  const filledCoreTiles = solidifyPrimaryContinentCore(
    tiles,
    primaryPlayerLandmassId,
    primaryLandmassId
  );
  const filledSeaTiles = fillEnclosedPrimarySeas(
    tiles,
    primaryPlayerLandmassId,
    primaryLandmassId
  );
  const reclassifiedAttachedTiles = reclassifyAttachedDistantLand(
    tiles,
    primaryPlayerLandmassId,
    primaryLandmassId
  );
  const distantLandOceanGap = enforceDistantLandOceanGap(
    tiles,
    primaryPlayerLandmassId
  );
  console.log("PANGAEA ULTIMA: deep-bay core tiles filled=" + filledCoreTiles);
  console.log("PANGAEA ULTIMA: enclosed sea tiles filled=" + filledSeaTiles);
  console.log("PANGAEA ULTIMA: attached distant-land tiles reclassified=" + reclassifiedAttachedTiles);
  console.log("PANGAEA ULTIMA: too-close distant-land tiles trimmed=" + distantLandOceanGap.trimmedTiles);
  console.log("PANGAEA ULTIMA: final shoreline coast tiles rebuilt=" + distantLandOceanGap.rebuiltCoastTiles);
  for (let y = 0; y < tiles.length; ++y) {
    for (let x = 0; x < tiles[y].length; ++x) {
      const tile = tiles[y][x];
      const isLand = tile.terrainType !== TerrainType.Ocean &&
                     tile.terrainType !== TerrainType.Coast;
      if (isLand && tile.playerLandmassId !== primaryPlayerLandmassId) {
        TerrainBuilder.addPlotTag(x, y, PlotTags.PLOT_TAG_ISLAND);
      } else if (isLand) {
        TerrainBuilder.removePlotTag(x, y, PlotTags.PLOT_TAG_ISLAND);
      }
      TerrainBuilder.setLandmassRegionId(x, y, tile.playerLandmassId);
      const type = (() => {
        switch (tile.terrainType) {
          case TerrainType.Flat:
            return g_FlatTerrain;
          case TerrainType.Mountainous:
          case TerrainType.Volcano:
            return g_MountainTerrain;
          case TerrainType.Rough:
            return g_HillTerrain;
          case TerrainType.Ocean:
            return g_OceanTerrain;
          case TerrainType.Coast:
            return g_CoastTerrain;
          default:
            return g_FlatTerrain;
        }
      })();
      TerrainBuilder.setTerrainType(x, y, type);
      if (tile.terrainType === TerrainType.Volcano) {
        TerrainBuilder.setFeatureType(x, y, {
          Feature: g_VolcanoFeature,
          Direction: -1,
          Elevation: 0
        });
      }
    }
  }
  const endTime = Date.now();
  console.log(`Initial Voronoi map generation took ${endTime - startTime} ms`);
  TerrainBuilder.validateAndFixTerrain();
  AreaBuilder.recalculateAreas();
  TerrainBuilder.stampContinents();
  generateLakes(iWidth, iHeight, iTilesPerLake);
  AreaBuilder.recalculateAreas();
  TerrainBuilder.buildElevation();
  addHills(iWidth, iHeight);
  buildRainfallMap(iWidth, iHeight);
  TerrainBuilder.modelRivers(5, 15, g_NavigableRiverTerrain);
  TerrainBuilder.validateAndFixTerrain();
  // Civ VII 1.5 removed defineNamedRivers; the native pipeline proceeds
  // from modelRivers to biomes without a separate river-naming call.
  designateBiomes(iWidth, iHeight);
  addNaturalWonders(iWidth, iHeight, iNumNaturalWonders);
  TerrainBuilder.addFloodplains(4, 10);
  addFeatures(iWidth, iHeight);
  TerrainBuilder.validateAndFixTerrain();
  AreaBuilder.recalculateAreas();
  const finalConnectivityCorrections = enforceFinalPrimaryLandConnectivity(
    tiles,
    primaryPlayerLandmassId,
    primaryLandmassId
  );
  console.log("PANGAEA ULTIMA: final attached-land corrections=" + finalConnectivityCorrections);
  AreaBuilder.recalculateAreas();
  TerrainBuilder.storeWaterData();
  generateSnow(iWidth, iHeight);
  dumpContinents(iWidth, iHeight);
  dumpTerrain(iWidth, iHeight);
  dumpElevation(iWidth, iHeight);
  dumpRainfall(iWidth, iHeight);
  dumpBiomes(iWidth, iHeight);
  dumpFeatures(iWidth, iHeight);
  dumpPermanentSnow(iWidth, iHeight);
  generateResources(iWidth, iHeight);
  let startPositions = [];
  voronoiMap.createMajorPlayerAreas(
    (tile) => StartPositioner.getPlotFertilityForCoord(tile.coord.x, tile.coord.y)
  );
  const playerRegions = Array.from({ length: iTotalPlayers }, () => new PlayerRegion());
  playerRegions.forEach((region, index) => {
    region.regionId = index;
  });
  for (const row of tiles) {
    for (const tile of row) {
      if (tile.playerLandmassId === primaryPlayerLandmassId &&
          tile.majorPlayerRegionId >= 0) {
        playerRegions[tile.majorPlayerRegionId].tiles.push({ x: tile.coord.x, y: tile.coord.y });
      }
    }
  }
  startPositions = assignStartPositionsFromTiles(playerRegions);
  // Run from this map's valid module context. Civ VII 1.5 no longer imports
  // standalone MapGenScripts reliably without a parent module.
  addCoastalStartReefs();
  replaceIslandResources(iWidth, iHeight, "RESOURCECLASS_TREASURE");
  generateDiscoveries(iWidth, iHeight, startPositions, g_PolarWaterRows);
  dumpResources(iWidth, iHeight);
  FertilityBuilder.recalculate();
  assignAdvancedStartRegions();
}
engine.on("RequestMapInitData", requestMapData);
engine.on("GenerateMap", generateMap);
console.log("Loaded EvW Balanced FFA Pangaea");
//# sourceMappingURL=pangaea-voronoi.js.map
