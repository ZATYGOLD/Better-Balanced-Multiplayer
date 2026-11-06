const GENERAL_RESOURCES = [
  "RESOURCE_CAMELS",
  "RESOURCE_CLAY",
  "RESOURCE_COTTON",
  "RESOURCE_COWRIE",
  "RESOURCE_CRABS",
  "RESOURCE_FISH",
  "RESOURCE_LIMESTONE",
  "RESOURCE_HARDWOOD",
  "RESOURCE_HORSES",
  "RESOURCE_IRON",
  "RESOURCE_SALT",
  "RESOURCE_HIDES",
  "RESOURCE_PEARLS",
  "RESOURCE_RICE",
  "RESOURCE_TIN",
  "RESOURCE_WHALES",
  "RESOURCE_WINE",
  "RESOURCE_SILK",
  "RESOURCE_TURTLES",
  "RESOURCE_WILD_GAME",
  "RESOURCE_WOOL",
  "RESOURCE_COAL",
  "RESOURCE_DYES",
  "RESOURCE_NITER"
];

const MODERN_GENERAL_RESOURCES = ["RESOURCE_RUBBER", "RESOURCE_OIL"];

const CONTINENT_POOLS = [
  ["RESOURCE_GOLD", "RESOURCE_SILVER", "RESOURCE_RUBIES"],
  ["RESOURCE_GYPSUM", "RESOURCE_IVORY", "RESOURCE_LLAMAS", "RESOURCE_COFFEE", "RESOURCE_TOBACCO"],
  ["RESOURCE_SPICES", "RESOURCE_TEA", "RESOURCE_QUININE", "RESOURCE_SUGAR", "RESOURCE_CITRUS"]
];

const OTHER_CONTINENT_RESOURCES = [
  "RESOURCE_DATES",
  "RESOURCE_FURS",
  "RESOURCE_INCENSE",
  "RESOURCE_FLAX",
  "RESOURCE_KAOLIN",
  "RESOURCE_JADE",
  "RESOURCE_MANGOS",
  "RESOURCE_MARBLE",
  "RESOURCE_TRUFFLES",
  "RESOURCE_COCOA",
  "RESOURCE_PITCH"
];

const STANDARD_DENSITY = { label: "Standard", fraction: 0.15 };

function shuffleInPlace(values, label) {
  for (let i = values.length - 1; i > 0; i--) {
    const j = TerrainBuilder.getRandomNumber(i + 1, label);
    [values[i], values[j]] = [values[j], values[i]];
  }
  return values;
}

function resolveResourceTypes(typeNames) {
  const result = [];
  for (const typeName of typeNames) {
    const definition = GameInfo.Resources.lookup(typeName);
    if (definition == null) {
      console.log(`EVW RESOURCES: ${typeName} is unavailable and will be skipped`);
      continue;
    }
    result.push(definition.$index);
  }
  return result;
}

function getLandContinent(x, y) {
  const continent = GameplayMap.getContinentType(x, y);
  return continent == null ? -1 : continent;
}

function collectContinents(width, height) {
  const continents = new Map();
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (GameplayMap.isWater(x, y)) continue;
      const continent = getLandContinent(x, y);
      if (continent < 0) continue;
      if (!continents.has(continent)) continents.set(continent, []);
      continents.get(continent).push(GameplayMap.getIndexFromXY(x, y));
    }
  }
  return continents;
}

function makePoolBag(typeNames, label) {
  return {
    source: [...typeNames],
    values: shuffleInPlace([...typeNames], label)
  };
}

function drawFromPoolBag(bag, label) {
  if (bag.values.length === 0) {
    bag.values = shuffleInPlace([...bag.source], label);
  }
  return bag.values.pop();
}

function chooseContinentResources(continents) {
  const selections = new Map();
  const poolBags = CONTINENT_POOLS.map((pool, index) => makePoolBag(pool, `EVW continent pool ${index + 1}`));
  for (const continent of [...continents.keys()].sort((a, b) => a - b)) {
    const selected = new Set();
    for (let poolIndex = 0; poolIndex < poolBags.length; poolIndex++) {
      selected.add(drawFromPoolBag(poolBags[poolIndex], `EVW continent pool ${poolIndex + 1} refill`));
    }
    const other = shuffleInPlace([...OTHER_CONTINENT_RESOURCES], `EVW continent ${continent} other resources`);
    for (let i = 0; i < 3 && i < other.length; i++) selected.add(other[i]);
    selections.set(continent, resolveResourceTypes([...selected]));
    console.log(
      `EVW RESOURCES: continent=${continent} selected=${[...selected].join(",")}`
    );
  }
  return selections;
}

function hasAdjacentResource(x, y, maximumAllowed) {
  let adjacent = 0;
  const location = { x, y };
  for (let direction = 0; direction < DirectionTypes.NUM_DIRECTION_TYPES; direction++) {
    const next = GameplayMap.getAdjacentPlotLocation(location, direction);
    if (next == null) continue;
    if (GameplayMap.getResourceType(next.x, next.y) !== ResourceTypes.NO_RESOURCE) {
      adjacent++;
      if (adjacent > maximumAllowed) return true;
    }
  }
  return false;
}

function clearGeneratedResources(width, height) {
  let removed = 0;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (GameplayMap.getResourceType(x, y) === ResourceTypes.NO_RESOURCE) continue;
      ResourceBuilder.setResourceType(x, y, ResourceTypes.NO_RESOURCE);
      removed++;
    }
  }
  return removed;
}

