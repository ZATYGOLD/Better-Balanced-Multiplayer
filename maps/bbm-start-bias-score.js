// The game's start-bias score (base-standard assign-starting-plots.js
// adjustScoreByStartBias, which is not exported), with each player's matching
// StartBias rows resolved once instead of on every scored tile.
import { isOceanAccess } from '../../base-standard/maps/map-utilities.js';

const BIAS_RADIUS = 3;

/** Per StartBias table: its type column (if any) and how one matching row scores a tile. */
const SCORERS = {
	StartBiasBiomes: { typeColumn: "BiomeType", table: "Biomes", score: (row, x, y) => radiusScore(x, y, row.Score, true, (px, py) => GameplayMap.getBiomeType(px, py) === row.typeIndex) },
	StartBiasTerrains: { typeColumn: "TerrainType", table: "Terrains", score: (row, x, y) => radiusScore(x, y, row.Score, true, (px, py) => GameplayMap.getTerrainType(px, py) === row.typeIndex) },
	StartBiasRivers: { score: (row, x, y) => radiusScore(x, y, row.Score, true, (px, py) => GameplayMap.isRiver(px, py)) },
	StartBiasAdjacentToCoasts: { score: (row, x, y) => (isOceanAccess(x, y) ? row.Score : 0) },
	StartBiasFeatureClasses: { typeColumn: "FeatureClassType", table: "FeatureClasses", score: (row, x, y) => radiusScore(x, y, row.Score, true, (px, py) => featureClassIndex(px, py) === row.typeIndex) },
	StartBiasResources: { typeColumn: "ResourceType", table: "Resources", score: (row, x, y) => radiusScore(x, y, row.Score, false, (px, py) => GameplayMap.getResourceType(px, py) === row.typeIndex) },
	StartBiasLakes: { score: (row, x, y) => radiusScore(x, y, row.Score, false, (px, py) => GameplayMap.isLake(px, py)) },
	StartBiasNaturalWonders: { score: (row, x, y) => radiusScore(x, y, row.Score, false, (px, py) => GameplayMap.isNaturalWonder(px, py)) },
	StartBiasIslands: { score: (row, x, y) => (GameplayMap.isIsland(x, y) ? row.Score : 0) }
};

const biasesByPlayer = new Map();
const featureClassByFeature = new Map();

function featureClassIndex(x, y) {
	const feature = GameplayMap.getFeatureType(x, y);
	if (!featureClassByFeature.has(feature)) {
		const featureClass = GameInfo.Features.lookup(feature)?.FeatureClassType;
		featureClassByFeature.set(feature, featureClass ? GameInfo.FeatureClasses.lookup(featureClass)?.$index : undefined);
	}
	return featureClassByFeature.get(feature);
}

/** Sum of score (divided by distance, at least 1, when scaled) over matching plots within the radius. */
function radiusScore(x, y, score, byDistance, matches) {
	let total = 0;
	for (const plotIndex of GameplayMap.getPlotIndicesInRadius(x, y, BIAS_RADIUS)) {
		const location = GameplayMap.getLocationFromIndex(plotIndex);
		if (!matches(location.x, location.y)) continue;
		total += byDistance ? score / Math.max(1, GameplayMap.getPlotDistance(x, y, location.x, location.y)) : score;
	}
	return total;
}

/** The player's matching rows; a row naming both the civilization and the leader counts twice, as in the game. */
function playerBiases(playerId) {
	if (biasesByPlayer.has(playerId)) return biasesByPlayer.get(playerId);
	const player = Players.get(playerId);
	if (player == null || !player.isAlive) return [];
	const civilization = GameInfo.Civilizations.lookup(player.civilizationType)?.CivilizationType;
	const leader = GameInfo.Leaders.lookup(player.leaderType)?.LeaderType;
	const biases = [];
	for (const [tableName, scorer] of Object.entries(SCORERS)) {
		for (const row of GameInfo[tableName] ?? []) {
			const matches = (row.CivilizationType && row.CivilizationType === civilization ? 1 : 0) +
				(row.LeaderType && row.LeaderType === leader ? 1 : 0);
			if (matches === 0 || (scorer.typeColumn && !row[scorer.typeColumn])) continue;
			const typeIndex = scorer.typeColumn ? GameInfo[scorer.table].lookup(row[scorer.typeColumn])?.$index : undefined;
			for (let i = 0; i < matches; i++) biases.push({ scorer, row: { Score: row.Score, typeIndex } });
		}
	}
	biasesByPlayer.set(playerId, biases);
	return biases;
}

function adjustScoreByStartBias(x, y, playerId) {
	let score = 0;
	for (const { scorer, row } of playerBiases(playerId)) score += scorer.score(row, x, y);
	return score;
}

/** Forget cached rows (a new map is being generated). */
function resetStartBiasScores() {
	biasesByPlayer.clear();
}

export { adjustScoreByStartBias, resetStartBiasScores };
