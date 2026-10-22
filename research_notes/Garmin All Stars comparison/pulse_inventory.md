# Pulse watch face: inventory of current design and implementation

Scope: local repo `/zz/dev/project/garmin_clock_face/bast`, HEAD `2bdb8ac` plus the working tree (uncommitted `AppName` change, untracked `pulse/store/`). All sources below are repo-relative file:line references. Internal names: the app class/prefix is "Panther" (`PantherApp`, `PantherView`); the store/app name is `bast_pulse`.

## 1. What does Pulse render (layout, fields, chapter ring, hands/digital, colours)?

### Takeaway
Pulse is an **analog-only** face (hour, minute, seconds hands; no digital time, no Digital/Hybrid modes) with **four** circular data gauges that relocate and resize to dodge the hour/minute hands, a cached chapter ring (compass / hour numerals / ticks only), and a purple palette with six selectable accent colours. Everything is drawn procedurally; there are no layout XMLs or image drawables except the launcher icon.

### Cited Findings
- Described as "An analog watch face for the Garmin Forerunner 965 (FR965), called 'Panther / Expanding circles' (a purple Black Panther colour study)" — [pulse/CLAUDE.md:7](pulse/CLAUDE.md)
- Store copy: "an analog watch face for the Forerunner 965 with data fields that move out of the way of the hands"; "Four circular gauges sit at the top, right, bottom and left" — [pulse/store/description.txt:1-3](pulse/store/description.txt)
- Exactly four fields by design ("There are exactly four") — [pulse/CONTEXT.md:9-11](pulse/CONTEXT.md)
- Screen geometry hard-coded for 454x454, centre 227 — [pulse/ciq/source/PantherView.mc:10](pulse/ciq/source/PantherView.mc), [pulse/ciq/source/Layout.mc:5-12](pulse/ciq/source/Layout.mc)
- Draw order in active mode: cached ring bitmap -> gauges -> hour hand -> minute hand -> seconds hand -> hub (filled 0xe5caff r=10 with 4px 0x283334 outline) — [PantherView.mc:68-83](pulse/ciq/source/PantherView.mc)
- Hands are filled polygons (fill 0xe5caff, 3px outline 0x553166); hour length ~115, minute ~168 px — [PantherView.mc:16-17, 176-195](pulse/ciq/source/PantherView.mc)
- Seconds hand: 2px accent-coloured line from -25 to +184 px with a hollow counterweight circle at -20 px — [PantherView.mc:197-206](pulse/ciq/source/PantherView.mc)
- Dial: circles at r=181 (0x49245c, 2px) and r=204 (0x50325e, 1px); 60 minute ticks (major every 5: 6px 0xdac5eb r 187-207; minor 2px 0x513262 r 198-203) — [PantherView.mc:117-130](pulse/ciq/source/PantherView.mc)
- Chapter ring styles: 0 Compass (N/E/S/W at cardinals, degree numbers 30..330 elsewhere), 1 Hour numerals (12,1..11), 2 Ticks only; labels at r=214, cardinals size 13 colour 0xe5cff6, others size 10 colour 0x9278a6, RobotoCondensedBold vector font — [PantherView.mc:131-138, 102-114](pulse/ciq/source/PantherView.mc); strings [strings.xml:43-45](pulse/ciq/resources/strings/strings.xml)
- "Compass style" is decorative only: "It doesn't measure heading" — [pulse/CONTEXT.md:45-47](pulse/CONTEXT.md)
- Gauge rendering: filled disc 0x100818, 2px outline 0x643887; if the field has a progress value, a 4px track 0x2a1838 plus an accent arc clockwise from 12 o'clock proportional to progress (continuous, not segmented); fields without progress get a 1px accent inner ring; 14x14 hand-drawn vector icon above, value text in 0xf5f6f7 auto-sized to fit (even sizes only), optional caption in accent colour below — [PantherView.mc:141-174, 216-262](pulse/ciq/source/PantherView.mc)
- Warning colour: arc turns orange 0xff993d (or red 0xff5a5a when accent is Amber) when Stress > 75% or Move bar > 0 — [PantherView.mc:157](pulse/ciq/source/PantherView.mc)
- Accent palette: 0xbc73ff Vibranium purple, 0x9252e3 Deep violet, 0xdcadff Soft lavender, 0xff993d Amber, 0x52dfff Ice Blue, 0xb8ed95 Lume Green — [PantherView.mc:11](pulse/ciq/source/PantherView.mc), [strings.xml:46-51](pulse/ciq/resources/strings/strings.xml)
- Layout engine: 8 slots on a ring r=133 (45 degrees apart); homes 0/2/4/6 = top/right/bottom/left; a slot is "blocked" if hour (len 117) or minute (len 170) hand segment is within 60 px; seconds hand ignored — [Layout.mc:7-51](pulse/ciq/source/Layout.mc), [CONTEXT.md:21-23](pulse/CONTEXT.md)
- Sticky relocation with one-minute lookahead (ADR 0002): home if clear now and next minute; else keep current relocation slot until blocked; else nearest slot clear now+next; else hidden (-1). Duplicated fields are skipped (hidden) — [Layout.mc:58-91](pulse/ciq/source/Layout.mc), [docs/adr/0002](pulse/docs/adr/0002-sticky-relocation-with-one-minute-lookahead.md)
- Gauge growth: start r=44, grow up to 10 steps toward centre (max r ~54), stop at dial edge 180, hand clearance r+16, neighbour clearance +7 — [Layout.mc:93-118](pulse/ciq/source/Layout.mc) (the prototype uses 26 steps — [crossover_965_bast_pulse.html:33](pulse/crossover_965_bast_pulse.html))
- Hidden-field priority: left hidden first, top last — [CONTEXT.md:29-31](pulse/CONTEXT.md)
- Store render (`pulse/store/pulse_dial_454_small.png`) shows: compass ring with N/E/S/W and degree labels, battery gauge "50%" top with partial arc, date gauge "Tue 20" left, heart "139" bottom, steps "0" lower-right (relocated), filled lavender hands, thin accent seconds hand — [pulse/store/pulse_dial_454_small.png](pulse/store/pulse_dial_454_small.png)
- No `resources/layouts` directory; drawables contain only `LauncherIcon` — [pulse/ciq/resources/drawables/drawables.xml:1-3](pulse/ciq/resources/drawables/drawables.xml)
- Browser prototype: single self-contained HTML (inline SVG/CSS/JS), title "Panther / Expanding circles", with time slider, Active/AOD toggle, "adaptive" toggle, field selects, accent picker, second-zone simulator, values simulated; persisted in localStorage — [crossover_965_bast_pulse.html:1-51](pulse/crossover_965_bast_pulse.html), [pulse/CLAUDE.md:11-30](pulse/CLAUDE.md). The prototype is "not kept in sync" with the CIQ app — [pulse/CLAUDE.md:9](pulse/CLAUDE.md)
- Prototype gauge ring uses a dashed stroke (`stroke-dasharray '2 3'`) — [crossover_965_bast_pulse.html:42](pulse/crossover_965_bast_pulse.html); the CIQ app draws a solid arc instead — [PantherView.mc:153-163](pulse/ciq/source/PantherView.mc)
- `shadow/` is a sibling browser-only prototype ("Panther / Adaptive dial"), same metric catalog (incl. a simulated "sleep" metric), no Connect IQ app — [shadow/AGENTS.md](shadow/AGENTS.md), [README.md](README.md)

