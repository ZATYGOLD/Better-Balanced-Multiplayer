# Better Balanced Multiplayer

Better Balanced Multiplayer (BBM) is a set of multiplayer features for **Sid Meier's Civilization VII**: a competitive turn timer, synchronized pause, competitive balance, multiplayer maps, pacing and gameplay settings, and lobby improvements. Current version: **0.7.3**, by Zatygold. **Multiplayer only:** single player keeps the game's own settings, text, keys and data (the one exception is Advisors Council moving to Ctrl+B).

## Features

- **Match Type**: Free for All, 1v1, 2v2, 3v3 or 4v4. It sets teams, slots, placement and map size.
- **Competitive Turn Timer**: the turn clock scales with cities, units, players and the turn number.
- **Synchronized Pause**: anyone can pause, and everyone resumes together.
- **Keybinds**: rebindable keys for lenses, units, Commanders and settlements.
- **Game Balance**: competitive balance changes across every Age.
- **Maps**: Pangaea Ultima, East vs West placement, strict start biases, a Resource List, and climate and terrain settings.
- **Pacing**: Pace Sets, per-Age pace settings and victory thresholds.
- **Gameplay settings**: settlements, independent powers, crises, Triumph Sets and World Wonders.
- **Lobby**: a rules summary, memento slots, single-player-style leader, civilization and memento pickers, and Random seed buttons.

## Installation

1. Copy the folder to `…\Sid Meier's Civilization VII\Mods\Multiplayer-Toolkit\`.
2. Enable **Better Balanced Multiplayer** in **Main Menu → Additional Content**.
3. **Every player needs the mod.** Saves made with it need it to load.

## Multiplayer defaults

New multiplayer games, and any Match Type change, start with these settings. The host can change any of them.

| Setting | Default |
|---|---|
| Turn Timer | Competitive |
| Game Speed | Online |
| End-of-Age countdown | 10 turns |
| Age Transition Impact | Continuity |
| Map / Map Size | Pangaea Ultima / Standard |
| Game Balance | Multiplayer |
| Start Bias | Multiplayer |
| Resource List / Amount / Clusters | All / Multiplayer / Disabled |
| Pace Set | Standard (Trade Speed Instant) |
| Victory Threshold | Low |
| Crises | Disabled |

## Match Type

The Match Type setting is under Game Settings → Multiplayer Settings. Free for All is the default.

| Match Type | Player Placement | Teams by slot | Start Position | Start Bias | Map Size |
|---|---|---|---|---|---|
| Free for All | whole map | — | (host) | (host) | Standard |
| 1v1 | Duel | 1-2 | Balanced | Multiplayer | Tiny (36x22 Duel map) |
| 2v2 | 2v2 | 1-2-1-2 | Balanced | Multiplayer | Tiny |
| 3v3 | 3v3 | 1-2-1-2-1-2 | Balanced | Multiplayer | Small |
| 4v4 | 4v4 | 1-2-1-2-1-2-1-2 | Balanced | Multiplayer | Standard |

- The lobby opens only the match's slots. Team 1 starts West and team 2 starts East.
- With Zatygold's Spectator, one extra slot is kept for the Observer while its **Spectator Slot** setting is on (default). Turn it off to play without a Spectator.
- When the host picks a Match Type, every other setting returns to its multiplayer default. These are kept: Multiplayer Settings (including Game Balance), the seeds, the map, the ruleset, the starting Age, and all player choices.

## Competitive Turn Timer

**Competitive** is a Turn Timer option and the multiplayer default. Every player gets the same clock each turn:

```
seconds = Base + PerCity × (most cities any civ has) + PerUnit × (most units any civ has)
        + PerHuman × (living humans) + PerTurn × (turn number)
