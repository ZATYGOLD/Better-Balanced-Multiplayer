// Snow pass with the Map Settings climate (climate.js).
// Port of {base-standard}maps/snow-generator.js generateSnow.
//
// The base lays permanent snow in rows inward from each polar edge: from the
// first land row past the polar water down to latitude 60, the chance of any
// snow falls from 90% to 30% and heavy snow gives way to medium and light. Here
// the same curve is laid by each land tile's Map Zones latitude plus the Map
// Temperature shift instead of its row, so snow follows the cold wherever it
// lies. With Standard on both settings the base pass runs unchanged.
import { g_PolarWaterRows } from '../../../base-standard/maps/map-globals.js';
import { generateSnow as generateBaseSnow } from '../../../base-standard/maps/snow-generator.js';
import { getClimate } from './climate.js';
import { forEachTile, interpolate } from './settings.js';

const SNOW_LATITUDE_MIN = 60;
const ANY_SNOW_CHANCE = 90;
const CHANCE_SPAN = 60;
// Light, medium, and heavy at the coldest edge; across the span light and
// medium each gain what heavy loses.
const WEIGHT_CHANCES = [10, 30, 60];
const HEAVY = 2;

const snowEffect = (weight) => MapPlotEffects.getPlotEffectTypesContainingTags(["SNOW", weight, "PERMANENT"])?.[0] ?? -1;

// The latitude where the base's first snow row lies, just past the polar water.
function coldestSnowLatitude(iHeight) {
  const halfHeight = iHeight / 2;
  return Math.round(90 - (g_PolarWaterRows / halfHeight) * 90);
}

export function generateSnow(iWidth, iHeight) {
  const climate = getClimate();
  if (climate.engineLatitude && climate.shift == 0) {
    generateBaseSnow(iWidth, iHeight);
    return;
  }
  console.log("MPT MAPS snow: laid by climate latitude");
  const effects = ["LIGHT", "MEDIUM", "HEAVY"].map(snowEffect);
  const coldest = coldestSnowLatitude(iHeight);
  forEachTile(iWidth, iHeight, (iX, iY) => {
    if (GameplayMap.isWater(iX, iY)) {
      return;
    }
    const latitude = Math.abs(climate.latitude(iX, iY)) + climate.shift;
    if (latitude < SNOW_LATITUDE_MIN) {
      return;
    }
    // 0 at the coldest edge, 1 at latitude 60.
    const gain = CHANCE_SPAN * interpolate(latitude, coldest, SNOW_LATITUDE_MIN, 0, 1);
    if (TerrainBuilder.getRandomNumber(100, "Any Snow") > ANY_SNOW_CHANCE - gain) {
      return;
    }
    // Heavy first, as in the base.
    let roll = TerrainBuilder.getRandomNumber(100, "Snow Weight");
    for (let weight = WEIGHT_CHANCES.length - 1; weight >= 0; --weight) {
      const chance = WEIGHT_CHANCES[weight] + (weight == HEAVY ? -gain : gain);
      if (roll < chance) {
        MapPlotEffects.addPlotEffect(GameplayMap.getIndexFromXY(iX, iY), effects[weight]);
        return;
      }
      roll -= chance;
    }
  });
}
