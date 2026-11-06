// This UI validator is intentionally self-contained. MapGenScripts unload
// after generation, so the warning must not depend on a map-generation module.
const LEADER_RULES = new Map([
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

const CIVILIZATION_RULES = new Map([
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

let warningCreated = false;
let validationAttempts = 0;
let trainAttempts = 0;
const MINIMUM_START_DISTANCE = 12;

function getValidationStorageKey() {
  try {
    const mapSeed = Configuration.getMap()?.mapSeed ?? "unknown-map";
    const gameSeed = Configuration.getGame()?.gameSeed ?? "unknown-game";
    return `evw-start-validation-v5-${mapSeed}-${gameSeed}`;
  } catch (_) {
    return null;
  }
}

function validationAlreadyCompleted() {
  const key = getValidationStorageKey();
  if (key == null) return false;
  try {
    return localStorage.getItem(key) === "1";
  } catch (_) {
    return false;
  }
}

function markValidationCompleted() {
  const key = getValidationStorageKey();
  if (key == null) return;
  try {
    localStorage.setItem(key, "1");
  } catch (_) {
    // Storage may be unavailable in restricted UI contexts; the turn gate
    // still prevents warnings during ordinary later-turn reloads.
  }
}

function strictBiasesEnabled() {
  if (typeof Configuration !== "undefined" && typeof Configuration.getMapValue === "function") {
    return Configuration.getMapValue("EvWStrictStartBiases") !== "EVW_STRICT_BIASES_OFF";
  }
  if (typeof GameSetup !== "undefined" && typeof GameSetup.findGameParameter === "function") {
    const parameter = GameSetup.findGameParameter("EvWStrictStartBiases");
    const rawValue = parameter?.value?.value ?? parameter?.value;
    const resolvedValue = typeof rawValue === "number" && typeof GameSetup.resolveString === "function"
      ? GameSetup.resolveString(rawValue)
      : rawValue;
    return resolvedValue !== "EVW_STRICT_BIASES_OFF";
  }
  // Strict biases default to On. Gameplay UI may omit both setup interfaces,
  // so validation must still run without throwing during normal games.
  return true;
}

function lookupTypeName(table, value, propertyName) {
  const entry = table.lookup(value);
  return entry ? entry[propertyName] : null;
}

function getPlayerRules(playerId) {
  const player = Players.get(playerId);
  if (player == null) return null;
  const leaderType = lookupTypeName(GameInfo.Leaders, player.leaderType, "LeaderType");
  const civilizationType = lookupTypeName(GameInfo.Civilizations, player.civilizationType, "CivilizationType");
  const rules = [];
  const leaderRule = LEADER_RULES.get(leaderType);
  const civilizationRule = CIVILIZATION_RULES.get(civilizationType);
  if (leaderRule) rules.push({ ...leaderRule, source: "Leader requirement" });
  if (civilizationRule) rules.push({ ...civilizationRule, source: "Civilization requirement" });
  return rules.length > 0 ? { leaderType, civilizationType, rules } : null;
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
  return volcano != null && adjacentLocations(iX, iY).some(
    (location) => GameplayMap.getFeatureType(location.x, location.y) === volcano.$index
  );
}

function adjacentToNaturalWonder(iX, iY) {
  return adjacentLocations(iX, iY).some((location) => GameplayMap.isNaturalWonder(location.x, location.y));
}

function withinFloodplains(iX, iY, radius) {
  for (const plotIndex of GameplayMap.getPlotIndicesInRadius(iX, iY, radius)) {
    const location = GameplayMap.getLocationFromIndex(plotIndex);
    const featureClass = GameInfo.FeatureClasses.lookup(GameplayMap.getFeatureClassType(location.x, location.y));
    if (featureClass?.FeatureClassType === "FEATURE_CLASS_FLOODPLAIN") return true;
  }
  return false;
}

function oceanCoast(iX, iY) {
  return adjacentLocations(iX, iY).some((location) => {
    if (!GameplayMap.getAreaIsWater(location.x, location.y)) return false;
    const terrain = GameInfo.Terrains.lookup(GameplayMap.getTerrainType(location.x, location.y));
    if (terrain?.TerrainType === "TERRAIN_NAVIGABLE_RIVER") return false;
    const areaId = GameplayMap.getAreaId(location.x, location.y);
    if (areaId < 0) return false;
    return typeof AreaBuilder !== "undefined"
      ? AreaBuilder.isAreaConnectedToOcean(areaId)
      : !GameplayMap.isLake(location.x, location.y);
  });
}

function matchesRule(ruleId, iX, iY) {
  switch (ruleId) {
    case "desert-or-plains": return biomeIs(iX, iY, ["BIOME_DESERT", "BIOME_PLAINS"]);
    case "tundra": return biomeIs(iX, iY, ["BIOME_TUNDRA"]);
    case "tropical": return biomeIs(iX, iY, ["BIOME_TROPICAL"]);
    case "navigable-river": return adjacentToNavigableRiver(iX, iY);
    // Map generation prefers a true ocean coast, but accepts an adjacent lake
    // when no valid coastal start exists. Final UI validation must recognize
    // both accepted outcomes or it will announce a false placement failure.
    case "ocean-coast": return oceanCoast(iX, iY) || adjacentToLake(iX, iY);
    case "floodplains-two": return withinFloodplains(iX, iY, 2);
    case "mountain": return adjacentToMountain(iX, iY);
    case "lake": return adjacentToLake(iX, iY);
    case "iceland":
      return (adjacentToVolcano(iX, iY) || adjacentToNaturalWonder(iX, iY)) &&
        biomeIs(iX, iY, ["BIOME_TUNDRA", "BIOME_GRASSLAND"]);
    case "songhai":
      return adjacentToNavigableRiver(iX, iY) && biomeIs(iX, iY, ["BIOME_PLAINS", "BIOME_DESERT"]);
    default: return true;
  }
}

function getFinalStartLocation(playerId) {
  try {
    if (typeof StartPositioner !== "undefined") {
      const plotIndex = StartPositioner.getStartPosition(playerId);
      if (plotIndex != null && plotIndex >= 0) return GameplayMap.getLocationFromIndex(plotIndex);
    }
  } catch (error) {
    console.log(`EVW STRICT START BIAS: StartPositioner unavailable in gameplay UI; using player objects (${error})`);
  }
  const player = Players.get(playerId);
  const capital = player?.Cities?.getCapital();
  if (capital?.location) return capital.location;
  const units = player?.Units?.getUnits() ?? [];
  return units.length > 0 ? units[0].location : null;
}

function getPlayerLabel(playerId) {
  const player = Players.get(playerId);
  if (player == null) return `Player ${playerId + 1}`;
  const leader = GameInfo.Leaders.lookup(player.leaderType);
  const civilization = GameInfo.Civilizations.lookup(player.civilizationType);
  const leaderName = leader?.Name ? Locale.compose(leader.Name) : `Player ${playerId + 1}`;
  const civilizationName = civilization?.Name ? Locale.compose(civilization.Name) : "Unknown Civilization";
  return `${leaderName} / ${civilizationName}`;
}

function createVisibleBanner(summary) {
  if (document.body == null) return;
  document.querySelector(".evw-strict-bias-banner")?.remove();
  const banner = document.createElement("div");
  banner.classList.add("evw-strict-bias-banner");
  Object.assign(banner.style, {
    position: "fixed", right: "5rem", top: "7rem", width: "29rem", zIndex: "10000",
    padding: "1rem 1.25rem", border: "2px solid #d9b56d", borderRadius: "0.35rem",
    background: "linear-gradient(135deg, rgba(39,31,24,0.98), rgba(18,23,30,0.98))",
    color: "#f4e6c2", fontSize: "1rem", lineHeight: "1.35", whiteSpace: "pre-wrap",
    boxShadow: "0 0 1.2rem rgba(0,0,0,0.85)", pointerEvents: "auto",
    transition: "opacity 0.5s ease"
  });
  banner.textContent = `${summary}\n\nSelect this message to close it. Select the notification icon to view these details again.`;
  banner.addEventListener("click", () => banner.remove());
  document.body.appendChild(banner);
  setTimeout(() => { banner.style.opacity = "0"; }, 20000);
  setTimeout(() => banner.remove(), 20600);
}

function addNotificationRailIcon(summary, failureCount) {
  const train = document.querySelector("panel-notification-train");
  const list = train?.querySelector(".notification-train__list");
  if (list == null) {
    if (trainAttempts++ < 15) setTimeout(() => addNotificationRailIcon(summary, failureCount), 1000);
    return;
  }
  const typeContainer = document.createElement("div");
  typeContainer.classList.add("notif__container", "notif__animate", "evw-strict-bias-notification");
  const notificationContainer = document.createElement("fxs-vslot");
  notificationContainer.classList.add("notification-container");
  const button = document.createElement("fxs-activatable");
  button.classList.add("notice", "notif__button");
  button.setAttribute("tabindex", "-1");
  button.setAttribute("data-tooltip-content", `Select to view start-placement failures.\n${summary}`);
  const background = document.createElement("div");
  background.classList.add("notif__button-bk");
  const icon = document.createElement("div");
  icon.classList.add("notif__button-icon");
  const iconUrl = UI.getIconURL("NOTIFICATION_WONDER_FAILED", "NOTIFICATION") ?? UI.getIconURL("DEFAULT_NOTIFICATION");
  icon.style.backgroundImage = `url("${iconUrl}")`;
  button.append(background, icon);
  const number = document.createElement("div");
  number.className = "notif__button-number bg-contain bg-no-repeat bg-center text-sm font-body size-6 top-0 right-2 absolute flex items-center justify-center pointer-events-none";
  number.textContent = `${failureCount}`;
  button.appendChild(number);
  const dismiss = () => typeContainer.remove();
  button.addEventListener("action-activate", () => createVisibleBanner(summary));
  button.addEventListener("contextmenu", (event) => { event.preventDefault(); dismiss(); });
  notificationContainer.appendChild(button);
  typeContainer.appendChild(notificationContainer);
  list.insertBefore(typeContainer, list.firstChild);
  train.querySelector(".notification-train__nav-help-container")?.classList.add("notification-available");
}

function createFailureNotification(failures) {
  const summary = "START PLACEMENT WARNING\nThe safe original-start fallback was used because these requirements were not met:\n" +
    failures.map((failure) => `- ${failure}`).join("\n");
  createVisibleBanner(summary);
  addNotificationRailIcon(summary, failures.length);
  UI.sendAudioEvent("notif-Wonder_Failed");
  console.log(`EVW STRICT START BIAS NOTIFICATION: displayed ${failures.length} failure(s)`);
}

function validateStrictBiases() {
  if (warningCreated) return;
  if (typeof Game === "undefined" || Game.turn == null) {
    if (validationAttempts++ < 15) setTimeout(runValidationSafely, 1000);
    return;
  }
  // This validator is only for a newly generated game's opening turn. The
  // seed marker prevents it from replaying after a turn-one desync/UI reload.
  if (Game.turn !== 1 || validationAlreadyCompleted()) return;
  const aliveMajorIds = Players.getAliveMajorIds();
  if (aliveMajorIds.length === 0 && validationAttempts++ < 15) {
    setTimeout(runValidationSafely, 1000);
    return;
  }
  const failures = [];
  const locations = new Map();
  let unresolvedStarts = 0;
  for (const playerId of aliveMajorIds) {
    const location = getFinalStartLocation(playerId);
    if (location == null) { unresolvedStarts++; continue; }
    locations.set(playerId, location);
    if (!GameplayMap.isFreshWater(location.x, location.y)) {
      failures.push(`${getPlayerLabel(playerId)}: starting tile does not have Fresh Water`);
    }
    if (strictBiasesEnabled()) {
      const bias = getPlayerRules(playerId);
      const failedRules = bias?.rules.filter((rule) => !matchesRule(rule.id, location.x, location.y)) ?? [];
      if (failedRules.length > 0) {
        failures.push(`${getPlayerLabel(playerId)}: ${failedRules.map((rule) => `${rule.source}: ${rule.label}`).join("; ")}`);
      }
    }
  }
  if (unresolvedStarts > 0 && validationAttempts++ < 15) {
    setTimeout(runValidationSafely, 1000);
    return;
  }
  for (let i = 0; i < aliveMajorIds.length; i++) {
    for (let j = i + 1; j < aliveMajorIds.length; j++) {
      const firstId = aliveMajorIds[i];
      const secondId = aliveMajorIds[j];
      const first = locations.get(firstId);
      const second = locations.get(secondId);
      if (first == null || second == null) continue;
      const distance = GameplayMap.getPlotDistance(first.x, first.y, second.x, second.y);
      if (distance < MINIMUM_START_DISTANCE) {
        failures.push(
          `${getPlayerLabel(firstId)} and ${getPlayerLabel(secondId)}: only ${distance} tiles apart; ` +
          `${MINIMUM_START_DISTANCE} required`
        );
      }
    }
  }
  markValidationCompleted();
  if (failures.length === 0) return;
  warningCreated = true;
  createFailureNotification(failures);
}

function scheduleValidation() {
  setTimeout(runValidationSafely, 3000);
}

function runValidationSafely() {
  try {
    validateStrictBiases();
  } catch (error) {
    console.error(`EVW STRICT START BIAS NOTIFICATION: validation error: ${error?.stack ?? error}`);
    // Never present an internal validator problem as a failed civilization
    // start. Only confirmed rule failures create player-facing notifications.
  }
}

window.addEventListener("user-interface-loaded-and-ready", scheduleValidation, { once: true });
// MPT: the start check follows the multiplayer Player Placement pass, which
// runs only when the Map Options exist (multiplayer setup).
engine.whenReady.then(() => {
  if (typeof Configuration !== "undefined" && Configuration.getMapValue?.("EvWPlayerPlacement") == null) return;
  scheduleValidation();
});
setTimeout(runValidationSafely, 7000);

console.log("EVW START PLACEMENT NOTIFICATION v3: loaded");
