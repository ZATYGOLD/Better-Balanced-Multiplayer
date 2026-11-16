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
 * Better Balanced Multiplayer - Pause styles.
 *
 * Exported as a string and injected once by the manager, mirroring the base
 * game's `*.scss.js` convention of shipping a component's CSS as a module.
 */
const styles = `
  /* Hint shown directly above the in-menu Resume button. */
  .bbm-host-hint {
    width: 100%; text-align: center; margin-bottom: 0.5rem;
    font-family: "Times New Roman", "BodyFont", serif; font-size: 1.05rem;
    letter-spacing: 0.04em; color: #e7d6ab; text-shadow: 0 0.1rem 0.4rem rgba(0,0,0,0.7);
  }
  /* Disconnect / resync notices: one bright-red line per player, padded below. */
  .bbm-host-hint .bbm-reason {
    display: block; color: #ff3b3b; font-weight: 700;
    margin-bottom: 1rem; text-shadow: 0 0.1rem 0.4rem rgba(0,0,0,0.85);
  }

  /* "Ready: X / N" tally placed in the footer, under the build number. */
  .bbm-footer-ready {
    width: 100%; text-align: center; margin-top: 1.75rem;
    font-family: "Times New Roman", "BodyFont", serif; font-size: 1.7rem; font-weight: 700;
    letter-spacing: 0.06em; text-shadow: 0 0.12rem 0.5rem rgba(0,0,0,0.9);
  }
  .bbm-footer-ready.bbm-not-enough { color: #ff5555; }
  .bbm-footer-ready.bbm-enough { color: #5dff86; }
  /* Who started the pause, under the tally, with leader and civilization icons. */
  .bbm-footer-ready .bbm-paused-by {
    margin-top: 0.6rem; font-size: 1.15rem; font-weight: 400; letter-spacing: 0.04em; color: #e7d6ab;
  }
  .bbm-footer-ready .bbm-paused-by-name { font-size: 1.2rem; letter-spacing: 0.02em; }

  /* Full-screen "UNPAUSING..." countdown overlay with a centered, dimming vignette. */
  #bbm-countdown {
    position: fixed; inset: 0; width: 100%; height: 100%; z-index: 9000; pointer-events: none;
    display: none; flex-direction: column; align-items: center; justify-content: center;
    font-family: "Times New Roman", "BodyFont", serif;
    background: radial-gradient(ellipse 120% 90% at center, rgba(8,10,18,0.12), rgba(8,10,18,0.55));
  }
  #bbm-countdown.bbm-show { display: flex; }
  #bbm-countdown .bbm-count-label {
    width: 100%; text-align: center; font-size: 1.7rem; letter-spacing: 0.16em;
    text-transform: uppercase; color: #e7d6ab; text-shadow: 0 0.1rem 0.5rem rgba(0,0,0,0.9);
  }
  #bbm-countdown .bbm-count-num {
    width: 100%; text-align: center; font-size: 7rem; line-height: 1; font-weight: 700;
    color: #f8ecca; text-shadow: 0 0.2rem 1rem rgba(0,0,0,0.95); animation: bbm-pop 1s ease-out;
  }
  @keyframes bbm-pop {
    0% { transform: scale(1.6); opacity: 0; }
    25% { transform: scale(1); opacity: 1; }
    100% { transform: scale(0.9); opacity: 0.85; }
  }
`;
export { styles as default };
