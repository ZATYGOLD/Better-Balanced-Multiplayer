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

const STRICT_BIASES_ON = "MPT_MAPS_STRICT_BIASES_ON";

let strictEnabled;
const biasByPlayer = new Map();
let volcanoIndex;
const biomeIndices = new Map();        // biome type list -> Set of biome indices
const floodplainClasses = new Map();   // feature class value -> is Floodplain

/** On only when chosen; the option exists only in multiplayer setup. */
function isStrictStartBiasEnabled() {
  strictEnabled ??= Configuration.getMapValue("MPTStrictStartBiases") === STRICT_BIASES_ON;
  return strictEnabled;
}

/** Forget cached rules (a new map is being generated). */
function resetStrictStartBiases() {
  strictEnabled = undefined;
  biasByPlayer.clear();
}

function lookupTypeName(table, value, propertyName) {
  const entry = table.lookup(value);
  return entry ? entry[propertyName] : null;
}

/** The player's leader and civilization rules (null when neither has one); cached per player. */
function getPlayerStrictStartBias(playerId) {
  if (biasByPlayer.has(playerId)) return biasByPlayer.get(playerId);
  const player = Players.get(playerId);
  if (player == null) return null;
  const leaderType = lookupTypeName(GameInfo.Leaders, player.leaderType, "LeaderType");
  const civilizationType = lookupTypeName(GameInfo.Civilizations, player.civilizationType, "CivilizationType");
  const rules = [];
  const leaderRule = STRICT_LEADER_RULES.get(leaderType);
  const civilizationRule = STRICT_CIVILIZATION_RULES.get(civilizationType);
  if (leaderRule) rules.push({ ...leaderRule, kind: "Leader", source: leaderType });
  if (civilizationRule) rules.push({ ...civilizationRule, kind: "Civilization", source: civilizationType });
  const bias = rules.length > 0 ? { playerId, leaderType, civilizationType, rules } : null;
  biasByPlayer.set(playerId, bias);
  return bias;
}

function adjacentLocations(x, y) {
  const origin = { x: x, y: y };
  const locations = [];
  for (let direction = 0; direction < 6; direction++) {
    const adjacent = GameplayMap.getAdjacentPlotLocation(origin, direction);
    if (adjacent != null && adjacent.x >= 0 && adjacent.y >= 0) locations.push(adjacent);
  }
  return locations;
}

/** Adjacent ocean-connected water; navigable rivers and lakes do not count. */
function isOceanAccess(x, y) {
  return adjacentLocations(x, y).some((location) => {
    if (GameplayMap.isNavigableRiver(location.x, location.y)) return false;
    if (!GameplayMap.getAreaIsWater(location.x, location.y)) return false;
    const areaId = GameplayMap.getAreaId(location.x, location.y);
    if (areaId < 0) return false;
    // AreaBuilder exists during map generation only; the UI rejects lakes instead.
    if (typeof AreaBuilder !== "undefined") return AreaBuilder.isAreaConnectedToOcean(areaId);
    return !GameplayMap.isLake(location.x, location.y);
  });
}

function biomeIs(x, y, biomeTypes) {
  const key = biomeTypes.join();
  if (!biomeIndices.has(key)) biomeIndices.set(key, new Set(biomeTypes.map((type) => GameInfo.Biomes.lookup(type)?.$index)));
  return biomeIndices.get(key).has(GameplayMap.getBiomeType(x, y));
}

function isFloodplain(x, y) {
  const featureClass = GameplayMap.getFeatureClassType(x, y);
  if (!floodplainClasses.has(featureClass)) {
    floodplainClasses.set(featureClass, GameInfo.FeatureClasses.lookup(featureClass)?.FeatureClassType === "FEATURE_CLASS_FLOODPLAIN");
  }
  return floodplainClasses.get(featureClass);
}

function adjacentToNavigableRiver(x, y) {
  return adjacentLocations(x, y).some((location) => GameplayMap.isNavigableRiver(location.x, location.y));
}

