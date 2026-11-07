/*
 * Multiplayer Toolkit - multiplayer quality-of-life features for Civilization VII.
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
 * Multiplayer Toolkit - Lobby memento picker model (shell scope).
 *
 * The game's memento picker model (core/ui-next/screens/create-game/
 * memento-select-model.js) for the local player in the lobby: a memento goes
 * only into a slot whose values offer it. Every equip writes the player's
 * own slot parameters, as the lobby's Choose Mementos does. Re-sync this copy
 * after a patch that changes the base model.
 */
import { createSignal } from 'fs://game/core/vendor/solid-js/dist/solid.js';
import { createMutable, modifyMutable, reconcile } from 'fs://game/core/vendor/solid-js/store/dist/store.js';
import { FullTextSearch } from 'fs://game/core/ui-next/utilities/search-utils.js';

const MEMENTO_NONE = "NONE";
const MAJOR_SLOT_PREFIX = "PlayerMementoMajorSlot";
const YIELD_ICON_PATTERN = /\[icon:(YIELD_(?:FOOD|PRODUCTION|GOLD|SCIENCE|CULTURE|HAPPINESS|DIPLOMACY))\]/g;
const funcDescName = GameSetup.findString("FunctionalDescription");

const isOffered = (param) => !!param && !param.hidden && param.invalidReason == GameSetupParameterInvalidReason.Valid;

function resolveMemento(value, mementos) {
  const funcDescProp = value.additionalProperties?.find((v) => v.name === funcDescName);
  const metadata = mementos.find((m) => m.mementoTypeId == value.value);
  return {
    value: value.value.toString(),
    name: GameSetup.resolveString(value.name),
    description: GameSetup.resolveString(value.description),
    functionalDescription: funcDescProp?.value,
    icon: GameSetup.resolveString(value.icon),
    isFavorite: metadata?.isFavorite ?? false,
    isNew: metadata?.isNewAndUnseenByPlayer ?? false,
    isLocked: metadata?.displayType == DisplayType.DISPLAY_LOCKED,
    unlockTitle: metadata?.unlockTitle ?? "",
    unlockReason: metadata?.unlockReason ?? ""
  };
}

/** The player's memento slots in order. */
function slotInfo(playerId, mementos) {
  const slotMetadata = Online.Metaprogression.getMementoSlotData();
  const params = GameSetup.getMementoFilteredPlayerParameters(playerId).filter(isOffered);
  const slots = [];
  for (const param of params) {
    const id = GameSetup.resolveString(param.ID) ?? "";
    const metadata = slotMetadata.find((m) => m.mementoTypeId == id);
    if (!metadata) {
      console.log(`Unable to find memento slot metadata for ${id}`);
      continue;
    }
    const resolved = GameSetup.findPlayerParameter(playerId, id) ?? param;
    const isLocked = metadata.displayType == DisplayType.DISPLAY_LOCKED;
    slots.push({
      gameParameter: id,
      slotType: id.startsWith(MAJOR_SLOT_PREFIX) ? 0 : 1,
      isLocked,
      unlockReason: metadata.unlockTitle,
      currentMemento: resolveMemento(resolved.value, mementos),
      availableMementos: isLocked ? [] : resolved.domain.possibleValues.map((v) => resolveMemento(v, mementos)),
      hotkey: slots.length == 0 ? "nav-previous" : "nav-next"
    });
  }
  return slots;
}

/** A model for the local player's slots, opened on a slot parameter's slot (else the first). */
function createLobbyMementoModel(slotParam = null) {
  const playerId = GameContext.localPlayerID;
  const mementos = Online.Metaprogression.getMementosData();
  const slots = createMutable(slotInfo(playerId, mementos));
  const [selectedSlot, setSelectedSlot] = createSignal(Math.max(0, slots.findIndex((slot) => slot.gameParameter == slotParam)));
  const setSlot = (gameParameter, value) => GameSetup.setPlayerParameterValue(playerId, gameParameter, value);
  const refresh = () => modifyMutable(slots, reconcile(slotInfo(playerId, mementos)));

  function clearNew(memento) {
    if (memento.isNewAndUnseenByPlayer) Online.Metaprogression.setSeenMemento(memento.mementoTypeId);
  }
  function clearAllNew() {
    for (const memento of mementos) clearNew(memento);
  }

  const equipMemento = (memento) => {
    const slot = slots[selectedSlot()];
    if (!slot) return;
    const id = memento.mementoTypeId;
    if (id == slot.currentMemento.value) {
      setSlot(slot.gameParameter, MEMENTO_NONE);
    } else {
      if (!slot.availableMementos.some((offered) => offered.value == id)) return;
      for (const other of slots) {
        if (other.currentMemento.value == id) setSlot(other.gameParameter, MEMENTO_NONE);
      }
      setSlot(slot.gameParameter, id);
    }
    clearNew(memento);
    memento.isNewAndUnseenByPlayer = false;
    refresh();
    const nextEmptySlot = slots.findIndex((s, i) => i != selectedSlot() && !s.isLocked && s.currentMemento.value == MEMENTO_NONE);
    if (nextEmptySlot >= 0) setSelectedSlot(nextEmptySlot);
  };

  const search = new FullTextSearch("MementoSelectFilter");
  search.addSearchData(mementos.map((m) => {
    const functionalTextDesc = Locale.plainText(Locale.compose(Locale.compose(m.functionalTextDesc).replaceAll(YIELD_ICON_PATTERN, "{LOC_$1_NAME}")));
    return { key: m.mementoTypeId, title: Locale.plainText(m.mementoName), fullText: Locale.toLower(Locale.plainText(functionalTextDesc)) };
  }));
  const fulltextSearch = (text) => search.find(text);

  return { slots, mementos, selectedSlot, setSelectedSlot, equipMemento, clearAllNew, fulltextSearch, refresh };
}

export { createLobbyMementoModel };
