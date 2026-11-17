// Resource Settings for the multiplayer maps, run by the placement pass
// (maps/scripts/global-team-starts.js). Resource List All replaces the map's resources
// with the general pool (generateGlobalResources) and, once starts are final, deals
// matched pools to each player's region and stocks the islands (placeDealtResources).
// Resource List Standard scales the game's own resources (scaleGameResources).
// Resource Amount and Resource Clusters apply to either list.
import { replaceIslandResources } from '../../base-standard/maps/map-utilities.js';
import { DENSITY_TARGET } from '../../base-standard/maps/resource-placement-common.js';
import { adjacentPlot, adjacentPlots } from './bbm-plots.js';

const GENERAL_RESOURCES = [
	"RESOURCE_CAMELS",
	"RESOURCE_CLAY",
	"RESOURCE_COTTON",
	"RESOURCE_COWRIE",
	"RESOURCE_CRABS",
	"RESOURCE_FISH",
	"RESOURCE_LIMESTONE",
	"RESOURCE_MARBLE",
	"RESOURCE_HARDWOOD",
	"RESOURCE_HORSES",
	"RESOURCE_IRON",
	"RESOURCE_SALT",
	"RESOURCE_HIDES",
	"RESOURCE_PEARLS",
	"RESOURCE_TIN",
	"RESOURCE_WHALES",
	"RESOURCE_SILK",
	"RESOURCE_TURTLES",
	"RESOURCE_WILD_GAME",
	"RESOURCE_WOOL",
	"RESOURCE_COAL",
	"RESOURCE_DYES",
	"RESOURCE_NITER"
];

const MODERN_GENERAL_RESOURCES = ["RESOURCE_RUBBER", "RESOURCE_OIL"];

// Each player region is dealt one from each pool (neighbors get different ones).
// Options within a pool are matched (comparable value, a different yield), so no
// draw is worse than another.
const REGION_POOLS = [
	["RESOURCE_GOLD", "RESOURCE_SILVER", "RESOURCE_RUBIES", "RESOURCE_SPICES"],   // Wealth: +1 Gold and a second yield
	["RESOURCE_SUGAR", "RESOURCE_TEA", "RESOURCE_CITRUS", "RESOURCE_RICE"],       // Harvest: +1 Food and a second yield
	["RESOURCE_WINE", "RESOURCE_QUININE", "RESOURCE_COCOA", "RESOURCE_FURS"],     // Comfort: Capital Happiness and a Celebration yield
	["RESOURCE_GYPSUM", "RESOURCE_IVORY", "RESOURCE_LLAMAS", "RESOURCE_COFFEE", "RESOURCE_TOBACCO"]   // two yields in a Settlement
];

const OTHER_REGION_RESOURCES = [
	"RESOURCE_DATES",
	"RESOURCE_INCENSE",
	"RESOURCE_FLAX",
	"RESOURCE_KAOLIN",
	"RESOURCE_JADE",
	"RESOURCE_MANGOS",
	"RESOURCE_TRUFFLES",
	"RESOURCE_PITCH"
];

const MODERN_AGE = "AGE_MODERN";
const WATER_REGION = -1;
const ADJACENCY_PASSES = 3;

// Resource Amount and Resource Clusters (config/maps.sql).
// Amount scales the game's density, lower with Resource List All, which deals
// every resource; Clusters grow a share of deposits into patches, with the seed
// count lowered so the amount stays the same.
const RESOURCE_AMOUNTS = {
	BBM_MAPS_RESOURCE_AMOUNT_SPARSE: 0.65,
	BBM_MAPS_RESOURCE_AMOUNT_STANDARD: 1,
	BBM_MAPS_RESOURCE_AMOUNT_ABUNDANT: 1.35
};
const LIST_ALL_AMOUNTS = {
	BBM_MAPS_RESOURCE_AMOUNT_SPARSE: 0.85,
	BBM_MAPS_RESOURCE_AMOUNT_STANDARD: 1,
	BBM_MAPS_RESOURCE_AMOUNT_ABUNDANT: 1.15
};
const RESOURCE_CLUSTERS = {
	BBM_MAPS_RESOURCE_CLUSTERS_NONE: { chance: 0, size: 1 },
	BBM_MAPS_RESOURCE_CLUSTERS_STANDARD: { chance: 50, size: 2 },
	BBM_MAPS_RESOURCE_CLUSTERS_MORE: { chance: 75, size: 3 }
};
// Copies of each dealt resource scale with the region's land: one per
// TILES_PER_COPY tiles, from 1 up to MAX_COPIES; land in no player's region
// (islands without a start) is dealt nothing. The first copy lies within
// NEAR_RANGE of the start, the others farther out in the region, and the range
// holds at least NEAR_GENERAL general resources. General resources are then
// trimmed so each region keeps the map's density.
const MAX_COPIES = 3;
const TILES_PER_COPY = 100;
const NEAR_RANGE = { min: 2, max: 6 };
const NEAR_GENERAL = 4;
const OTHER_PER_REGION = 3;
const ISLAND_RESOURCES = 2;          // resources on every island without a start (Treasure in Exploration on island maps)
const DEFAULT_AMOUNT = "BBM_MAPS_RESOURCE_AMOUNT_STANDARD";
const DEFAULT_CLUSTERS = "BBM_MAPS_RESOURCE_CLUSTERS_NONE";
const CLUSTER_SUCCESS_RATE = 0.6;   // first estimate of a patch's neighbors accepting the resource
const FILL_ROUNDS = 3;              // seed-and-grow rounds topping the map up to the target

