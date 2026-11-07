# Better Balanced Multiplayer

Multiplayer quality-of-life features for **Sid Meier's Civilization VII**,
built on the game's own UI components. Current version: **0.6.2**.
By Zatygold and Gohei427.

- **Competitive turn timer** — a Turn Timer option that scales with cities,
  units, human players and the turn number, with urgency tiers and sounds.
- **Synchronized pause** — anyone can pause; everyone readies up (or the host
  resumes) and a shared countdown restarts the game. Disconnects, host
  changes and rejoins pause automatically.
- **Game Balance** — competitive balance changes for civilizations,
  leaders, units, governments, wonders, resources, pantheons, mementos and
  victories (lobby option, On by default).
- **Maps** — the Pangaea Ultima map, East vs West player placement, strict
  start biases, a Resource List (the game's resources or every resource in
  every Age) with Resource Amount and Clusters, and climate and terrain settings.
- **Pacing** — Pace Set presets, Age Length, research, building, growth,
  road, trade and raze pace per Age, and Culture, Economic and Military
  victory thresholds with a Victory Threshold Set; no Epic or Marathon speed
  or Long Age Length in multiplayer.
- **Gameplay settings** — settlement limit and distance, independent powers,
  trade range, crises and Triumph Sets per Age.
- **Match Type** — the kind of match (Free for All, 1v1, 2v2, 3v3, 4v4): player
  placement, teams, slots and the matching map settings, starting every other
  setting from Standard.
- **Keybinds** — rebindable pause, lens, unit, Commander and settlement keys on
  keys the game leaves free.
- **Lobby** — the host's settings shown to everyone, memento slots under each
  leader, the single-player memento picker, Random buttons for the seeds, ability names in civ / leader tooltips
  and a 5-second start countdown.

**Multiplayer only:** every feature acts in multiplayer games and setups only;
single player keeps the game's own settings, text, keys and data. Works
alongside **Zatygold's Advanced Settings Pro** (single player) and
**Zatygold's Spectator** (the Observer, formerly part of this mod).

## Installation

1. Copy the folder to `…\Sid Meier's Civilization VII\Mods\Multiplayer-Toolkit\`.
2. Enable **Better Balanced Multiplayer** in **Main Menu → Additional Content**.
3. **Every player needs the mod** (it changes game data, and menus and timer
   enforcement run per client). Saves made with it need it to load.

---

## Match Type

Multiplayer only. **Match Type** (Game Settings, in Multiplayer Settings under
Hidden Game; Free for All by default) is the kind of match; it decides Player
Placement (see Maps), and the team matches also set the map settings.

| Match Type | Player Placement | Teams by slot | Start Position | Strict Start Biases | Map Size |
|---|---|---|---|---|---|
| Free for All | whole map | — | (host) | (host) | (host) |
| 1v1 | Duel | 1-2 | Balanced | On | Tiny (built as the 36x22 Duel map) |
| 2v2 | 2v2 | 1-2-1-2 | Balanced | On | Tiny |
| 3v3 | 3v3 | 1-2-1-2-1-2 | Balanced | On | Small |
| 4v4 | 4v4 | 1-2-1-2-1-2-1-2 | Balanced | On | Standard |

The lobby opens exactly the match's slots and closes the rest. Even slots are
team 1 and start West, odd slots team 2 and start East (in 2v2 the first two
slots are the backline, the next two the frontline). With Zatygold's
Spectator a last slot is kept for the Spectator, with no team; the player who
takes it becomes the Observer. The values live in `config/match-types.sql`.

**Choosing a Match Type** (any of them, Free for All included) starts the match
from Standard: every other setting on the Game Settings, Pace, Map and
Advanced tabs returns to its multiplayer default from the setup database
(Disaster Intensity Light, for example), Game Speed becomes Online and Turn
Timer Competitive. Kept as they are: the values the Match Type sets (table
above), the Multiplayer Settings section (game name, Hidden Game, Multiplayer
Balance, Kick Vote), the Game and Map seeds, the map, the ruleset and starting Age, the
hidden settings the mod manages, and every player setting (slots, teams,
leaders, civilizations, mementos). Only the host's own change applies it;
opening, rejoining or loading a setup does not
(`ui/setup/match-type-rules.js`).

---

## Competitive Turn Timer

Set **Turn Timer** to **Competitive** in multiplayer setup (Simultaneous
turns). Each turn's clock, per Age:

```
seconds = Base + PerCity × (most cities any civ has) + PerUnit × (most units any civ has)
        + PerHuman × (living humans, Observers excluded) + PerTurn × (turn number)
