// Applies the Map Age setup setting when a map script raises its rough ground.
//
// A New world is freshly buckled and still broken: more rough ground, less flat.
// An Old world has been worn down: less rough ground, broader plains. Standard
// leaves the base game's own terrain alone.
//
// Rough is TERRAIN_HILL in the game's data, which is why the base symbols and
// the hill score below keep that name; everything the player reads says rough.
//
// Map Age moves rough ground only. Mountains are the Mountains setting's
// business, so the two never pull on the same tiles: pick a map age for how
// broken the ground is, and Mountains for how many peaks rise out of it.
import { g_HillTerrain } from '../../../base-standard/maps/map-globals.js';
import { forEachTile, settingTier } from './bbm-settings.js';

const MAP_AGE_SETTING_KEY = "BBMMapAge";

// Port of {base-standard}maps/elevation-terrain-generator.js addHills, which
// scores each land tile by how much its elevation differs from its neighbors
// and roughens it wherever that score clears a threshold. A lower threshold
// catches gentler ground, so it yields more rough tiles; Standard is the base
// game's own 950 - 3 * 20.
const MAP_AGE_TIERS = {
	BBM_MAPS_MAP_AGE_NEW: 790,
	BBM_MAPS_MAP_AGE_STANDARD: 890,
	BBM_MAPS_MAP_AGE_OLD: 990,
};

export function addHills(iWidth, iHeight) {
	const threshold = settingTier(MAP_AGE_TIERS, MAP_AGE_SETTING_KEY, "BBM_MAPS_MAP_AGE_STANDARD");
	console.log(`BBM map age: rough score threshold ${threshold}`);
	forEachTile(iWidth, iHeight, (iX, iY) => {
		if (GameplayMap.isWater(iX, iY) || GameplayMap.isMountain(iX, iY)) {
			return;
		}
		const location = { x: iX, y: iY };
		const elevation = GameplayMap.getElevation(iX, iY);
		let score = 0;
		for (let direction = 0; direction < DirectionTypes.NUM_DIRECTION_TYPES; direction++) {
			if (GameplayMap.isCliffCrossing(iX, iY, direction)) {
				continue;
			}
			const adjacent = GameplayMap.getAdjacentPlotLocation(location, direction);
			score += Math.abs(GameplayMap.getElevation(adjacent.x, adjacent.y) - elevation);
		}
		if (score > threshold) {
			TerrainBuilder.setTerrainType(iX, iY, g_HillTerrain);
		}
	});
}