// ============================ Shared helpers ============================

function shuffleInPlace(values, label) {
	for (let i = values.length - 1; i > 0; i--) {
		const j = TerrainBuilder.getRandomNumber(i + 1, label);
		[values[i], values[j]] = [values[j], values[i]];
	}
	return values;
}

function mapSetting(table, key, fallback) {
	const value = Configuration.getMapValue(key);
	return { name: table[value] != null ? value : fallback, value: table[value] ?? table[fallback] };
}

/** Resource Amount (from the Resource List's table) and Resource Clusters as set up. */
function resourceSettings(amounts) {
	return {
		amount: mapSetting(amounts, "BBMResourceAmount", DEFAULT_AMOUNT),
		clusters: mapSetting(RESOURCE_CLUSTERS, "BBMResourceClusters", DEFAULT_CLUSTERS)
	};
}

function resolveResourceTypes(typeNames) {
	const result = [];
	for (const typeName of typeNames) {
		const definition = GameInfo.Resources.lookup(typeName);
		if (definition == null) {
			console.log(`BBM resources: ${typeName} is unavailable and will be skipped`);
			continue;
		}
		result.push(definition.$index);
	}
	return result;
}

const currentAgeType = () => GameInfo.Ages.lookup(Game.age)?.AgeType;

// Kept from generateGlobalResources for placeDealtResources: the plots a general
// resource can take, and those holding the one guaranteed copy of each.
let placeablePlotSet = new Set();
let guaranteedPlotSet = new Set();

/** The general pool for this Age (Oil and Rubber from Modern). */
function generalResourceTypes(ageType) {
	return resolveResourceTypes(ageType === MODERN_AGE ? [...GENERAL_RESOURCES, ...MODERN_GENERAL_RESOURCES] : GENERAL_RESOURCES);
}

const isIslandLand = (x, y) => !GameplayMap.isWater(x, y) && GameplayMap.hasPlotTag(x, y, PlotTags.PLOT_TAG_ISLAND);

/** The continent of a land tile, or the shared water region. */
function regionOf(x, y) {
	if (GameplayMap.isWater(x, y)) return WATER_REGION;
	const continent = GameplayMap.getContinentType(x, y);
	return continent == null ? WATER_REGION : continent;
}

// ============================ Player regions ============================

/**
 * Each player's region: the land on their start's continent closer to their start
 * than to any other start there, with its copies per dealt resource and its
 * neighboring regions.
 */
function buildPlayerRegions() {
	const width = GameplayMap.getGridWidth();
	const height = GameplayMap.getGridHeight();
	const starts = Players.getAliveMajorIds()
		.map((playerId) => ({ playerId, plotIndex: StartPositioner.getStartPosition(playerId) }))
		.filter((start) => start.plotIndex >= 0)
		.map((start) => ({ ...start, ...GameplayMap.getLocationFromIndex(start.plotIndex) }))
		.map((start) => ({ ...start, continent: regionOf(start.x, start.y) }));
	const owner = new Int32Array(width * height).fill(-1);
	const regions = starts.map((start) => ({ ...start, plots: [], neighbors: new Set(), copies: 0 }));
	const regionsByContinent = new Map();
	regions.forEach((region, index) => {
		if (!regionsByContinent.has(region.continent)) regionsByContinent.set(region.continent, []);
		regionsByContinent.get(region.continent).push(index);
	});
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			const continent = regionOf(x, y);
			const candidates = continent === WATER_REGION ? null : regionsByContinent.get(continent);
			if (candidates == null) continue;
			let best = -1;
			let bestDistance = Number.POSITIVE_INFINITY;
			for (const index of candidates) {
				const distance = GameplayMap.getPlotDistance(x, y, regions[index].x, regions[index].y);
				if (distance < bestDistance) { bestDistance = distance; best = index; }
			}
			const plotIndex = GameplayMap.getIndexFromXY(x, y);
			owner[plotIndex] = best;
			regions[best].plots.push(plotIndex);
		}
	}
	for (const [index, region] of regions.entries()) {
		region.copies = Math.max(1, Math.min(MAX_COPIES, Math.floor(region.plots.length / TILES_PER_COPY)));
		for (const plotIndex of region.plots) {
			for (const next of adjacentPlots(GameplayMap.getLocationFromIndex(plotIndex))) {
				const other = owner[GameplayMap.getIndexFromXY(next.x, next.y)];
				if (other >= 0 && other !== index) region.neighbors.add(other);
			}
		}
	}
	return regions;
}

