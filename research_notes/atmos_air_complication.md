# Atmos Air Quality: can Pulse read its complication?

Researched 2026-10-31. Short answer: **yes, the developer says so.** Atmos Air Quality (developer "TitanicTurtle") publishes an AQI complication for watch faces. Its long label is `AtmosAirAQI`, and the store lists all ten Pulse targets as compatible. Pulse would have to find it by iterating `Complications.getComplications()` and matching the long label. The current `Fields.complication(type)` helper can't reach it, because it builds an `Id` from a native type.

Note: the app is named **"Atmos Air Quality"**. The homepage is https://gapps.orcatec.net/atmosair. That page is a JavaScript SPA, and its text lives in the site bundle `https://gapps.orcatec.net/gapps2/main.a304530771e82a8c9029.js` and in the product API `https://gapps.orcatec.net/api/products.php` (record id 40, `apiName: "AtmosAirQuality"`). The quotes below are taken from those two sources and from the store's JSON API.

Sources:

- [S1] Developer homepage: https://gapps.orcatec.net/atmosair. Rendered text is in the bundle above; keys are under `aqpro.*` and `atmosair`.
- [S2] Connect IQ store listing: https://apps.garmin.com/apps/b9a3f779-5272-4b44-bc21-7ba1c65fa5e9. Raw data: https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/b9a3f779-5272-4b44-bc21-7ba1c65fa5e9
- [S3] Garmin Core Topic "Complications": https://developer.garmin.com/connect-iq/core-topics/complications/. The page is JS-rendered, so I read the identical copy shipped in SDK 9.3.0: `doc/docs/Core_Topics/Complications.html`.
- [S4] Garmin API docs, Toybox.Complications: https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html. The SDK copy is `doc/Toybox/Complications.html`.
- [S5] Complication class: https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications/Complication.html
- [S6] Id class: https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications/Id.html
- [S7] Iterator class: https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications/Iterator.html

---

## 1. What Atmos Air Quality publishes

### Confirmed from source

- **It publishes complications.** The store description [S2] says:
  > For developers:
  > -- This app publishes complications for use in watch faces
  > - "AtmosAirAQI": Current air quality index (EU or US index, depending on user selection)
  >    -> Includes the "range" indicating where this value lies.
  > - "AtmosAirTs": UTC timestamp of the current value
  > -- Long label: "AtmosAirAQI"

  The homepage settings tab "Complications" [S1] repeats the same text word for word (`aqpro.settings.comp.*`). The homepage feature list [S1] adds: "Complications for watch faces with the AQI and the time of the last update."
- **Store permissions** [S2]: `["Communications", "ComplicationPublisher", "Positioning", "Background"]`.
- **Value: an AQI number on one of two scales, chosen by the user.** The homepage [S1] says: "European or US. Affects the number, colours and category labels everywhere (main view, charts, glance, complications)." It also warns: "Do not mix the two numbers. An '80' on the EU scale is not the same as an '80' on the US scale."
  - The homepage "EU vs US index" tab [S1] gives the category bands for each scale:

    | European AQI (EAQI) | Category | US AQI (EPA) | Category |
    |---|---|---|---|
    | 0–20 | Good | 0–50 | Good |
    | 21–40 | Fair | 51–100 | Moderate |
    | 41–60 | Moderate | 101–150 | Unhealthy for Sensitive Groups |
    | 61–80 | Poor | 151–200 | Unhealthy |
    | 81–100 | Very Poor | 201–300 | Very Unhealthy |
    | 101+ | Extremely Poor | 301+ | Hazardous |

  - On gauge scaling, the homepage [S1] says: "EU typically runs with lower absolute numbers (gauge ends around 120). US AQI commonly goes up to 300+ on the gauge."
- **The complication carries `ranges`.** Per [S2], it "Includes the 'range' indicating where this value lies". Garmin defines ranges as "An optional array of numeric values. Ranges allow breakdowns of sets of values" [S3]. These are presumably the category thresholds of whichever scale is active (see Unknown).
- **The complication does not carry PM2.5.** PM2.5, PM10, O3 and the other pollutants appear only on the app's own pages [S1]. The only published values are the AQI and the timestamp.
- **Update frequency** [S1]: "How often the background service should refresh (minutes). Minimum 10, maximum 720. Default 60." "Force update" in the watch menu loads data immediately [S1].
- **Data path** [S1]: "Internet requests go through the paired phone." The store says "If there is no internet connection, the forecast values for the next 32 hours are cached" [S2].
- **Devices.** The store lists 249 devices [S1 products API, `supportedDevicesCount`]. I checked the store's `compatibleDevicePartNumbers` [S2] against the SDK's `compiler.json` part numbers. All Pulse targets are included: fr965 (006-B4315-00), fr970 (006-B4565-00), fenix843mm, fenix847mm, fenix8pro47mm, fenix943mm, fenix947mm, fenix9pro43mm, fenix9pro47mm and fenix9pro51mm.
- **Version.** 1.1.4 was released 2026-10-10. Per the store [S2], the app "is currently in beta phase".

