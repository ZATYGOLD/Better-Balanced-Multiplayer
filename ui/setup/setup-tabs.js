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
 * Better Balanced Multiplayer - Create Game tabs and seed buttons (shell scope).
 *
 * The multiplayer Create Game screen gets Pace and Map tabs after Game
 * Settings (Game Settings, Pace, Map, Advanced, Add-Ons), each holding
 * its parameter groups, and every tab shows its sections in the layout's order
 * (ui/setup/setup-layout.js). The tabs use the game's tab bar, as single player's
 * Create Game does, and a Random button sits beside the Game and Map seed
 * fields. The screen is multiplayer only.
 *
 * A decorator runs after the screen's constructor and before onInitialize, which
 * builds the tabs from the index-aligned slotIDs and navControlButtonInfo.
 */
import { Decorator, createLogger } from '../shared/mpt-util.js';
import { resolveString } from '../shared/mpt-setup.js';
import { SETUP_TABS, TABS, baseGroupOf, tabIndexOfGroup } from './setup-layout.js';

const log = createLogger('setup tabs');
const SCREEN_TAG = "screen-mp-create-game";
const FIRST_TAB_INDEX = 1;
const ADDED_TABS = SETUP_TABS.map((tab) => ({ ...tab, id: `mpt-advanced-setup-mp__${tab.key}`, containerClass: `mpt-advanced-setup__mp-${tab.key}-container` }));
// The screen's own tabs' containers.
const BASE_CONTAINER_CLASSES = { game: "advanced-setup__game-options-container", advanced: "advanced-setup__mp-advanced-options-container" };
// A row-height Random button beside each seed field, drawing a new positive seed.
const SEED_PARAM_IDS = ["GameRandomSeed", "MapRandomSeed"];
const SEED_BUTTON_STYLE = { width: "7rem", minWidth: "0", minHeight: "2rem", padding: "0", fontSize: "0.75rem", flex: "0 0 auto" };
const MAX_SEED = 2 ** 31 - 1;
const randomSeed = () => 1 + Math.floor(Math.random() * (MAX_SEED - 1));

/** The same shape as the screen's own setup panels. */
function createPanel(tab) {
  const panel = document.createElement("fxs-vslot");
  panel.classList.add("flex", "flex-col");
  panel.id = tab.id;
  const scrollable = document.createElement("fxs-scrollable");
  scrollable.classList.add("flex-auto");
  scrollable.setAttribute("allow-mouse-panning", "true");
  panel.appendChild(scrollable);
  const container = document.createElement("div");
  container.classList.add(tab.containerClass, "flex-auto", "mx-8");
  scrollable.appendChild(container);
  return panel;
}

/** Runs after(result, ...args) once the component's method has run. */
function afterMethod(component, name, after) {
  const base = component[name].bind(component);
  component[name] = (...args) => {
    const result = base(...args);
    after(result, ...args);
    return result;
  };
}

function seedButton(parameterId) {
  const button = document.createElement("fxs-button");
  button.classList.add("mr-4");
  Object.assign(button.style, SEED_BUTTON_STYLE);
  button.setAttribute("caption", "LOC_ADVANCED_OPTIONS_RANDOM");
  button.addEventListener("action-activate", () => GameSetup.setGameParameterValue(parameterId, randomSeed()));
  return button;
}

/**
 * Puts a container's listed sections in their order, in the places they hold
 * (other sections stay where the screen put them). A section is the header and
 * body of one of the screen's group containers.
 */
function orderSections(groupContainers, container, order) {
  const rank = (section) => order.indexOf(baseGroupOf(section.groupId));
  const children = [...container.children];
  const listed = [...groupContainers]
    .map(([handle, group]) => ({ groupId: resolveString(handle), group }))
    .filter((section) => section.group.headerElement.parentElement === container && rank(section) >= 0)
    .sort((a, b) => children.indexOf(a.group.headerElement) - children.indexOf(b.group.headerElement));
  const sorted = [...listed].sort((a, b) => rank(a) - rank(b));
  if (sorted.every((section, i) => section === listed[i])) return;
  const marks = listed.map(({ group }) => {
    const mark = document.createElement("div");
    container.insertBefore(mark, group.headerElement);
    return mark;
  });
  sorted.forEach(({ group }, i) => {
    container.insertBefore(group.headerElement, marks[i]);
    container.insertBefore(group.bodyElement, marks[i]);
    marks[i].remove();
  });
}

