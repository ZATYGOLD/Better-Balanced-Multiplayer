// Plot helpers shared by the multiplayer map scripts.

/** The adjacent plot in a direction, or null off the map. */
export function adjacentPlot(location, direction) {
  const next = GameplayMap.getAdjacentPlotLocation(location, direction);
  return next == null || next.x < 0 || next.y < 0 ? null : next;
}

/** The plots adjacent to a location, in direction order, skipping those off the map. */
export function adjacentPlots(location) {
  const plots = [];
  for (let direction = 0; direction < DirectionTypes.NUM_DIRECTION_TYPES; direction++) {
    const next = adjacentPlot(location, direction);
    if (next != null) plots.push(next);
  }
  return plots;
}