### Inferences
- Versus All Stars: Pulse has no Digital or Hybrid mode, no digital time readout, 4 vs 6 data slots, no fixed complication positions (positions move with the hands), no segmented step arc, no weekday ring around a date, no weather hi/lo, no sunset.
- The adaptive "dodge the hands" layout is Pulse's distinctive feature; All Stars-style fixed slots would conflict with it in analog mode.

### Gaps
- No screenshot of always-on mode or of the hour-numeral/ticks ring styles found in `pulse/store/`.

## 2. Which data fields exist, which are configurable, and how are settings applied?

### Takeaway
14 field types; the user picks any 4 (top/right/bottom/left) plus second-zone city or custom offset, chapter ring style and accent colour. Settings come from the phone (settings.xml) and an on-watch Menu2 (fields only); both funnel into `PantherView.loadSettings()`, which validates indices and invalidates caches.

### Cited Findings
- Field enum (14): HEART, RESTING, RECOVERY, BODY, WEATHER, BATTERY, STEPS, DATE, CALORIES, DISTANCE, SUNRISE, STRESS, ZONE, MOVE — [Fields.mc:16-17](pulse/ciq/source/Fields.mc); display names M0..M13 — [strings.xml:15-28](pulse/ciq/resources/strings/strings.xml)
- Per-field source and output (`[text, progress 0..1 or null, caption or null]`) — [Fields.mc:13-14, 54-107](pulse/ciq/source/Fields.mc):
  - Heart rate: `COMPLICATION_TYPE_HEART_RATE`, no arc (l.56-58)
  - Resting HR: `UserProfile.getProfile().averageRestingHeartRate` (l.59-61)
  - Recovery: `COMPLICATION_TYPE_RECOVERY_TIME`, minutes rounded up to hours, "Nh" (l.62-65)
  - Body Battery / Stress: complications, value plus arc v/100 (l.66-68)
  - Weather: `COMPLICATION_TYPE_CURRENT_TEMPERATURE` only, Celsius converted to F if statute units, "NN°"; no condition icon, no hi/lo (l.69-74)
  - Watch battery: `System.getSystemStats().battery`, "NN%" plus arc (l.75-77)
  - Steps: `ActivityMonitor` steps / stepGoal, arc = steps/goal capped 1.0, "7.4K" format above 1000 (l.78-82)
  - Date: `Gregorian.info(..., FORMAT_MEDIUM)` -> "Tue 20" (weekday + day); no month (l.83-85)
  - Calories: `ActivityMonitor.calories` (l.86-88)
  - Distance: `ActivityMonitor.distance`, km or mi per device settings (l.89-93)
  - Sunrise: `COMPLICATION_TYPE_SUNRISE` (seconds since midnight) -> hh:mm honouring 12/24 h; sunset not offered (l.94-99)
  - Move alert: `ActivityMonitor.moveBarLevel`, text "MOVE"/"OK", arc = level/MOVE_BAR_LEVEL_MAX (l.100-105)
  - Second zone: city via `Gregorian.localMoment(lat/lon)` or custom fixed offset; caption is city code plus "+1d/-1d" (l.106-132)