class SetupTabs extends Decorator {
  constructor(component) {
    super();
    this.component = component;
    this.panels = ADDED_TABS.map(createPanel);
    this.insertTabs();
    this.useTabBar();
    this.routeGroups();
    this.orderTabs();
    this.decorateRows();
  }

  /** The tabs after Game Settings; Advanced and Add-Ons keep their panel ids, which the screen reads by index. */
  insertTabs() {
    const component = this.component;
    const [advancedId, addOnsId] = component.slotIDs.slice(FIRST_TAB_INDEX);
    component.slotIDs.splice(FIRST_TAB_INDEX, 0, ...ADDED_TABS.map((tab) => tab.id));
    component.navControlButtonInfo.splice(FIRST_TAB_INDEX, 0, ...ADDED_TABS.map((tab, i) => ({
      category: tab.title,
      isActive: false,
      eventHandler: () => component.goToNewPanel(this.panels[i])
    })));
    this.panels.forEach((panel) => component.setupSlotGroup.appendChild(panel));
    afterMethod(component, "createAdvancedPanel", () => { component.mpAdvancedSetupPanel.id = advancedId; });
    if (addOnsId) afterMethod(component, "createAddOnsPanel", () => { component.addOnsSetupPanel.id = addOnsId; });
  }

  /**
   * The game's tab bar replaces the screen's tab buttons, which stay hidden for the
   * screen's own panel bookkeeping. The bar takes the bumpers (it handles them on the
   * frame first) and follows every panel change.
   */
  useTabBar() {
    const component = this.component;
    const baseTopNav = component.createTopNav.bind(component);
    component.createTopNav = () => {
      const buttons = baseTopNav();
      buttons.classList.add("hidden");
      const bar = document.createElement("fxs-tab-bar");
      bar.classList.add("mx-8", "my-4");
      bar.setAttribute("tab-items", JSON.stringify(component.navControlButtonInfo.map((info) => ({ label: info.category }))));
      bar.setAttribute("selected-tab-index", String(component.currentSlotIndex));
      bar.addEventListener("tab-selected", (event) => {
        const index = event.detail.index;
        if (index !== component.currentSlotIndex) component.navControlButtonInfo[index].eventHandler();
      });
      this.tabBar = bar;
      const nav = document.createElement("div");
      nav.append(bar, buttons);
      return nav;
    };
    afterMethod(component, "goToNewPanel", () => this.tabBar?.setAttribute("selected-tab-index", String(component.currentSlotIndex)));
  }

  /** The container of an added tab, or null. */
  addedContainer(key) {
    const index = ADDED_TABS.findIndex((tab) => tab.key === key);
    return index >= 0 ? this.panels[index].querySelector(`.${ADDED_TABS[index].containerClass}`) : null;
  }

  /** Each added tab takes its groups; every other setting keeps the screen's own tab. */
  routeGroups() {
    const component = this.component;
    const baseContainer = component.getTabContainerForParam.bind(component);
    component.getTabContainerForParam = (param) => {
      const groupId = resolveString(component.resolveParamGroup(param));
      return this.addedContainer(TABS[tabIndexOfGroup(groupId)].key) ?? baseContainer(param);
    };
  }

  /** Once the screen has built its sections, every tab shows them in the layout's order. */
  orderTabs() {
    const component = this.component;
    afterMethod(component, "refreshGameOptions", () => {
      for (const tab of TABS) {
        const baseClass = BASE_CONTAINER_CLASSES[tab.key];
        const container = baseClass ? component.Root.querySelector(`.${baseClass}`) : this.addedContainer(tab.key);
        if (container) orderSections(component.groupContainers, container, tab.sections);
      }
    });
  }

  /** Random buttons beside the seeds. */
  decorateRows() {
    afterMethod(this.component, "createParamEleLabel", (row, setupParam) => {
      const parameterId = resolveString(setupParam.ID);
      if (SEED_PARAM_IDS.includes(parameterId) && !setupParam.readOnly) row.appendChild(seedButton(parameterId));
    });
  }
}

Controls.decorate(SCREEN_TAG, (component) => {
  try { return new SetupTabs(component); } catch (e) { log(`tabs not added: ${e}`); return new Decorator(); }
});
