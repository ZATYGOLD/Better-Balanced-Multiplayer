// The climate every map shares: the Map Temperature and Map Zones settings.
// Adapted, with permission, from Scrum Lord's Climate Controls.
//
// Map Zones decides each tile's latitude, from 0 at the hottest point to 90
// at the coldest. The biome, feature and snow passes all read it here instead
// of from the engine, so every layout reaches all three. Standard returns
// the engine's own latitude untouched.
//
// Map Temperature then sets, per step:
//   bands    upper bounds of the Tropical, Plains, Desert, and Grassland biome
//            bands; Tundra lies beyond the last.
//   shift    degrees added to the latitude that sea ice, reefs, open-water
//            features, and snow read; positive is colder.
//   weights  how strongly elevation (colder), rainfall (wet warmer, dry colder),
//            and rivers (warmer) move a land tile's latitude for its biome.
// Standard matches the base game in every value.
import { interpolate, settingTier } from './settings.js';

const TEMPERATURE_SETTING_KEY = "MPTMapTemperature";
const MAP_ZONES_SETTING_KEY = "MPTMapZones";
const MAX_LATITUDE = 90;
// map-globals.js gives the landmass, mountain, and hill fractals ids 0 to 2.
const PATCHWORK_FRACTAL = 3;
const PATCHWORK_GRAIN = 2;

const weights = (elevation, rainfall, river) => ({ elevation, rainfall, river });

const TEMPERATURE_TIERS = {
  MPT_MAPS_TEMPERATURE_FRIGID: { bands: [4, 13, 13, 27], shift: 45, weights: weights(1.75, 1, 1.75) },
  MPT_MAPS_TEMPERATURE_COLD: { bands: [17, 33, 37, 50], shift: 10, weights: weights(1.25, 1, 1.25) },
  MPT_MAPS_TEMPERATURE_STANDARD: { bands: [17, 33, 44, 58], shift: 0, weights: weights(1, 1, 1) },
  MPT_MAPS_TEMPERATURE_HOT: { bands: [17, 33, 51, 65], shift: -10, weights: weights(1, 1.25, 1.25) },
  MPT_MAPS_TEMPERATURE_SCORCHING: { bands: [40, 48, 82, 105], shift: -45, weights: weights(1.5, 1.5, 1.75) },
};

// --------------------------------------------------------- band shapes --
// Each returns a function from a tile to a signed latitude in [-1, 1]: 0 is the
// equator, -1 the south pole, 1 the north pole.

// Straight-line distance on the hex grid, odd rows offset by half a tile.
function distance(x1, y1, x2, y2) {
  const dx = (x1 + (y1 % 2) * 0.5) - (x2 + (y2 % 2) * 0.5);
  return Math.sqrt(dx * dx + (y1 - y2) * (y1 - y2));
}

const stripeBands = () => (x, y) => GameplayMap.getPlotLatitude(x, y) / MAX_LATITUDE;

// Rings around the map's center: one pole in the middle, the other at the edges.
function ringBands(hotCenter) {
  const width = GameplayMap.getGridWidth();
  const height = GameplayMap.getGridHeight();
  const centerX = (width - 1) / 2;
  const centerY = (height - 1) / 2;
  const poleSpan = Math.max(width, height) / 2;
  const equator = poleSpan / 2;
  // Tuned to balance the two hemispheres on every base map size.
  const centerRadius = Math.round(Math.min(width, height) * 10 / 9.5) / 10;
  return (x, y) => {
    const fromCenter = distance(x, y, centerX, centerY) - centerRadius;
    const fromPole = Math.min(fromCenter, poleSpan - fromCenter);
    const sign = (fromCenter <= equator) != hotCenter ? 1 : -1;
    return sign * interpolate(fromPole, 0, equator, 1, 0);
  };
}

