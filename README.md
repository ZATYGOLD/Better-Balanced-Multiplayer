# Multiplayer Toolkit

Multiplayer quality-of-life features for **Sid Meier's Civilization VII**,
built on the game's own UI components. Current version: **0.6.2**.
By Zatygold and Gohei427.

- **Competitive turn timer** — a Turn Timer option that scales with cities,
  units, human players and the turn number, with urgency tiers and sounds.
- **Synchronized pause** — anyone can pause; everyone readies up (or the host
  resumes) and a shared countdown restarts the game. Disconnects, host
  changes and rejoins pause automatically.
- **Multiplayer Balance** — competitive balance changes for civilizations,
  leaders, units, governments, wonders, resources, pantheons, mementos and
  victories (lobby option, On by default).
- **Maps** — the Pangaea Ultima map, East vs West player placement, strict
  start biases and a custom resource system.
- **Multiplayer Rule Set** — the kind of match (Free for All, 1v1, 2v2, 3v3,
  4v4): player placement, teams, slots and the matching map settings.
- **Keybinds** — rebindable pause, lens, unit, Commander and settlement keys,
  Civilization VI style.
- **Lobby fixes** — ability names in civ / leader tooltips; a 5-second start
  countdown.

Works alongside **Zatygold's Spectator** (the Observer, formerly part of
this mod).

## Installation

1. Copy the folder to `…\Sid Meier's Civilization VII\Mods\Multiplayer-Toolkit\`.
2. Enable **Multiplayer Toolkit** in **Main Menu → Additional Content**.
3. **Every player needs the mod** (it changes game data, and menus and timer
   enforcement run per client). Saves made with it need it to load.

---

## Multiplayer Rule Set

Multiplayer only. **Multiplayer Rule Set** (Game Settings, Free for All by
default) is the kind of match; it decides Player Placement (see Maps), and the
team matches also set the map settings.

| Rule Set | Player Placement | Teams by slot | Start Position | Strict Start Biases | Map Size |
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
takes it becomes the Observer. The values live in `config/rule-sets.sql`.

---

## Competitive Turn Timer

Set **Turn Timer** to **Competitive** in multiplayer setup (Simultaneous
turns). Each turn's clock, per Age:

```
seconds = Base + PerCity × (most cities any civ has) + PerUnit × (most units any civ has)
        + PerHuman × (living humans, Observers excluded) + PerTurn × (turn number)
