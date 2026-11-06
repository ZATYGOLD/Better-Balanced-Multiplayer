function shuffle(values, label) {
  for (let i = values.length - 1; i > 0; i--) {
    const j = TerrainBuilder.getRandomNumber(i + 1, label);
    [values[i], values[j]] = [values[j], values[i]];
  }
}

function guaranteeModernResource(resourceType) {
  const resource = GameInfo.Resources.lookup(resourceType);
  if (resource == null) return;
  const counts = ResourceBuilder.getResourceCounts(PlotTags.PLOT_TAG_ALL);
  const target = Math.max(1, resource.MinimumPerLandmass ?? 1);
  let needed = target - (counts[resource.$index] ?? 0);
  if (needed <= 0) return;

  const candidates = [];
  const width = GameplayMap.getGridWidth();
  const height = GameplayMap.getGridHeight();
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (GameplayMap.getResourceType(x, y) !== ResourceTypes.NO_RESOURCE) continue;
      if (GameplayMap.isNaturalWonder(x, y)) continue;
      if (!ResourceBuilder.canHaveResource(x, y, resource.$index, true)) continue;
      candidates.push(GameplayMap.getIndexFromXY(x, y));
    }
  }
  shuffle(candidates, `EVW ${resourceType} transition candidates`);
  for (const plotIndex of candidates) {
    if (needed <= 0) break;
    const location = GameplayMap.getLocationFromIndex(plotIndex);
    if (GameplayMap.getResourceType(location.x, location.y) !== ResourceTypes.NO_RESOURCE) continue;
    ResourceBuilder.setResourceType(location.x, location.y, resource.$index);
    needed--;
  }
  console.log(`EVW RESOURCES: transition guarantee ${resourceType}, target=${target}, remaining=${needed}`);
}

function guaranteeModernStrategics() {
  if (GameInfo.Ages.lookup(Game.age)?.AgeType !== "AGE_MODERN") return;
  guaranteeModernResource("RESOURCE_OIL");
  guaranteeModernResource("RESOURCE_RUBBER");
}

engine.on("GenerateAgeTransition", guaranteeModernStrategics);
console.log("EVW RESOURCES: Modern Oil/Rubber transition guarantee loaded");

export { guaranteeModernStrategics };
