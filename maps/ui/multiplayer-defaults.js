const EVW_MULTIPLAYER_DEFAULTS = [
  ["GameSpeeds", "GAMESPEED_ONLINE"],
  ["AgeLength", "AGE_LENGTH_ABBREVIATED"],
  ["AgeCountdownTimer", "AGE_COUNTDOWN_LENGTH_NONE"],
  ["Map", "{multiplayer-toolkit}maps/maps/balanced-ffa-pangaea.js"],
  ["MapSize", "MAPSIZE_STANDARD"],
  ["EvWResourceSystem", "EVW_RESOURCE_SYSTEM_ON"]
];

function evwApplyMultiplayerDefaults(screen, attempt = 0) {
  if (!screen.isConnected || screen.dataset.evwDefaultsApplied === "1") return;
  if (typeof GameSetup === "undefined" ||
      typeof GameSetup.findGameParameter !== "function" ||
      typeof GameSetup.setGameParameterValue !== "function") {
    if (attempt < 20) setTimeout(() => evwApplyMultiplayerDefaults(screen, attempt + 1), 50);
    return;
  }

  // MPT: Custom Resource System is optional - removed when Advanced Settings
  // Pro supplies resources - so only the base parameters must be present.
  const optional = new Set(["EvWResourceSystem"]);
  const parametersReady = EVW_MULTIPLAYER_DEFAULTS.every(([parameterID]) =>
    optional.has(parameterID) || GameSetup.findGameParameter(parameterID) != null
  );
  if (!parametersReady) {
    if (attempt < 20) setTimeout(() => evwApplyMultiplayerDefaults(screen, attempt + 1), 50);
    return;
  }

  try {
    for (const [parameterID, value] of EVW_MULTIPLAYER_DEFAULTS) {
      if (GameSetup.findGameParameter(parameterID) == null) continue;
      GameSetup.setGameParameterValue(parameterID, value);
    }
    screen.dataset.evwDefaultsApplied = "1";
    console.log("EVW MULTIPLAYER DEFAULTS: applied Online / Abbreviated / No Countdown / Pangaea Ultima / Standard / Custom Resources On.");
  } catch (error) {
    console.error(`EVW MULTIPLAYER DEFAULTS: failed to apply defaults: ${error?.stack ?? error}`);
  }
}

function evwFindMultiplayerCreateScreen() {
  const screen = document.querySelector("screen-mp-create-game");
  if (screen == null || screen.dataset.evwDefaultsScheduled === "1") return;
  screen.dataset.evwDefaultsScheduled = "1";
  // The base screen resets its configuration during attachment. Run immediately
  // afterward so these become the initial values shown to the host.
  setTimeout(() => evwApplyMultiplayerDefaults(screen), 0);
}

function evwInitializeMultiplayerDefaults() {
  const observer = new MutationObserver(evwFindMultiplayerCreateScreen);
  observer.observe(document.documentElement, { childList: true, subtree: true });
  evwFindMultiplayerCreateScreen();
  console.log("EVW MULTIPLAYER DEFAULTS: initializer loaded.");
}

engine.whenReady.then(evwInitializeMultiplayerDefaults);
