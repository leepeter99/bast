# Connect IQ (Monkey C) techniques for an "All Stars"-class multi-complication face on Forerunner 965

Target device baseline: FR965 = AMOLED, 454x454 round, Connect IQ API level 5.2 (FR970 = AMOLED 454x454, API 6.0) — [Garmin compatible devices](https://developer.garmin.com/connect-iq/compatible-devices/). Every API below with level <= 5.2 is therefore available by API level on FR965; per-method device lists on the API pages were not checked row by row for FR965 (see Gaps).

## 1. User-selectable complication slots (Toybox.Complications) and tap-to-launch

### Takeaway
All Complications functions are API 4.2.0 (FR965 qualifies). Pattern: register a change callback, then `subscribeToUpdates(new Id(type))` per slot; draw from the cached `Complication.value`; in `WatchFaceDelegate.onPress` hit-test the slot rectangle/circle and call `Complications.exitTo(id)` to open the native glance/widget. Slot choice is your own setting (store a `Complications.Type` number per slot) — the system does not provide a per-slot picker on FR965-class firmware.

### Cited Findings
- Functions (all API 4.2.0): `exitTo(id)`, `getComplication(id)`, `getComplications()` (iterator), `registerComplicationChangeCallback(cb or null)`, `subscribeToUpdates(id) as Boolean`, `unsubscribeFromAllUpdates()`, `unsubscribeFromUpdates(id)`, `updateComplication(index, data)` (publisher side) — [Toybox.Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)
- Register the change callback before subscribing; `subscribeToUpdates` throws `Lang.OperationNotAllowedException` when there are too many active subscriptions and `ComplicationNotFoundException` if absent; `getComplication` also throws `ComplicationNotFoundException`; `exitTo` throws `InvalidValueException` for an Id not from a valid app — [Toybox.Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)
- Type enum (all 4.2.0 unless noted): BATTERY 1, STEPS 2, CALORIES 3, FLOORS_CLIMBED 4, INTENSITY_MINUTES 5, DATE 6, WEEKDAY_MONTHDAY 7, CURRENT_WEATHER 8, FORECAST_WEATHER_1/2/3DAY 9–11, CALENDAR_EVENTS 12, SUNRISE 13, SUNSET 14, ALTITUDE 15, SEA_LEVEL_PRESSURE 16, NOTIFICATION_COUNT 17, HEART_RATE 18, WEEKLY_RUN_DISTANCE 19, WEEKLY_BIKE_DISTANCE 20, RECOVERY_TIME 21, STRESS 22, BODY_BATTERY 23, VO2MAX_RUN 24, VO2MAX_BIKE 25, TRAINING_STATUS 26, race predictors 27–30, race pace predictors 31–34, PULSE_OX 35, RESPIRATION_RATE 36, SOLAR_INPUT 37, CURRENT_TEMPERATURE 38, HIGH_LOW_TEMPERATURE 39, WHEELCHAIR_PUSHES 40 (4.2.3), LAST_GOLF_ROUND_SCORE 41 (5.0.0), SLEEP_SCORE 42 (6.0.2 — NOT on FR965 at API 5.2) — [Toybox.Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)
- `Complication` members (4.2.0, all nullable): `complicationId`, `value`, `unit`, `shortLabel`, `longLabel`, `ranges`; icon via `getIcon()` (user complications only); `getType()` returns the system Type or INVALID for user complications — [Complication class](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications/Complication.html)
- `WatchFaceDelegate.onPress(clickEvent as ClickEvent) as Boolean` is API 4.2.0, "called when user does a touch and hold"; `onTap`, `onWatchFaceConfigEdited`, `setSelectedComplication` exist but have narrower, mostly newer device lists — [WatchFaceDelegate](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFaceDelegate.html)
- Only watch faces can subscribe; the `ComplicationSubscriber` manifest permission is rejected in a watch-app — [forum: Complications questions](https://forums.garmin.com/developer/connect-iq/f/discussion/314641/complications-questions/1574292)
- Pitfall: `getComplication(26)` fails — must pass `new Complications.Id(Complications.COMPLICATION_TYPE_TRAINING_STATUS)`, not a raw number — [forum: Training Status](https://forums.garmin.com/developer/connect-iq/f/app-ideas/365103/integrating-training-status-into-watchface)
- Pitfall: with strict type checking, `ComplicationChangedCallback` PolyType error reported; advice was typecheck 0 / cast. Subscribe in `initialize()`/`getInitialView()`, not `onStart()` (which also runs for background) — [forum: Complications questions](https://forums.garmin.com/developer/connect-iq/f/discussion/314641/complications-questions/1574292)
- Reference samples with square and round onPress hit-tests that launch the complication widget: sunpazed/garmin-complicate and garmin-complicate-circle; reports that onPress did not fire for FR955 in the sim, and that exitTo behaviour differed between CIQ-published and native complications on some devices — [forum: Complication samples](https://forums.garmin.com/developer/connect-iq/f/discussion/315443/here-are-a-few-complication-samples/1588917), [GitHub garmin-complicate-circle](https://github.com/sunpazed/garmin-complicate-circle)
- Segment34 MkII (popular OSS face) offers configurable "press to open" targets per field and pulls Stress / Body Battery from the complications API when available — [Segment34mkII](https://github.com/ludw/Segment34mkII)

### Inferences
- Minimal pattern (assembled from the API signatures above; verify against the samples):
  ```monkeyc
  // manifest: <iq:uses-permission id="ComplicationSubscriber"/>
  function initialize() {
      WatchFace.initialize();
      Complications.registerComplicationChangeCallback(method(:onComp));
      for (var i = 0; i < slotTypes.size(); i++) {
          try { Complications.subscribeToUpdates(new Complications.Id(slotTypes[i])); }
          catch (e) { /* not on this device: hide slot */ }
      }
  }
  function onComp(id as Complications.Id) as Void {
      cache[id] = Complications.getComplication(id).value; // cache, draw in onUpdate
  }
  // Delegate
  function onPress(evt as WatchUi.ClickEvent) as Boolean {
      var xy = evt.getCoordinates();
      var i = hitSlot(xy[0], xy[1]);        // (dx*dx+dy*dy) < r*r per slot centre
      if (i >= 0) { Complications.exitTo(slotIds[i]); return true; }
      return false;
  }
  ```
- FR965 is touch + buttons; onPress is a touch-and-hold, so tap-to-launch requires touch enabled on the watch face; always provide a fallback (glances via button) — do not make the feature critical.
- When the user changes a slot in settings: `unsubscribeFromAllUpdates()` then resubscribe; keeps you under the subscription limit.

### Gaps
- Exact max subscription count not documented on the page fetched.
- Whether FR965 is in the device list for `onTap`/`setSelectedComplication` (native complication editing) was not verified; the core-topic "Complications" page did not render via fetch.
- Sample repo source code (src/) not read; README confirms only that tap launches the widget.

## 2. Style setting: digital / analog / hybrid

### Takeaway
No dedicated API; implement as an enum property read in `onSettingsChanged()` that swaps a draw routine (strategy per style) and invalidates caches.

### Cited Findings
- App settings defined in resources XML appear in the Connect IQ mobile app/Garmin Express; on-device settings come from `getSettingsView()` — [forum: settings on WatchFace](https://forums.garmin.com/developer/connect-iq/f/discussion/406273/settings-on-watchface-not-working/1910203)
- Arc/angle convention for analog hands/ticks: 0° = 3 o'clock, 90° = 12, counter-clockwise; `ARC_CLOCKWISE`/`ARC_COUNTER_CLOCKWISE` — [Dc](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html)
- `drawBitmap2` (4.2.1) supports `:transform` (AffineTransform) and `:filterMode`, usable for rotated bitmap hands — [Dc](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html)

### Inferences
- Polygon hands via `fillPolygon` with anti-aliasing are cheaper in memory than rotated bitmaps; rotated bitmaps via drawBitmap2 look better but cost a full redraw each minute (no partial on AMOLED anyway).
- Hybrid = analog hands + small digital time in a subdial; share the complication layer, only the time layer changes. Hide seconds hand in AOD (see §6).

### Gaps
- No primary source on how All Stars implements its style switch.

## 3. Segmented arc gauges (steps goal, body battery)

### Takeaway
Use `dc.drawArc` with `setPenWidth` per segment (N short arcs with gaps), anti-alias on; cache the static track (background segments) in a BufferedBitmap and draw only the filled segments each update.

### Cited Findings
- `drawArc(x, y, r, attr, degreeStart, degreeEnd)` API 1.2.0; params truncated to integers; equal start/end draws a full circle (beware zero-length segment = full ring) — [Dc](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html)
- `setAntiAlias(true)` API 3.2.0; throws `InvalidPaletteException` on a paletted BufferedBitmap — [Dc](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html)
- `setStroke`/`setFill` (4.0.0) accept 0xAARRGGBB or a `BitmapTexture` (gradient-like fills) and override setColor — [Dc](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html)
- Body Battery = COMPLICATION_TYPE_BODY_BATTERY (23), steps = STEPS (2) — [Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)

### Inferences
- Segment loop: `for i in 0..N-1: a0 = start - i*(seg+gap); dc.drawArc(cx,cy,r,ARC_CLOCKWISE,a0,a0-seg)`; guard `a0 != a1` because of the full-circle rule. Integer truncation means use segment sizes in whole degrees to avoid uneven gaps.
- Rounded caps are not provided by drawArc; emulate with `fillCircle` at endpoints if wanted.
- Don't anti-alias inside a paletted (memory-saving) buffer — choose: small palette buffer without AA, or full-colour buffer with AA.

### Gaps
- No measured cost figures for drawArc vs. cached bitmap on FR965.

## 4. Weekday ring around a date subdial

### Takeaway
Use `dc.drawRadialText` (API 4.2.1, vector font) to place the 7 weekday labels on a ring and highlight today; FR965 (API 5.2) qualifies by level.

### Cited Findings
- `drawRadialText(x, y, font as VectorFont, text, justification, angle, radius, direction)` API 4.2.1; `drawAngledText(...)` 4.2.1; angle in degrees CCW from 3 o'clock — [Dc](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html)
- `RADIAL_TEXT_DIRECTION_CLOCKWISE` (0): top of text away from centre (upright along top of circle); `COUNTER_CLOCKWISE` (1): bottom away (upright along bottom) — [Graphics](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics.html)
- `Graphics.getVectorFont({:face, :size})` API 4.2.1, returns null if unavailable; `:font`/`:scale` options need CIQ 5.1.0+ — [Graphics](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics.html)
- COMPLICATION_TYPE_WEEKDAY_MONTHDAY (7) exists for tap target — [Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)

### Inferences
- Ring: 7 positions at 360/7 ≈ 51.4°, or a top arc spread; split labels on the upper half (CLOCKWISE) vs lower half (COUNTER_CLOCKWISE) so all read upright.
- `getVectorFont` with an Array of face names gives a fallback chain; always null-check and fall back to `drawText` at fixed positions.
- Render the ring once per day into a cached bitmap — vector text is comparatively expensive.

### Gaps
- Face names available on FR965 (e.g. "RobotoCondensedBold") not confirmed from a primary source fetched here.

## 5. Weather current + hi/lo, sunrise/sunset

### Takeaway
`Weather.getCurrentConditions()` (3.2.0) gives temperature, highTemperature, lowTemperature, condition (Celsius, nullable); `Weather.getSunrise/getSunset(location, moment)` (3.3.0). Use `observationLocationPosition` as the location so no GPS permission is needed for sun times.

### Cited Findings
- `getCurrentConditions()` returns most recently cached conditions or null; `getDailyForecast()`, `getHourlyForecast()` (3.2.0); `getSunrise/getSunset(Position.Location, Time.Moment)` (3.3.0); 54 condition constants 0–53 — [Toybox.Weather](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather.html)
- CurrentConditions fields: temperature, highTemperature, lowTemperature (°C), condition, feelsLikeTemperature, observationLocationPosition (null without position permission), observationTime (UTC), precipitationChance, relativeHumidity, windSpeed (m/s), windBearing; 5.1.0 adds cloudCover, dewPoint, pressure (Pa), uvIndex, visibility; observationLocationName deprecated — [CurrentConditions](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather/CurrentConditions.html)
- Alternatives via complications: CURRENT_WEATHER 8, CURRENT_TEMPERATURE 38, HIGH_LOW_TEMPERATURE 39, SUNRISE 13, SUNSET 14 — [Complications](https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html)
- Segment34 caches weather for offline use, using forecast values up to 12 h — [Segment34mkII](https://github.com/ludw/Segment34mkII)

### Inferences
- Convert units with `System.getDeviceSettings().temperatureUnits`; every field can be null — guard each.
- Compute sunrise/sunset once per day (or when location changes), not per update.
- Using SUNRISE/SUNSET complications avoids location handling entirely and gives exitTo to the native sunrise glance.

### Gaps
- Whether observationLocationPosition requires the Positioning permission on watch faces specifically (doc says null without permission) — confirm in sim.

## 6. AMOLED always-on (AOD) rules for FR965

### Takeaway
In `onEnterSleep` switch to a low-power render: ≤ ~10% of pixels lit, no pixel lit > 3 minutes (shift layout each minute), thin/outline fonts, no seconds; `onUpdate` comes once per minute in low power. `DeviceSettings.requiresBurnInProtection` tells you the device enforces this (it is always true on AMOLED, not a mode indicator).

### Cited Findings
- CIQ 3.1 release notes (quoted): AMOLED faces don't get MIP-style partial updates; in sleep they may render low-power with ~10% of pixels lit and no pixel lit > 3 minutes; prevent burn-in with a thin font and shifting the time every minute; detect via `requiresBurnInProtection` — [forum: always-on for Venu/AMOLED](https://forums.garmin.com/developer/connect-iq/f/discussion/192673/how-to-enable-an-always-on-mode-for-venu-amoled)
- `requiresBurnInProtection` always returns true on AMOLED regardless of power mode; it does not check compliance. Sim burn-in warnings reported during high→low transition — [forum: AMOLED high to low transition](https://forums.garmin.com/developer/connect-iq/f/discussion/287537/amoled-high-to-low-power-mode-transition-in-sim-triggers-burn-in/1386518)
- `onEnterSleep`/`onExitSleep` (1.0.0): stop timers and prepare for once-per-minute updates; high power = onUpdate every second; low power = onUpdate top of minute; `onPartialUpdate` (2.3.0, needs setClip) and `onPowerBudgetExceeded` apply to partial updates — [WatchFace](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html), [WatchFaceDelegate](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFaceDelegate.html)
- Segment34 practice: AOD text always in dot font to prevent burn-in; outline-only clock style for AOD; AOD with all fields is opt-in — [Segment34mkII](https://github.com/ludw/Segment34mkII)

### Inferences
- Pattern: `onEnterSleep(){ lowPower=true; WatchUi.requestUpdate(); }` / `onExitSleep(){ lowPower=false; ... }`; in onUpdate when lowPower: `dc.setColor(BLACK,BLACK); dc.clear();` then draw outline time + few data at `offset = (minute % N)` px shift (e.g. ±4–8 px cycle).
- Big filled arcs/gauges and bright backgrounds must be dropped in AOD; a full-screen BufferedBitmap blit will blow the 10% budget.
- Use the sim's "Display burn-in" checker (Settings > Low power mode) to verify.

### Gaps
- No current official Garmin page with the numeric rules was fetched (forum quote of 3.1 notes only); the core-topics watch face URL 404'd. Whether a user-visible AOD toggle setting is required for store approval was not found.

## 7. On-device settings (getSettingsView + Menu2) vs Connect IQ app settings

### Takeaway
Two complementary channels: properties/settings XML (edited in Connect IQ phone app/Garmin Express) and `AppBase.getSettingsView()` returning `[Menu2, Menu2InputDelegate]` shown via the watch face "Customize" entry. A watch face can't bind its own button delegate to open a menu.

### Cited Findings
- Put `getSettingsView()` in the AppBase subclass; firmware calls it and pushes the returned view+delegate; reached by holding UP > watch face > Customize; XML settings are shown in the phone app/Garmin Express — [forum: settings on WatchFace](https://forums.garmin.com/developer/connect-iq/f/discussion/406273/settings-on-watchface-not-working/1910203)
- Flow is multi-step on some devices; one dev pushed Menu2 directly from the settings view; sim behaves differently from device; exiting by popping views twice worked on hardware; watch faces can't use a button delegate to open a menu — [forum: CIQ 3.2 wow](https://forums.garmin.com/developer/connect-iq/f/discussion/235958/ciq-3-2---wow/1120987), [forum: on-watch screen menus](https://forums.garmin.com/developer/connect-iq/f/discussion/348162/documentation-or-example-for-on-watch-screen-menus/1679233)
- Popular faces (Segment34) rely on Garmin-app settings plus a web theme designer producing pasteable codes — [Segment34mkII](https://github.com/ludw/Segment34mkII)

### Inferences
- Write via `Application.Properties.setValue()` from the Menu2 delegate, then call your shared `onSettingsChanged()` path so both channels converge. Keep the on-device menu to the high-value items (style, slot types, accent colour); leave long lists in phone settings.
- `WatchFaceDelegate.onWatchFaceConfigEdited` hints at a newer native config flow, but its device list is narrow — don't rely on it for FR965 without checking.

### Gaps
- Official "Watch face settings" core-topic not retrieved.

## 8. Performance: buffers, caching, AA, fonts

### Takeaway
`Graphics.createBufferedBitmap` (4.0.0) allocates in the shared graphics pool (not app heap); create once, reuse, use small palettes where AA isn't needed, and catch `OutOfGraphicsMemoryException`. Cache static layers (ticks, gauge tracks, weekday ring) and redraw only dynamic layers.

### Cited Findings
- `createBufferedBitmap({:width,:height,:palette,:colorDepth,:bitmapResource,:alphaBlending})` returns `BufferedBitmapReference`, API 4.0.0; palette ≤256 colours, smaller palette = smaller bitmap; `ALPHA_BLENDING_PARTIAL` may differ between device and sim; `OutOfGraphicsMemoryException` exists — [Graphics](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics.html)
- On CIQ 4+ buffered bitmaps live in a graphics pool shared between apps; multiple faces crashed with out-of-memory when becoming visible again (after Morning Report / activity); creating buffers once and reusing them stopped crashes in a test app; nulling in onHide/onStop did not fix it — [forum: OOM crashes](https://forums.garmin.com/developer/connect-iq/f/discussion/320323/multiple-watch-faces-crashing-simultaneously-with-out-of-memory-error-minimal-repro-app-included/1801132)
- AA not supported on paletted BufferedBitmap; `setClip/clearClip` 2.3.0; `drawBitmap2` 4.2.1 with tint/transform — [Dc](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html)
- `BLEND_MODE_MULTIPLY/ADDITIVE` (4.2.1) only on GPU devices — [Graphics](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics.html)
- Vector fonts: `getVectorFont` 4.2.1, `:scale` 5.1.0+ — [Graphics](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics.html)
- Watch-face memory is tight; Segment34 disables its cache on very low-memory devices and reduced CPU and storage writes for battery — [Segment34mkII](https://github.com/ludw/Segment34mkII)

### Inferences
- `BufferedBitmapReference` must be `.get()`-ed to a `BufferedBitmap` before drawing; hold the reference, not the resolved object, across updates.
- Partial updates are irrelevant on FR965 AOD (AMOLED gets full minute updates), so optimise onUpdate cost and AOD pixel count instead.
- Avoid `Storage.setValue` on every update (flash wear/battery); cache in memory, persist on change.

### Gaps
- FR965 watch-face heap limit and graphics-pool size not found on the devices page (likely in SDK `compiler.json`/device files — check locally in SDK Manager device folder).

## 9. Connect IQ Store presentation

### Takeaway
Official guidance covers only icon/store assets (500x500 px sRGB); everything else is community practice: square, framed device screenshots, small file sizes, test against light app background.

### Cited Findings
- Brand guidelines: store asset 500x500 px, sRGB; the app icon is the most effective promotional asset — [Connect IQ brand guidelines](https://developer.garmin.com/brand-guidelines/connect-iq/)
- Forum-reported limits: cover images & icons 500x500 max 300 KB; screen images max 150 KB; non-square images are distorted without warning — [forum: image size limitations](https://forums.garmin.com/developer/connect-iq/f/connect-iq-web-store/427625/i-want-nice-things-reasonable-image-size-limitations/2039453)
- A 1440x720 hero image was not shown in the store (unresolved) — [forum: Hero Image not shown](https://forums.garmin.com/developer/connect-iq/f/discussion/325554/hero-image-not-shown)
- Sim screenshots capture only the canvas; devs composite onto a watch frame; make area outside watch transparent; the CIQ app background is now white — [forum: screenshots with watch frame](https://forums.garmin.com/developer/connect-iq/f/discussion/289275/how-to-take-screenshots-with-watch-frame-for-the-store/1527987)

### Inferences
- For an All Stars-style listing: lead icon = the face itself in a device frame; screenshots should show each style (digital/analog/hybrid), AOD mode, and the settings/slot options, each square and < 150 KB.
- Description: list supported complications and the tap-to-open behaviour; changelog-style updates (as Segment34 does) build trust.

### Gaps
- No official hero-image spec or description guidance found; no data on what drives All Stars' ranking specifically.