### Unknown / not documented

- **The short label.** It isn't documented anywhere. Don't match on it.
- **Whether "AtmosAirAQI" and "AtmosAirTs" are two complications or one.** The text lists them separately but gives a single "Long label". The likeliest reading is two complications, with long labels `AtmosAirAQI` and probably `AtmosAirTs`, but only `AtmosAirAQI` is stated as a long label.
- **The `access` level** (public, protected or private). Pulse is signed with a different developer key, so it can see the complication only if it is `public` [S3]. The developer writes "for use in watch faces", which implies public, but the access level itself is never stated.
- **The `unit` field.** It isn't documented. AQI has no unit, so expect `null`.
- **The value's type.** Number or Float isn't stated, and neither is how "no data yet" is represented (likely `null`).
- **The exact `ranges` array contents**, and whether they change when the user switches between EU and US.
- **Whether the complication tells you which scale is active.** Nothing documented does, apart from what the `ranges` might imply.
- **The `AtmosAirTs` timestamp format.** "UTC timestamp" is all it says: presumably Unix seconds as a Number, but unconfirmed.
- **Developer forum posts.** I searched and found none on forums.garmin.com about this complication.

## 2. Documented way for other faces to consume it

### Confirmed from source

- The only consumer instructions are the "For developers" block quoted above [S1, S2]: match the long label `"AtmosAirAQI"`.
- The developer's sibling app, Atmos Weather, uses the same mechanism with labels `AtmosWeather 1..3` [S1]. Its help text says "The background service updates glance and complications also when the app is closed", so the pattern is consistent across the developer's apps.

### Unknown / not documented

- There is no "works with" list of watch faces.
- There are no user-facing instructions for picking the complication in a face's complication slot.

## 3. How a watch face reads a third-party complication (Garmin docs)

Confirmed from source:

- **Permission.** "To subscribe to a complication you need to add the `ComplicationSubscriber` permission to your manifest file." [S3] Pulse already declares it (`pulse/ciq/manifest.xml`).
- **Only watch faces can subscribe.** "Connect IQ device apps and audio content providers can publish complication data, but only watch faces can subscribe to complication information." [S3]
- **Discovery.**
  - "You can use `Complications.getComplications()` to query the all complications supported by the system. You can also query a native complication directly by constructing a `Complications.Id` explicitly … **This only works for native complications.**" [S3]
  - `getComplications() as Complications.Iterator`: "Provide an iterator over complication id that we have access to". Since API Level 4.2.0 [S4].
  - `Iterator.next() as Complications.Complication or Null`: "Next complication instance or null on completion". Since API Level 4.2.0 [S7].
  - `Id` has only `initialize(id as Complications.Type)`, `getType()` and `equals()` [S6]. You can't construct an Id for an app complication, so you have to take it from the iterator.
- **Type.**
  - `Complication.getType()`: "For native complications, returns the `COMPLICATION_TYPE`. Will return `COMPLICATION_TYPE_INVALID` for Connect IQ complications." [S3]
  - The class page says "Returns COMPLICATION_TYPE_INVALID for user complications." [S5]
- **Fields** [S3, S5]. All are Since API Level 4.2.0.
  - `complicationId` (`Complications.Id`)
  - `longLabel`: "A textual name for the complication. The long label is intended for display in a configuration menu."
  - `shortLabel`: "A five-character string intended to summarize your complication as a radial complication."
  - `ranges`: "An optional array of numeric values."
  - `unit`: "If this is `null` then the unit shouldn't be displayed … If the unit is a string, the value should be interpreted without conversion."
  - `value`: "A string or numeric value describing the value to be displayed to the user".
  - Typedefs [S4]: `Label as Lang.String`. `Value as Lang.String or Complications.RangeValue`. `RangeValue as Lang.Number or Lang.Float or Lang.Long or Lang.Double`. `Ranges as Lang.Array<Complications.RangeValue>`.
  - Publisher side [S3]: `:ranges => newRanges` is an "Array<Numeric> with at least 3 elements".