```

| Age | Base | PerCity | PerUnit | PerHuman | PerTurn |
|---|---|---|---|---|---|
| Antiquity | 10 | 1.00 | 1.15 | 1.15 | 1.20 |
| Exploration | 20 | 1.15 | 1.20 | 1.20 | 1.30 |
| Modern | 30 | 1.25 | 1.25 | 1.30 | 1.40 |

Every player gets the same clock. At zero the turn ends automatically (idle
units skip, pending choices are dismissed). From 30s the display turns orange
with a beep every 5 seconds; from 15s it flashes red with a beep per second.
The first turn of every session (new game, loaded save, each new Age) is
untimed; the clock holds until you found a settlement and stands still while
paused or while an Age is ending. The lobby **Game Rules** popup names the
timer **Competitive**.

| Tune | Where |
|---|---|
| Per-Age values (table above) | `data/timers/<age>/CompetitiveTimer.sql` |
| Schema and defaults | `data/timers/TimerScaling.sql` |
| Tiers, colours, sounds, grace turn, debug | `ui/mp-timer/mp-timer-config.js` |

The engine only computes its built-in timers, so the mod registers a subclass
of the game's action panel (only when Competitive is chosen) that draws the
native text and ring from its own wall clock and ends the turn itself. The
engine times the unknown type by Turn Time, which the mod sets to one hour
for Competitive (`config/SetupParameters.sql`), a backstop the Toolkit's
clock always beats. Its numbers live in mod-owned tables; the Dynamic timer is
untouched.

---

## Synchronized Pause

- **Pause:** **Pause Game** in the Esc menu, or the **P** key (rebindable in
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

Settings: `ui/mp-pause/mp-pause-config.js`. The engine exposes only a total
"want pause" count, so host resume uses hidden chat commands between clients.

---

## Keybinds

Rebindable in **Options → keyboard mapping**, with Civilization VI's keys where
it had the same action:

| Action | Default |
|---|---|
| Toggle Trade / Continent / Appeal / Settler / Discovery Lens | 1 / 2 / 3 / 4 / 5 |
| Found Settlement | B |
| Search (Scout) | J |
| Previous / Next Settlement, Capital | [ / ] / \ |
| Unit Join / Leave Commander | Ctrl+Z / Ctrl+X |
| Commander Pack / Unpack Units | Ctrl+Q / Ctrl+W |
| Pause Game (multiplayer) | P |
| Government (game action) | F7 (was L) |
| Advisors (game action) | F8 (was B) |
| Trade Routes / Religion (game actions) | F4 (was U) / L (was J) |
| Attributes (game action) | F10 (was P) |

A lens key switches to that lens, or back to the default lens if it is
already active. Unit keys run the same actions as the unit's buttons (choosing
a plot when one is needed) and are blocked while paused. Settlement keys select
and open the previous, next or capital settlement.
Actions and keys: `config/mpt-input.sql`, `ui/mp-keybind/`.

---

## Multiplayer Balance

Multiplayer only. Lobby option **Multiplayer Balance** (its own **Balance
Settings** group, On by default). Off gives the game's own balance; every
balance file loads only when it is On, so single-player games always use the
game's own balance.

- Balance changes for civilizations, leaders, units, governments, policies,
  traditions, wonders, buildings, resources, city-states, pantheons,
  mementos, Triumphs, diplomacy, happiness, razing and victories, per Age.
- **Victory Threshold Scaling** (Advanced Victory Options): Standard, Low or
  Very Low (default) for Culture, Economic and Military victories.

Always available in multiplayer setup, whatever the option:

- A second minor memento slot.

Everything lives in `balance/` (see Project structure).

---

## Maps

Multiplayer only: the options below exist only in multiplayer setup, Pangaea
Ultima is listed only there, and single-player maps are generated untouched.

- **Pangaea Ultima** — one large central Pangaea, in the Map list, built on the
  game's own Voronoi map generation. Its islands, kept clear of the continent,
  are the Distant Lands (the other landmass region): no player starts on them,
  each holds at least 2 resources, which turn to Treasure in Exploration, and
  30% of their mountains become Rough.
- **Player Placement** (set by the Multiplayer Rule Set) — whole map, or Duel,
  2v2, 3v3 or 4v4 East vs West layouts for any map. Every start needs Fresh
  Water and 12 tiles of separation; the most constrained player is placed
  first.
- **Strict Start Biases** (Map Options) — leaders and civilizations start on
  their terrain; everyone is warned on the first turn if one could not.
- **Custom Resource System** (Map Options, On by default) — player resource
  identities, persistent resources across Ages, custom yields, classes,
  tooltips and per-Age effects. Military and construction resources (Horses,
  Iron, Niter, Hardwood, Limestone, Marble) are general, with even counts per
  continent. Each player's region (the land on their continent closest to their
  start) is dealt one resource from each matched pool, Wealth (Gold, Silver,
  Rubies, Spices), Harvest (Sugar, Tea, Citrus, Rice) and Comfort (Wine,
  Quinine, Cocoa, Furs), different from its neighbours', with 1 copy per 100
  tiles of the region (up to 3); islands without a start get only general
  resources. Off keeps the game's resources. While On:
  - **Resource Amount** — Scarce, Sparse, Standard (default) or Abundant: 35%,
    50%, 70% or 100% of the game's resource density.
  - **Resource Clusters** — Off (default), Small or Large: deposits grow into
    patches of the same resource (2 or up to 3 tiles); the amount stays the same.
- **Duel Map** — Duel placement on the Tiny size builds a 36x22 Duel map
  (Tiny is 60x38) that shows as Duel. Multiplayer rejects new map sizes, so
  Duel is Tiny on a smaller grid; other sizes keep their grid.
- **Match slots** — the lobby opens exactly the players of a team match, on
  their teams (see Multiplayer Rule Set), plus the Spectator's slot. Tiny and
  Small also get the Spectator's slot in a Free for All: a 2v2 + Spectator
  plays on Tiny and a 3v3 + Spectator on Small. The game only allows that many
  players on the next size up, so the host launches that size and it is built
  with the chosen size's land and name.
- **Disasters** — Off, Light, Moderate, Catastrophic or Custom (one setting
  per Age), replacing Disaster Intensity in multiplayer.
- **Natural Wonders** — how many a map places (Off, Half, Standard, More,
  Double), one On/Off toggle per Natural Wonder, and spawn fixes for Gullfoss,
  Iguazú Falls and Valley of Flowers.
- **Lakes** — Less, Standard or More, beside Sea Level in Terrain Settings.
- **Map Settings tab** — the multiplayer Create Game screen gets a Map Settings
  tab after Game Settings with every map setting (map, size, terrain,
  disasters, natural wonders and the options above), as in Advanced Settings
  Pro; Crises stay on the Advanced tab.
- **Multiplayer defaults** — new multiplayer games start on Online speed,
  Abbreviated Ages, no end-of-Age countdown, Pangaea Ultima and Standard size
  (the host can change them).

Everything lives in `maps/` (see Project structure).

---

## Compatibility

- **Zatygold's Advanced Settings Pro** — where both mods have a setting
  (Disasters, Natural Wonders, Lakes, Resources), its own applies in single
  player and the Toolkit's in multiplayer, where its counterparts are removed
  (never applied twice). The Custom Resource System stays in multiplayer. Its
  lobby tooltips add the ability names, so the Toolkit's own are switched off.
  Its settings (pacing, triumph sets, units...) apply on top of the balance
  changes. Its lobby memento slots show the first two slots; the second minor
  slot is set with Choose Mementos. The Map Options appear on its Map tab and
  Balance Settings on its General tab; both mods share the same setup-database
  conventions.
- **Zatygold's Spectator** — adds its slot to the match slots on Tiny and
  Small. The Observer adds no time to the Competitive timer and never pauses
  the game by disconnecting; the Spectator keeps the Observer out of Player
  Placement and off the start-bias warning.

---

## Project structure

```
Multiplayer-Toolkit/
├─ multiplayer-toolkit.modinfo   # manifest: features, lobby-option criteria, per-Age data
├─ config/                       # lobby DB: Competitive option, keybinds, Rule Sets
├─ data/timers/                  # Competitive timer numbers (default + per Age)
├─ text/en_us/                   # mod info and Toolkit strings
├─ ui/
│  ├─ mpt-shared/                # logger, method wrapping, deferred patching, companion mods
│  ├─ mp-keybind/                # keyboard-mapping entries; lens, unit and settlement keys
│  ├─ mp-lobby/                  # tooltips, countdown
│  ├─ mp-pause/                  # pause manager, overlay, chat commands
│  └─ mp-timer/                  # Competitive timer, Game Rules label
├─ balance/                      # Multiplayer Balance (everything balance)
│  ├─ config/                    # Balance option, memento slot, victory thresholds
│  ├─ data/                      # one folder per subject (civilizations, leaders, units, policies,
│  │                             #   religion, resources, victories...): common and per-Age files
│  └─ text/en_us/                # balance strings
└─ maps/                         # Maps (everything map)
   ├─ config/                    # map list, Map Options, multiplayer-only filter, compatibility
   ├─ data/                      # custom resource system (per Age), Pangaea Ultima islands
   ├─ maps/                      # Pangaea Ultima, strict start biases, start-bias scoring, resources
   ├─ scripts/                   # multiplayer placement pass, Pangaea Ultima Voronoi settings
   ├─ text/en_us/                # map strings
   └─ ui/                        # multiplayer defaults, Map Settings tab, match slots, turn-1 start warning
