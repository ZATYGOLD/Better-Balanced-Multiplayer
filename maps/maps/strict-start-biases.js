const STRICT_LEADER_RULES = new Map([
  ["LEADER_AMINA", { id: "desert-or-plains", label: "Desert or Plains" }],
  ["LEADER_CATHERINE", { id: "tundra", label: "Tundra" }],
  ["LEADER_HATSHEPSUT", { id: "navigable-river", label: "adjacent to a Navigable River" }],
  ["LEADER_TRUNG_TRAC", { id: "tropical", label: "Tropical" }],
  ["LEADER_PACHACUTI", { id: "mountain", label: "adjacent to a Mountain" }],
  ["LEADER_EDWARD_TEACH", { id: "ocean-coast", label: "ocean coast" }],
  ["LEADER_LAFAYETTE", { id: "ocean-coast", label: "ocean coast" }],
  ["LEADER_SAYYIDA_AL_HURRA", { id: "ocean-coast", label: "ocean coast" }],
  ["LEADER_YI_SUN_SIN", { id: "ocean-coast", label: "ocean coast" }],
  ["LEADER_ELIZABETH", { id: "ocean-coast", label: "ocean coast" }]
]);

const STRICT_CIVILIZATION_RULES = new Map([
  ["CIVILIZATION_AKSUM", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_CARTHAGE", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_EGYPT", { id: "navigable-river", label: "adjacent to a Navigable River" }],
  ["CIVILIZATION_KHMER", { id: "floodplains-two", label: "within 2 tiles of Floodplains" }],
  ["CIVILIZATION_MAYA", { id: "tropical", label: "Tropical" }],
  ["CIVILIZATION_TONGA", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_CHOLA", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_DAI_VIET", { id: "tropical", label: "Tropical" }],
  ["CIVILIZATION_HAWAII", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_ICELAND", { id: "iceland", label: "adjacent to a Volcano or Natural Wonder and on Tundra or Grassland" }],
  ["CIVILIZATION_INCA", { id: "mountain", label: "adjacent to a Mountain" }],
  ["CIVILIZATION_MAJAPAHIT", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_PIRATE_REPUBLIC", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_SONGHAI", { id: "songhai", label: "adjacent to a Navigable River and on Plains or Desert" }],
  ["CIVILIZATION_SPAIN", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_BUGANDA", { id: "lake", label: "adjacent to a Lake" }],
  ["CIVILIZATION_GREAT_BRITAIN", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_ENGLAND", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_MEIJI", { id: "ocean-coast", label: "ocean coast" }],
  ["CIVILIZATION_NEPAL", { id: "mountain", label: "adjacent to a Mountain" }],
  ["CIVILIZATION_PRUSSIA", { id: "navigable-river", label: "adjacent to a Navigable River" }],
  ["CIVILIZATION_RUSSIA", { id: "tundra", label: "Tundra" }]
]);

const strictBiasFailures = new Map();

function isStrictStartBiasEnabled() {
  // MPT: On only when chosen; the option exists only in multiplayer setup.
  return Configuration.getMapValue("EvWStrictStartBiases") === "EVW_STRICT_BIASES_ON";
}

function lookupTypeName(table, value, propertyName) {
  const entry = table.lookup(value);
  return entry ? entry[propertyName] : null;
}

function getPlayerStrictStartBias(playerId) {
  const player = Players.get(playerId);
  if (player == null) return null;
  const leaderType = lookupTypeName(GameInfo.Leaders, player.leaderType, "LeaderType");
  const civilizationType = lookupTypeName(GameInfo.Civilizations, player.civilizationType, "CivilizationType");
  const rules = [];
  const leaderRule = STRICT_LEADER_RULES.get(leaderType);
  const civilizationRule = STRICT_CIVILIZATION_RULES.get(civilizationType);
  if (leaderRule) rules.push({ ...leaderRule, source: leaderType });
  if (civilizationRule) rules.push({ ...civilizationRule, source: civilizationType });
  if (rules.length === 0) return null;
  return { playerId, leaderType, civilizationType, rules };
}

function adjacentLocations(iX, iY) {
  const origin = GameplayMap.getLocationFromIndex(GameplayMap.getIndexFromXY(iX, iY));
  const locations = [];
  for (let direction = 0; direction < 6; direction++) {
    const adjacent = GameplayMap.getAdjacentPlotLocation(origin, direction);
    if (adjacent != null && adjacent.x >= 0 && adjacent.y >= 0) locations.push(adjacent);
  }
  return locations;
}

function isOceanAccess(iX, iY) {
  return adjacentLocations(iX, iY).some((location) => {
    const terrain = GameInfo.Terrains.lookup(GameplayMap.getTerrainType(location.x, location.y));
    // Coast-biased starts must touch actual ocean-connected coastal water.
    // Navigable rivers do not qualify, even when the river reaches the ocean.
    if (terrain?.TerrainType === "TERRAIN_NAVIGABLE_RIVER") return false;
    if (!GameplayMap.getAreaIsWater(location.x, location.y)) return false;
    const areaId = GameplayMap.getAreaId(location.x, location.y);
    if (areaId < 0) return false;
    if (typeof AreaBuilder !== "undefined") {
      return AreaBuilder.isAreaConnectedToOcean(areaId);
    }
    // UI validation does not expose AreaBuilder on every game version. In
    // that context, reject lakes and navigable rivers, and accept other water.
    return !GameplayMap.isLake(location.x, location.y);
  });
}

function biomeIs(iX, iY, biomeTypes) {
  const biome = GameInfo.Biomes.lookup(GameplayMap.getBiomeType(iX, iY));
  return biome != null && biomeTypes.includes(biome.BiomeType);
}

function adjacentToNavigableRiver(iX, iY) {
  return adjacentLocations(iX, iY).some((location) => GameplayMap.isNavigableRiver(location.x, location.y));
}

function adjacentToLake(iX, iY) {
  return adjacentLocations(iX, iY).some((location) => GameplayMap.isLake(location.x, location.y));
}

function adjacentToMountain(iX, iY) {
  return adjacentLocations(iX, iY).some((location) => GameplayMap.isMountain(location.x, location.y));
}

function adjacentToVolcano(iX, iY) {
  const volcano = GameInfo.Features.lookup("FEATURE_VOLCANO");
  if (volcano == null) return false;
  return adjacentLocations(iX, iY).some(
    (location) => GameplayMap.getFeatureType(location.x, location.y) === volcano.$index
  );
}

function adjacentToNaturalWonder(iX, iY) {
  return adjacentLocations(iX, iY).some(
    (location) => GameplayMap.isNaturalWonder(location.x, location.y)
  );
}

function withinFloodplains(iX, iY, radius) {
  const plots = GameplayMap.getPlotIndicesInRadius(iX, iY, radius);
  for (const plotIndex of plots) {
    const location = GameplayMap.getLocationFromIndex(plotIndex);
    const featureClass = GameInfo.FeatureClasses.lookup(GameplayMap.getFeatureClassType(location.x, location.y));
    if (featureClass?.FeatureClassType === "FEATURE_CLASS_FLOODPLAIN") return true;
  }
  return false;
}

function matchesRule(ruleId, iX, iY) {
  switch (ruleId) {
    case "desert-or-plains":
      return biomeIs(iX, iY, ["BIOME_DESERT", "BIOME_PLAINS"]);
    case "tundra":
      return biomeIs(iX, iY, ["BIOME_TUNDRA"]);
    case "tropical":
      return biomeIs(iX, iY, ["BIOME_TROPICAL"]);
    case "navigable-river":
      return adjacentToNavigableRiver(iX, iY);
    case "ocean-coast":
      return isOceanAccess(iX, iY);
    case "floodplains-two":
      return withinFloodplains(iX, iY, 2);
    case "mountain":
      return adjacentToMountain(iX, iY);
    case "lake":
      return adjacentToLake(iX, iY);
    case "iceland":
      return (
        (adjacentToVolcano(iX, iY) || adjacentToNaturalWonder(iX, iY)) &&
        biomeIs(iX, iY, ["BIOME_TUNDRA", "BIOME_GRASSLAND"])
      );
    case "songhai":
      return adjacentToNavigableRiver(iX, iY) && biomeIs(iX, iY, ["BIOME_PLAINS", "BIOME_DESERT"]);
    default:
      return true;
  }
}

function matchesPlayerStrictStartBias(iX, iY, playerId) {
  if (!isStrictStartBiasEnabled()) return true;
  const bias = getPlayerStrictStartBias(playerId);
  return bias == null || bias.rules.every((rule) => matchesRule(rule.id, iX, iY));
}

function matchesPlayerStrictStartBiasWithLakeFallback(iX, iY, playerId) {
  if (!isStrictStartBiasEnabled()) return true;
  const bias = getPlayerStrictStartBias(playerId);
  if (bias == null) return true;
  return bias.rules.every((rule) =>
    rule.id === "ocean-coast" ? adjacentToLake(iX, iY) : matchesRule(rule.id, iX, iY)
  );
}

function describePlayerStrictStartBias(playerId) {
  const bias = getPlayerStrictStartBias(playerId);
  if (bias == null) return "none";
  return bias.rules.map((rule) => `${rule.source}: ${rule.label}`).join("; ");
}

function recordStrictStartBiasFailure(playerId, reason) {
  if (!strictBiasFailures.has(playerId)) {
    strictBiasFailures.set(playerId, { playerId, reason, requirement: describePlayerStrictStartBias(playerId) });
  }
  console.log(
    `EVW STRICT START BIAS FAILURE: player=${playerId} requirement=${describePlayerStrictStartBias(playerId)} reason=${reason}`
  );
}

function clearStrictStartBiasFailure(playerId) {
  strictBiasFailures.delete(playerId);
}

function clearStrictStartBiasFailures() {
  strictBiasFailures.clear();
}

function getStrictStartBiasFailures() {
  return [...strictBiasFailures.values()];
}

export {
  clearStrictStartBiasFailure,
  clearStrictStartBiasFailures,
  describePlayerStrictStartBias,
  getPlayerStrictStartBias,
  getStrictStartBiasFailures,
  isStrictStartBiasEnabled,
  matchesPlayerStrictStartBias,
  matchesPlayerStrictStartBiasWithLakeFallback,
  recordStrictStartBiasFailure
};
