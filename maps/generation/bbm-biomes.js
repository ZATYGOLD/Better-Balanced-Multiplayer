// Biome pass with the Map Settings climate (climate.js).
// Port of {base-standard}maps/feature-biome-generator.js designateBiomes.
//
// Each land tile starts from its Map Zones latitude, which elevation, rainfall,
// and nearby rivers then move by the Map Temperature weights; the result falls
// into that step's biome bands. The rainfall extremes that force Desert and
// Tropical outright are untouched. At Standard every value matches the base.
import { g_MarineBiome, g_DesertBiome, g_MountainTerrain, g_TropicalBiome, g_PlainsBiome, g_GrasslandBiome, g_TundraBiome } from '../../../base-standard/maps/map-globals.js';
import { getClimate } from './bbm-climate.js';
import { forEachTile } from './bbm-settings.js';

const BAND_BIOMES = [g_TropicalBiome, g_PlainsBiome, g_DesertBiome, g_GrasslandBiome];

// Rainfall and river offsets in degrees; negative is warmer.
function moistureOffset(rainfall) {
	return rainfall < 100 ? (100 - rainfall) / 10 : -(rainfall - 100) / 10;
}

function riverOffset(iX, iY) {
	if (GameplayMap.isRiver(iX, iY)) {
		return -10;
	}
	return GameplayMap.isAdjacentToRivers(iX, iY, 1) ? -5 : 0;
}

function bandBiome(bands, latitude) {
	const band = bands.findIndex((max) => latitude < max);
	return band < 0 ? g_TundraBiome : BAND_BIOMES[band];
}

export function designateBiomes(iWidth, iHeight) {
	console.log("Biomes");
	const { bands, weights, latitude: climateLatitude } = getClimate();
	forEachTile(iWidth, iHeight, (iX, iY) => {
		if (GameplayMap.isWater(iX, iY)) {
			TerrainBuilder.setBiomeType(iX, iY, g_MarineBiome);
			return;
		}
		const rainfall = GameplayMap.getRainfall(iX, iY);
		if (rainfall < 25) {
			TerrainBuilder.setBiomeType(iX, iY, g_DesertBiome);
		} else if (rainfall > 250 && GameplayMap.getTerrainType(iX, iY) != g_MountainTerrain) {
			TerrainBuilder.setBiomeType(iX, iY, g_TropicalBiome);
		} else {
			const latitude = Math.abs(climateLatitude(iX, iY))
				+ weights.elevation * Math.round(GameplayMap.getElevation(iX, iY) / 120)
				+ weights.rainfall * moistureOffset(rainfall)
				+ weights.river * riverOffset(iX, iY);
			TerrainBuilder.setBiomeType(iX, iY, bandBiome(bands, latitude));
		}
	});
}
