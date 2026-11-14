// Pangaea Ultima: the game's Voronoi Pangaea pipeline with one solid central
// continent. After the Voronoi pass the continent's core is filled, enclosed
// seas become land, land touching the continent joins it, and other land keeps
// a clear ocean gap from it. The islands beyond that gap are the Distant Lands:
// they join the other landmass region, so they host Exploration's Treasure Fleets.
// The terrain and snow passes apply the Map and Terrain Settings
// (./generation/), as on the multiplayer copies of the base maps.
import { assignAdvancedStartRegions } from '../../base-standard/maps/assign-advanced-start-region.js';
import { assignStartPositionsFromHexMap } from '../../base-standard/maps/assign-starting-plots.js';
import { generateDiscoveries } from '../../base-standard/maps/discovery-generator.js';
import { g_HillTerrain, g_MountainTerrain, g_PolarWaterRows } from '../../base-standard/maps/map-globals.js';
import { generateResources } from '../../base-standard/maps/resource-generator.js';
import { GenerationContext, GenerationPhases } from '../../base-standard/scripts/common-generation.js';
import { FeatureType, TerrainType } from '../../base-standard/scripts/voronoi-types.js';
import { VoronoiPangaeaUltima } from './scripts/voronoi_maps/pangaea-ultima.js';
import { generateMapFeatures } from './generation/bbm-map-features.js';
import { generateSnow } from './generation/bbm-snow.js';
import { adjacentPlots, isLandPlot } from './bbm-plots.js';
// Loads the multiplayer Player Placement pass with the map (it arms itself once).
import './scripts/global-team-starts.js';

const CORE_RADIUS_X = 0.43;
const CORE_RADIUS_Y = 0.38;
const DISTANT_LAND_GAP = 4;
const MOUNTAIN_KEEP_PERCENT = 70;   // island mountains kept; the rest become Rough (Hills)

const isLand = (tile) => tile.terrainType !== TerrainType.Ocean && tile.terrainType !== TerrainType.Coast;
const isWater = (tile) => !isLand(tile);

function setLand(tile, primaryId) {
	tile.terrainType = TerrainType.Flat;
	tile.featureType = FeatureType.None;
	tile.playerLandmassId = primaryId;
	tile.majorPlayerRegionId = -1;
}

/** Sinks the tile, with any volcano the Voronoi pass gave it. */
function setOcean(tile) {
	tile.terrainType = TerrainType.Ocean;
	tile.featureType = FeatureType.None;
	tile.playerLandmassId = -1;
	tile.majorPlayerRegionId = -1;
}

/** Breadth-first walk from the seeds through tiles accepted by `canEnter`; returns the visited set of tiles. */
function flood(hexMap, tiles, seeds, canEnter) {
	const visited = new Set(seeds);
	const queue = [...seeds];
	for (let index = 0; index < queue.length; index++) {
		const tile = queue[index];
		hexMap.forNeighbors(tile.coord.x, tile.coord.y, tiles, (neighbor) => {
			if (!visited.has(neighbor) && canEnter(neighbor)) {
				visited.add(neighbor);
				queue.push(neighbor);
			}
		});
	}
	return visited;
}

/** The player landmass with the most land tiles. */
function findPrimaryLandmass(tiles) {
	const counts = new Map();
	for (const row of tiles) {
		for (const tile of row) {
			if (isLand(tile) && tile.playerLandmassId > 0) counts.set(tile.playerLandmassId, (counts.get(tile.playerLandmassId) ?? 0) + 1);
		}
	}
	let primaryId = -1;
	let largest = -1;
	for (const [id, count] of counts) {
		if (count > largest) { primaryId = id; largest = count; }
	}
	return primaryId;
}

/** The continent's bounding box (east < west when it has no land). */
function continentBounds(tiles, primaryId) {
	let west = Infinity, east = -1, south = Infinity, north = -1;
	for (const row of tiles) {
		for (const tile of row) {
			if (!isLand(tile) || tile.playerLandmassId !== primaryId) continue;
			west = Math.min(west, tile.coord.x); east = Math.max(east, tile.coord.x);
			south = Math.min(south, tile.coord.y); north = Math.max(north, tile.coord.y);
		}
	}
	return { west, east, south, north };
}

/** Fill water inside a rounded rectangle (fourth-power superellipse) over the continent, so no deep channel cuts its core. */
function solidifyCore(tiles, primaryId) {
	const { west, east, south, north } = continentBounds(tiles, primaryId);
	if (east < west || north < south) return 0;
	const centerX = (west + east) * 0.5;
	const centerY = (south + north) * 0.5;
	const radiusX = Math.max(2, (east - west) * CORE_RADIUS_X);
	const radiusY = Math.max(2, (north - south) * CORE_RADIUS_Y);
	let filled = 0;
	for (let y = south; y <= north; y++) {
		for (let x = west; x <= east; x++) {
			const inside = Math.abs((x - centerX) / radiusX) ** 4 + Math.abs((y - centerY) / radiusY) ** 4 <= 1;
			if (inside && isWater(tiles[y][x])) { setLand(tiles[y][x], primaryId); filled++; }
		}
	}
	return filled;
}