/** Deal each region one option per pool (a different one from its dealt neighbors where possible) and OTHER_PER_REGION others. */
function dealRegionResources(regions) {
	const dealt = regions.map(() => []);
	REGION_POOLS.forEach((pool, poolIndex) => {
		let bag = [];
		const label = `BBM MAPS pool ${poolIndex + 1}`;
		regions.forEach((region, index) => {
			if (bag.length === 0) bag = shuffleInPlace([...pool], label);
			const taken = new Set([...region.neighbors].map((other) => dealt[other][poolIndex]));
			const pick = bag.findIndex((name) => !taken.has(name));
			dealt[index][poolIndex] = bag.splice(pick >= 0 ? pick : 0, 1)[0];
		});
	});
	regions.forEach((region, index) => {
		const others = shuffleInPlace([...OTHER_REGION_RESOURCES], `BBM MAPS region ${region.playerId} other resources`);
		dealt[index].push(...others.slice(0, OTHER_PER_REGION));
		console.log(`BBM resources: player=${region.playerId} tiles=${region.plots.length} copies=${region.copies} identity=${dealt[index].join(",")}`);
	});
	return dealt.map(resolveResourceTypes);
}

// ============================ Placement ============================

/** More than `maximumAllowed` adjacent plots already hold a resource. */
function hasAdjacentResource(x, y, maximumAllowed) {
	let adjacent = 0;
	for (const next of adjacentPlots({ x, y })) {
		if (GameplayMap.getResourceType(next.x, next.y) !== ResourceTypes.NO_RESOURCE && ++adjacent > maximumAllowed) return true;
	}
	return false;
}

// With Resource Clusters None no resource touches another; with Clusters on,
// only the clusters themselves put the same resource side by side.
// Resource List All: Coal forms in wet ground at the edge of vegetation, so its
// tiles (data/maps/resource-system.sql) must lie within WATER_RANGE of water, with
// at most EDGE_VEGETATION vegetated neighbors, preferably at least one.
const WATER_BOUND_RESOURCES = ["RESOURCE_COAL"];
const WATER_RANGE = 2;
const EDGE_VEGETATION = 2;
// Resource List All: the fewest tiles between two copies of a resource (it never clusters).
const TILES_BETWEEN = { RESOURCE_COAL: 5 };
let spacedOut = true;
let waterBound = new Set();
let vegetated = new Set();
let tilesBetween = new Map();   // resource index -> tiles between copies
let spacedCopies = new Map();   // resource index -> placed copies { x, y }

/** Read once per pass, after the map's own resources are cleared: spacing, the water rule and the spaced copies already placed (Resource List All only). */
function readSettings(listAll) {
	spacedOut = resourceSettings(RESOURCE_AMOUNTS).clusters.value.chance <= 0;
	waterBound = new Set(listAll ? resolveResourceTypes(WATER_BOUND_RESOURCES) : []);
	vegetated = new Set();
	for (const feature of GameInfo.Features) {
		if (feature.FeatureClassType === "FEATURE_CLASS_VEGETATED") vegetated.add(feature.$index);
	}
	tilesBetween = new Map(listAll ? Object.entries(TILES_BETWEEN).map(([type, tiles]) => [GameInfo.Resources.lookup(type)?.$index, tiles]).filter(([index]) => index != null) : []);
	spacedCopies = new Map([...tilesBetween.keys()].map((index) => [index, []]));
	if (spacedCopies.size === 0) return;
	for (let y = 0; y < GameplayMap.getGridHeight(); y++) {
		for (let x = 0; x < GameplayMap.getGridWidth(); x++) spacedCopies.get(GameplayMap.getResourceType(x, y))?.push({ x, y });
	}
}

/** Another copy of a spaced resource lies within its tiles between. */
function tooClose(x, y, resourceIndex) {
	const tiles = tilesBetween.get(resourceIndex);
	return tiles != null && spacedCopies.get(resourceIndex).some((copy) => GameplayMap.getPlotDistance(x, y, copy.x, copy.y) <= tiles);
}

