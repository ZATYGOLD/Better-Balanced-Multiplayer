import { COMPANION_MODS, createLogger, isModEnabled } from '../../ui/mpt-shared/mpt-util.js';

// A Map Settings tab on the multiplayer Create Game screen, after Game Settings,
// holding the map, terrain, disaster and natural wonder groups (and their
// multiplayer "MPAdvanced" groups), as Advanced Settings Pro's Map tab does.
// With Advanced Settings Pro enabled its own tabs are used instead.
//
// A decorator runs after the screen's constructor and before onInitialize, which
// builds the tabs from the index-aligned slotIDs and navControlButtonInfo.
const log = createLogger('maps tab');
const SCREEN_TAG = "screen-mp-create-game";
const TAB_INDEX = 1;
const TAB_TITLE = "LOC_GROUPID_MAPOPTIONS";
const PANEL_ID = "mpt-advanced-setup-mp__map";
const CONTAINER_CLASS = "mpt-advanced-setup__mp-map-container";
const MP_GROUP_PREFIX = "MPAdvanced";
const MAP_GROUPS = new Set(["MapOptions", "TerrainOptions", "DisasterOptions", "NaturalWonderSelectionOptions"]
  .flatMap((group) => [group, MP_GROUP_PREFIX + group]));
// The tab buttons are sized for three tabs (16.7rem); the frame's nine-slice ends scale with the width.
const NAV_BUTTON_MIN_WIDTH = "11rem";
const NAV_BUTTON_BORDER_WIDTH = "0.8889rem 3.5rem 2rem 3.5rem";

/** The same shape as the screen's own setup panels. */
function createPanel() {
  const panel = document.createElement("fxs-vslot");
  panel.classList.add("flex", "flex-col");
  panel.id = PANEL_ID;
  const scrollable = document.createElement("fxs-scrollable");
  scrollable.classList.add("flex-auto");
  scrollable.setAttribute("allow-mouse-panning", "true");
  panel.appendChild(scrollable);
  const container = document.createElement("div");
  container.classList.add(CONTAINER_CLASS, "flex-auto", "mx-8");
  scrollable.appendChild(container);
  return panel;
}

/** Runs `after` once the component's method has run. */
function afterMethod(component, name, after) {
  const base = component[name].bind(component);
  component[name] = (...args) => {
    const result = base(...args);
    after(result);
    return result;
  };
}

/** Controls.decorate calls all four hooks; a decorator overrides only those it uses. */
class Decorator {
  beforeAttach() {}
  afterAttach() {}
  beforeDetach() {}
  afterDetach() {}
}

class MapTab extends Decorator {
  constructor(component) {
    super();
    this.component = component;
    this.panel = createPanel();
    this.insertTab();
    this.fitNavButtons();
    this.routeGroups();
  }

  /** Map Settings after Game Settings; Advanced and Add-Ons keep their panel ids, which the screen reads by index. */
  insertTab() {
    const component = this.component;
    const [advancedId, addOnsId] = component.slotIDs.slice(TAB_INDEX);
    component.slotIDs.splice(TAB_INDEX, 0, PANEL_ID);
    component.navControlButtonInfo.splice(TAB_INDEX, 0, {
      category: TAB_TITLE,
      isActive: false,
      eventHandler: () => component.goToNewPanel(this.panel)
    });
    component.setupSlotGroup.appendChild(this.panel);
    afterMethod(component, "createAdvancedPanel", () => { component.mpAdvancedSetupPanel.id = advancedId; });
    if (addOnsId) afterMethod(component, "createAddOnsPanel", () => { component.addOnsSetupPanel.id = addOnsId; });
  }

  fitNavButtons() {
    const component = this.component;
    afterMethod(component, "createTopNav", () => {
      for (const button of component.navControlTabs ?? []) {
        button.style.minWidth = NAV_BUTTON_MIN_WIDTH;
        button.style.borderImageWidth = NAV_BUTTON_BORDER_WIDTH;
      }
    });
  }

  /** Map groups go to the tab; every other setting keeps the screen's own tab. */
  routeGroups() {
    const component = this.component;
    const baseContainer = component.getTabContainerForParam.bind(component);
    const onMapTab = (param) => MAP_GROUPS.has(GameSetup.resolveString(component.resolveParamGroup(param)) ?? "");
    component.getTabContainerForParam = (param) =>
      (onMapTab(param) ? this.panel.querySelector(`.${CONTAINER_CLASS}`) : baseContainer(param));
  }
}

if (isModEnabled(COMPANION_MODS.advancedSettingsPro)) {
  log("Advanced Settings Pro is enabled: its Map tab is used");
} else {
  Controls.decorate(SCREEN_TAG, (component) => {
    try { return new MapTab(component); } catch (e) { log(`tab not added: ${e}`); return new Decorator(); }
  });
}
