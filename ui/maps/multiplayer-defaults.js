// New multiplayer games start on these values (the host can change them). The
// Create Game screen resets the configuration as it attaches, so they are set
// right after; a parameter the setup lacks is skipped. The other multiplayer
// defaults (Crises, Pace, victory thresholds...) are the setup database's; these
// rows hotseat shares with single player (speed, map), Map Size is set per map,
// and the Turn Timer keeps the previous game's choice unless it is written here.
import { createLogger, whenDefined, wrapMethod } from '../shared/mpt-util.js';

const log = createLogger('maps defaults');
const SCREEN_TAG = "screen-mp-create-game";
const RETRY_MS = 50;
const MAX_ATTEMPTS = 20;
const REQUIRED_PARAMETERS = ["GameSpeeds", "Map", "MapSize"];
const COMPETITIVE = "MPT_TURNTIMER_COMPETITIVE";
const MULTIPLAYER_DEFAULTS = [
  ["TurnTimerType", COMPETITIVE],
  ["GameSpeeds", "GAMESPEED_ONLINE"],
  ["Map", "{multiplayer-toolkit}maps/pangaea-ultima.js"],
  ["MapSize", "MAPSIZE_STANDARD"]
];
const COMPETITIVE_BACKSTOP = 3600;

/**
 * Competitive's engine backstop (Turn Time, config/timer.sql) comes from a
 * configuration update; if the default did not trigger it, writing the timer again does.
 */
function ensureCompetitiveBackstop() {
  if (GameSetup.findGameParameter("TurnTimerType")?.value?.value !== COMPETITIVE) return;
  if (Number(Configuration.getGame()?.getValue("TurnTimerTime")) === COMPETITIVE_BACKSTOP) return;
  GameSetup.setGameParameterValue("TurnTimerType", "TURNTIMER_STANDARD");
  GameSetup.setGameParameterValue("TurnTimerType", COMPETITIVE);
  log("rewrote the Competitive timer for its backstop");
}

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
    ensureCompetitiveBackstop();
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