/** A river, or a water tile (coast, lake, navigable river), within WATER_RANGE. */
function byWater(x, y) {
	if (GameplayMap.isRiver(x, y) || GameplayMap.isAdjacentToRivers(x, y, WATER_RANGE)) return true;
	const plots = GameplayMap.getPlotIndicesInRadius(x, y, WATER_RANGE);
	for (let i = 0; i < plots.length; i++) {
		const plot = GameplayMap.getLocationFromIndex(plots[i]);
		if (GameplayMap.isWater(plot.x, plot.y)) return true;
	}
	return false;
}

const vegetatedNeighbors = (x, y) => adjacentPlots({ x, y }).filter((next) => vegetated.has(GameplayMap.getFeatureType(next.x, next.y))).length;

/** The game allows the resource here, and a water-bound resource has water and lies at the edge of vegetation. */
function canPlace(x, y, resourceIndex) {
	return ResourceBuilder.canHaveResource(x, y, resourceIndex, true)
		&& (!waterBound.has(resourceIndex) || (byWater(x, y) && vegetatedNeighbors(x, y) <= EDGE_VEGETATION));
}

/** A water-bound resource away from vegetation counts one copy more, so it goes to a vegetation edge when one is free. */
const placementPenalty = (x, y, resourceIndex) => (waterBound.has(resourceIndex) && vegetatedNeighbors(x, y) === 0 ? 1 : 0);

/** Placing this resource here would crowd it: too close to its own copies, touching another resource (spaced out) or the same resource. */
function isCrowded(x, y, resourceIndex) {
	if (tooClose(x, y, resourceIndex)) return true;
	if (spacedOut) return hasAdjacentResource(x, y, 0);
	return adjacentPlots({ x, y }).some((next) => GameplayMap.getResourceType(next.x, next.y) === resourceIndex);
}

/** Placed copies per continent (and the water) and resource: general resources keep even counts within each. */
class RegionCounts {
	constructor() { this.counts = new Map(); this.regions = new Map(); }
	key(region, resourceIndex) { return region * 4096 + resourceIndex; }
	get(region, resourceIndex) { return this.counts.get(this.key(region, resourceIndex)) ?? 0; }
	add(region, resourceIndex) {
		this.counts.set(this.key(region, resourceIndex), this.get(region, resourceIndex) + 1);
		const totals = this.regions.get(region) ?? { tiles: 0, types: new Set() };
		totals.tiles++;
		totals.types.add(resourceIndex);
		this.regions.set(region, totals);
	}
	/** Copies per resource type placed in the region so far. */
	average(region) {
		const totals = this.regions.get(region);
		return totals ? totals.tiles / totals.types.size : 0;
	}
}

/** The candidate with the fewest copies in this region, for the plot at x, y (random tie-break). */
function pickEvenly(candidates, region, counts, x, y) {
	let best = -1;
	let bestScore = Number.POSITIVE_INFINITY;
	for (const resourceIndex of candidates) {
		const score = counts.get(region, resourceIndex) + placementPenalty(x, y, resourceIndex) + TerrainBuilder.getRandomNumber(1000, "BBM MAPS resource balance") / 1000;
		if (score < bestScore) {
			bestScore = score;
			best = resourceIndex;
		}
	}
	return best;
}

function placeResource(x, y, resourceIndex, counts, seeds) {
	ResourceBuilder.setResourceType(x, y, resourceIndex);
	spacedCopies.get(resourceIndex)?.push({ x, y });
	counts.add(regionOf(x, y), resourceIndex);
	seeds?.push({ x, y, resourceIndex });
}

/**
 * Place up to `limit` resources on empty plots in random order, spread out (with
 * Resource Clusters on, each pass allows one more adjacent resource); `pick`
 * chooses a plot's resource (-1: none).
 */
function spreadResources(plots, limit, pick, counts, seeds, label) {
	shuffleInPlace(plots, label);
	let placed = 0;
	const passes = spacedOut ? 1 : ADJACENCY_PASSES;
	for (let pass = 0; pass < passes && placed < limit; pass++) {
		for (const plotIndex of plots) {
			if (placed >= limit) break;
			const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
			if (GameplayMap.getResourceType(x, y) !== ResourceTypes.NO_RESOURCE || hasAdjacentResource(x, y, pass)) continue;
			const resourceIndex = pick(plotIndex, x, y);
			if (resourceIndex < 0 || isCrowded(x, y, resourceIndex)) continue;
			placeResource(x, y, resourceIndex, counts, seeds);
			placed++;
		}
	}
	return placed;
}

/** Fill up to `limit` empty plots with their candidates, keeping counts even (recorded as seeds). */
function fillEvenly(plots, candidatesByPlot, counts, limit, seeds, label) {
	return spreadResources(plots, limit, (plotIndex, x, y) => {
		const candidates = candidatesByPlot.get(plotIndex)?.filter((resourceIndex) => !isCrowded(x, y, resourceIndex));
		return candidates?.length ? pickEvenly(candidates, regionOf(x, y), counts, x, y) : -1;
	}, counts, seeds, label);
}

