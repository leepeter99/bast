# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Bast Pulse: an analog watch face for AMOLED Garmin watches (FR965, FR970, fenix 8 and fenix 9 AMOLED; see `ciq/manifest.xml`). Three gauges move out of the way of the hands; four corner bars run along the edge. The vocabulary is in `CONTEXT.md`, the decisions in `docs/adr/`. Read both before changing behaviour.

The app is the Connect IQ build in `ciq/` (Monkey C). `crossover_965_bast_pulse.html` is the original design prototype: it is stale (old chapter ring, four fields, eight slots) and not kept in sync. Don't use it as a reference for current behaviour.

## Build and test

From the repo root: `monkeyc -d fr965 -f pulse/ciq/monkey.jungle -o pulse/ciq/bin/pulse.prg -y "$GARMIN_DEVELOPER_KEY" -w -l 3`. Keep `-l 3` (strict typing) clean. Tests (`ciq/source/LayoutTest.mc`): add `-t`, then `monkeydo <prg> fr965 -t` with the simulator open. They sweep two 12-hour cycles of the layout and check the recovery peak.

## Code layout (`ciq/source/`)

- **`Layout.mc`:** slot assignment and gauge sizing. Geometry is designed at 454 px and rescaled by `setup(width)`. `assign()` keeps a relocated field in place until its slot is blocked and checks the next minute too (ADR 0002, don't simplify it away). It picks relocation slots with the cheap `grow()`, because running the full `fit()` per candidate trips the watchdog on device.
- **`Fields.mc`:** the data provider. `read(id)` returns `[text, progress 0..1 or null, caption or null]`, plus extras for some fields (steps count, weekday). Complications come first, direct APIs second (ADR 0001). A missing reading returns `--`. Settings are validated with `index()`, because phone values can be stale.
- **`PantherView.mc`:** the renderer. Data is drawn first and the hands last. Layout and readings are cached per minute (heart rate refreshes every update). Ticks and bar tracks are drawn once into a buffered bitmap. Always-on mode draws only 1 px outlined hands, shifted each minute (ADR 0003). `tint()` recolours the purple theme to the accent.
- **`FieldMenu.mc`:** the on-watch settings menus. They never offer a metric already used in the same group.

Adding a metric means updating the `Fields` enum and `COUNT`, `read()`, the `M<n>` string, the `settings.xml` lists (gauge lists leave out bar-only metrics, see `Fields.fixed`), and `drawIcon`.