function adjacentToLake(x, y) {
  return adjacentLocations(x, y).some((location) => GameplayMap.isLake(location.x, location.y));
}

function adjacentToMountain(x, y) {
  return adjacentLocations(x, y).some((location) => GameplayMap.isMountain(location.x, location.y));
}

function adjacentToVolcano(x, y) {
  volcanoIndex ??= GameInfo.Features.lookup("FEATURE_VOLCANO")?.$index ?? -1;
  if (volcanoIndex < 0) return false;
  return adjacentLocations(x, y).some((location) => GameplayMap.getFeatureType(location.x, location.y) === volcanoIndex);
}

function adjacentToNaturalWonder(x, y) {
  return adjacentLocations(x, y).some((location) => GameplayMap.isNaturalWonder(location.x, location.y));
}

function withinFloodplains(x, y, radius) {
  for (const plotIndex of GameplayMap.getPlotIndicesInRadius(x, y, radius)) {
    const location = GameplayMap.getLocationFromIndex(plotIndex);
    if (isFloodplain(location.x, location.y)) return true;
  }
  return false;
}

function matchesRule(ruleId, x, y) {
  switch (ruleId) {
    case "desert-or-plains": return biomeIs(x, y, ["BIOME_DESERT", "BIOME_PLAINS"]);
    case "tundra": return biomeIs(x, y, ["BIOME_TUNDRA"]);
    case "tropical": return biomeIs(x, y, ["BIOME_TROPICAL"]);
    case "navigable-river": return adjacentToNavigableRiver(x, y);
    case "ocean-coast": return isOceanAccess(x, y);
    case "floodplains-two": return withinFloodplains(x, y, 2);
    case "mountain": return adjacentToMountain(x, y);
    case "lake": return adjacentToLake(x, y);
    case "iceland":
      return (adjacentToVolcano(x, y) || adjacentToNaturalWonder(x, y)) &&
        biomeIs(x, y, ["BIOME_TUNDRA", "BIOME_GRASSLAND"]);
    case "songhai":
      return adjacentToNavigableRiver(x, y) && biomeIs(x, y, ["BIOME_PLAINS", "BIOME_DESERT"]);
    default: return true;
  }
}

/** A coast rule falls back to an adjacent lake when no ocean start exists. */
function matchesRuleWithLakeFallback(ruleId, x, y) {
  return ruleId === "ocean-coast" ? adjacentToLake(x, y) : matchesRule(ruleId, x, y);
}

function matchesPlayerStrictStartBias(x, y, playerId) {
  if (!isStrictStartBiasEnabled()) return true;
  const bias = getPlayerStrictStartBias(playerId);
  return bias == null || bias.rules.every((rule) => matchesRule(rule.id, x, y));
}

function matchesPlayerStrictStartBiasWithLakeFallback(x, y, playerId) {
  if (!isStrictStartBiasEnabled()) return true;
  const bias = getPlayerStrictStartBias(playerId);
  return bias == null || bias.rules.every((rule) => matchesRuleWithLakeFallback(rule.id, x, y));
}

function describePlayerStrictStartBias(playerId) {
  const bias = getPlayerStrictStartBias(playerId);
  return bias == null ? "none" : bias.rules.map((rule) => `${rule.source}: ${rule.label}`).join("; ");
}

function recordStrictStartBiasFailure(playerId, reason) {
  console.log(`MPT MAPS STRICT START BIAS FAILURE: player=${playerId} requirement=${describePlayerStrictStartBias(playerId)} reason=${reason}`);
}

export {
  getPlayerStrictStartBias,
  isStrictStartBiasEnabled,
  matchesPlayerStrictStartBias,
  matchesPlayerStrictStartBiasWithLakeFallback,
  matchesRule,
  matchesRuleWithLakeFallback,
  recordStrictStartBiasFailure,
  resetStrictStartBiases
};
