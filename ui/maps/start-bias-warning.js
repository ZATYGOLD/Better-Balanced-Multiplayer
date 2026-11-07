// Turn-1 check of the multiplayer Player Placement pass: Fresh Water, spacing and strict start biases.
import { createLogger, isMultiplayerGame } from '../shared/mpt-util.js';
import { PLACEMENT_SETTING_KEY, START_MINIMUM_DISTANCE } from '../../maps/placement.js';
import { getPlayerStrictStartBias, isStrictStartBiasEnabled, matchesRule, matchesRuleWithLakeFallback } from '../../maps/strict-start-biases.js';

const log = createLogger('maps start check');
const RETRY_MS = 1000;
const MAX_ATTEMPTS = 15;

let warningCreated = false;
let validationAttempts = 0;
let trainAttempts = 0;

/** The placement pass runs only in multiplayer, where the Map Options exist. */
function placementApplied() {
  try { return isMultiplayerGame() && Configuration.getMapValue(PLACEMENT_SETTING_KEY) != null; } catch (_) { return false; }
}

function getValidationStorageKey() {
  try {
    const mapSeed = Configuration.getMap()?.mapSeed ?? "unknown-map";
    const gameSeed = Configuration.getGame()?.gameSeed ?? "unknown-game";
    return `mpt-maps-start-validation-v5-${mapSeed}-${gameSeed}`;
  } catch (_) {
    return null;
  }
}

function validationAlreadyCompleted() {
  const key = getValidationStorageKey();
  if (key == null) return false;
  try { return localStorage.getItem(key) === "1"; } catch (_) { return false; }
}

function markValidationCompleted() {
  const key = getValidationStorageKey();
  if (key == null) return;
  try { localStorage.setItem(key, "1"); } catch (_) { /* storage unavailable: the turn gate still applies */ }
}

/** Generation accepts an adjacent lake when no ocean-coast start exists. */
function ruleMet(rule, x, y) {
  return matchesRule(rule.id, x, y) || matchesRuleWithLakeFallback(rule.id, x, y);
}

function getFinalStartLocation(playerId) {
  try {
    if (typeof StartPositioner !== "undefined") {
      const plotIndex = StartPositioner.getStartPosition(playerId);
      if (plotIndex != null && plotIndex >= 0) return GameplayMap.getLocationFromIndex(plotIndex);
    }
  } catch (error) {
    log(`StartPositioner unavailable; using player objects (${error})`);
  }
  const player = Players.get(playerId);
  const capital = player?.Cities?.getCapital();
  if (capital?.location) return capital.location;
  const units = player?.Units?.getUnits() ?? [];
  return units.length > 0 ? units[0].location : null;
}

function getPlayerLabel(playerId) {
  const player = Players.get(playerId);
  if (player == null) return `Player ${playerId + 1}`;
  const leader = GameInfo.Leaders.lookup(player.leaderType);
  const civilization = GameInfo.Civilizations.lookup(player.civilizationType);
  const leaderName = leader?.Name ? Locale.compose(leader.Name) : `Player ${playerId + 1}`;
  const civilizationName = civilization?.Name ? Locale.compose(civilization.Name) : "Unknown Civilization";
  return `${leaderName} / ${civilizationName}`;
}

function createVisibleBanner(summary) {
  if (document.body == null) return;
  document.querySelector(".mpt-maps-strict-bias-banner")?.remove();
  const banner = document.createElement("div");
  banner.classList.add("mpt-maps-strict-bias-banner");
  Object.assign(banner.style, {
    position: "fixed", right: "5rem", top: "7rem", width: "29rem", zIndex: "10000",
    padding: "1rem 1.25rem", border: "2px solid #d9b56d", borderRadius: "0.35rem",
    background: "linear-gradient(135deg, rgba(39,31,24,0.98), rgba(18,23,30,0.98))",
    color: "#f4e6c2", fontSize: "1rem", lineHeight: "1.35", whiteSpace: "pre-wrap",
    boxShadow: "0 0 1.2rem rgba(0,0,0,0.85)", pointerEvents: "auto",
    transition: "opacity 0.5s ease"
  });
  banner.textContent = `${summary}\n\nSelect this message to close it. Select the notification icon to view these details again.`;
  banner.addEventListener("click", () => banner.remove());
  document.body.appendChild(banner);
  setTimeout(() => { banner.style.opacity = "0"; }, 20000);
  setTimeout(() => banner.remove(), 20600);
}

