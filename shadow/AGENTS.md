# Repository Guidelines

## Project Structure & Module Organization

`crossover_965_bast_shadow.html` is the complete browser prototype for a purple Garmin FR965 analog watch face. It contains page markup, inline CSS, SVG artwork, and JavaScript; there are no separate source, asset, or test directories. Key functions include `draw()` for layout and rendering, `blocked()` for hand clearance, and `updateTravel()` for second-zone time. The Connect IQ implementation brief describes future work, not an existing Monkey C application.

## Build, Test, and Development Commands

- Open `crossover_965_bast_shadow.html` directly in a modern browser for a quick preview.
- Run `python3 -m http.server 8000 --bind 127.0.0.1` from this directory, then visit `http://127.0.0.1:8000/crossover_965_bast_shadow.html` for a consistent local origin and browser storage.

No dependency installation, build step, automated test runner, formatter, or linter is configured.

## Coding Style & Naming Conventions

Use plain HTML, CSS, and JavaScript with native browser APIs. Existing code is compact and largely unindented; keep edits localized and avoid unrelated whole-file reformatting. Use two-space indentation when adding multiline blocks. Follow existing camelCase JavaScript names such as `selectedFields` and `updateSeconds`, and lowercase, hyphenated CSS classes such as `active-only`. Preserve control IDs, accessible labels, and `aria-pressed` state updates. Create SVG elements through the existing `el()` helper.

## Testing Guidelines

Validate changes manually in the browser and check the developer console for errors. Exercise:

- Time presets and the full 12-hour slider, with adaptation enabled and disabled.
- Active/AOD transitions, seconds controls, and field relocation near both hands.
- All field choices, accent colors, and narrow-screen layouts.
- Second-zone dates, daylight-saving boundaries, PM selection, and day offsets.
- Saved preferences after reload and graceful behavior when storage is unavailable.

There are no automated coverage requirements or test naming conventions. Keep sample data clearly identified; browser behavior does not validate device API support or AMOLED power behavior.

## Commit & Pull Request Guidelines

Git history is unavailable in this checkout, so no established commit convention can be verified. Prefer short, imperative subjects such as `Fix field overlap near noon`. Describe changed behavior, list manual checks, link relevant issues, and include screenshots for visual changes.
