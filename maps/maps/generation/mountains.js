// Applies the Mountains setup setting.
//
// Classic maps raise their peaks in addMountains, a port of the base
// addMountains, which turns land above a fractal height percentile into
// mountains: a higher cutoff yields fewer, a lower one more. Standard keeps the
// base cutoff of 90, the tallest ~10% of land.
//
// Voronoi maps take their mountains from the Voronoi simulation instead, so
// adjustMountains scales them afterwards, picking tiles by how many mountain
// neighbours they have: Less erodes the most isolated peaks and More grows
// existing ranges outward, which keeps ranges contiguous. The ordering is stable
// and uses no random numbers, so a map seed still reproduces exactly.
import { g_MountainFractal, g_HillFractal, g_MountainTerrain, g_HillTerrain, g_FlatTerrain } from '../../../../base-standard/maps/map-globals.js';
import { forEachTile, settingTier } from './settings.js';

const MOUNTAINS_SETTING_KEY = "MPTMapMountains";
// cutoff: fractal height percentile on classic maps; scale: the mountain count
// multiplier on Voronoi maps.
const MOUNTAINS_TIERS = {
  MPT_MAPS_MOUNTAINS_LESS: { cutoff: 95, scale: 0.5 },
  MPT_MAPS_MOUNTAINS_STANDARD: { cutoff: 90, scale: 1 },
  MPT_MAPS_MOUNTAINS_MORE: { cutoff: 80, scale: 2 },
};
// The Marvelous Mountains live event lowers the cutoff, as in the base.
const LIVE_EVENT_EXTRA_MOUNTAINS = 40;

const mountainsTier = () => settingTier(MOUNTAINS_TIERS, MOUNTAINS_SETTING_KEY, "MPT_MAPS_MOUNTAINS_STANDARD");

export function addMountains(iWidth, iHeight) {
  const grainAmount = 5;
  const liveEventDBRow = GameInfo.GlobalParameters.lookup("REGISTERED_MARVELOUS_MOUNTAINS_EVENT");
  const extraMountains = liveEventDBRow && liveEventDBRow.Value != "0" ? LIVE_EVENT_EXTRA_MOUNTAINS : 0;
  const mountains = mountainsTier().cutoff - extraMountains;
  console.log(`MPT MAPS mountains: height percentile ${mountains}`);
  FractalBuilder.create(g_MountainFractal, iWidth, iHeight, grainAmount, 0);
  FractalBuilder.create(g_HillFractal, iWidth, iHeight, grainAmount, 0);
  const iMountainThreshold = FractalBuilder.getHeightFromPercent(g_MountainFractal, mountains);
  forEachTile(iWidth, iHeight, (iX, iY) => {
    if (GameplayMap.isWater(iX, iY)) {
      return;
    }
    let terrain = GameplayMap.getTerrainType(iX, iY);
    if (FractalBuilder.getHeight(g_MountainFractal, iX, iY) >= iMountainThreshold) {
      terrain = g_MountainTerrain;
    }
    if (terrain != g_FlatTerrain) {
      TerrainBuilder.setTerrainType(iX, iY, terrain);
    }
  });
}

function countMountainNeighbours(location) {
  let count = 0;
  for (let direction = 0; direction < DirectionTypes.NUM_DIRECTION_TYPES; direction++) {
    const adjacent = GameplayMap.getAdjacentPlotLocation(location, direction);
    if (adjacent.x >= 0 && adjacent.y >= 0 && GameplayMap.isMountain(adjacent.x, adjacent.y)) {
      count++;
    }
  }
  return count;
}

export function adjustMountains(iWidth, iHeight) {
  const { scale } = mountainsTier();
  if (scale == 1) {
    return;
  }
  const mountains = [];
  const rough = [];
  forEachTile(iWidth, iHeight, (x, y) => {
    if (GameplayMap.isWater(x, y)) {
      return;
    }
    if (GameplayMap.isMountain(x, y)) {
      mountains.push({ x, y });
    } else if (GameplayMap.getTerrainType(x, y) == g_HillTerrain) {
      rough.push({ x, y });
    }
  });
  // Counted once up front: the comparator runs many times, and using the
  // pre-adjustment counts keeps the result independent of processing order.
  const neighbourCount = new Map();
  for (const tile of mountains.concat(rough)) {
    neighbourCount.set(tile, countMountainNeighbours(tile));
  }
  const byNeighbours = (ascending) => (a, b) => {
    const diff = neighbourCount.get(a) - neighbourCount.get(b);
    if (diff !== 0) {
      return ascending ? diff : -diff;
    }
    return (a.y - b.y) || (a.x - b.x);
  };
  const target = Math.round(mountains.length * scale);
  let changed = 0;
  if (scale < 1) {
    mountains.sort(byNeighbours(true));
    changed = Math.max(0, mountains.length - target);
    for (let i = 0; i < changed; i++) {
      TerrainBuilder.setTerrainType(mountains[i].x, mountains[i].y, g_HillTerrain);
    }
  } else {
    rough.sort(byNeighbours(false));
    changed = Math.max(0, Math.min(rough.length, target - mountains.length));
    for (let i = 0; i < changed; i++) {
      TerrainBuilder.setTerrainType(rough[i].x, rough[i].y, g_MountainTerrain);
    }
  }
  console.log(`MPT MAPS mountains: ${mountains.length} mountain and ${rough.length} rough tiles adjusted by ${scale < 1 ? "-" : "+"}${changed}`);
}