function addNotificationRailIcon(summary, failureCount) {
  const train = document.querySelector("panel-notification-train");
  const list = train?.querySelector(".notification-train__list");
  if (list == null) {
    if (trainAttempts++ < MAX_ATTEMPTS) setTimeout(() => addNotificationRailIcon(summary, failureCount), RETRY_MS);
    return;
  }
  const typeContainer = document.createElement("div");
  typeContainer.classList.add("notif__container", "notif__animate", "mpt-maps-strict-bias-notification");
  const notificationContainer = document.createElement("fxs-vslot");
  notificationContainer.classList.add("notification-container");
  const button = document.createElement("fxs-activatable");
  button.classList.add("notice", "notif__button");
  button.setAttribute("tabindex", "-1");
  button.setAttribute("data-tooltip-content", `Select to view start-placement failures.\n${summary}`);
  const background = document.createElement("div");
  background.classList.add("notif__button-bk");
  const icon = document.createElement("div");
  icon.classList.add("notif__button-icon");
  const iconUrl = UI.getIconURL("NOTIFICATION_WONDER_FAILED", "NOTIFICATION") ?? UI.getIconURL("DEFAULT_NOTIFICATION");
  icon.style.backgroundImage = `url("${iconUrl}")`;
  button.append(background, icon);
  const number = document.createElement("div");
  number.className = "notif__button-number bg-contain bg-no-repeat bg-center text-sm font-body size-6 top-0 right-2 absolute flex items-center justify-center pointer-events-none";
  number.textContent = `${failureCount}`;
  button.appendChild(number);
  const dismiss = () => typeContainer.remove();
  button.addEventListener("action-activate", () => createVisibleBanner(summary));
  button.addEventListener("contextmenu", (event) => { event.preventDefault(); dismiss(); });
  notificationContainer.appendChild(button);
  typeContainer.appendChild(notificationContainer);
  list.insertBefore(typeContainer, list.firstChild);
  train.querySelector(".notification-train__nav-help-container")?.classList.add("notification-available");
}

function createFailureNotification(failures) {
  const summary = "START PLACEMENT WARNING\nThe safe original-start fallback was used because these requirements were not met:\n" +
    failures.map((failure) => `- ${failure}`).join("\n");
  createVisibleBanner(summary);
  addNotificationRailIcon(summary, failures.length);
  UI.sendAudioEvent("notif-Wonder_Failed");
  log(`displayed ${failures.length} failure(s)`);
}

function retryValidation() {
  if (validationAttempts++ >= MAX_ATTEMPTS) return false;
  setTimeout(runValidationSafely, RETRY_MS);
  return true;
}

function validateStarts() {
  if (warningCreated || !placementApplied()) return;
  if (typeof Game === "undefined" || Game.turn == null) { retryValidation(); return; }
  // Only a newly generated game's opening turn; the seed marker stops replays after a reload.
  if (Game.turn !== 1 || validationAlreadyCompleted()) return;
  const aliveMajorIds = Players.getAliveMajorIds();
  if (aliveMajorIds.length === 0 && retryValidation()) return;
  const strict = isStrictStartBiasEnabled();
  const failures = [];
  const locations = new Map();
  let unresolvedStarts = 0;
  for (const playerId of aliveMajorIds) {
    const location = getFinalStartLocation(playerId);
    if (location == null) { unresolvedStarts++; continue; }
    locations.set(playerId, location);
    if (!GameplayMap.isFreshWater(location.x, location.y)) {
      failures.push(`${getPlayerLabel(playerId)}: starting tile does not have Fresh Water`);
    }
    if (strict) {
      const failedRules = getPlayerStrictStartBias(playerId)?.rules.filter((rule) => !ruleMet(rule, location.x, location.y)) ?? [];
      if (failedRules.length > 0) {
        failures.push(`${getPlayerLabel(playerId)}: ${failedRules.map((rule) => `${rule.kind} requirement: ${rule.label}`).join("; ")}`);
      }
    }
  }
  if (unresolvedStarts > 0 && retryValidation()) return;
  for (let i = 0; i < aliveMajorIds.length; i++) {
    for (let j = i + 1; j < aliveMajorIds.length; j++) {
      const first = locations.get(aliveMajorIds[i]);
      const second = locations.get(aliveMajorIds[j]);
      if (first == null || second == null) continue;
      const distance = GameplayMap.getPlotDistance(first.x, first.y, second.x, second.y);
      if (distance < START_MINIMUM_DISTANCE) {
        failures.push(
          `${getPlayerLabel(aliveMajorIds[i])} and ${getPlayerLabel(aliveMajorIds[j])}: only ${distance} tiles apart; ` +
          `${START_MINIMUM_DISTANCE} required`
        );
      }
    }
  }
  markValidationCompleted();
  if (failures.length === 0) return;
  warningCreated = true;
  createFailureNotification(failures);
}

/** Never present an internal validator problem as a failed start; only confirmed rule failures notify. */
function runValidationSafely() {
  try { validateStarts(); }
  catch (error) { log(`validation error: ${error?.stack ?? error}`); }
}

window.addEventListener("user-interface-loaded-and-ready", () => setTimeout(runValidationSafely, 3000), { once: true });
engine.whenReady.then(() => setTimeout(runValidationSafely, 3000));