```

| Age | Base | PerCity | PerUnit | PerHuman | PerTurn | About (8 humans, turns 2-70) |
|---|---|---|---|---|---|---|
| Antiquity | 30 | 1.00 | 1.00 | 1.00 | 1.00 | 43-123s |
| Exploration | 35 | 2.00 | 1.00 | 2.50 | 1.25 | 76-180s |
| Modern | 40 | 3.00 | 1.00 | 3.00 | 1.50 | 106-236s |

- When the clock hits zero, the turn ends.
- At 30 seconds left, the clock turns orange and beeps every 5 seconds. At 15 seconds, it flashes red and beeps every second.
- The first turn of each Age is untimed and shows no number; every other turn shows the clock, including after a loaded save or a reconnect. The clock stops while the game is paused, through the unpause countdown, or while an Age is ending.
- To tune the timer, edit the per-Age values in `data/timers/<age>/competitive-timer.sql`. Tiers, colours and sounds are in `ui/timer/bbm-timer-config.js`.

## Synchronized Pause

- **Pause** with the game's own **Pause** button in the Esc menu or its **Multiplayer Pause** key ([ by default). The pause menu opens for everyone, in place of the game's pause screen.
- **While paused**, players press the game's **Resume** button when they are ready. The game's Pause / Resume button sits under Back to Game (under the status line while paused), and the footer shows the ready count and who paused. **View Map** lets players look around. Actions that advance the game are blocked.
- **Resume** happens when every connected player is ready. A 5-second **UNPAUSING…** countdown runs, then play resumes together.
- **Disconnects, host changes and rejoins** pause the game automatically. The host can **Drop Disconnected & Resume**.

## Keybinds

Keybinds are active in multiplayer games and can be changed in **Options → keyboard mapping**.

| Action | Default |
|---|---|
| Trade / Continent / Appeal / Settler / Discovery Lens (toggle) | 1 / 2 / 3 / 4 / 5 |
| Found Settlement | B |
| Advisors Council (moved from B, also in single player) | Ctrl+B |
| Search (Scout) | Ctrl+J |
| Previous / Next Settlement / Capital | Page Up / Page Down / Home |
| Unit Join / Leave Commander | Ctrl+Z / Ctrl+X |
| Commander Pack / Unpack Units | Ctrl+Q / Ctrl+W |

Pressing a lens key again returns to the default lens. Unit keys are blocked while paused. The Advisor Council popup no longer opens on its own in multiplayer, but its button and key still work.

## Game Balance

The **Game Balance** option is in Multiplayer Settings, above Kick Vote. **Multiplayer** (the default) applies the mod's balance. **Standard** keeps the game's own balance.

- The changes cover civilizations, leaders, units, governments, policies, traditions, wonders, buildings, resources, city-states, pantheons, mementos, Triumphs, diplomacy, happiness, razing and victories, in every Age.
- Culture, Economic and Military victories follow a longer victory curve, scaled by Victory Threshold.
- In every Age, trade routes start from a distance, as in the Modern Age.
- Commanders on a Military Building in their own Settlement gain 2 XP each turn.

## Maps

The Create Game screen gets a **Map** tab after the Pace tab. Every option below exists only in multiplayer.

- **Pangaea Ultima** is one large central continent. Its islands are Distant Lands: no player starts on them, and each one has guaranteed resources (including Treasure in Exploration).
- **Player Placement** is set by the Match Type. It is whole map or an East vs West layout for any map. Every start gets fresh water and 12 tiles of separation.
- **Start Bias** (Spawn Settings) has two options:
  - **Multiplayer** (the default) uses strict start biases. Coastal starts also get a few Reefs, and everyone is warned on turn 1 if a bias could not be met.
  - **Standard** uses the game's own weighted biases.
- **Resource List** (Resource Settings) has two options:
  - **All** (the default) makes every resource valid in every Age and keeps it across Age transitions (Oil and Rubber arrive in Modern). It comes with custom yields and effects.
    - Military and construction resources come in even counts on each continent.
    - Each player's region gets one resource from each pool: Wealth (Gold, Silver, Rubies, Spices), Harvest (Sugar, Tea, Citrus, Rice) and Comfort (Wine, Quinine, Cocoa, Furs). Neighbours get different resources.
  - **Standard** uses the game's own resources and rules.
- **Resource Amount**: Scarce, Limited, Multiplayer (the default) or Standard, which is 35%, 50%, 70% or 100% of the game's density. Standard is the game's own density, as in Advanced Settings Pro.
- **Resource Clusters**: Disabled (the default), Small or Large. Deposits grow into patches of 2 to 3 tiles, and the total amount stays the same.
- **Climate and terrain** (from Advanced Settings Pro) has two groups of settings. Choosing Standard for all of them generates the game's own maps.
  - **Map Settings**: Map Age, Map Temperature and **Map Zones**, which sets where the hot and cold regions lie: Standard, Hot Poles, Hot Edge, Hot Center, Cold Center, Warm Ring, Patchwork or Random.
  - **Terrain Settings**: Lakes, Rivers, Mountains and Sea Level.
- **Natural Wonders**: how many are placed, with an Enabled/Disabled toggle for each wonder.
- **Disasters**: the game's own Disaster Intensity, on Game Settings.
- The Earth and Random Earth maps keep the game's resources.

## Pacing

The **Pace** tab comes after Game Settings. Its settings are carried over from Advanced Settings Pro.

- **Pace Set**: Standard (the default), Balanced or Multiplayer. Each preset fills in every pace setting. Changing any single setting switches Pace Set to Custom.
- **Pace settings**: each has an All Ages value, or per-Age values with Custom.
  - **Age Length**: Swift, Abbreviated, Standard or Custom (90–140 points per Age, in steps of 10).
  - **Age Progression**, plus **Technology, Civic, Building and Victory Project Cost**.
  - **Settlement Growth** and **Road Speed**.
  - **Trade Speed** (default Instant: routes start from a distance; Merchants have 1 Movement and 1 Sight) and **Raze Speed**.
- **Victory Threshold** (Game Settings → Victory Settings): Low (x0.5, the default), Standard or High (x1.5). It sets the Culture, Economic and Military thresholds at once. You can also set each of them separately on the Advanced tab, which shows as Custom. Science is unchanged.
- **Removed from multiplayer**: the Epic and Marathon speeds and the Long Age Length. Single player keeps them.

## Gameplay settings

Most of these settings are carried over from Advanced Settings Pro. Settings with per-Age values use them when set to Custom.

| Setting | Options (default first) | Location |
|---|---|---|
| Settlement Distance | Standard (3), Less (2), More (4) | Advanced |
| Settlement Limit | Standard (3/8/16), Less (1/4/10), More (5/12/20), Custom (1–25 per Age) | Advanced |
| Independent Amount / Spacing / Aggression | Standard, or less/more | Advanced |
| World Wonders | Standard, Carry Over | Advanced |
| Crises / Crisis Timing | Disabled, Enabled / Standard, Early, Late | Game Settings |
| Triumph Set | the game's sets, Custom (one per Age, set on the Advanced tab) | Game Settings |

- **Crises**: a single crisis list, as in single player. Setting Crises to Disabled excludes every crisis in the list.
- **World Wonders: Carry Over**: World Wonders of earlier Ages that nobody built stay buildable in later Ages, with no unlock needed. There is still only one of each wonder per world. A few one-time effects tied to the wonder's original Age are not granted.

## Lobby

- **Game Rules** lists every mod setting the host changed from its multiplayer default. The Game Options box shows Match Type, Game Balance and Pace Set.
- **Memento slots** appear under each leader, showing each memento's art, name and effect.
- **Mementos** (formerly Choose Mementos) and your own memento slots open the single-player memento picker, with search and filters.
- **Browse** opens the single-player leader, civilization and details screens in one pass, with the 3D leader and voice. You can use it while you can still change your pick. The lobby dropdowns work as before.
- **Random** buttons sit beside the Game and Map seed fields.
- Ability names appear in civ and leader tooltips, and there is a 5-second start countdown.

## Compatibility

- **Zatygold's Advanced Settings Pro**: it handles single player and BBM handles multiplayer. Both can be enabled at once.
- **Zatygold's Spectator**: it takes the extra Spectator slot. The Observer adds no time to the timer, never pauses the game by disconnecting, and is left out of Player Placement.

## Project structure

```
Better-Balanced-Multiplayer/
├─ zatygolds-multiplayer-balance.modinfo   # manifest
├─ config/                       # lobby setup: one .sql per feature
├─ data/                         # game data: balance/, gameplay/, maps/, pace/, timers/
├─ maps/                         # map scripts (Pangaea Ultima, placement, Resource List)
│  ├─ generation/                #   climate and terrain passes
│  ├─ standard/                  #   multiplayer copies of the standard maps
│  └─ scripts/                   #   multiplayer post-process
├─ text/en_us/                   # strings, one file per feature
└─ ui/                           # advisor, gameplay, keybind, lobby, maps, pace, pause,
                                 #   setup, shared, timer
