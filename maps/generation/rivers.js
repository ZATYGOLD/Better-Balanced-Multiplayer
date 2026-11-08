// Applies the Rivers setup setting when a map script models its rivers.
//
// One setting covers both halves of river generation. Every tier scales the
// map script's own intensity, and the tiers that shift how much of the water is
// navigable additionally re-run the base game's river finalisation with their
// own large river share, above or below the base 25. Standard sets neither
// field, so the default path is exactly what the base game produces.
import { g_NavigableRiverTerrain } from '../../../base-standard/maps/map-globals.js';
import { settingTier } from './settings.js';

const RIVERS_SETTING_KEY = "BBMMapRivers";
// scale multiplies the map script's own river percent. The rest re-run the base
// game's river finalisation, which decides which of those rivers become
// navigable, and a tier that leaves them unset gets the base path untouched:
//
//   largeRiverPercent  share promoted to navigable, against the base 25
//   upstream           minor rivers that must feed a river before it may be
//                      promoted at all, against the base 2; this is a gate, so
//                      raising the share above does nothing while it rejects
//                      the candidates
//   navLength          tiles a river must run to be worth promoting, against
//                      the base 2; raising it trades a few long navigable
//                      rivers for many short ones
//
// Listed in the order the setup screen shows them: grouped by river count,
// fewest first, and within each group by how much of that water is navigable.
const RIVERS_TIERS = {
  BBM_MAPS_RIVERS_WADI: { scale: 0.5, largeRiverPercent: 12, upstream: 3 },
  BBM_MAPS_RIVERS_ARID: { scale: 0.5 },
  BBM_MAPS_RIVERS_CHANNEL: { scale: 0.5, largeRiverPercent: 65, upstream: 1, navLength: 3 },
  BBM_MAPS_RIVERS_SHALLOW: { largeRiverPercent: 12, upstream: 3 },
  BBM_MAPS_RIVERS_STANDARD: {},
  BBM_MAPS_RIVERS_WATERWAY: { largeRiverPercent: 65, upstream: 1, navLength: 3 },
  BBM_MAPS_RIVERS_STREAM: { scale: 1.5, largeRiverPercent: 12, upstream: 3 },
  BBM_MAPS_RIVERS_RIVERLAND: { scale: 1.5 },
  BBM_MAPS_RIVERS_DEEP: { scale: 1.5, largeRiverPercent: 65, upstream: 1, navLength: 3 },
};
const MIN_PERCENT = 2.5;
const MAX_PERCENT = 80;
// The base GenerationContext defaults, used wherever a tier says nothing.
const BASE_NAV_RIVER_LENGTH = 2;
const BASE_UPSTREAM_MINOR_RIVERS = 2;

export function modelRivers(defaultLength, defaultPercent) {
  const tier = settingTier(RIVERS_TIERS, RIVERS_SETTING_KEY, "BBM_MAPS_RIVERS_STANDARD");
  const percent = tier.scale
    ? Math.max(MIN_PERCENT, Math.min(MAX_PERCENT, Math.round(defaultPercent * tier.scale)))
    : defaultPercent;
  console.log(`BBM MAPS rivers: modelRivers(${defaultLength}, ${percent})`);
  TerrainBuilder.modelRivers(defaultLength, percent, g_NavigableRiverTerrain);
  if (tier.largeRiverPercent) {
    const navLength = tier.navLength ?? BASE_NAV_RIVER_LENGTH;
    const upstream = tier.upstream ?? BASE_UPSTREAM_MINOR_RIVERS;
    console.log(`BBM MAPS rivers: finalizeRivers at ${tier.largeRiverPercent}% large rivers, min length ${navLength}, min upstream ${upstream}`);
    TerrainBuilder.finalizeRivers(true, tier.largeRiverPercent, navLength, upstream);
  }
}
