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

## Competitive Turn Timer

Set **Turn Timer** to **Competitive** in multiplayer setup (Simultaneous
turns). Each turn's clock, per Age:

```
seconds = Base + PerCity × (most cities any civ has) + PerUnit × (most units any civ has)
        + PerHuman × (living humans, Observers excluded) + PerTurn × (turn number)
```

Every player gets the same clock. At zero the turn ends automatically. Below
30s the display turns orange with warning beeps; below 15s it turns red with a
beep per second. The clock holds until you found a settlement and stands still
while paused or while an Age is ending.

| Tune | Where |
|---|---|
| Per-Age `Base` / `PerCity` / `PerUnit` (and overrides) | `data/timers/<age>/CompetitiveTimer.sql` |
| Default `PerHuman` / `PerTurn` | `data/timers/TimerScaling.sql` |
| Tiers, colours, sounds, debug | `ui/mp-timer/mp-timer-config.js` |

The engine only enforces its built-in timers, so the mod registers a subclass
of the game's action panel (only when Competitive is chosen) that draws the
native text and ring from the synchronized phase clock and ends the turn
itself. Its numbers live in mod-owned tables; the Dynamic timer is untouched.
Known cosmetic: the lobby **Rules** popup shows a debug string for the timer.

---

## Synchronized Pause

- **Pause:** **Pause Game** in the Esc menu, or the **P** key (rebindable in
  keyboard mapping). The pause menu opens for everyone.
- **While paused:** **Ready** (or **Resume (All Players)** for the host) and
  **View Map** to look around (Esc returns to the menu). A "Ready X / N" tally
  counts connected players. Game-advancing actions (end turn, unit orders,
  quick load) are blocked; camera, selection and panels are not.
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

## Multiplayer Balance

Multiplayer only. Lobby option **Multiplayer Balance** (its own **Balance Settings**
group, On by default). Off gives the game's own balance; every balance file loads only when
it is On, so single-player games always use the game's own balance.

- Balance changes for civilizations, leaders, units, governments, policies,
  traditions, wonders, buildings, resources, city-states, pantheons,
  mementos, Triumphs, diplomacy, happiness, razing and victories, per Age.
- **One technology per turn** — research completes at most one technology a
  turn (overflow waits), queued paths still work.
- **Victory Threshold Scaling** (Advanced Victory Options): Standard, Low or
  Very Low (default) for Culture, Economic and Military victories.

Always available in multiplayer setup, whatever the option:

- **Advanced Turn Timer Options** — presets for the game's Dynamic timer:
  Standard, Competitive, Blitz and Casual (base / per city / per unit seconds).
- A second minor memento slot.

Everything lives in `balance/` (see Project structure).

---

## Maps

Multiplayer only: the options below exist only in multiplayer setup, Pangaea
Ultima is listed only there, and single-player maps are generated untouched.

- **Pangaea Ultima** — one large central Pangaea with islands, in the Map list.
- **Player Placement** (Map Options) — Base, Duel, 2v2, 3v3 or 4v4 East vs
  West layouts for any map. Every start needs Fresh Water and 12 tiles of
  separation; the most constrained player is placed first.
- **Strict Start Biases** (Map Options) — leaders and civilizations start on
  their terrain; everyone is warned on the first turn if one could not.
- **Custom Resource System** (Map Options, On by default) — continent resource
  identities, persistent resources across Ages, custom yields, classes,
  tooltips and per-Age effects; Off keeps the game's resources.
- **Multiplayer defaults** — new multiplayer games start on Online speed,
  Abbreviated Ages, no end-of-Age countdown, Pangaea Ultima and Standard size
  (the host can change them).

Everything lives in `maps/` (see Project structure).

---

## Compatibility

- **Zatygold's Advanced Settings Pro** — its Resources setting is used: with
  it enabled the Custom Resource System option is removed and Pangaea Ultima
  keeps the game's resources. Its lobby tooltips add the ability names, so the
  Toolkit's own are switched off. Its settings (pacing, triumph sets, units...)
  apply on top of the balance changes. Its lobby memento slots show the first
  two slots; the second minor slot is set with Choose Mementos.
  The Map Options appear on its Map tab and Balance Settings on its General
  tab; both mods share the same setup-database conventions.
- **Zatygold's Spectator** — the Observer adds no time to the Competitive timer
  and never pauses the game by disconnecting; the Spectator keeps the Observer
  out of Player Placement and off the start-bias warning.

---

## Project structure

```
Multiplayer-Toolkit/
├─ multiplayer-toolkit.modinfo   # manifest: features, lobby-option criteria, per-Age data
├─ config/                       # lobby DB: Competitive option, pause keybind
├─ data/timers/                  # Competitive timer numbers (default + per Age)
├─ text/en_us/                   # mod info and Toolkit strings
├─ ui/
│  ├─ mpt-shared/                # logger, method wrapping, deferred patching, companion mods
│  ├─ mp-keybind/                # pause action in keyboard mapping
│  ├─ mp-lobby/                  # tooltips, countdown
│  ├─ mp-pause/                  # pause manager, overlay, chat commands
│  └─ mp-timer/                  # Competitive timer
├─ balance/                      # Multiplayer Balance (everything balance)
│  ├─ config/                    # Balance option, turn-phase presets, memento slot, victory thresholds
│  ├─ data/                      # one folder per subject (civilizations, leaders, units, policies,
│  │                             #   religion, resources, victories...): common and per-Age files
│  ├─ text/en_us/                # balance strings
│  └─ ui/                        # balance settings, one technology per turn
└─ maps/                         # Maps (everything map)
   ├─ config/                    # map list, Map Options, multiplayer-only filter, compatibility
   ├─ data/                      # custom resource system (per Age)
   ├─ maps/                      # map scripts (Pangaea Ultima, start placement, resources)
   ├─ scripts/                   # Voronoi map generator, multiplayer placement pass
   ├─ text/en_us/                # map strings
   └─ ui/                        # multiplayer defaults, turn-1 start warning
```

Each Toolkit feature has a `*-config.js` for settings, and modules patch the
base UI at runtime (no base-game files are replaced). Identifiers follow the
Toolkit's naming: `MPT_BALANCE_` / `MPTBalance` for Balance, `MPT_MAPS_` /
`MPT` for Maps (lobby options such as `MPTPlayerPlacement`), `MPT_TURNPHASE_`
for the Dynamic timer presets. Diagnostics go to `UI.log`.

---

## Changelog

### 0.6.2

- **New: Multiplayer Balance** (with Gohei427) — competitive balance changes
  behind the new **Multiplayer Balance** lobby option (On by default), plus
  one technology per turn, Victory Threshold Scaling, Dynamic timer presets
  (Standard, Competitive, Blitz, Casual) and a second minor memento slot.
- **New: Maps** (with Gohei427) — Pangaea Ultima, Player Placement (Base,
  Duel, 2v2, 3v3, 4v4), Strict Start Biases and the Custom Resource System.
- **Multiplayer only** — every Balance and Maps option exists only in
  multiplayer setup; Pangaea Ultima is listed only there; single-player map
  generation is left untouched.
- **Compatible with Advanced Settings Pro and Zatygold's Spectator** (see
  Compatibility).
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

Copyright (C) 2026 Zatygold and Gohei427. Free software under the **GNU General Public
License v3 or later**, without any warranty. See [`LICENSE`](LICENSE) or
<https://www.gnu.org/licenses/>.