/** Plots where any of the resources can go, except where skip(x, y): { plots, candidatesByPlot, plotsByResource }. */
function candidatePlots(resourceIndices, skip) {
	const width = GameplayMap.getGridWidth();
	const height = GameplayMap.getGridHeight();
	const plots = [];
	const candidatesByPlot = new Map();
	const plotsByResource = new Map();
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			if (GameplayMap.isNaturalWonder(x, y) || skip(x, y)) continue;
			const fits = resourceIndices.filter((resourceIndex) => canPlace(x, y, resourceIndex));
			if (fits.length === 0) continue;
			const plotIndex = GameplayMap.getIndexFromXY(x, y);
			for (const resourceIndex of fits) {
				if (!plotsByResource.has(resourceIndex)) plotsByResource.set(resourceIndex, []);
				plotsByResource.get(resourceIndex).push(plotIndex);
			}
			candidatesByPlot.set(plotIndex, fits);
			plots.push(plotIndex);
		}
	}
	return { plots, candidatesByPlot, plotsByResource };
}

/** Place up to `copies` of one resource on the given plots. */
function placeCopies(resourceIndex, plots, copies, counts, seeds, label) {
	const placed = spreadResources(plots, copies, () => resourceIndex, counts, seeds, label);
	if (placed < copies) console.log(`BBM resources: ${GameInfo.Resources[resourceIndex]?.ResourceType} placed ${placed}/${copies} (${label})`);
	return placed;
}

/**
 * Grow a share of seeds into patches of their resource on empty neighbors in the
 * same region, up to `limit` deposits; with evenCounts, only while its count is
 * within the region's share.
 */
function growClusters(seeds, counts, clusters, evenCounts, limit) {
	if (clusters.chance <= 0 || clusters.size <= 1) return 0;
	let grown = 0;
	for (const seed of seeds) {
		if (grown >= limit) break;
		if (TerrainBuilder.getRandomNumber(100, "BBM MAPS cluster roll") >= clusters.chance) continue;
		const region = regionOf(seed.x, seed.y);
		const start = TerrainBuilder.getRandomNumber(DirectionTypes.NUM_DIRECTION_TYPES, "BBM MAPS cluster direction");
		let size = 1;
		for (let step = 0; step < DirectionTypes.NUM_DIRECTION_TYPES && size < clusters.size && grown < limit; step++) {
			const next = adjacentPlot(seed, (start + step) % DirectionTypes.NUM_DIRECTION_TYPES);
			if (next == null) continue;
			if (GameplayMap.getResourceType(next.x, next.y) !== ResourceTypes.NO_RESOURCE || GameplayMap.isNaturalWonder(next.x, next.y)) continue;
			if (regionOf(next.x, next.y) !== region || !canPlace(next.x, next.y, seed.resourceIndex) || tooClose(next.x, next.y, seed.resourceIndex)) continue;
			if (evenCounts && counts.get(region, seed.resourceIndex) > counts.average(region)) break;   // no patch past the region's share
			placeResource(next.x, next.y, seed.resourceIndex, counts, null);
			size++;
			grown++;
		}
	}
	return grown;
}

/**
 * Grow the placed seeds, then seed and grow in rounds up to `target` deposits:
 * seedRound(limit, roundSeeds, round) places up to limit seeds (recorded in
 * roundSeeds), sized by the growth achieved so far. Returns the deposits grown.
 */
function fillToTarget(target, seeds, counts, clusters, evenCounts, seedRound) {
	let perSeed = 1 + (clusters.chance / 100) * (clusters.size - 1) * CLUSTER_SUCCESS_RATE;
	let grown = growClusters(seeds, counts, clusters, evenCounts, target - seeds.length);
	for (let round = 0; round < FILL_ROUNDS && seeds.length + grown < target; round++) {
		const roundSeeds = [];
		const placed = seedRound(Math.max(1, Math.round((target - seeds.length - grown) / perSeed)), roundSeeds, round);
		if (placed === 0) break;
		const roundGrown = growClusters(roundSeeds, counts, clusters, evenCounts, target - seeds.length - grown - placed);
		seeds.push(...roundSeeds);
		grown += roundGrown;
		perSeed = 1 + roundGrown / placed;
	}
	return grown;
}

// ============================ Map generation ============================

function clearGeneratedResources(width, height) {
	let removed = 0;
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			if (GameplayMap.getResourceType(x, y) === ResourceTypes.NO_RESOURCE) continue;
			ResourceBuilder.setResourceType(x, y, ResourceTypes.NO_RESOURCE);
			removed++;
		}
	}
	return removed;
}