/** Water bodies not reachable from the map edge, bordered mostly by the continent, become land. */
function fillEnclosedSeas(hexMap, tiles, primaryId) {
	const height = tiles.length;
	const width = tiles[0].length;
	const edgeWater = [];
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			if ((y === 0 || y === height - 1 || x === 0 || x === width - 1) && isWater(tiles[y][x])) edgeWater.push(tiles[y][x]);
		}
	}
	const exterior = flood(hexMap, tiles, edgeWater, isWater);
	const inspected = new Set();
	let filled = 0;
	for (const row of tiles) {
		for (const tile of row) {
			if (isLand(tile) || exterior.has(tile) || inspected.has(tile)) continue;
			const component = flood(hexMap, tiles, [tile], (neighbor) => isWater(neighbor) && !exterior.has(neighbor));
			let primaryBorder = 0;
			let foreignBorder = 0;
			for (const water of component) {
				inspected.add(water);
				hexMap.forNeighbors(water.coord.x, water.coord.y, tiles, (neighbor) => {
					if (!isLand(neighbor)) return;
					if (neighbor.playerLandmassId === primaryId) primaryBorder++;
					else foreignBorder++;
				});
			}
			if (primaryBorder > 0 && primaryBorder >= foreignBorder * 2) {
				for (const water of component) setLand(water, primaryId);
				filled += component.size;
			}
		}
	}
	return filled;
}

/** The land tile of the continent nearest the map center. */
function centralTile(tiles, primaryId, isPrimaryLand) {
	const centerX = (tiles[0].length - 1) * 0.5;
	const centerY = (tiles.length - 1) * 0.5;
	let seed = null;
	let best = Infinity;
	for (const row of tiles) {
		for (const tile of row) {
			if (!isPrimaryLand(tile)) continue;
			const distance = (tile.coord.x - centerX) ** 2 + (tile.coord.y - centerY) ** 2;
			if (distance < best) { best = distance; seed = tile; }
		}
	}
	return seed;
}

/** Every land tile connected to the continent joins it. */
function joinAttachedLand(hexMap, tiles, primaryId) {
	const seed = centralTile(tiles, primaryId, (tile) => isLand(tile) && tile.playerLandmassId === primaryId);
	if (seed == null) return 0;
	let joined = 0;
	for (const tile of flood(hexMap, tiles, [seed], isLand)) {
		if (tile.playerLandmassId !== primaryId) { tile.playerLandmassId = primaryId; tile.majorPlayerRegionId = -1; joined++; }
	}
	return joined;
}

/** Other land closer than DISTANT_LAND_GAP tiles to the continent sinks (DISTANT_LAND_GAP - 1 water tiles between), then every coast is rebuilt from the final shape. */
function enforceDistantLandGap(hexMap, tiles, primaryId) {
	const distance = new Map();
	const queue = [];
	for (const row of tiles) {
		for (const tile of row) {
			if (isLand(tile) && tile.playerLandmassId === primaryId) { distance.set(tile, 0); queue.push(tile); }
		}
	}
	for (let index = 0; index < queue.length; index++) {
		const tile = queue[index];
		const next = distance.get(tile) + 1;
		if (next >= DISTANT_LAND_GAP) continue;
		hexMap.forNeighbors(tile.coord.x, tile.coord.y, tiles, (neighbor) => {
			if (!distance.has(neighbor)) { distance.set(neighbor, next); queue.push(neighbor); }
		});
	}
	let trimmed = 0;
	for (const row of tiles) {
		for (const tile of row) {
			if (isLand(tile) && tile.playerLandmassId !== primaryId && distance.has(tile)) { setOcean(tile); trimmed++; }
			else if (isWater(tile)) setOcean(tile);
		}
	}
	hexMap.validateCoasts();
	return trimmed;
}

/** After terrain generation, land connected to the continent on the final map belongs to it. */
function joinFinalAttachedLand(tiles, primaryId) {
	const seedTile = centralTile(tiles, primaryId, (tile) => tile.playerLandmassId === primaryId && isLandPlot(tile.coord.x, tile.coord.y));
	if (seedTile == null) return 0;
	const seed = { x: seedTile.coord.x, y: seedTile.coord.y };
	const visited = new Set([GameplayMap.getIndexFromXY(seed.x, seed.y)]);
	const queue = [seed];
	let corrected = 0;
	for (let index = 0; index < queue.length; index++) {
		const location = queue[index];
		if (GameplayMap.getLandmassRegionId(location.x, location.y) !== primaryId) {
			TerrainBuilder.setLandmassRegionId(location.x, location.y, primaryId);
			tiles[location.y][location.x].playerLandmassId = primaryId;
			corrected++;
		}
		TerrainBuilder.removePlotTag(location.x, location.y, PlotTags.PLOT_TAG_ISLAND);
		for (const adjacent of adjacentPlots(location)) {
			const adjacentIndex = GameplayMap.getIndexFromXY(adjacent.x, adjacent.y);
			if (!visited.has(adjacentIndex) && isLandPlot(adjacent.x, adjacent.y)) {
				visited.add(adjacentIndex);
				queue.push(adjacent);
			}
		}
	}
	return corrected;
}