```

| Age | Base | PerCity | PerUnit | PerHuman | PerTurn | About (8 humans, turns 2-70) |
|---|---|---|---|---|---|---|
| Antiquity | 30 | 1.00 | 1.00 | 1.00 | 1.00 | 43-123s |
| Exploration | 35 | 2.00 | 1.00 | 2.50 | 1.25 | 76-180s |
| Modern | 40 | 3.00 | 1.00 | 3.00 | 1.50 | 106-236s |

Every player gets the same clock. At zero the turn ends automatically (idle
units skip, pending choices are dismissed). From 30s the display turns orange
with a beep every 5 seconds; from 15s it flashes red with a beep per second.
The first turn of every session (new game, loaded save, each new Age) is
untimed; the clock holds until you found a settlement and stands still while
paused or while an Age is ending. The lobby **Game Rules** popup names the
timer **Competitive**.

| Tune | Where |
|---|---|
| Per-Age values (table above) | `data/timers/<age>/competitive-timer.sql` |
| Schema and defaults | `data/timers/timer-scaling.sql` |
| Tiers, colours, sounds, grace turn, debug | `ui/timer/mp-timer-config.js` |

The engine only computes its built-in timers, so the mod registers a subclass
of the game's action panel (only when Competitive is chosen) that draws the
native text and ring from its own wall clock and ends the turn itself. The
engine times the unknown type by Turn Time, which the mod sets to one hour
for Competitive (`config/timer.sql`), a backstop the mod's
clock always beats. Its numbers live in mod-owned tables; the Dynamic timer is
untouched.

---

## Synchronized Pause

- **Pause:** **Pause Game** in the Esc menu, or **Ctrl+P** (rebindable in
  keyboard mapping). The pause menu opens for everyone.
- **While paused:** **Ready** (or **Resume (All Players)** for the host) and
  **View Map** to look around (Esc returns to the menu); the pause key toggles
  Ready. A "Ready: X / N" tally counts connected players. Game-advancing
  actions (end turn, unit orders, quick load) are blocked; camera, selection
  and panels are not (the production list shows hidden items, disabled).
- **Resume:** when every connected player is ready, or the host resumes for
  all, a 5-second **UNPAUSING…** countdown runs (still paused) and play resumes
  together.
- **Disconnects:** a dropped player pauses the game before the AI takes over
  (disconnect event, connection polling and a turn-start guard). The host gets
  **Drop Disconnected & Resume** to continue without them. Host changes and
  rejoin resyncs also pause, with a notice in the menu.

Settings: `ui/pause/mp-pause-config.js`. The engine exposes only a total
"want pause" count, so host resume uses hidden chat commands between clients.

---

## Keybinds

Multiplayer games only. Rebindable in **Options → keyboard mapping**; the
defaults are keys the game leaves free, and the game's own keys are unchanged:

| Action | Default |
|---|---|
| Toggle Trade / Continent / Appeal / Settler / Discovery Lens | 1 / 2 / 3 / 4 / 5 |
| Found Settlement | Ctrl+B |
| Search (Scout) | Ctrl+J |
| Previous / Next Settlement, Capital | [ / ] / \ |
| Unit Join / Leave Commander | Ctrl+Z / Ctrl+X |
| Commander Pack / Unpack Units | Ctrl+Q / Ctrl+W |
| Pause Game | Ctrl+P |

A lens key switches to that lens, or back to the default lens if it is
already active. Unit keys run the same actions as the unit's buttons (choosing
a plot when one is needed) and are blocked while paused. Settlement keys select
and open the previous, next or capital settlement.
Actions and keys: `config/input.sql`, `ui/keybind/`.

---

## Game Balance

Multiplayer only. Lobby option **Game Balance** (Game Settings, in
Multiplayer Settings directly above Kick Vote): Multiplayer (default) or
Standard, the game's own balance. Every balance file, its text included, loads
only on Multiplayer, so single
player (and every setup screen) keeps the game's own balance and text.

- Balance changes for civilizations, leaders, units, governments, policies,
  traditions, wonders, buildings, resources, city-states, pantheons,
  mementos, Triumphs, diplomacy, happiness, razing and victories, per Age.
- Trade routes start from a distance in every Age, as in the Modern Age (a
  Pace Trade Speed travel setting overrides this).
- A longer victory curve for Culture, Economic and Military victories, scaled
  by the Pace tab's victory thresholds (see Pacing).

The option is in `config/balance.sql`, the data in `data/balance/` and the text in
`text/en_us/balance-*.xml` (see Project structure).

---

## Maps

Multiplayer only: the options below exist only in multiplayer setup, Pangaea
Ultima and the multiplayer copies of the standard maps are listed only there,
and single-player maps are generated untouched.

- **Pangaea Ultima** — one large central Pangaea, in the Map list, built on the
  game's own Voronoi map generation. Its islands, kept clear of the continent,
  are the Distant Lands (the other landmass region): no player starts on them,
  each holds at least 2 resources with Resource List All (Treasure in
  Exploration), and 30% of their mountains become Rough.
- **Player Placement** (set by the Match Type) — whole map, or Duel,
  2v2, 3v3 or 4v4 East vs West layouts for any map. Every start needs Fresh
  Water and 12 tiles of separation; the most constrained player is placed
  first.
- **Strict Start Biases** (Spawn Settings) — leaders and civilizations start on
  their terrain; everyone is warned on the first turn if one could not.
- **Resource List** (Resource Settings) — **All** (default): the mod's
  resource system. Every resource is valid in every Age and kept across Age
  transitions (Oil and Rubber from Modern), with custom yields, classes,
  tooltips and per-Age effects. Military and construction resources (Horses,
  Iron, Niter, Hardwood, Limestone, Marble) are general, with even counts per
  continent. Each player's region (the land on their continent closest to their
  start) is dealt one resource from each matched pool, Wealth (Gold, Silver,
  Rubies, Spices), Harvest (Sugar, Tea, Citrus, Rice) and Comfort (Wine,
  Quinine, Cocoa, Furs), different from its neighbours', with 1 copy per 100
  tiles of the region (up to 3); islands without a start get only general
  resources. **Standard**: the game's own resource list, rules, yields and
  effects (none of the mod's resource data loads); the game places its
  resources, then Resource Amount and Clusters scale them: one of each resource
  per continent (and in the water) stays, the rest return in random order on
  their own tiles until the amount is met, and clusters grow only where the
  game allows that resource. Island resources stay as the map placed them.
  For either list:
  - **Resource Amount** — Scarce, Sparse, Standard (default) or Abundant: 35%,
    50%, 70% or 100% of the game's resource density. With Resource List
    Standard, every continent keeps at least one of each resource the game
    placed there, so Scarce and Sparse can place more on small continents.
  - **Resource Clusters** — Off (default), Small or Large: deposits grow into
    patches of the same resource (2 or up to 3 tiles); the amount stays the same.

  Both run in the multiplayer post-process (`maps/scripts/global-team-starts.js`,
  `maps/global-resource-system.js`), so they apply to every multiplayer
  map: Pangaea Ultima and the multiplayer copies of the standard maps. The
  game's Earth map keeps the game's resources: Resource Settings hide there and
  Resource List becomes Standard.
- **Duel Map** — Duel placement on the Tiny size builds a 36x22 Duel map
  (Tiny is 60x38) that shows as Duel. Multiplayer rejects new map sizes, so
  Duel is Tiny on a smaller grid; other sizes keep their grid.
- **Match slots** — the lobby opens exactly the players of a team match, on
  their teams (see Match Type), plus the Spectator's slot. Tiny and
  Small also get the Spectator's slot in a Free for All: a 2v2 + Spectator
  plays on Tiny and a 3v3 + Spectator on Small. The game only allows that many
  players on the next size up, so the host launches that size and it is built
  with the chosen size's land and name.
- **Disasters** — the game's own Disaster Intensity (Disaster Frequency), on
  Game Settings in Disaster and Crisis Settings (with Crises and Crisis
  Timing) before the Crises list, as in single player.
- **Natural Wonders** — how many a map places (Off, Half, Standard, More,
  Double), one On/Off toggle per Natural Wonder, and spawn fixes for Gullfoss,
  Iguazú Falls and Valley of Flowers.
- **Climate and terrain** (from Advanced Settings Pro, same options, defaults
  and order) — in Map Settings: **Map Age** (Old, Standard, New: less or more
  rough ground), **Map Temperature** (Frigid, Cold, Standard, Hot, Scorching,
  Random) and **Map Zones**, where the hot and cold regions lie (Standard,
  Hot Poles, Hot Edge, Hot Center, Cold Center, Warm Ring, Patchwork, Random;
  Advanced Settings Pro's Heat Source with Dual Sun and Tilted Axis renamed);
  in Terrain Settings: **Lakes**
  (Less, Standard, More), **Rivers** (Wadis, Arid, Channels, Shallow, Standard,
  Waterways, Streams, Riverlands, Deep: how many rivers and how many are
  navigable), **Mountains** (Less, Standard, More), then Sea Level. Multiplayer
  lists its own copies of the game's standard maps (same names and order) in
  place of the base scripts; they and Pangaea Ultima run the shared passes in
  `maps/generation/` (the climate adapted, with permission, from Scrum
  Lord's Climate Controls). Resources stay the game's, then the Resource List
  and Player Placement run as before. Standard everywhere generates the
  game's own maps.
- **Map tab** — the multiplayer Create Game screen gets a Map tab after the
  Pace tab: Spawn Settings (Start Position, Strict Start Biases),
  one Map Settings section (map, size, Map Age, Map Temperature, Map Zones,
  Natural Wonders and the seed), Resource Settings (Resource List, Resource
  Amount, Resource Clusters), then Terrain and Natural Wonder Selection;
  Disasters and Crises sit on Game Settings.
- **Multiplayer defaults** — new multiplayer games start on Online speed, no
  end-of-Age countdown, Pangaea Ultima and Standard size (the host can change
  them).

The map scripts are in `maps/`, the options in `config/maps.sql`, the data in
`data/maps/` and the lobby scripts in `ui/maps/` (see Project structure).

---

## Pacing

Multiplayer only: the settings below exist only in multiplayer setup, on a
**Pace** tab after Game Settings, carried over from Advanced Settings Pro's
Pace tab with the same values and order.

- **Pace Set** (Game Settings, mirrored at the top of the Pace tab) — Standard
  (default), Balanced or Multiplayer presets fill every
  setting below; changing one switches Pace Set to Custom, and Age Length
  leaving Custom returns the others to Standard.
- **Pace Settings** — each with an All Ages value and a row per Age
  (Antiquity, Exploration, Modern) that follows it, or set on its own with
  Custom:
  - **Age Length** — Swift, Abbreviated, Standard or Custom (90 to 140 points
    per Age, by 10); replaces the game's Age Length in multiplayer.
  - **Age Progression** — Slow, Standard, Balanced or Fast milestone awards.
  - **Technology, Civic, Building and Victory Project Cost** — Low, Standard,
    Medium, High, Double, or the presets' per-Age curves (-25% to +100%).
  - **Settlement Growth** and **Road Speed** — Slow, Standard, Quick, Fast.
  - **Trade Speed** — Merchant movement or Instant routes (Standard is Instant
    in every Age with Game Balance on Multiplayer); **Raze Speed** —
    Standard, Fast or Instant.
- **Victory Thresholds** (Advanced tab, after Victory Settings) — Culture,
  Economic and Military, each Low (x0.5, default), Standard or High (x1.5),
  over the victory curve in use (the game's own, or Game Balance's when
  it is On), rounded half up. Science stays fixed.
- **Victory Threshold Set** (Game Settings, Victory Settings) — Low (default),
  Standard or High sets all three thresholds; changing one switches it to
  Custom, as Triumph Set does with its per-Age rows.
- **No longer games** — multiplayer offers no Epic or Marathon Game Speed and
  no Long Age Length (the game's or the mod's); single player keeps them.
- **Multiplayer defaults** — new multiplayer games start on Standard Age
  Length, so Pace Set shows Standard.

The settings are in `config/pace.sql`, the data in `data/pace/` and the rules in
`ui/pace/`; the Create Game tabs are in `ui/setup/`.

---

## Gameplay Settings

Multiplayer only: the settings below exist only in multiplayer setup, carried
over from Advanced Settings Pro with the same values, data and order. Settings
with a row per Age follow their All Ages value, or are set on their own with
Custom.

| Setting | Options (default first) | Where |
|---|---|---|
| **Settlement Distance** | Standard (3), Less (2), More (4) | Advanced: Settlement Settings |
| **Settlement Limit** | Standard (3/8/16), Less (1/4/10), More (5/12/20), Custom (1-25 per Age) | Advanced: Settlement Settings |
| **Independent Amount / Spacing / Aggression** | Standard, None/Less/More, Less/More, Calm/Raging | Advanced: Independent Power Settings, with Initial Independent Hostility |
| **Trade Range** | Standard, -50% to +100%, Custom (per Age) | Advanced: Trade Settings |
| **World Wonders** | Standard, Carry Over | Advanced: Wonder Settings |
| **Crises** | On, Off (every crisis in the Crises list) | Game Settings: Disaster and Crisis Settings |
| **Crisis Timing** | Standard, Off, Early, Late | Game Settings: Disaster and Crisis Settings |
| **Triumph Set** | the game's sets, plus Custom | Game Settings: Triumph Settings |
| **Triumph Set per Age** | a set for each Age, used with Custom | Advanced: Triumph Settings |

- **Crises** — after Triumph Settings on Game Settings, Disaster and Crisis
  Settings holds Disaster Frequency, Crises and Crisis Timing, then the
  **Crises** section lists every crisis in one list, as single player shows it
  (a multiplayer copy of the game's crisis list; single player keeps the game's
  own, or Advanced Settings Pro's). Crises and the list follow each other (Off excludes every crisis;
  excluding every crisis turns it Off), and Crisis Timing shows Off while
  crises are off.
- **Triumph Sets** — the Triumph Set stays on Game Settings; its per-Age rows
  sit on the Advanced tab and follow it (Custom leaves them to the host).
- **World Wonders** (the mod's own, not from Advanced Settings Pro) — with
  Carry Over, a World Wonder from a previous Age stays buildable for each
  player who unlocked it (researched its technology or civic) in that Age,
  until anyone builds it; the game still allows one of each wonder per world.
  Each Age records the wonders a player unlocks as narrative tags (player
  state the game keeps across Ages); later Ages unlock those wonders again for
  the tag holders and clear their Age, as the game does for buildings that
  stay buildable in every Age. Pure game data: nothing runs in a script. The
  wonders keep their base cost and effects; a few one-time effects that exist
  only in the wonder's own Age (Nalanda's Codex, the Great Lighthouse's
  Merchant, House of Wisdom's Relics, Notre-Dame's celebration, Havana
  Harbor's Treasure Fleets) are not granted, and a carried wonder may count
  as a current-Age wonder for the game's checks.
- Not carried over: Advanced Settings Pro's Unit Settings (Settler and
  Treasure Convoy Speed, Military and Civilian Unit Cost), its Resources
  density (Resource Settings has its own Resource Amount), AI
  Mementos and Age Transition AI Mementos, and its Online 2.0 / Marathon 2.0
  speeds (retired: never offered in setup, kept only for old saves).

The settings are in `config/gameplay.sql`, the data in `data/gameplay/` and the
rules in `ui/gameplay/` (see Project structure).

---

## Lobby

- **Game Rules** — the lobby's rules window lists every mod setting the
  host changed from its multiplayer default (Match Type, Balance, Pace, Map
  Settings, Start Position, Resource Settings, Gameplay...), in the setup
  tabs' order; per-Age rows (and the per-victory thresholds) show while their
  setting is Custom, and switched-off Natural Wonders as a count. The Game Options box shows Match Type, Game Balance and Pace Set.
- **Memento slots** — each leader in the lobby shows its memento slots, with
  each memento's art, name and effect.
- **Memento picker** — Choose Mementos and your own lobby memento slots open
  the single-player memento picker (search and attribute filter); a slot
  opens the picker on that slot. You edit only your own mementos, while mementos are on and you are not
  ready. Hotseat keeps the game's memento editor.
- **Seed buttons** — Random beside the Game and Map seed fields on the Create
  Game screen.

The scripts live in `ui/lobby/` and `ui/setup/`.

---

## Compatibility

- **Zatygold's Advanced Settings Pro** — Advanced Settings Pro is for single
  player, Better Balanced Multiplayer for multiplayer; both can be enabled together.
  Its settings are not offered in multiplayer and the mod's not in single
  player, so each mode has one set of settings with the same values and the
  same order, and neither mod's data or scripts act in the other's mode.
- **Zatygold's Spectator** — adds its slot to the match slots on Tiny and
  Small. The Observer adds no time to the Competitive timer and never pauses
  the game by disconnecting; the Spectator keeps the Observer out of Player
  Placement and off the start-bias warning.

---

## Project structure

```
Multiplayer-Toolkit/
├─ multiplayer-toolkit.modinfo   # manifest: features, lobby-option criteria, per-Age data
├─ config/                       # lobby DB, one file per feature
│  ├─ balance.sql                #   Game Balance option, memento slot
│  ├─ gameplay.sql               #   Gameplay settings with per-Age rows, Custom Triumph Set
│  ├─ input.sql                  #   keybind actions and default keys
│  ├─ maps.sql                   #   map list, Map Options, Map Settings, multiplayer-only filter
│  ├─ match-types.sql            #   Match Types
│  ├─ pace.sql                   #   Pace Set, Pace Settings with per-Age rows, victory thresholds
│  └─ timer.sql                  #   Competitive timer option
├─ data/                         # game data, loaded by setting and Age
│  ├─ balance/                   #   one folder per subject (civilizations, leaders, units, policies,
│  │                             #     religion, resources, victories...): common and per-Age files
│  ├─ gameplay/                  #   one folder per setting: a file per value
│  ├─ maps/                      #   All resource list (per Age), Map Settings, Pangaea Ultima islands
│  ├─ pace/                      #   one folder per setting: a file per value (per Age where it differs)
│  └─ timers/                    #   Competitive timer numbers (default + per Age)
├─ maps/                         # map scripts: Pangaea Ultima, strict start biases, start-bias
│  │                             #   scoring, Resource List
│  ├─ generation/                #   climate and terrain passes (Map Settings) shared by the maps
│  ├─ standard/                  #   multiplayer copies of the game's standard maps
│  └─ scripts/                   #   multiplayer placement pass, Pangaea Ultima Voronoi settings
├─ text/en_us/                   # strings: mod-info.xml, shared.xml, then one file per feature
│                                #   (balance-*.xml, gameplay.xml, maps-*.xml, pace.xml)
└─ ui/
   ├─ shared/                    # logger, method wrapping, deferred patching, multiplayer check,
   │                             #   companion mods, setup poll, defaults and per-Age rows
   ├─ gameplay/                  # Gameplay per-Age and crisis rules
   ├─ keybind/                   # keyboard-mapping entries; lens, unit and settlement keys
   ├─ lobby/                     # tooltips, countdown, Game Rules summary, memento slots and picker
   ├─ maps/                      # multiplayer defaults, match slots, turn-1 start warning
   ├─ pace/                      # Pace Set, Victory Threshold Set and per-Age rules
   ├─ pause/                     # pause manager, overlay, chat commands
   ├─ setup/                     # Create Game tabs (Pace, Map), section order, seed buttons,
   │                             #   Match Type rules
   └─ timer/                     # Competitive timer, Game Rules label
