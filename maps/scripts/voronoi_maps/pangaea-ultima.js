import { RandomImpl } from '../../../../base-standard/scripts/random-pcg-32.js';
import { ContinentGenerator, continentGeneratorSchema, continentGeneratorRulesSettings } from '../../../../base-standard/scripts/voronoi_generators/continent-generator.js';
import { VoronoiMap, voronoiMapSchema } from '../../../../base-standard/scripts/voronoi_maps/map-common.js';
import pangaeaUltimaSettings from '../voronoi_data/pangaea-ultima.mapconfig.js';

// The game's Voronoi Pangaea with the Pangaea Ultima settings: one larger,
// centred player continent with fewer coastal islands.
class VoronoiPangaeaUltima extends VoronoiMap {
  constructor() {
    const generator = new ContinentGenerator({ ...continentGeneratorSchema }, { ...continentGeneratorRulesSettings });
    super({ ...voronoiMapSchema }, generator, generator.getDefaultGeneratorSettings(), generator.getDefaultRuleSettings(), pangaeaUltimaSettings);
  }
  static getName() {
    return "Pangaea Ultima";
  }
  init(hexDims) {
    this.initInternal(hexDims);
  }
  simulateInternal() {
    const settings = this.getGenerator().getSettings();
    settings.landmass[0].playerAreas = this.getSettings().totalPlayers;
    settings.landmass[0].xPos = 0.46 + RandomImpl.fRand("Pangaea Ultima seed x") * 0.08;
    settings.landmass[0].yPos = 0.43 + RandomImpl.fRand("Pangaea Ultima seed y") * 0.14;
  }
  getFilename() {
    return "pangaea-ultima.mapconfig.js";
  }
}

export { VoronoiPangaeaUltima };
