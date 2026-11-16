// Copy of {base-standard}maps/donut-voronoi.js for multiplayer: the terrain pass
// comes from ../generation/bbm-map-features.js (Map and Terrain Settings);
// Resource Settings apply afterwards (maps/scripts/global-team-starts.js).
// Donut keeps the game's square grid for each size (commonRequestMapData).
import { generateMapFeatures } from '../generation/bbm-map-features.js';
import { assignAdvancedStartRegions } from '../../../base-standard/maps/assign-advanced-start-region.js';
import { assignStartPositionsFromHexMap } from '../../../base-standard/maps/assign-starting-plots.js';
import { generateDiscoveries } from '../../../base-standard/maps/discovery-generator.js';
import { g_PolarWaterRows } from '../../../base-standard/maps/map-globals.js';
import { commonRequestMapData } from '../../../base-standard/maps/map-utilities.js';
import { profileScope } from '../../../base-standard/scripts/profiling.js';
import { VoronoiDonut } from '../../../base-standard/scripts/voronoi_maps/donut.js';
// Loads the multiplayer Player Placement pass with the map (it arms itself once).
import '../scripts/global-team-starts.js';

console.log("Generating using script donut-voronoi.ts");
async function generateMap() {
	console.log("Generating a map!");
	console.log(`Age - ${GameInfo.Ages.lookup(Game.age).AgeType}`);
	const voronoiScope = new profileScope("Donut Voronoi Generation");
	const iWidth = GameplayMap.getGridWidth();
	const iHeight = GameplayMap.getGridHeight();
	const uiMapSize = GameplayMap.getMapSize();
	const mapInfo = GameInfo.Maps.lookup(uiMapSize);
	if (mapInfo == null) return;
	const iTotalPlayers = Players.getAliveMajorIds().length;
	const startTime = Date.now();
	const voronoiMap = new VoronoiDonut();
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
	const endTime = Date.now();
	console.log(`Initial Voronoi map generation took ${endTime - startTime} ms`);
	generateMapFeatures(voronoiMap.getHexTiles());
	const fertilityGetter = (tile) => StartPositioner.getPlotFertilityForCoord(tile.coord.x, tile.coord.y);
	voronoiMap.createMajorPlayerAreas(fertilityGetter);
	const startPositions = assignStartPositionsFromHexMap(voronoiMap.getHexTiles());
	generateDiscoveries(iWidth, iHeight, startPositions, g_PolarWaterRows);
	FertilityBuilder.recalculate();
	assignAdvancedStartRegions();
	voronoiScope.end();
}
engine.on("RequestMapInitData", commonRequestMapData(VoronoiDonut));
engine.on("GenerateMap", generateMap);