- Missing data renders "--" ("Unavailable" state keeps icon and slot) — [Fields.mc:55](pulse/ciq/source/Fields.mc), [CONTEXT.md:61-63](pulse/CONTEXT.md)
- Move alert and weekday-in-date were added in commit d9ee850 "Add move alert field and show weekday in date field" — `git log`
- Defaults: field0 (top)=5 Battery, field1 (right)=6 Steps, field2 (bottom)=0 Heart rate, field3 (left)=7 Date; city 0 London; useCustomZone false; customOffset 0; customLabel "UTC"; ringStyle 0 Compass; accent 0 — [properties.xml:1-12](pulse/ciq/resources/properties/properties.xml)
- Phone settings: four 14-entry lists, city list (9 cities: London, New York, Tokyo, Sydney, Singapore, Kuala Lumpur, Kolkata, Dubai, UTC), boolean custom zone, grouped numeric offset -720..840 min and 3-char alphanumeric label (enabled only if custom zone on), ring style list, accent list — [settings.xml:1-115](pulse/ciq/resources/properties/settings.xml)
- City coordinates table — [Fields.mc:19-24](pulse/ciq/source/Fields.mc); rationale ADR 0004 — [docs/adr/0004](pulse/docs/adr/0004-second-zone-from-city-coordinates.md)
- On-watch settings: `getSettingsView` returns `FieldMenu` (only the 4 fields); picker hides metrics already used in another position; selection writes `Application.Properties` and calls `onSettingsChanged()` — [PantherApp.mc:15-17](pulse/ciq/source/PantherApp.mc), [FieldMenu.mc:16-57](pulse/ciq/source/FieldMenu.mc)
- FieldMenu notes it may be rejected on device: "If getSettingsView rejects Menu2InputDelegate on device, delete this file..." — [FieldMenu.mc:6-7](pulse/ciq/source/FieldMenu.mc)
- Apply path: `onSettingsChanged()` -> `view.loadSettings()` + `requestUpdate()` — [PantherApp.mc:19-22](pulse/ciq/source/PantherApp.mc); `loadSettings` validates each value via `Fields.index` (fallback to defaults for out-of-range/non-Number), resets `last` slots, `cachedMin=-1` and drops the ring bitmap — [PantherView.mc:38-45](pulse/ciq/source/PantherView.mc), [Fields.mc:26-29](pulse/ciq/source/Fields.mc)
- Duplicate fields chosen via phone are hidden (second occurrence) — [Layout.mc:64-68](pulse/ciq/source/Layout.mc), test [LayoutTest.mc:26](pulse/ciq/source/LayoutTest.mc)