/**
 * Resource List All: replace the map's resources with the general pool (every
 * pooled resource in every Age; Oil and Rubber from Modern): every general
 * resource at least once, then up to the Resource Amount with even counts per
 * region; player regions make room for their dealt resources after Player
 * Placement (placeDealtResources).
 */
function generateGlobalResources() {
	const width = GameplayMap.getGridWidth();
	const height = GameplayMap.getGridHeight();
	const ageType = currentAgeType();
	const general = generalResourceTypes(ageType);

	const removed = clearGeneratedResources(width, height);
	readSettings(true);
	const counts = new RegionCounts();
	const { plots: placeablePlots, candidatesByPlot, plotsByResource } = candidatePlots(general, () => false);

	const seeds = [];
	for (const resourceIndex of general) placeCopies(resourceIndex, [...(plotsByResource.get(resourceIndex) ?? [])], 1, counts, seeds, "BBM MAPS guaranteed general resource");
	placeablePlotSet = new Set(placeablePlots);
	guaranteedPlotSet = new Set(seeds.map((seed) => GameplayMap.getIndexFromXY(seed.x, seed.y)));

	const { amount, clusters } = resourceSettings(LIST_ALL_AMOUNTS);
	// Each player region is trimmed back to this density once its resources are dealt (trimToDensity).
	const target = Math.round(placeablePlots.length * DENSITY_TARGET * amount.value);
	const grown = fillToTarget(target, seeds, counts, clusters.value, true, (limit, roundSeeds, round) =>
		fillEvenly(placeablePlots, candidatesByPlot, counts, limit, roundSeeds, `BBM MAPS resource plot order ${round + 1}`));
	console.log(`BBM resources: age=${ageType} amount=${amount.name} clusters=${clusters.name} candidates=${placeablePlots.length} general=${seeds.length + grown}/${target} (${seeds.length} seeds, ${grown} grown) replaced=${removed}`);
}

/**
 * Resource List Standard: the game's own resources (its list, rules and placement)
 * scaled to the Resource Amount and grown into Resource Clusters. Every deposit
 * off the islands is lifted; one of each resource per continent (and in the
 * water) returns, as the game guarantees, then the rest return in random order,
 * with clusters grown where the game allows the resource, until the amount is met.
 * An amount above the game's own adds more of the map's resources on empty plots.
 * Island resources stay as the map placed them.
 */
function scaleGameResources() {
	readSettings(false);
	const { amount, clusters } = resourceSettings(RESOURCE_AMOUNTS);
	if (amount.value === 1 && clusters.value.chance <= 0) {
		console.log(`BBM resources: game resources kept (amount=${amount.name} clusters=${clusters.name})`);
		return;
	}
	const width = GameplayMap.getGridWidth();
	const height = GameplayMap.getGridHeight();
	const deposits = [];
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			const resourceIndex = GameplayMap.getResourceType(x, y);
			if (resourceIndex === ResourceTypes.NO_RESOURCE || isIslandLand(x, y)) continue;
			deposits.push({ x, y, resourceIndex });
			ResourceBuilder.setResourceType(x, y, ResourceTypes.NO_RESOURCE);
		}
	}
	shuffleInPlace(deposits, "BBM MAPS game resource order");
	const target = Math.round(deposits.length * amount.value);
	const counts = new RegionCounts();
	const seeds = [];
	const queue = [];
	const kept = new Set();
	for (const deposit of deposits) {
		const key = counts.key(regionOf(deposit.x, deposit.y), deposit.resourceIndex);
		if (kept.has(key)) { queue.push(deposit); continue; }
		kept.add(key);
		placeResource(deposit.x, deposit.y, deposit.resourceIndex, counts, seeds);
	}
	let next = 0;
	let extra = null;   // empty plots for deposits past the game's own, found when first needed
	const grown = fillToTarget(target, seeds, counts, clusters.value, false, (limit, roundSeeds, round) => {
		let placed = 0;
		while (placed < limit && next < queue.length) {
			const { x, y, resourceIndex } = queue[next++];
			if (GameplayMap.getResourceType(x, y) !== ResourceTypes.NO_RESOURCE) continue;   // taken by a cluster
			placeResource(x, y, resourceIndex, counts, roundSeeds);
			placed++;
		}
		if (placed < limit && next >= queue.length) {
			extra ??= candidatePlots([...new Set(deposits.map((deposit) => deposit.resourceIndex))],
				(x, y) => isIslandLand(x, y) || GameplayMap.getResourceType(x, y) !== ResourceTypes.NO_RESOURCE);
			placed += fillEvenly(extra.plots, extra.candidatesByPlot, counts, limit - placed, roundSeeds, `BBM MAPS game resource extra order ${round + 1}`);
		}
		return placed;
	});
	console.log(`BBM resources: game resources amount=${amount.name} clusters=${clusters.name} placed=${seeds.length + grown}/${target} of ${deposits.length} (${seeds.length} seeds, ${grown} grown)`);
}

