import { RandomImpl } from '../random-pcg-32.js';
import { ContinentGenerator, continentGeneratorSchema, continentGeneratorRulesSettings } from '../voronoi_generators/continent-generator.js';
import ffaPangaeaSettings from '../voronoi_data/ffa-pangaea.mapconfig.js';
import { VoronoiMap, voronoiMapSchema } from './map-common.js';

class VoronoiFfaPangaea extends VoronoiMap {
  constructor() {
    const generator = new ContinentGenerator(
      { ...continentGeneratorSchema },
      { ...continentGeneratorRulesSettings }
    );
    super(
      { ...voronoiMapSchema },
      generator,
      generator.getDefaultGeneratorSettings(),
      generator.getDefaultRuleSettings(),
      ffaPangaeaSettings
    );
  }
  static getName() {
    return "Balanced FFA Pangaea";
  }
  init(hexDims) {
    this.initInternal(hexDims);
  }
  simulateInternal() {
    const settings = this.getGenerator().getSettings();
    settings.landmass[0].playerAreas = this.getSettings().totalPlayers;
    // Keep the player continent centered with modest seed variation.
    settings.landmass[0].xPos = 0.46 + RandomImpl.fRand("FFA Pangaea seed x") * 0.08;
    settings.landmass[0].yPos = 0.43 + RandomImpl.fRand("FFA Pangaea seed y") * 0.14;
  }
  getFilename() {
    return "ffa-pangaea.mapconfig.js";
  }
}

export { VoronoiFfaPangaea };
//# sourceMappingURL=pangaea.js.map
