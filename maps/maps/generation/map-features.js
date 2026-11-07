// Copy of {base-standard}scripts/common-generation.js generateMapFeatures, the
// terrain pass every Voronoi map shares, with the Map Settings rough, mountain,
// river, biome, feature and snow passes substituted in (Resource Settings apply
// afterwards, in maps/scripts/global-team-starts.js); the phase order matches the base.
import { buildRainfallMap } from '../../../../base-standard/maps/elevation-terrain-generator.js';
import { addFeatures } from './features.js';
import { dumpContinents, dumpTerrain, dumpElevation, dumpRainfall, dumpBiomes, dumpFeatures, dumpResources } from '../../../../base-standard/maps/map-debug-helpers.js';
import { addNaturalWonders } from '../../../../base-standard/maps/natural-wonder-generator.js';
import { generateResources } from '../../../../base-standard/maps/resource-generator.js';
import { dumpPermanentSnow } from '../../../../base-standard/maps/snow-generator.js';
import { generateSnow } from './snow.js';
import { GenerationContext, GenerationPhases } from '../../../../base-standard/scripts/common-generation.js';
import { profileScope, profileFunction } from '../../../../base-standard/scripts/profiling.js';
import { modelRivers } from './rivers.js';
import { designateBiomes } from './biomes.js';
import { adjustMountains } from './mountains.js';
import { addHills } from './hills.js';

export async function generateMapFeatures(hexMap, context = new GenerationContext()) {
  const generateMapFeaturesScope = new profileScope("Generate Features");
  const iWidth = GameplayMap.getGridWidth();
  const iHeight = GameplayMap.getGridHeight();
  const uiMapSize = GameplayMap.getMapSize();
  const mapInfo = GameInfo.Maps.lookup(uiMapSize);
  if (mapInfo == null) return;
  const iNumNaturalWonders = mapInfo.NumNaturalWonders;
  if (context.phases & GenerationPhases.Lakes) {
    profileFunction("generateLakes", () => hexMap.GenerateLakes());
  }
  if (context.phases & GenerationPhases.WriteToTerrainBuilder) {
    hexMap.writeToTerrainBuilder();
  }
  profileFunction("TerrainBuilder.validateAndFixTerrain", () => TerrainBuilder.validateAndFixTerrain());
  profileFunction("AreaBuilder.recalculateAreas", () => AreaBuilder.recalculateAreas());
  if (context.phases & GenerationPhases.Continents) {
    profileFunction("TerrainBuilder.stampContinents", () => TerrainBuilder.stampContinents());
  }
  profileFunction("AreaBuilder.recalculateAreas", () => AreaBuilder.recalculateAreas());
  if (context.phases & GenerationPhases.Elevation) {
    profileFunction("TerrainBuilder.buildElevation", () => TerrainBuilder.buildElevation());
  }
  if (context.phases & GenerationPhases.Hills) {
    // Map Age in place of the base addHills. This is the only pass that raises
    // rough ground on these maps, so the Mountains pass has to follow it rather
    // than run on the simulated tiles: before this point the map holds flat and
    // mountainous ground only, and More Mountains grows its ranges outward into
    // rough tiles that would not exist yet.
    profileFunction("addHills", () => addHills(iWidth, iHeight));
    profileFunction("adjustMountains", () => adjustMountains(iWidth, iHeight));
  }
  if (context.phases & GenerationPhases.Rainfall) {
    profileFunction("buildRainfallMap", () => buildRainfallMap(iWidth, iHeight));
  }
  if (context.phases & GenerationPhases.Rivers) {
    profileFunction("modelRivers", () => modelRivers(5, 15));
  } else {
    profileFunction(
      "TerrainBuilder.finalizeRivers",
      () => TerrainBuilder.finalizeRivers(
        context.bRunAestheticRiverValidation,
        context.largeRiverPercent,
        context.minNavRiverLength,
        context.minUpstreamMinorRivers
      )
    );
  }
  if (context.phases & GenerationPhases.Biomes) {
    profileFunction("designateBiomes", () => designateBiomes(iWidth, iHeight));
  }
  if (context.phases & GenerationPhases.NaturalWonders) {
    profileFunction("addNaturalWonders", () => addNaturalWonders(iWidth, iHeight, iNumNaturalWonders));
  }
  if (context.phases & GenerationPhases.FloodPlains) {
    profileFunction("TerrainBuilder.addFloodplains", () => TerrainBuilder.addFloodplains(4, 10));
  }
  if (context.phases & GenerationPhases.Features) {
    profileFunction("addFeatures", () => addFeatures(iWidth, iHeight));
  }
  profileFunction("TerrainBuilder.validateAndFixTerrain", () => TerrainBuilder.validateAndFixTerrain());
  profileFunction("AreaBuilder.recalculateAreas", () => AreaBuilder.recalculateAreas());
  profileFunction("TerrainBuilder.storeWaterData", () => TerrainBuilder.storeWaterData());
  if (context.phases & GenerationPhases.Snow) {
    profileFunction("generateSnow", () => generateSnow(iWidth, iHeight));
  }
  if (context.phases & GenerationPhases.Resources) {
    profileFunction("generateResources", () => generateResources(iWidth, iHeight));
  }
  dumpContinents(iWidth, iHeight);
  dumpTerrain(iWidth, iHeight);
  dumpElevation(iWidth, iHeight);
  dumpRainfall(iWidth, iHeight);
  dumpBiomes(iWidth, iHeight);
  dumpFeatures(iWidth, iHeight);
  dumpPermanentSnow(iWidth, iHeight);
  dumpResources(iWidth, iHeight);
  generateMapFeaturesScope.end();
}
