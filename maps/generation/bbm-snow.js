// Snow pass with the Map Settings climate (climate.js).
// Port of {base-standard}maps/snow-generator.js generateSnow.
//
// The base lays permanent snow in rows from latitude 53 to each polar edge: the
// snow chance rises from 0 to 100, give or take a random 15, and the thresholds
// of its SnowGenConfig turn it into no, light, medium or heavy snow. Here the same
// curve is laid by each land tile's Map Zones latitude plus the Map Temperature
// shift instead of its row, so snow follows the cold wherever it lies. With
// Standard on both settings the base pass runs unchanged.
import { SnowGenConfig, generateSnow as generateBaseSnow } from '../../../base-standard/maps/snow-generator.js';
import { getClimate } from './bbm-climate.js';
import { forEachTile, interpolate } from './bbm-settings.js';

const POLE_LATITUDE = 90;

const snowEffect = (weight) => MapPlotEffects.getPlotEffectTypesContainingTags(["SNOW", weight, "PERMANENT"])?.[0] ?? -1;

export function generateSnow(iWidth, iHeight) {
	const climate = getClimate();
	if (climate.engineLatitude && climate.shift == 0) {
		generateBaseSnow(iWidth, iHeight);
		return;
	}
	console.log("BBM snow: laid by climate latitude");
	const config = new SnowGenConfig();
	const effects = ["LIGHT", "MEDIUM", "HEAVY"].map(snowEffect);
	forEachTile(iWidth, iHeight, (iX, iY) => {
		if (GameplayMap.isWater(iX, iY)) {
			return;
		}
		const signed = climate.latitude(iX, iY);
		const snowLatitude = signed < 0 ? config.snowLatitudeSouth : config.snowLatitudeNorth;
		const latitude = Math.abs(signed) + climate.shift;
		if (latitude < snowLatitude) {
			return;
		}
		const chance = interpolate(latitude, snowLatitude, POLE_LATITUDE, 0, 100) +
			TerrainBuilder.getRandomNumber(config.snowDensityVariation * 2, "Any Snow") - config.snowDensityVariation;
		// Each threshold reached is one step heavier, as in the base.
		const weight = config.snowThresholds.filter((threshold) => chance >= threshold).length;
		if (weight > 0) {
			MapPlotEffects.addPlotEffect(GameplayMap.getIndexFromXY(iX, iY), effects[weight - 1]);
		}
	});
}
