/*
 * Better Balanced Multiplayer - multiplayer quality-of-life features for Civilization VII.
 * Copyright (C) 2026  Zatygold
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/**
 * Better Balanced Multiplayer - Lobby memento slots (shell scope).
 *
 * Each lobby row shows its mementos as small generic diamonds inside the leader
 * dropdown. These become memento slots: the slot base and a "+" when empty, the
 * memento's own art when filled, its name and effect on hover. On your own row a
 * slot opens the memento picker on that slot while you can still change them; a
 * slot answers that click itself, so it never opens the dropdown, and other
 * rows' slots pass clicks through as the diamonds did. The lobby's Choose
 * Mementos opens the same picker (ui/lobby/mp-memento-select.js).
 */
import { Audio } from 'fs://game/core/ui/audio-base/audio-support.js';
import { Decorator, createLogger } from '../shared/mpt-util.js';
import { onSetupRevision, resolveString } from '../shared/mpt-setup.js';
import { canEditMementos, openMementoPicker } from './mp-memento-select.js';

const log = createLogger('lobby mementos');
const DROPDOWN_TAG = "leader-dropdown";
const LOBBY_TAG = "screen-mp-lobby";
const SLOT_BASE_IMAGE = "url('blp:memento_slot-base.png')";
const SLOT_PLUS_IMAGE = "url('blp:shell_memento-maj-plus.png')";
// A plain gold frame: the unit panel box draws a bar across a slot this small.
const SLOT_REM = 2.75;
const PLUS_REM = 1.3;
const SLOT_FRAME = { border: "0.0833rem solid #8c7e62", backgroundColor: "rgba(13, 15, 20, 0.6)" };
const CLICK_INPUTS = new Set(["mousebutton-left", "touch-tap"]);
const MEMENTO_PARAM_IDS = ["PlayerMementoMajorSlot", "PlayerMementoMinorSlot1"];
const MEMENTO_NONE = "NONE";

/** A slot's value as tooltip text: its name in bold, then what it does. */
function mementoTooltip(value) {
  if (!value || value.value === MEMENTO_NONE) return Locale.compose("LOC_MEMENTO_NONE_NAME");
  const name = Locale.compose(resolveString(value.name));
  const functional = GameSetup.findString("FunctionalDescription");
  const effect = value.additionalProperties?.find((property) => property.name === functional)?.value;
  return effect ? `[B]${name}[/B][N]${Locale.compose(effect)}` : name;
}

function createSlot() {
  const slot = document.createElement("div");
  slot.className = "relative flex items-center justify-center pointer-events-auto group mr-2";
  Object.assign(slot.style, SLOT_FRAME, { width: `${SLOT_REM}rem`, height: `${SLOT_REM}rem` });
  const art = document.createElement("div");
  art.className = "absolute inset-0 bg-center bg-no-repeat bg-contain";
  const highlight = document.createElement("div");
  highlight.className = "img-rollover-highlight absolute inset-0 opacity-0 group-hover\\:opacity-100 pointer-events-none";
  slot.append(art, highlight);
  return slot;
}

/** Draws a slot's memento; a slot already showing it is left as is (every setup change repaints every row). */
function paintSlot(slot, value) {
  const memento = value?.value ?? MEMENTO_NONE;
  if (slot.mptMemento === memento) return;
  slot.mptMemento = memento;
  const art = slot.firstChild;
  const icon = memento === MEMENTO_NONE ? "" : resolveString(value.icon);
  if (icon) {
    art.style.backgroundImage = `url('blp:${icon}')`;
    art.style.backgroundSize = "";
    art.style.opacity = "1";
  } else {
    art.style.backgroundImage = `${SLOT_PLUS_IMAGE}, ${SLOT_BASE_IMAGE}`;
    art.style.backgroundSize = `${PLUS_REM}rem ${PLUS_REM}rem, contain`;
    art.style.opacity = "0.6";
  }
  slot.setAttribute("data-tooltip-content", mementoTooltip(value));
}

// Every row's slots refresh together when the setup changes, so a slot's click
// follows its player's readiness.
const liveSlots = new Set();

class LobbyMementoSlots extends Decorator {
  constructor(component) {
    super();
    this.component = component;
    this.slots = [];
    const onAttributeChanged = component.onAttributeChanged.bind(component);
    component.onAttributeChanged = (name, oldValue, newValue) => {
      onAttributeChanged(name, oldValue, newValue);
      if (name === "mementos" || name === "data-player-id") this.refresh();
    };
  }

  playerId() {
    return parseInt(this.component.Root.getAttribute("data-player-id") ?? "-1");
  }

  isLocal() {
    return this.playerId() === GameContext.localPlayerID;
  }

  /** As the lobby's diamonds: rows it lists mementos for, while mementos are on. */
  isShown() {
    return !!Configuration.getGame()?.isMementosEnabled && (this.component.Root.getAttribute("mementos") ?? "") !== "";
  }

  /** The dropdown builds its diamonds in render(); the slots replace them the first time there is something to show. */
  ensureSlots() {
    const container = this.component.mementoContainer;
    if (!container || this.slots.length > 0) return this.slots.length > 0;
    container.innerHTML = "";
    container.classList.add("items-center");
    MEMENTO_PARAM_IDS.forEach(() => {
      const slot = createSlot();
      slot.addEventListener("engine-input", (event) => this.onSlotInput(event, MEMENTO_PARAM_IDS[this.slots.indexOf(slot)]));
      container.appendChild(slot);
      this.slots.push(slot);
    });
    return true;
  }

  onSlotInput(event, slotParam) {
    if (!this.isLocal() || !canEditMementos() || !CLICK_INPUTS.has(event.detail.name)) return;
    event.stopPropagation();
    event.preventDefault();
    if (event.detail.status === InputActionStatuses.FINISH) {
      Audio.playSound("data-audio-activate", "data-audio-activate-ref");
      openMementoPicker(slotParam);
    }
  }

  refresh() {
    try {
      if (!this.isShown()) {
        if (this.slots.length > 0) this.component.mementoContainer?.classList.add("hidden");
        return;
      }
      if (!this.ensureSlots()) return;
      this.component.mementoContainer.classList.remove("hidden");
      const playerId = this.playerId();
      const editable = this.isLocal() && canEditMementos();
      this.slots.forEach((slot, index) => {
        paintSlot(slot, GameSetup.findPlayerParameter(playerId, MEMENTO_PARAM_IDS[index])?.value);
        slot.classList.toggle("cursor-pointer", editable);
      });
    } catch (error) {
      log(`slots not drawn: ${error?.stack ?? error}`);
    }
  }

  afterAttach() {
    liveSlots.add(this);
    this.refresh();
  }

  beforeDetach() {
    liveSlots.delete(this);
  }
}

/** The lobby's Choose Mementos (its button and hotkey) opens the picker. */
class ChooseMementos extends Decorator {
  constructor(component) {
    super();
    component.openMementos = () => openMementoPicker();
  }
}

onSetupRevision("lobby mementos", () => liveSlots.forEach((slots) => slots.refresh()), () => liveSlots.size > 0);
Controls.decorate(DROPDOWN_TAG, (component) => new LobbyMementoSlots(component));
Controls.decorate(LOBBY_TAG, (component) => new ChooseMementos(component));