### Inferences
- Minor inconsistency: `FieldMenu.fieldAt` falls back to 0 (Heart rate) for an invalid stored value, whereas the view falls back to `DEFAULTS[i]` — [FieldMenu.mc:13](pulse/ciq/source/FieldMenu.mc) vs [PantherView.mc:39](pulse/ciq/source/PantherView.mc).
- "Harden settings" is incomplete for the zone: `customOffset` is cast `as Numeric` and `useCustomZone` `as Boolean` without null/type checks — [Fields.mc:112-113](pulse/ciq/source/Fields.mc).
- No settings for: time format/mode, colour themes beyond accent, hiding seconds, AOD content, units override, data-in-AOD.

### Gaps
- Not verified on a real FR965 which complications return data (ADR 0001 flags this) — [docs/adr/0001:8](pulse/docs/adr/0001-complications-first-for-field-data.md)

## 3. Low-power / always-on, burn-in, caching, Complications, Weather, sunrise, battery/Body Battery, heart rate

### Takeaway
Always-on mode is hands-only (1 px outlines, no anti-aliasing, 4-position pixel shift per minute); there is no `onPartialUpdate`, so seconds show only in high-power mode. Field values are cached per minute (heart rate per frame) and the chapter ring is cached in a buffered bitmap. Data comes from `Toybox.Complications` read synchronously via `getComplication`, not subscriptions; `Toybox.Weather` and sunset are not used.

### Cited Findings
- `onEnterSleep` sets `sleeping=true`; `onExitSleep` clears it and forces recompute (`cachedMin=-1`) — [PantherView.mc:47-49](pulse/ciq/source/PantherView.mc)
- Sleeping path: clear to black, draw only hour/minute AOD hands and a 6 px hub circle; anti-alias off — [PantherView.mc:53-59, 208-214](pulse/ciq/source/PantherView.mc)
- AOD hand shapes start at -14 px (no centre fill) and are drawn as 1 px outline 0x84718f — [PantherView.mc:18-19, 187-190](pulse/ciq/source/PantherView.mc)
- Burn-in: frame shifted by `SHIFTS[m % 4]` = (0,0),(2,0),(2,2),(0,2) — [PantherView.mc:14, 210](pulse/ciq/source/PantherView.mc); rationale cites Garmin AMOLED rule (pixel lit at most 3 consecutive minute updates, at most 10% pixels lit) — [docs/adr/0003:3-7](pulse/docs/adr/0003-outline-hands-in-always-on-mode.md)
- No `onPartialUpdate` and no `onPowerBudgetExceeded` anywhere in source (grep of `pulse/ciq/source/*.mc`); seconds hand drawn only in `onUpdate` active path — [PantherView.mc:77](pulse/ciq/source/PantherView.mc)
- Caching (commit 2bdb8ac): "Read field values once a minute (heart rate every frame) and draw the chapter ring once into a buffered bitmap, instead of redrawing and re-reading everything at 1 Hz" — `git show 2bdb8ac`; implementation: `cachedMin` gate around layout + `Fields.read` — [PantherView.mc:61-67](pulse/ciq/source/PantherView.mc); HR re-read each frame — [PantherView.mc:71](pulse/ciq/source/PantherView.mc)
- Ring cache: `Graphics.createBufferedBitmap({454x454})` held as `BufferedBitmapReference`; recreated if the graphics pool purges it or settings change — [PantherView.mc:87-100, 44](pulse/ciq/source/PantherView.mc)
- Font cache: dictionary of `getVectorFont("RobotoCondensedBold", size)`, value sizes rounded to even numbers "to bound the font cache"; falls back to `FONT_XTINY` if vector font unavailable — [PantherView.mc:102-114, 168-169](pulse/ciq/source/PantherView.mc)
- Complications usage: `Complications.getComplication(new Complications.Id(type)).value` in try/catch, Number/Float/Double only — [Fields.mc:40-47](pulse/ciq/source/Fields.mc); types used: HEART_RATE, RECOVERY_TIME, BODY_BATTERY, STRESS, CURRENT_TEMPERATURE, SUNRISE — [Fields.mc:57-96](pulse/ciq/source/Fields.mc). No `registerComplicationChangeCallback`/`subscribeToUpdates` calls.
- ADR 0001 rationale: complications chosen over SensorHistory (docs contradictory for watch faces) and over `Weather.getSunrise` (needs location); Sleep replaced by Stress since Sleep Score needs API 6.0.2 — [docs/adr/0001:3-9](pulse/docs/adr/0001-complications-first-for-field-data.md)
- `Toybox.Weather` is not imported; imports are Application, Lang, Math, System, Time, Gregorian, ActivityMonitor, UserProfile, Complications, Position, WatchUi — [Fields.mc:1-11](pulse/ciq/source/Fields.mc)
- No sunrise/sunset calculation of its own; only the sunrise complication value — [Fields.mc:94-99](pulse/ciq/source/Fields.mc)
- Battery from `System.getSystemStats().battery` (always available, arc shown) — [Fields.mc:75-77](pulse/ciq/source/Fields.mc); Body Battery from complication — [Fields.mc:66-68](pulse/ciq/source/Fields.mc)

