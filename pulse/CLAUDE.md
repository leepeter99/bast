# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

An analog watch face for the Garmin Forerunner 965 (FR965), called "Panther / Expanding circles" (a purple Black Panther colour study). It has two parts: a design prototype in one self-contained file, `crossover_965_bast_pulse.html` (inline CSS, inline SVG, vanilla JS, no dependencies or build step), and the Connect IQ app in `ciq/`.

The Connect IQ build for FR965 lives in `ciq/` (Monkey C). It implements the decisions recorded in `CONTEXT.md` and `docs/adr/`; the HTML stays as the design prototype and is not kept in sync. The HTML predates the Chronos-style redesign (corner bars, Hybrid time style; ADR 0005), so it still shows the old chapter ring and four field types that are now bar-only. Build from the repo root (see the README): `monkeyc -d fr965 -f pulse/ciq/monkey.jungle -o pulse/ciq/bin/pulse.prg -y "$GARMIN_DEVELOPER_KEY" -w -l 3`. Keep `-l 3` (strict typing) clean. Layout test: add `-t`, then `monkeydo <prg> fr965 -t` with the simulator open.

Run the prototype by opening the file in a browser. To check a change, drag the time slider through the full 12 hours, toggle Active/AOD, and turn "adaptive" on and off.

## Code style

The CSS and JS are hand-minified: dense one-liners with short names (`$`, `el`, `cs`, `p`). Edit them in the same style. Don't reformat the file or split it into several files unless asked.

## Architecture (inside the `<script>`)

- **Dial geometry:** SVG `viewBox` is 454×454, centred at (227,227). The inner dial edge is r=180. Hand lengths are hour=117 and minute=170. Angles are in degrees clockwise from 12 o'clock.
- **Slots:** `slots` holds 8 positions on a ring of r=133. Positions 0/2/4/6 are the "home" positions top/right/bottom/left for the four chosen fields (`selectedFields` → `metricCatalog`).
- **Layout engine:**
  1. `blocked()` marks a slot unsafe if either hand passes within 60 of it (`handDistance` measures point-to-segment distance).
  2. In `draw()`, each field keeps its home slot if that slot is safe. Otherwise it moves to the nearest free safe slot by circular index distance. If none is free, it gets -1 and is hidden.
  3. `fitCircles()` grows each gauge from r=44, moving it toward the centre as it grows. Growth stops at the dial edge (180), at hand clearance (r+16) or at neighbour clearance (+7).
  - Only the hour and minute hands trigger relocation; the seconds hand is ignored on purpose.
- **Rendering:** `draw()` rebuilds `#metrics` on every change. `dataIcon()` draws each metric's icon, keyed by its label string (e.g. `'HEART RATE'`). If you add a metric, add matching entries to `metricCatalog`, all four `<select id="fieldN">` option lists and `dataIcon`.
- **AOD:** `mode(true)` adds the `.aod` class to the SVG. That hides every `.active-only` group and dims the hands, leaving only the hour/minute hands and the hub.
- **Second time zone:** `updateTravel()` treats the slider as Malaysia time (UTC+8) plus the `pm` checkbox and the chosen date. It converts that time with `Intl.DateTimeFormat` into `metricCatalog.zone`. `cityCodes` is the allowlist of zones.
- **Persistence:** the chosen fields and the zone are saved in `localStorage` under the keys `panther-fields-circles` and `panther-travel-circles`, inside try/catch.
- **Accent colour:** the `--accent` CSS variable; the colour selector changes it at runtime.

## Target production design (from the in-page brief)

The page describes a Monkey C version with four parts:
- **WatchFace:** the lifecycle.
- **DataProvider:** supplies the supported values.
- **LayoutEngine:** tests measured text bounds against the hand geometry.
- **Renderer:** draws the data first and the hands last.

In that version, `onEnterSleep` switches to the analog-only renderer, and the layout is re-evaluated each minute and on wake. All metric values in the HTML are simulated. FR965 API support for recovery time, Body Battery, resting HR and weather has not been verified.
