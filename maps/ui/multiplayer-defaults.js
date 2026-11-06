const MPT_MAPS_MULTIPLAYER_DEFAULTS = [
  ["GameSpeeds", "GAMESPEED_ONLINE"],
  ["AgeLength", "AGE_LENGTH_ABBREVIATED"],
  ["AgeCountdownTimer", "AGE_COUNTDOWN_LENGTH_NONE"],
  ["Map", "{multiplayer-toolkit}maps/maps/pangaea-ultima.js"],
  ["MapSize", "MAPSIZE_STANDARD"],
  ["MPTResourceSystem", "MPT_MAPS_RESOURCE_SYSTEM_ON"]
];

function mptApplyMultiplayerDefaults(screen, attempt = 0) {
  if (!screen.isConnected || screen.dataset.mptDefaultsApplied === "1") return;
  if (typeof GameSetup === "undefined" ||
      typeof GameSetup.findGameParameter !== "function" ||
      typeof GameSetup.setGameParameterValue !== "function") {
    if (attempt < 20) setTimeout(() => mptApplyMultiplayerDefaults(screen, attempt + 1), 50);
    return;
  }

  // MPT: Custom Resource System is optional - removed when Advanced Settings
  // Pro supplies resources - so only the base parameters must be present.
  const optional = new Set(["MPTResourceSystem"]);
  const parametersReady = MPT_MAPS_MULTIPLAYER_DEFAULTS.every(([parameterID]) =>
    optional.has(parameterID) || GameSetup.findGameParameter(parameterID) != null
  );
  if (!parametersReady) {
    if (attempt < 20) setTimeout(() => mptApplyMultiplayerDefaults(screen, attempt + 1), 50);
    return;
  }

  try {
    for (const [parameterID, value] of MPT_MAPS_MULTIPLAYER_DEFAULTS) {
      if (GameSetup.findGameParameter(parameterID) == null) continue;
      GameSetup.setGameParameterValue(parameterID, value);
    }
    screen.dataset.mptDefaultsApplied = "1";
    console.log("MPT MAPS MULTIPLAYER DEFAULTS: applied Online / Abbreviated / No Countdown / Pangaea Ultima / Standard / Custom Resources On.");
  } catch (error) {
    console.error(`MPT MAPS MULTIPLAYER DEFAULTS: failed to apply defaults: ${error?.stack ?? error}`);
  }
}

function mptFindMultiplayerCreateScreen() {
  const screen = document.querySelector("screen-mp-create-game");
  if (screen == null || screen.dataset.mptDefaultsScheduled === "1") return;
  screen.dataset.mptDefaultsScheduled = "1";
  // The base screen resets its configuration during attachment. Run immediately
  // afterward so these become the initial values shown to the host.
  setTimeout(() => mptApplyMultiplayerDefaults(screen), 0);
}

function mptInitializeMultiplayerDefaults() {
  const observer = new MutationObserver(mptFindMultiplayerCreateScreen);
  observer.observe(document.documentElement, { childList: true, subtree: true });
  mptFindMultiplayerCreateScreen();
  console.log("MPT MAPS MULTIPLAYER DEFAULTS: initializer loaded.");
}

engine.whenReady.then(mptInitializeMultiplayerDefaults);