/** A region's land by distance from its start (nearest first), split at NEAR_RANGE; the start's own ring is left out. */
function splitRegion(region) {
	const byDistance = [];
	for (const plotIndex of region.plots) {
		const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
		const distance = GameplayMap.getPlotDistance(x, y, region.x, region.y);
		if (distance >= NEAR_RANGE.min && !GameplayMap.isNaturalWonder(x, y)) byDistance.push({ plotIndex, distance });
	}
	byDistance.sort((a, b) => a.distance - b.distance);
	const plots = byDistance.map((entry) => entry.plotIndex);
	const nearCount = byDistance.filter((entry) => entry.distance <= NEAR_RANGE.max).length;
	return { plots, near: plots.slice(0, nearCount), far: plots.slice(nearCount) };
}

function fitting(plots, resourceIndex) {
	return plots.filter((plotIndex) => {
		const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
		return canPlace(x, y, resourceIndex);
	});
}

/** One copy within NEAR_RANGE of the start, else on the nearest free plot of the region that takes it. */
function placeNear(resourceIndex, split, counts, seeds, label) {
	if (spreadResources(fitting(split.near, resourceIndex), 1, () => resourceIndex, counts, seeds, label) > 0) return 1;
	for (const plotIndex of fitting(split.far, resourceIndex)) {
		const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
		if (GameplayMap.getResourceType(x, y) !== ResourceTypes.NO_RESOURCE || isCrowded(x, y, resourceIndex)) continue;
		placeResource(x, y, resourceIndex, counts, seeds);
		console.log(`BBM resources: ${GameInfo.Resources[resourceIndex]?.ResourceType} placed beyond range (${label})`);
		return 1;
	}
	console.log(`BBM resources: ${GameInfo.Resources[resourceIndex]?.ResourceType} placed 0/1 (${label})`);
	return 0;
}

/** Top the start's range up to NEAR_GENERAL general resources, preferring those it lacks. */
function topUpGeneral(general, near, counts, seeds, label) {
	const nearCounts = new RegionCounts();
	for (const plotIndex of near) {
		const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
		const resourceIndex = GameplayMap.getResourceType(x, y);
		if (general.includes(resourceIndex)) nearCounts.add(0, resourceIndex);
	}
	const needed = NEAR_GENERAL - (nearCounts.regions.get(0)?.tiles ?? 0);
	if (needed <= 0) return 0;
	return spreadResources([...near], needed, (plotIndex, x, y) => {
		const fits = general.filter((resourceIndex) => canPlace(x, y, resourceIndex) && !isCrowded(x, y, resourceIndex));
		if (fits.length === 0) return -1;
		const resourceIndex = pickEvenly(fits, 0, nearCounts, x, y);
		nearCounts.add(0, resourceIndex);
		return resourceIndex;
	}, counts, seeds, label);
}

const plotsOf = (seeds) => new Set(seeds.map((seed) => GameplayMap.getIndexFromXY(seed.x, seed.y)));
const hasResource = (plotIndex) => {
	const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
	return GameplayMap.getResourceType(x, y) !== ResourceTypes.NO_RESOURCE;
};

/**
 * Remove general resources until the region holds the map's density: far plots
 * first, then near ones above NEAR_GENERAL; dealt, topped-up and guaranteed
 * copies and the start's own ring stay.
 */
function trimToDensity(region, split, dealtPlots, toppedPlots, amount, label) {
	const placeable = region.plots.filter((plotIndex) => placeablePlotSet.has(plotIndex)).length;
	let excess = region.plots.filter(hasResource).length - Math.round(placeable * DENSITY_TARGET * amount);
	if (excess <= 0) return 0;
	const removable = (plots) => plots.filter((plotIndex) => hasResource(plotIndex) && !dealtPlots.has(plotIndex) && !toppedPlots.has(plotIndex) && !guaranteedPlotSet.has(plotIndex));
	const nearGeneral = split.near.filter((plotIndex) => hasResource(plotIndex) && !dealtPlots.has(plotIndex)).length;
	const far = shuffleInPlace(removable(split.far), `${label} far`);
	const near = shuffleInPlace(removable(split.near), `${label} near`).slice(0, Math.max(0, nearGeneral - NEAR_GENERAL));
	let removed = 0;
	for (const plotIndex of [...far, ...near]) {
		if (excess <= 0) break;
		const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
		ResourceBuilder.setResourceType(x, y, ResourceTypes.NO_RESOURCE);
		excess--;
		removed++;
	}
	return removed;
}