function pickCandidate(candidates, placedCounts, eligibleCounts) {
  let best = -1;
  let bestScore = Number.POSITIVE_INFINITY;
  for (const resourceIndex of candidates) {
    const eligible = Math.max(1, eligibleCounts[resourceIndex]);
    const score = placedCounts[resourceIndex] / eligible + TerrainBuilder.getRandomNumber(1000, "EVW resource balance") / 100000000;
    if (score < bestScore) {
      bestScore = score;
      best = resourceIndex;
    }
  }
  return best;
}

function placeGuaranteedResource(resourceIndex, candidatesByResource, placedCounts, maximumAdjacent, label) {
  const candidates = candidatesByResource.get(resourceIndex);
  if (candidates == null || candidates.length === 0) return false;
  shuffleInPlace(candidates, label);
  for (const plotIndex of candidates) {
    const location = GameplayMap.getLocationFromIndex(plotIndex);
    if (GameplayMap.getResourceType(location.x, location.y) !== ResourceTypes.NO_RESOURCE) continue;
    if (hasAdjacentResource(location.x, location.y, maximumAdjacent)) continue;
    ResourceBuilder.setResourceType(location.x, location.y, resourceIndex);
    placedCounts[resourceIndex]++;
    return true;
  }
  return false;
}

function generateGlobalResources() {
  const width = GameplayMap.getGridWidth();
  const height = GameplayMap.getGridHeight();
  const ageType = GameInfo.Ages.lookup(Game.age)?.AgeType;
  const density = STANDARD_DENSITY;
  const generalNames = [...GENERAL_RESOURCES];
  if (ageType === "AGE_MODERN") generalNames.push(...MODERN_GENERAL_RESOURCES);
  const generalResources = resolveResourceTypes(generalNames);

  const removed = clearGeneratedResources(width, height);
  const continents = collectContinents(width, height);
  const selectedByContinent = chooseContinentResources(continents);
  const candidatesByPlot = new Map();
  const candidatesByResource = new Map();
  const eligibleCounts = new Uint32Array(GameInfo.Resources.length);
  const placeablePlots = [];

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (GameplayMap.isNaturalWonder(x, y)) continue;
      const plotIndex = GameplayMap.getIndexFromXY(x, y);
      const candidates = [...generalResources];
      if (!GameplayMap.isWater(x, y)) {
        const continent = getLandContinent(x, y);
        const selected = selectedByContinent.get(continent);
        if (selected != null) candidates.push(...selected);
      }
      const valid = [];
      for (const resourceIndex of candidates) {
        if (!ResourceBuilder.canHaveResource(x, y, resourceIndex, true)) continue;
        valid.push(resourceIndex);
        eligibleCounts[resourceIndex]++;
        if (!candidatesByResource.has(resourceIndex)) candidatesByResource.set(resourceIndex, []);
        candidatesByResource.get(resourceIndex).push(plotIndex);
      }
      if (valid.length === 0) continue;
      candidatesByPlot.set(plotIndex, valid);
      placeablePlots.push(plotIndex);
    }
  }

  const placedCounts = new Uint16Array(GameInfo.Resources.length);
  let placedTotal = 0;
  for (const resourceIndex of generalResources) {
    if (placeGuaranteedResource(resourceIndex, candidatesByResource, placedCounts, 0, "EVW guaranteed general resource")) {
      placedTotal++;
    } else {
      console.log(`EVW RESOURCES: no valid tile for general resource ${GameInfo.Resources[resourceIndex]?.ResourceType}`);
    }
  }
  for (const [continent, resources] of selectedByContinent) {
    for (const resourceIndex of resources) {
      const continentCandidates = (candidatesByResource.get(resourceIndex) ?? []).filter((plotIndex) => {
        const location = GameplayMap.getLocationFromIndex(plotIndex);
        return getLandContinent(location.x, location.y) === continent;
      });
      const temporaryMap = new Map([[resourceIndex, continentCandidates]]);
      if (placeGuaranteedResource(resourceIndex, temporaryMap, placedCounts, 0, "EVW guaranteed continent resource")) {
        placedTotal++;
      } else {
        console.log(
          `EVW RESOURCES: continent=${continent} has no valid tile for ${GameInfo.Resources[resourceIndex]?.ResourceType}`
        );
      }
    }
  }

  const target = Math.max(placedTotal, Math.round(placeablePlots.length * density.fraction));
  shuffleInPlace(placeablePlots, "EVW resource plot order");
  for (let pass = 0; pass < 3 && placedTotal < target; pass++) {
    const maximumAdjacent = pass === 0 ? 0 : pass;
    for (const plotIndex of placeablePlots) {
      if (placedTotal >= target) break;
      const location = GameplayMap.getLocationFromIndex(plotIndex);
      if (GameplayMap.getResourceType(location.x, location.y) !== ResourceTypes.NO_RESOURCE) continue;
      if (hasAdjacentResource(location.x, location.y, maximumAdjacent)) continue;
      const resourceIndex = pickCandidate(candidatesByPlot.get(plotIndex), placedCounts, eligibleCounts);
      if (resourceIndex < 0) continue;
      ResourceBuilder.setResourceType(location.x, location.y, resourceIndex);
      placedCounts[resourceIndex]++;
      placedTotal++;
    }
  }

  console.log(
    `EVW RESOURCES: density=${density.label} candidates=${placeablePlots.length} target=${target} placed=${placedTotal} replaced=${removed}`
  );
}

export { generateGlobalResources };