// Irregular regions from a coarse fractal: its height sets each tile's distance
// from the equator, and the median height splits the hemispheres.
function patchworkBands() {
  FractalBuilder.create(PATCHWORK_FRACTAL, GameplayMap.getGridWidth(), GameplayMap.getGridHeight(), PATCHWORK_GRAIN, 0);
  const equatorHeight = FractalBuilder.getHeightFromPercent(PATCHWORK_FRACTAL, 49);
  const midHeight = FractalBuilder.getHeightFromPercent(PATCHWORK_FRACTAL, 100) / 2;
  return (x, y) => {
    const fractalHeight = FractalBuilder.getHeight(PATCHWORK_FRACTAL, x, y);
    const latitude = Math.min(1, Math.abs(fractalHeight - midHeight) / midHeight);
    return fractalHeight < equatorHeight ? -latitude : latitude;
  };
}

// --------------------------------------------------------- suns --
// Each maps a band latitude to where the heat falls.

const standardSun = (latitude) => latitude;
// The southern pole faces the sun: hottest there, cooling evenly to the coldest
// at the northern pole. On ring bands the poles are the center and the edges.
const hotEdgeSun = (latitude) => (latitude + 1) / 2;
// Hot poles and a cold equator.
const hotPolesSun = (latitude) => (latitude < 0 ? -1 : 1) - latitude;

// rollHotEdge: the map seed picks which pole faces the sun, north or south.
const MAP_ZONE_TIERS = {
  MPT_MAPS_MAP_ZONES_STANDARD: null,
  MPT_MAPS_MAP_ZONES_HOT_POLES: { bands: stripeBands, sun: hotPolesSun },
  MPT_MAPS_MAP_ZONES_HOT_EDGE: { bands: stripeBands, sun: hotEdgeSun, rollHotEdge: true },
  MPT_MAPS_MAP_ZONES_HOT_CENTER: { bands: () => ringBands(true), sun: hotEdgeSun },
  MPT_MAPS_MAP_ZONES_COLD_CENTER: { bands: () => ringBands(false), sun: hotEdgeSun },
  MPT_MAPS_MAP_ZONES_WARM_RING: { bands: () => ringBands(false), sun: standardSun },
  MPT_MAPS_MAP_ZONES_PATCHWORK: { bands: patchworkBands, sun: standardSun },
};

// Signed latitude in degrees for every tile, by Map Zones, and whether it is
// the engine's own.
function mapZoneLatitude() {
  const source = settingTier(MAP_ZONE_TIERS, MAP_ZONES_SETTING_KEY, "MPT_MAPS_MAP_ZONES_STANDARD", "MPT_MAPS_MAP_ZONES_RANDOM");
  if (!source) {
    return { latitude: (x, y) => GameplayMap.getPlotLatitude(x, y), engineLatitude: true };
  }
  let bands = source.bands();
  if (source.rollHotEdge) {
    const northHot = TerrainBuilder.getRandomNumber(2, "MPT Map Zones Hot Edge") == 1;
    console.log(`MPT MAPS climate: ${northHot ? "north" : "south"} edge hot`);
    if (northHot) {
      const southHot = bands;
      bands = (x, y) => -southHot(x, y);
    }
  }
  return { latitude: (x, y) => Math.round(source.sun(bands(x, y)) * MAX_LATITUDE), engineLatitude: false };
}

let climate = null;
// A new map resolves both settings afresh.
if (typeof engine !== "undefined") engine.on("RequestMapInitData", () => { climate = null; });

// Both settings resolve once per map, so a Random roll holds for every pass.
export function getClimate() {
  if (!climate) {
    const temperature = settingTier(TEMPERATURE_TIERS, TEMPERATURE_SETTING_KEY, "MPT_MAPS_TEMPERATURE_STANDARD", "MPT_MAPS_TEMPERATURE_RANDOM");
    climate = { ...temperature, ...mapZoneLatitude() };
    console.log(`MPT MAPS climate: bands ${temperature.bands.join("/")}, shift ${temperature.shift}, weights ${Object.values(temperature.weights).join("/")}`);
  }
  return climate;
}
