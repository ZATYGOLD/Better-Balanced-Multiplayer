import { createLogger, whenDefined, wrapMethod } from '../../ui/mpt-shared/mpt-util.js';

// New multiplayer games start on these values (the host can change them). The
// Create Game screen resets the configuration as it attaches, so they are set
// right after; a parameter the setup lacks (the Custom Resource System, removed
// with Advanced Settings' Resources) is skipped.
const log = createLogger('maps defaults');
const SCREEN_TAG = "screen-mp-create-game";
const RETRY_MS = 50;
const MAX_ATTEMPTS = 20;
const REQUIRED_PARAMETERS = ["GameSpeeds", "AgeLength", "AgeCountdownTimer", "Map", "MapSize"];
const MULTIPLAYER_DEFAULTS = [
  ["GameSpeeds", "GAMESPEED_ONLINE"],
  ["AgeLength", "AGE_LENGTH_ABBREVIATED"],
  ["AgeCountdownTimer", "AGE_COUNTDOWN_LENGTH_NONE"],
  ["Map", "{multiplayer-toolkit}maps/maps/pangaea-ultima.js"],
  ["MapSize", "MAPSIZE_STANDARD"],
  ["MPTResourceSystem", "MPT_MAPS_RESOURCE_SYSTEM_ON"]
];

function applyMultiplayerDefaults(attempt = 0) {
  const ready = REQUIRED_PARAMETERS.every((parameterID) => GameSetup.findGameParameter(parameterID) != null);
  if (!ready) {
    if (attempt < MAX_ATTEMPTS) setTimeout(() => applyMultiplayerDefaults(attempt + 1), RETRY_MS);
    return;
  }
  try {
    for (const [parameterID, value] of MULTIPLAYER_DEFAULTS) {
      if (GameSetup.findGameParameter(parameterID) != null) GameSetup.setGameParameterValue(parameterID, value);
    }
    log("applied the multiplayer defaults");
  } catch (error) {
    log(`failed to apply the multiplayer defaults: ${error?.stack ?? error}`);
  }
}

whenDefined(SCREEN_TAG, (definition) => {
  wrapMethod(definition.createInstance.prototype, "onAttach", function (base, ...args) {
    const result = base(...args);
    setTimeout(() => applyMultiplayerDefaults(), 0);
    return result;
  });
}, { log });