/**
 * On the final map: every island tile joins the other landmass region (the
 * Distant Lands to the continent's players). Island mountains stay with
 * MOUNTAIN_KEEP_PERCENT and otherwise become Rough (Hills).
 */
function markDistantIslands(primaryId) {
	const distantId = primaryId === LandmassRegion.LANDMASS_REGION_EAST ? LandmassRegion.LANDMASS_REGION_WEST
		: primaryId === LandmassRegion.LANDMASS_REGION_WEST ? LandmassRegion.LANDMASS_REGION_EAST : -1;
	if (distantId < 0) {
		console.log(`BBM pangaea ultima: continent region ${primaryId} is neither East nor West; islands left unmarked`);
		return;
	}
	const width = GameplayMap.getGridWidth();
	const height = GameplayMap.getGridHeight();
	let marked = 0;
	let leveled = 0;
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			if (!GameplayMap.hasPlotTag(x, y, PlotTags.PLOT_TAG_ISLAND) || GameplayMap.isWater(x, y)) continue;
			TerrainBuilder.setLandmassRegionId(x, y, distantId);
			marked++;
			// Volcanoes and Natural Wonders keep their mountain.
			if (GameplayMap.getTerrainType(x, y) !== g_MountainTerrain || GameplayMap.getFeatureType(x, y) !== FeatureTypes.NO_FEATURE) continue;
			const roll = TerrainBuilder.getRandomNumber(100, "Pangaea Ultima island mountain");
			if (roll >= MOUNTAIN_KEEP_PERCENT) {
				TerrainBuilder.setTerrainType(x, y, g_HillTerrain);
				leveled++;
			}
		}
	}
	console.log(`BBM pangaea ultima: Distant Lands region=${distantId} islandTiles=${marked} mountainsToRough=${leveled}`);
}

function requestMapData(initParams) {
	engine.call("SetMapInitData", initParams);
}

function generateMap() {
	const iWidth = GameplayMap.getGridWidth();
	const iHeight = GameplayMap.getGridHeight();
	if (GameInfo.Maps.lookup(GameplayMap.getMapSize()) == null) return;
	const voronoiMap = new VoronoiPangaeaUltima();
	switch (Configuration.getMapValue("SeaLevel")) {
		case "SEA_LEVEL_LOW": voronoiMap.setSelectedVariantKey("Sea Level", "Low"); break;
		case "SEA_LEVEL_HIGH": voronoiMap.setSelectedVariantKey("Sea Level", "High"); break;
	}
	voronoiMap.init({ x: iWidth, y: iHeight });
	voronoiMap.setPrimaryMapSetting(["totalPlayers"], Players.getAliveMajorIds().length);
	voronoiMap.simulate();

	const hexMap = voronoiMap.getHexTiles();
	const tiles = hexMap.getTiles();
	const primaryId = findPrimaryLandmass(tiles);
	if (primaryId > 0) {
		const core = solidifyCore(tiles, primaryId);
		const seas = fillEnclosedSeas(hexMap, tiles, primaryId);
		const joined = joinAttachedLand(hexMap, tiles, primaryId);
		const trimmed = enforceDistantLandGap(hexMap, tiles, primaryId);
		console.log(`BBM pangaea ultima: core=${core} enclosedSeas=${seas} joined=${joined} trimmed=${trimmed}`);
	}

	// Snow and resources follow the final continent pass.
	const context = new GenerationContext();
	context.phases &= ~(GenerationPhases.Snow | GenerationPhases.Resources);
	generateMapFeatures(hexMap, context);
	if (primaryId > 0) {
		console.log(`BBM pangaea ultima: final attached-land corrections=${joinFinalAttachedLand(tiles, primaryId)}`);
		markDistantIslands(primaryId);
		AreaBuilder.recalculateAreas();
	}
	generateSnow(iWidth, iHeight);
	generateResources(iWidth, iHeight);

	voronoiMap.createMajorPlayerAreas((tile) => StartPositioner.getPlotFertilityForCoord(tile.coord.x, tile.coord.y));
	const startPositions = assignStartPositionsFromHexMap(hexMap);
	generateDiscoveries(iWidth, iHeight, startPositions, g_PolarWaterRows);
	FertilityBuilder.recalculate();
	assignAdvancedStartRegions();
}

engine.on("RequestMapInitData", requestMapData);
engine.on("GenerateMap", generateMap);
console.log("Loaded Pangaea Ultima");