- **Persisting the Id.** "Once you have the complication id, you can persist the id in storage for later use." [S3]
- **Subscriptions** [S3, S4].
  - The calls are `registerComplicationChangeCallback(callback)` and then `subscribeToUpdates(id) as Lang.Boolean`. The docs say: "Information is sent to registered ComplicationChangedCallback method. Make sure you have registered your change callback."
  - `subscribeToUpdates` throws `OperationNotAllowedException` ("too many active subscriptions") or `ComplicationNotFoundException`.
  - "All subscriptions are terminated when your app shuts down and must be re-done when your app is launched." [S3]
  - Plain `getComplication(id)` without a subscription is also valid. That's what Pulse does today for native types.
- **Removal.** "If the complication is no longer available, for example the user has uninstalled the publishing app, the system will throw a `Complications.ComplicationNotFoundException` … If a publishing app is uninstalled, the system will send an event to your ComplicationChangeCallback and automatically unsubscribe your app" [S3].
- **Visibility.** Publishers set `access` to `public`, `protected` or `private`:
  - `public`: your apps, Face It and all apps.
  - `protected`: your apps and Face It.
  - `private`: only apps with the publisher's developer key.

  For a third-party face like Pulse, only `public` is visible [S3].
- **Hold to launch.** `Complications.exitTo(id)` "Launches the app associated with the complication", wired through `WatchFaceDelegate.onPress()` [S3, S4].
- **Minimum API level.** The whole module is Since API Level 4.2.0 [S4]. Pulse's `minApiLevel` is 4.2.1, so that's fine. Supported devices include Forerunner 965, Forerunner 970, fēnix 8 and fēnix 9 [S4].

## 4. Limitations and caveats

Confirmed:

- **Phone required for fresh data** [S1]. Without a connection the app serves up to 32 hours of cached forecast [S2], so the value can be stale. `AtmosAirTs` exists so a face can judge staleness [S2].
- **Updates come from the app's background service.** Default every 60 minutes, configurable from 10 to 720 [S1].
- **The value's meaning depends on a user setting** (EU vs US) that the face can't read directly [S1].
- **No PM2.5 or individual pollutants** are published [S1, S2].
- **The app is in beta** [S2].
- **Only Connect IQ apps publish; only watch faces subscribe.** The system limits active subscriptions [S3, S4].
- **The complication disappears if the user uninstalls the app** [S3].

Unknown:

- Whether the value is `null` before the first successful fetch, or after the cache expires.
- The exact behaviour on fēnix 9 and FR970 firmware. Nothing device-specific is documented beyond the store compatibility list.

## Implications for an Air gauge in Pulse

- **Discovery.** `Fields.complication(type)` (`pulse/ciq/source/Fields.mc:107`) can't reach this complication, because it builds `new Complications.Id(type)` and that "only works for native complications" [S3]. Instead:
  1. Iterate `Complications.getComplications()`.
  2. Keep the complication where `getType() == COMPLICATION_TYPE_INVALID` and `longLabel.equals("AtmosAirAQI")`.
  3. Cache its `complicationId` in `Application.Storage`.
  4. On later reads, use `getComplication(id)` and catch `ComplicationNotFoundException`, then re-scan or show `--`.
- **Match on the long label `AtmosAirAQI` exactly.** Don't match on the short label, which is undocumented.
- **Value type.** Accept Number or Float. A String or `null` should give `--`, which is what the existing `complication()` type filter already does.
- **Gauge scale.** Prefer the published `ranges`:
  - If `ranges` is non-null, use its last element as full scale. That adapts to EU or US automatically.
  - Without `ranges`, fall back to the developer's own gauge ends [S1]: about **0–120 for EU** and about **0–300 for US**.
  - If you can tell which scale is active, `ranges.size()` or its top value (≈100 vs ≈300) probably separates EU from US. That's unverified: check it on device or in the simulator with the app installed.
  - Clamp progress to 0..1, because EU can exceed 100 and US can exceed 300.
- **Display.** Show the number with no unit. `unit` is undocumented and AQI has none.
- **Staleness.** Optionally read `AtmosAirTs` the same way and grey out or hide the gauge if it's more than a few hours old.
- **Test before shipping.** Install Atmos Air Quality on a real target, then dump `longLabel`, `shortLabel`, `unit`, `value` and `ranges` from the iterator. That settles every item in the Unknown lists above, including whether access is `public` at all.