### Inferences
- On FR965 the face in high-power mode updates at 1 Hz only briefly after a gesture; without `onPartialUpdate`, the seconds hand disappears entirely in always-on mode (by design per ADR 0003 / CONTEXT "only the hour and minute hands").
- Always-on shows no data at all (no time digits, no date, no fields); All Stars-style AOD with data would require new burn-in handling.
- Weather hi/lo and condition would require `Toybox.Weather.getCurrentConditions()` (hi/lo temperature, condition) — not currently used; adding it would need no new permission per current manifest pattern but is untested here.
- A segmented step arc would be a change to `drawGauge` (currently continuous `drawArc`).

### Gaps
- No measured memory or power numbers in repo; the 454x454 buffered bitmap's memory cost is not documented.
- Behaviour of `ComplicationSubscriber` reads when the complication is not subscribed is untested on device (ADR 0001 consequence).

## 4. Target devices, memory considerations, TODOs / known gaps

### Takeaway
Single target `fr965`, minApiLevel 4.2.1, permissions ComplicationSubscriber + UserProfile, English only. No TODO/FIXME markers; known gaps are recorded as ADR "Consequences" and CLAUDE.md caveats, mostly "verify on a real FR965".

### Cited Findings
- Manifest: type watchface, entry `PantherApp`, `minApiLevel="4.2.1"`, product `fr965` only, permissions `ComplicationSubscriber`, `UserProfile`, language `eng`, no barrels — [pulse/ciq/manifest.xml:3-14](pulse/ciq/manifest.xml)
- `monkey.jungle` is one line: `project.manifest = manifest.xml` (no device-specific resource overrides) — [pulse/ciq/monkey.jungle:1](pulse/ciq/monkey.jungle)
- Build with strict typing `-l 3`; layout test via `-t` — [pulse/CLAUDE.md:9](pulse/CLAUDE.md), [README.md](README.md)
- Unit test: `layoutSweep` sweeps 1440 minutes checking hand clearance, no moves into slots blocked at m or m+1, no hopping between non-home slots, and duplicate hiding — [LayoutTest.mc:4-28](pulse/ciq/source/LayoutTest.mc)
- Memory measures present: per-minute value cache, ring bitmap via graphics pool reference, bounded font cache — [PantherView.mc:27-31, 87-105, 168](pulse/ciq/source/PantherView.mc)
- No `TODO`/`FIXME` found in `pulse/` or `shadow/` (grep).
- Known gaps: complication data must be checked on a real FR965 — [docs/adr/0001:8](pulse/docs/adr/0001-complications-first-for-field-data.md); `localMoment` accuracy/offline unknown, DST to be tested per city — [docs/adr/0004:7](pulse/docs/adr/0004-second-zone-from-city-coordinates.md); FR965 support for recovery/Body Battery/resting HR/weather "has not been verified" — [pulse/CLAUDE.md:40](pulse/CLAUDE.md); on-watch settings menu may be rejected — [FieldMenu.mc:6-7](pulse/ciq/source/FieldMenu.mc)
- Untracked `pulse/store/` holds store listing assets: `description.txt`, `cover_500x500.png`, `hero_1440x720.png` (+ small jpg), `pulse_device.png` (+ small jpg), `pulse_dial_454.png` (+ small png), all dated 2026-10-20 — directory listing of [pulse/store/](pulse/store/)
- Uncommitted change renames `AppName` from "Panther" to "bast_pulse" — [strings.xml:2](pulse/ciq/resources/strings/strings.xml) (`git diff`)
- Git history (7 commits): Initial commit; SDK Manager/Nix shell work (2647b97, 8e63406, e63e797, 9b0112c); d9ee850 move alert + weekday; 2bdb8ac caching/hardening — `git log --oneline -30`

### Inferences
- Pulse is being prepared for Connect IQ Store submission (store assets + rename), still single-device and single-language.
- Expanding to other AMOLED/MIP devices would need geometry parametrised (CX=227 and 454 hard-coded in [PantherView.mc:10, 91](pulse/ciq/source/PantherView.mc) and [Layout.mc:7-12](pulse/ciq/source/Layout.mc)).

### Gaps
- No on-device test results, crash logs, or memory/battery profiling present in the repo.