```

Every script the mod adds is named `bbm-*.js` and indented with tabs, as in Advanced Settings Pro; the copies in `maps/standard/` and `maps/scripts/` keep the base map names. The mod patches the base UI at runtime and replaces no base-game files. Diagnostics go to `UI.log`, tagged `BBM <feature>:`.

## Changelog

### 0.7.3

Compatibility with Civilization VII 1.5.1.

- Previous / Next Settlement / Capital move to Page Up / Page Down / Home: the game now uses [ for its own multiplayer pause.
- The new Donut map gets a multiplayer copy, so Map and Terrain Settings apply to it. It keeps the game's square map sizes.
- Random Earth keeps the game's resources, like Earth: Resource Settings hide there.
- Passing over Earth or Random Earth in the map list no longer switches Resource List to Standard for the next map; it stays as chosen.
- The Competitive timer works again: 1.5.1 loads the game screens later, and the timer stopped waiting before they were ready (the engine's one-hour backstop showed instead).
- Pause uses the game's own Pause / Resume button and Multiplayer Pause key; BBM's Pause Game button, Ready button and Ctrl+P key are removed. The game's pause screen is replaced by the pause menu, so View Map, the ready tally, Drop Disconnected & Resume and the countdown keep working.
- Opening Create Game no longer shows the game's new "Settings Changed" notice for Map Type, and the multiplayer defaults wait until the setup is ready instead of giving up after one second.
- Create Game shows the values BBM sets (multiplayer defaults, Match Type, presets): 1.5.1 stopped redrawing a row whose value changed by script, so the old values stayed on screen even though the game used the new ones.
- Closing the lobby's Mementos picker brings the lobby back: 1.5.1 hides the lobby while Mementos is open.
- The pause menu shows who paused under the ready count, with their leader and civilization icons as on the game's pause screen, and the game's Pause / Resume button sits under Back to Game (under the status line while paused); the host's Resume (All Players) button is removed (the game's Resume readies each player).
- The turn timer waits for the unpause countdown to finish.
- Chat no longer shows the pause commands, and the keyboard options list the mod's keys again (same cause as the timer).
- Custom Map Zones and Map Temperature lay snow on the game's new snow curve (from latitude 53 toward the poles).
- Militaristic's Commander node: each Commander garrisoned on a District gives its Settlement +1 Science and +1 Culture per Promotion, up to 15 (it counted every Commander level in every Settlement).
- With the Policy Yield Previews mod enabled, the Militaristic Commander node shows its Science and Culture from your garrisoned Commanders (that mod showed +0).

### 0.7.2

- Commanders on a Military Building in their own Settlement gain 2 XP at the start of each turn (it was granted only once).
- World Wonders: Carry Over no longer crashes, and earlier-Age wonders that nobody built are buildable by everyone with no unlock needed.
- Cocoa (Resource List All) gives +2 Science instead of +2 Influence while in a Celebration.
- Trade Speed Instant gives Merchants 1 Movement and 1 Sight.
- The Trade Range setting is removed.
- Victory Threshold defaults to Low again.
- With Zatygold's Spectator, the new Spectator Slot setting can turn off the extra lobby slot in Match Types.
- The Competitive timer no longer lets the game end every turn at once: its one-hour Turn Time backstop is now held by the setup instead of written once when Create Game opens.
- The Competitive timer is hidden only on the first turn of each Age, and shows on every other turn, including the first turn after loading a save or reconnecting.

### 0.7.1

Hotfix.

- Commanders on a Military Building in their own Settlement gain 1 XP each turn again (restored).
- The lobby's leader and civilization tooltips and memento slots show the Game Balance text when Game Balance is Multiplayer.
- The Competitive timer no longer switches to the engine's own countdown after a pause.
- The Competitive timer ring no longer flickers, which showed most when hovering the End Turn button.

### 0.7.0

**Renamed:** the mod was formerly Multiplayer Toolkit, and its mod id is now `zatygolds-multiplayer-balance` (was `multiplayer-toolkit`; the manifest is now `zatygolds-multiplayer-balance.modinfo`), so saves and setups from earlier versions don't load. Other renames:

- Game Set → **Match Type**
- Multiplayer Balance → **Game Balance**
- Strict Start Biases → **Start Bias**
- Heat Source → **Map Zones** (Dual Sun and Tilted Axis are now Hot Poles and Hot Edge)
- Custom Resource System → **Resource List**
- Victory Threshold Set → **Victory Threshold**
- Choose Mementos → **Mementos**

**New:**

- **Game Balance** (with Gohei427): competitive balance changes, on by default.
- **Maps** (with Gohei427):
  - Pangaea Ultima with Distant Lands islands.
  - East vs West Player Placement and a 36x22 Duel map.
  - Start Bias, plus Resource List with Amount and Clusters.
  - Climate and terrain settings.
- **Match Type**: Free for All, 1v1, 2v2, 3v3 or 4v4, with automatic teams and slots.
- **Pacing**: the Pace tab, Pace Sets, and per-victory thresholds with one Victory Threshold setting.
- **Gameplay settings**: Settlement Limit and Distance, independent powers, Trade Range, Crises with the crisis list, and Triumph Sets per Age.
- **World Wonders: Carry Over**.
- **Keybinds**: lens toggles, Found Settlement (B), Search, settlement navigation and Commander keys. Pause moves to Ctrl+P, and Advisors Council moves to Ctrl+B.
- **Lobby**:
  - A Game Rules summary and memento slots.
  - Single-player memento picker, plus a leader and civilization picker (Browse).
  - Random seed buttons.
- The Advisor Council popup no longer opens on its own in multiplayer.

**Changed:**

- New multiplayer defaults:
  - Competitive timer and Online speed.
  - 10-turn end-of-Age countdown (was none).
  - Continuity.
  - Crises Disabled.
  - Trade Speed Instant.
- Age Length is limited to 90–140 points per Age. The Balanced option is gone.
- Settlement Limit Custom is capped at 25 per Age.
- Resources: fewer by default (70% density), with even counts per continent and matched Empire resource pools for each player region.
- Resource Amount's options are now Scarce, Limited, Multiplayer (the default) and Standard, so Standard means the game's own density here and in Advanced Settings Pro.
- On/Off options now read Enabled/Disabled, matching Advanced Settings Pro.
- The Competitive timer is retuned for each Age.
- The Create Game tabs and sections follow the single-player layout (Spawn, Map, Resource and Terrain Settings).
- Multiplayer uses the game's own Disaster Intensity again.
- All options exist only in multiplayer, and single-player map generation is untouched.
- The maps are rebuilt on the game's current map scripts.

**Fixed:**

- Every machine now generates the same start positions.
- The Competitive timer no longer ends every turn at once when Turn Time was unset.
- Game Balance no longer sets Merchants to 1 Movement, and Trade Speed now works with it.
- Balance fixes:
  - Bulgaria's Stratagems no longer stacks.
  - Maurya's Matha and the Empire style apply their values.
  - Kiem gives Science again.
  - Militaristic's Commander node keeps its yields after an Age transition.
  - Modern Coal and Dyes work as intended.
  - Daimyo applies to Infantry only.
  - Iron Working's Codex works with or without DLC.
  - Iceland's Reiði Guðanna is unlocked correctly.
- Pangaea Ultima no longer leaves volcanoes in the ocean.
- Starts are no longer placed on a Discovery.
- The memento picker opens only in a new game's lobby.

**Removed:**

- Unit Settings (Settler and Treasure Convoy Speed, unit costs).
- The Epic and Marathon speeds and the Long Age Length in multiplayer.
- The mod's own Disasters setting.
- The one-technology-per-turn limit.

## License

Copyright (C) 2026 Zatygold. Free software under the **GNU
General Public License v3 or later**, without any warranty. See
[`LICENSE`](LICENSE) or <https://www.gnu.org/licenses/>.