```

Each Toolkit feature has a `*-config.js` for settings, and modules patch the
base UI at runtime (no base-game files are replaced). Identifiers follow the
Toolkit's naming: `LOC_MPT_` for text, `mpt-` for keybind actions and element
ids, `MPT_BALANCE_` / `MPTBalance` for Balance, `MPT_MAPS_` / `MPT` for Maps
(lobby options such as `MPTPlayerPlacement`). Diagnostics go to `UI.log`,
tagged `[MPT <feature>]`.

---

## Changelog

### 0.6.2

- **New: Multiplayer Balance** (with Gohei427) — competitive balance changes
  behind the new **Multiplayer Balance** lobby option (On by default), plus
  Victory Threshold Scaling and a second minor memento slot.
- **New: Maps** (with Gohei427) — Pangaea Ultima, Player Placement (Base,
  Duel, 2v2, 3v3, 4v4), Strict Start Biases and the Custom Resource System.
- **Multiplayer only** — every Balance and Maps option exists only in
  multiplayer setup; Pangaea Ultima is listed only there; single-player map
  generation is left untouched.
- **Compatible with Advanced Settings Pro and Zatygold's Spectator** (see
  Compatibility).
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
- **New: Multiplayer Rule Set** — Free for All, 1v1, 2v2, 3v3 and 4v4; it
  replaces the Player Placement option and sets teams, slots and the map
  settings.
- **Match slots** — team matches open exactly their players on their teams
  (unused slots closed), plus a Spectator slot the Spectator claims.
- **New: Keybinds** — lens toggles (1–5), Found Settlement (B), Search (J),
  Previous/Next Settlement and Capital ([ ] \), Commander join/leave/pack/unpack
  (Ctrl+Z/X/Q/W); game screens on Civilization VI's keys (Government F7, Trade
  Routes F4, Religion L), Advisors F8 and Attributes F10. All rebindable.
- **Pangaea Ultima Distant Lands:** its islands are marked as Distant Lands
  (never a start) with guaranteed resources, so Treasure Fleets work; games
  starting in Exploration also get Treasure on islands with the Custom Resource
  System. Sunk land no longer leaves volcanoes in the ocean.
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
  never set (the game's own timer backs it up at one hour); retuned per Age;
  the lobby Game Rules popup names it instead of showing a debug string.
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