```

Each feature has a `*-config.js` for settings, and modules patch the
base UI at runtime (no base-game files are replaced). Identifiers follow the
The mod's naming: `LOC_MPT_` for text, `mpt-` for keybind actions and element
ids, `MPT_BALANCE_` / `MPTBalance` for Balance, `MPT_MAPS_` / `MPT` for Maps
(lobby options such as `MPTPlayerPlacement`), `MPT_PACE_` / `MPTPace` for
Pacing, `MPT_GAMEPLAY_` / `MPTGameplay` for Gameplay. Diagnostics go to `UI.log`, tagged `[MPT <feature>]`.

---

## Changelog

### 0.6.2

- **Settlement Limit** Custom values capped at 25 per Age.
- **Age Length** trimmed to 90-140 points per Age (Standard and shorter); the
  Balanced choice is gone and the Balanced and Multiplayer Pace Sets use
  Standard Age Length.
- Files reorganized by type: one `config/`, `data/`, `text/` and `ui/` folder,
  with `maps/` for the map scripts only.
- **Fixes:** start positions are searched with a step limit instead of a time
  limit, so every machine generates the same starts; Game Balance no longer
  sets Merchants to 1 Movement, and Pace Trade Speed travel settings now work
  with it; new multiplayer games start on Standard Age Length; the memento
  picker only opens in a new game's lobby.
- **Renamed** to Better Balanced Multiplayer (formerly Multiplayer Toolkit); the
  mod id, folder and `MPT` prefixes are unchanged, so saves keep working.
- **New: Game Balance** (with Gohei427) — competitive balance changes
  behind the new **Game Balance** lobby option (Multiplayer by default, or
  Standard), in
  Multiplayer Settings directly above Kick Vote (the Balance Settings section
  is gone).
- **New: Maps** (with Gohei427) — Pangaea Ultima, Player Placement (Base,
  Duel, 2v2, 3v3, 4v4), Strict Start Biases and the Resource List.
- **Multiplayer only** — every option exists only in multiplayer setup;
  Pangaea Ultima is listed only there; single-player map generation is left
  untouched. Balance text loads only in games with Game Balance on Multiplayer, the keybinds and
  every in-game script act only in multiplayer, and the game's own keys are no
  longer remapped.
- **Compatible with Advanced Settings Pro (single player) and Zatygold's
  Spectator** (see Compatibility); the Advanced Settings Pro workarounds are
  gone.
- **Cleanup:** balance fixes (Bulgaria's Stratagems no longer stacks, Maurya's
  Matha and the Empire style apply their values, tooltip names resolve), per-Age
  building data, no-op and dead code removed; lighter timer, pause and
  start-check code built on the game's own modules.
- **Maps on the game's current scripts:** Pangaea Ultima and Player Placement
  now use the installed game's map generation instead of older copies (start
  biases include island biases again); placement solves several times faster
  with time limits; Reefs are added once, after placement; the Oil/Rubber
  guarantee is left to the game's own Age transition (minimum 2 each).
- **Duel Map** — a 36x22 map for 1v1 (Duel placement on Tiny).
- **New: Pacing** — Advanced Settings Pro's Pace tab for multiplayer (Pace Set
  presets, Age Length and every Pace Setting with per-Age rows) on a new Pace
  tab, in Advanced Settings Pro's order; Victory Threshold Scaling becomes
  separate Culture, Economic and Military victory thresholds (Low x0.5,
  Standard, High x1.5) on the Advanced tab, working with Game Balance Multiplayer
  or Off.
- **New: Gameplay settings** — Advanced Settings Pro's Settlement Limit (per
  Age) and Distance, Independent Amount, Spacing and Aggression, Trade Range (per Age),
  Crises and Crisis Timing (with the crisis list) and
  Triumph Sets per Age, for multiplayer, in Advanced Settings Pro's order.
- **New: World Wonders** — Carry Over keeps the World Wonders you unlocked in
  a previous Age buildable in later Ages until someone builds them
  (multiplayer only; Advanced tab, new Wonder Settings section).
- **New: Lobby** — the Game Rules window and Game Options box show the host's
  mod settings to everyone; memento slots (all three) under each leader;
  Random buttons for the Game and Map seeds.
- **New: Match Type** — Free for All, 1v1, 2v2, 3v3 and 4v4; it replaces the
  Player Placement option and sets teams, slots and the map settings.
- **Match slots** — team matches open exactly their players on their teams
  (unused slots closed), plus a Spectator slot the Spectator claims.
- **New: Keybinds** (multiplayer games) — lens toggles (1–5), Found Settlement
  (Ctrl+B), Search (Ctrl+J), Previous/Next Settlement and Capital ([ ] \),
  Commander join/leave/pack/unpack (Ctrl+Z/X/Q/W); Pause moves to Ctrl+P. All
  rebindable; the game's own keys are unchanged.
- **Pangaea Ultima Distant Lands:** its islands are marked as Distant Lands
  (never a start) with guaranteed resources, so Treasure Fleets work; games
  starting in Exploration also get Treasure on islands with Resource List All. Sunk land no longer leaves volcanoes in the ocean.
- **Empire resources:** matched Wealth, Harvest and Comfort pools dealt per
  player region (1–3 copies by region size); Gold +2 Happiness; Rubies,
  Spices, Tea, Citrus and Rice on the "+1 and +1 in all Settlements" template;
  Wine, Quinine and Cocoa give Capital Happiness and a Celebration yield;
  Marble is general (+5% toward Buildings); the pooled resources stay Empire
  in Modern (Treasure in Exploration).
- **Resources (player feedback):** fewer resources by default (Resource
  Amount, 70% of the game's density) with optional Resource Clusters; even
  counts per continent instead of widely-valid resources such as Coal flooding
  the map; Player Placement no longer puts a start on a Discovery; Crises sit
  on Game Settings in multiplayer.
- **Create Game layout:** one Map Settings section on the Map tab;
  every tab's sections and settings in Advanced Settings Pro's single-player
  order; Sea Level for Pangaea Ultima.
- **Player feedback:** Militaristic's garrisoned-Commander node keeps its
  Science and Culture after an Age transition; Kiem gives Science again (it
  duplicated the Artilleryman's Gloves); Modern Coal works when slotted in a
  Factory and Modern Dyes count without a Factory slot; the per-turn Commander
  XP on Military Buildings (which also triggered XP-based leader and memento
  bonuses) and the one-technology-per-turn limit are removed.
- **Balance:** Daimyo applies to Infantry only, Iron Working's Codex works with
  or without DLC, and Iceland's Reiði Guðanna I is unlocked by Origins (in
  place of Drottkvætt I) and upgrades to Reiði Guðanna.
- **Competitive timer** — no longer ends every turn at once when Turn Time was
  never set (the game's own timer backs it up at one hour); retuned per Age,
  tuned per Age (about 43-123s, 76-180s and 106-236s with 8 humans);
  the lobby Game Rules popup names it instead of showing a debug string.
- **Climate and terrain settings** — Advanced Settings Pro's Map Age, Map
  Temperature, Heat Source (as Map Zones), Rivers and Mountains for
  multiplayer, on multiplayer copies of the standard maps and on Pangaea Ultima, with Sea
  Level on every copy that has it.
- **Unit Settings removed** — Settler and Treasure Convoy Speed and Military
  and Civilian Unit Cost are no longer offered.
- **Crises** — a multiplayer copy of the game's crisis list in its own Crises
  section, one list as in single player; single player keeps the game's (or
  Advanced Settings Pro's) list.
- **Triumph Sets per Age** move to the Advanced tab; the Triumph Set stays on
  Game Settings.
- **Memento picker** — Choose Mementos and the lobby memento slots open the
  single-player memento picker.
- **Victory Threshold Set** — one setting on Game Settings (Victory Settings)
  for the Culture, Economic and Military thresholds, Custom when they differ.
- **Spawn Settings** — Start Position and Strict Start Biases get their own
  section before Map Settings.
- **Match Type** (formerly Game Set) sits in Multiplayer Settings under Hidden
  Game; choosing one returns every other setting to Standard (Multiplayer
  Settings, Game Balance included, stay as they are), on Online speed
  and the Competitive timer.
- **Resource List** replaces the Custom Resource System: Standard (the game's
  resources) or All (the mod's resource system, default). Resource Amount
  and Clusters apply to both, in a new Resource Settings section after Map
  Settings.
- **Map Zones** replaces Heat Source (Dual Sun and Tilted Axis are now Hot
  Poles and Hot Edge).
- **Disasters** — the mod's Disasters setting and its per-Age rows are
  removed; multiplayer uses the game's Disaster Intensity again, on Game
  Settings in the single-player layout (Disaster and Crisis Settings with
  Crises and Crisis Timing, then the Crises list).
- **Game Balance** (formerly Multiplayer Balance): Standard or Multiplayer
  (default).
- **No longer games in multiplayer** — the Epic and Marathon speeds and the Long
  Age Length are removed from multiplayer setup.
- The mod now affects saved games. Gohei427 joins as co-author.

### 0.6.1

- **Observer removed** — the Observer is no longer part of Multiplayer
  Toolkit; it continues as its own mod, Zatygold's Spectator. Multiplayer
  Toolkit no longer replaces any base-game file.
- **Works with Zatygold's Spectator** — its Observer adds no time to the
  Competitive timer (it still counts toward ending turns), never has its clock
  held, counts toward the pause's ready tally and never pauses the game by
  disconnecting.

### 0.6.01

- **Fix:** the Competitive timer kept counting while paused (when a pause
  event was missed); it also stands still from the moment an Age is complete
  until the next Age starts.
- **Performance:** the Competitive timer retries an expired turn once a
  second; the pause manager re-scans players once a turn; lobby tooltips no
  longer rebuild the civilization data on every refresh.

### 0.6.00

- Shared helpers (logging, method wrapping, deferred patching) across every
  feature; pause-menu texts localized; pause/resume chat commands no longer
  play the chat sound or mark chat unread.

### 0.5.9

- **Fix:** Competitive timer ending opening turns; timer-ended turns no longer
  cancel unit orders.

### 0.5.8

- Pause: consensus of connected players or host **Resume (All Players)**;
  **Drop Disconnected & Resume**; cross-client chat commands.

### 0.5.7

- Competitive timer retuned.

### 0.5.5

- Rebindable pause key; timer fixes (capital turn, stalls, strict expiry,
  starts turn 2); retuned timings.

### 0.5.4

- 5-second lobby countdown.

### 0.5.3

- Lobby tooltip ability names; timer as an action-panel subclass with its own
  tables and a synced ring. More than 8 players is not moddable (engine
  limit).

### 0.5.2

- Decimal timer weights; vote resume off by default; disconnect, host-change
  and rejoin pauses.

### 0.5.1

- Competitive turn timer; config / logic split.

---

## License

Copyright (C) 2026 Zatygold and Gohei427. Free software under the **GNU
General Public License v3 or later**, without any warranty. See
[`LICENSE`](LICENSE) or <https://www.gnu.org/licenses/>.