/**
 * After Player Placement: each player region is dealt one resource from every pool
 * and OTHER_PER_REGION others. Its first copy lies within NEAR_RANGE of the start,
 * the others farther out in the region, the range is topped up to NEAR_GENERAL
 * general resources, and the region is trimmed to the map's density
 * (trimToDensity); then the islands are stocked (stockIslands).
 */
function placeDealtResources() {
	readSettings(true);
	const regions = buildPlayerRegions();
	const dealt = dealRegionResources(regions);
	const general = generalResourceTypes(currentAgeType());
	const { amount } = resourceSettings(LIST_ALL_AMOUNTS);
	const counts = new RegionCounts();
	let placed = 0;
	let topped = 0;
	let trimmed = 0;
	regions.forEach((region, index) => {
		const split = splitRegion(region);
		const label = `BBM MAPS player ${region.playerId} resource`;
		const dealtSeeds = [];
		const toppedSeeds = [];
		for (const resourceIndex of dealt[index]) {
			placed += placeNear(resourceIndex, split, counts, dealtSeeds, label);
			if (region.copies > 1) placed += placeCopies(resourceIndex, fitting(split.far, resourceIndex), region.copies - 1, counts, dealtSeeds, label);
		}
		topped += topUpGeneral(general, split.near, counts, toppedSeeds, `BBM MAPS player ${region.playerId} general`);
		trimmed += trimToDensity(region, split, plotsOf(dealtSeeds), plotsOf(toppedSeeds), amount.value, `BBM MAPS player ${region.playerId} trim`);
	});
	console.log(`BBM resources: dealt ${placed} copies to ${regions.length} player regions; ${topped} general resources added near starts, ${trimmed} trimmed to the map's density`);
	stockIslands(new Set(regions.map((region) => region.plotIndex)));
}

/** Connected land tagged as island, as lists of plot indices. */
function collectIslands() {
	const width = GameplayMap.getGridWidth();
	const height = GameplayMap.getGridHeight();
	const seen = new Set();
	const islands = [];
	for (let y = 0; y < height; y++) {
		for (let x = 0; x < width; x++) {
			const start = GameplayMap.getIndexFromXY(x, y);
			if (seen.has(start) || !isIslandLand(x, y)) continue;
			const island = [start];
			seen.add(start);
			for (let index = 0; index < island.length; index++) {
				for (const next of adjacentPlots(GameplayMap.getLocationFromIndex(island[index]))) {
					if (!isIslandLand(next.x, next.y)) continue;
					const plotIndex = GameplayMap.getIndexFromXY(next.x, next.y);
					if (!seen.has(plotIndex)) { seen.add(plotIndex); island.push(plotIndex); }
				}
			}
			islands.push(island);
		}
	}
	return islands;
}

/**
 * Every island without a start holds ISLAND_RESOURCES general resources, then the
 * map's island rule for this Age applies (island resources become Treasure in
 * Exploration), as the game does when it places resources itself.
 */
function stockIslands(startPlots) {
	const ageType = currentAgeType();
	const general = generalResourceTypes(ageType);
	const counts = new RegionCounts();
	let islands = 0;
	let added = 0;
	for (const island of collectIslands()) {
		if (island.some((plotIndex) => startPlots.has(plotIndex))) continue;
		islands++;
		const present = island.filter((plotIndex) => {
			const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
			return GameplayMap.getResourceType(x, y) !== ResourceTypes.NO_RESOURCE;
		}).length;
		let needed = ISLAND_RESOURCES - present;
		for (const plotIndex of shuffleInPlace([...island], "BBM MAPS island resources")) {
			if (needed <= 0) break;
			const { x, y } = GameplayMap.getLocationFromIndex(plotIndex);
			if (GameplayMap.getResourceType(x, y) !== ResourceTypes.NO_RESOURCE || GameplayMap.isNaturalWonder(x, y)) continue;
			const fits = general.filter((resourceIndex) => canPlace(x, y, resourceIndex) && !isCrowded(x, y, resourceIndex));
			if (fits.length === 0) continue;
			placeResource(x, y, pickEvenly(fits, regionOf(x, y), counts, x, y), counts, null);
			needed--;
			added++;
		}
	}
	const mapType = Configuration.getMapValue("Name");
	const rules = GameInfo.MapIslandBehavior.filter((rule) => rule.MapType === mapType && rule.AgeType === ageType);
	for (const rule of rules) replaceIslandResources(GameplayMap.getGridWidth(), GameplayMap.getGridHeight(), rule.ResourceClassType);
	console.log(`BBM resources: islands=${islands} islandResourcesAdded=${added} islandRules=${rules.map((rule) => rule.ResourceClassType).join(",") || "none"}`);
}

export { generateGlobalResources, placeDealtResources, scaleGameResources };
