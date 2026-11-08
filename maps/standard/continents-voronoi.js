// Copy of {base-standard}maps/continents-voronoi.js for multiplayer: the terrain pass
// comes from ../generation/map-features.js (Map and Terrain Settings);
// Resource Settings apply afterwards (maps/scripts/global-team-starts.js).
import { generateMapFeatures } from '../generation/map-features.js';
import { assignAdvancedStartRegions } from '../../../base-standard/maps/assign-advanced-start-region.js';
import { assignStartPositionsFromHexMap } from '../../../base-standard/maps/assign-starting-plots.js';
import { generateDiscoveries } from '../../../base-standard/maps/discovery-generator.js';
import { g_PolarWaterRows } from '../../../base-standard/maps/map-globals.js';
import { profileScope } from '../../../base-standard/scripts/profiling.js';
import { VoronoiContinents } from '../../../base-standard/scripts/voronoi_maps/continents.js';
// Loads the multiplayer Player Placement pass with the map (it arms itself once).
import '../scripts/global-team-starts.js';

console.log("Generating using script Continents-Voronoi.ts");
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
async function generateMap() {
  console.log("Generating a map!");
  console.log(`Age - ${GameInfo.Ages.lookup(Game.age).AgeType}`);
  const voronoiScope = new profileScope("Continents Voronoi Generation");
  const iWidth = GameplayMap.getGridWidth();
  const iHeight = GameplayMap.getGridHeight();
  const uiMapSize = GameplayMap.getMapSize();
  const mapInfo = GameInfo.Maps.lookup(uiMapSize);
  if (mapInfo == null) return;
  const iTotalPlayers = Players.getAliveMajorIds().length;
  const voronoiMap = new VoronoiContinents();
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
  generateMapFeatures(voronoiMap.getHexTiles());
  const fertilityGetter = (tile) => StartPositioner.getPlotFertilityForCoord(tile.coord.x, tile.coord.y);
  voronoiMap.createMajorPlayerAreas(fertilityGetter);
  const startPositions = assignStartPositionsFromHexMap(voronoiMap.getHexTiles());
  generateDiscoveries(iWidth, iHeight, startPositions, g_PolarWaterRows);
  FertilityBuilder.recalculate();
  assignAdvancedStartRegions();
  voronoiScope.end();
}
engine.on("RequestMapInitData", requestMapData);
engine.on("GenerateMap", generateMap);
