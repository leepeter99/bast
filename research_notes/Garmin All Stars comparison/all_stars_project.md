# Garmin All Stars – fēnix 9 Chronos (the "All Stars" watch face in the screenshot)

Method note: the Connect IQ store pages are rendered client-side, so most facts below come from the store's public JSON API, which the store page itself calls:
- App metadata: `https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc`
- Reviews: `.../asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=N&pageSize=30`
- Screenshots: `https://apps.garmin.com/api/appsLibraryExternalServices/api/screenshots/{fileId}`
- Device names: `.../asw/deviceTypes`
- Series search: `.../asw/apps/keywords?keywords=Garmin%20All%20Stars&startPageIndex=0&pageSize=30`

All data was pulled on 2026-10-20. Store page: https://apps.garmin.com/en-US/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc

## Who makes All Stars and where is it listed?

### Takeaway
"All Stars" is not a single face from an indie developer. **Garmin All Stars** is Garmin's own series of paid Connect IQ faces that remaster the default faces built into its watches. The face in the screenshot is **"Garmin All Stars – fēnix 9 Chronos"**, published by Garmin. I matched it exactly against its first store screenshot: the Digital, Analog and Hybrid panels all carry the labels Top Left, Top Right, Left, Right, Bottom Left and Lower Center, with 15000 steps, 01 AUG and an S M T W T F S ring, 7:50, 88, 32° and 28°|33°, a stacked 10 10 with 38 seconds, and an orange/copper contour panel.

### Cited Findings
- Listing: "Garmin All Stars – fēnix 9 Chronos". The developer is shown as "Garmin" (`developerDisplayName: Garmin`, `trustedDeveloper: false`), and the support email is ciqapac.issues@garmin.com. The "apac" suggests a Garmin Asia-Pacific Connect IQ team, but that is an inference. — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- Price $4.99 USD (list and sale price are the same), with no trial mode. Version 2026.9.2.4 (internal version 5). 1,000+ downloads. Average rating 4.4 from 153 reviews. — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- First approved 2026-08-25. The latest version was released 2026-10-13. — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- Series concept, quoted from every All Stars description: "In the Garmin All Stars series, we remastered the default watch faces built in to our watches. The All Stars series brings the original experience to your new watch, with added customizations to make it uniquely yours." — [epix Pro listing API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/3544ce6b-4a97-4dab-965b-87ed79ad61df)
- Chronos is the remaster of a stock fēnix 9 face: "fēnix 9 Chronos brings together contour-map patterns, curved dimensional plates, and high-contrast data displays." One reviewer compares it to "the standard Chronos". — [Store API / reviews](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=0&pageSize=30)
- The series began around 2024-08-06, the first approval date of the epix Pro, epix Pro II and Forerunner 965 All Stars faces. As of October 2026 the store has about 27 entries, nearly all $4.99: fēnix 8 Iron Grit, fēnix 8 Pro Forge, fēnix 8 Pro Energize, fēnix 9 Chronos, Dynamo, Cluster and Uncharted, quatix 8 Deep Currents, Forerunner 965, Forerunner 970/570 Runners, Forerunner 170, Venu 3, Venu 4 Headline, Venu X1 Snapshot, vívoactive 6 Waves, tactix 7 Pro, tactix 8 Alpha and Delta, Instinct 3 Console, Descent Mk3, epix Pro, epix Pro II, epix (Gen 2) II, Approach S44 Driver and Approach S72 Golf Day. — [Store keyword search API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/keywords?keywords=Garmin%20All%20Stars&startPageIndex=0&pageSize=30)
- Sister faces with the same Digital/Analog/Hybrid layout system: fēnix 9 Dynamo (4480379c…), fēnix 9 Uncharted (6509de7f…) and fēnix 9 Cluster (9649aa52…), all first approved 2026-08-25. Also Forerunner 170 and Approach S72 Golf Day (first approved 2026-10-07). — [Dynamo](https://apps.garmin.com/en-US/apps/4480379c-8f49-4c8a-aae6-252cf11f2a87), [Uncharted](https://apps.garmin.com/apps/6509de7f-3e4d-40b3-b64b-2337e7d34b41), [Cluster](https://apps.garmin.com/apps/9649aa52-fafe-403e-bb62-f330d9e26940), [Golf Day](https://apps.garmin.com/apps/7cc1b1ac-20f8-40c5-aa36-d37320500f66)
- Tom's Guide (syndicated on Yahoo Tech) covers the series as paid ports of stock faces. The writer says the Forerunner 965 one is worth about $5 and the Iron Grit port is weaker than the original. — [Yahoo Tech / Tom's Guide](https://tech.yahoo.com/wearables/articles/review-garmin-living-5-favorite-103000841.html)
- Garmin Community threads describe the series as a "paywall" for faces that came free on older models. — [Garmin forum: Analog Iron Grit](https://forums.garmin.com/outdoor-recreation/outdoor-recreation/f/fenix-8-series/406944/analog-iron-grit-watch-face/1913656), [Garmin forum: New Garmin All Stars watch faces](https://forums.garmin.com/apps-software/mobile-apps-web/f/connect-iq-store-ios/380091/new-garmin-all-stars-watch-faces/1812714)

### Inferences
- The "phone app gallery" look of the screenshot is just the Connect IQ store's 550×800 screenshot format. It is not a Face It or Google Play companion app.
- Supported devices (40, mapped from `compatibleDeviceTypeIds`): Approach S70 42/47mm; D2 Air X15, Mach 1, Mach 1 Pro, Mach 2, Mach 2 Pro; Descent MK3 43mm and MK3i 51mm; Forerunner 170 and 170 Music, 265 and 265S, 570 42/47mm, 965; MARQ (Gen 2), MARQ Commander (Gen 2) Carbon, MARQ Aviator (Gen 2); Venu 3 and 3S, Venu 4 41/45mm; epix (Gen 2) ×2 entries, epix Pro 42/47/51mm; fēnix 9 43/47mm, fēnix 9 Pro 43/47/51mm; fēnix 8 AMOLED 43mm and 47/51mm, fēnix 8 Pro, fēnix E; tactix 7 AMOLED, tactix 8 47mm AMOLED; vívoactive 6. Every device on the list has an AMOLED screen, which suggests the face is AMOLED-only. No MIP fēnix 8 or Instinct appears. The Forerunner 970 is missing, which one reviewer also notes. — [deviceTypes API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/deviceTypes)

### Gaps
- No Reddit thread specifically about Chronos turned up. The forum threads I found cover the series in general.
- No developer website, GitHub or social account was found. `websiteUrl` is empty on the listing.

## What are the complications and the per-slot configurable options?

### Takeaway
There are six labelled data slots: Top Left, Top Right, Left, Right, Bottom Left and Lower Center. The face also has a fixed weekday ring, an hour-index bezel, and a time element that switches between Digital, Analog and Hybrid. Settings live in the phone's Connect IQ app. They cover Time Style, Digital Clock Font, a data field for each slot, hand style, gradient accents and "micro-color" controls. The store does not publish the full list of data options.

### Cited Findings
- Listing text: "supports three distinct layouts: Digital, Analog, and Hybrid. • Analog: The most classic Chronos layout. Realistic dimensional hands… • Digital: A cleaner information-first layout with large modern numerals. • Hybrid: A balanced, layered presentation where analog hands float above the digital time." — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- Listed customizations: "10 Digital Font Sets • 10 Analog Hand Styles • Custom Gradient Accents • Micro-Color Control • Customizable Data Fields • Dynamic Font Scaling". — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- What the store screenshots show (screenshots 1–4, viewed directly):
  - Top Left: steps "15000" on a segmented blue arc along the upper-left bezel.
  - Top Right: a circular subdial with the date ("01 / AUG") inside a weekday ring "S M T W T F S", with today highlighted in orange.
  - Left: a sunrise icon with "7:50".
  - Right: a battery icon in Digital and Hybrid (a small icon beside the big time), and a full subdial reading "100%" in Analog.
  - Bottom Left: a gauge-style icon with "88" on a segmented arc along the lower-left bezel, partly orange. It looks like Body Battery or recovery.
  - Lower Center: weather, "32°" with "28°|33°" low|high.
  - Time: stacked "10 / 10" with seconds "38" below in Digital and Hybrid. Hybrid adds orange-tipped skeleton hands on top.
  - Bezel: minute numerals 05–55 with orange index markers at 12, 3, 6 and 9.
  - Background: a copper/orange contour-map panel on the right.
  - Screenshot 2 says "3 Time Styles / 10 Font Styles / 10 Hand Styles" and shows a serif font option. Screenshot 3 shows it on a fēnix in "Device Display: Round".
  - — [Screenshot 1](https://apps.garmin.com/api/appsLibraryExternalServices/api/screenshots/c7395b18-664c-4579-ad79-21392f57ec1d), [Screenshot 2](https://apps.garmin.com/api/appsLibraryExternalServices/api/screenshots/a5745cf8-6711-4b48-8425-0218f5b1c267), [Screenshot 3](https://apps.garmin.com/api/appsLibraryExternalServices/api/screenshots/f34c50ad-3a4c-4250-ad8b-0538c5a0df95)
- Settings screenshot 4 ("How To Change Your Watchface?") shows the Connect IQ app settings list:
  - "★Time Style: Digital"
  - "Digital Clock Font (Available when Time Style is set to Digital / Hybrid.): 01-Elevon"
  - "★Top Left Data: Date"
  - "★Top Right Data: Battery Level in %"
  - "★Right Data"
  - Caption: "You can start by adjusting the ★ options."
  - — [Screenshot 4](https://apps.garmin.com/api/appsLibraryExternalServices/api/screenshots/e1ffaefa-1c50-4a62-bcde-b562893c9af8)
- The series' unsupported data list, which is identical in every All Stars description: Training Readiness, Training Status, Acute Load, Hill Score, Endurance Score, Active Calories, HRV Status, Tide, No Fly Time, Surface Interval. The listing gives the reason: "access to certain data is not supported by ConnectIQ watch faces." — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- The latest What's New reads: "You can now adjust the accent color on your watch." — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- Reviews point to these data gaps: no precipitation chance, weekly run or bike distance, timer, calendar/next appointment, wind direction or Training Readiness. Battery in Hybrid shows an icon only, with no percent and no days-left option. 24h digital time is missing in Hybrid. Days of the week cannot be set to another language. — [Reviews API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=0&pageSize=30)
- Reviews say the progress arcs do not track their values. "Progress bar for 2h recovery looks exactly the same as 30h". "The bottom arch never does anything. It's always full". "Most data did not harmonise with the data progress bars". In German: the blue bars don't work for every category, for example pulse. — [Reviews API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=0&pageSize=30)
- One review says the seconds digits and the seconds hand can only be shown or hidden together, not separately. — [Reviews API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=0&pageSize=30)
- Mode switching: a 2026-08-25 review says "Being able to switch between different time styles is really useful… I can switch them directly on the watch… A few options still need to be set on the phone." Reviews from 2026-10-17 to 19, on v2026.9.2.4, say instead that settings are missing ("Where is the setting options!?", "No setting option"). One says: "until they removed the ability to customize it… the QR code redirects you to the IQ app where you're unable to make any further changes." — [Reviews API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=0&pageSize=30)
- Related series feature: the epix Pro and epix Pro II All Stars What's New lists "Hold data to open glance" and "Low power mode display in Always On mode". — [epix Pro API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/3544ce6b-4a97-4dab-965b-87ed79ad61df)

### Inferences
- The bezel arcs seem to be drawn as a fixed or decorative fill instead of being scaled to each metric's value, at least for some metrics. Several independent reviews say so.
- The mode switch is a single "Time Style" enum setting with values Digital, Analog and Hybrid. The font setting applies only in Digital and Hybrid; hand styles apply in Analog and Hybrid.
- The default slot mapping in the settings screenshot (Top Left = Date, Top Right = Battery %) does not match the marketing image (Top Left = steps, Top Right = date). So slots take any data type, and the screenshots show one particular configuration.

### Gaps
- The full enum of data options per slot isn't public. The store does not expose the settings schema, and no manual page exists for the CIQ version. Getting it would mean installing the face and opening Connect IQ settings.
- Whether a separate "Upper/Bottom Right" slot exists in some modes. Chronos screenshots show only six labels.

## How does it handle always-on/low-power mode, AMOLED burn-in and battery?

### Takeaway
Garmin's only published notes are boilerplate. AOD is AMOLED-only and "reduces brightness and hides certain animations (such as the seconds)". The face is said to be "optimized for performance". No battery-life numbers are given. Users report a very dim AOD and lag or slow wake.

### Cited Findings
- From the listing: "Always-On Display (AOD): Only available on AMOLED models. Can be configured in Display settings. When enabled, instead of turning off, the screen reduces its brightness and hides certain animations (such as the seconds) after the selected timeout." — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- From the listing: "AMOLED Displays: Images are more vibrant with higher contrast. Brightness increases under strong light, which may slightly increase battery consumption." It also says: "Complex animations or displaying more data can slightly increase battery consumption. Some older models may experience a brief rendering delay when switching between screens." — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- The FAQ answer on battery: "This watch face is optimized for performance and will not significantly drain the battery under normal use. If you experience abnormal battery drain, please update your watch firmware. Some older versions with third-party watch faces had battery issues, which has been fixed by Garmin." — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- Review (2★, 2026-09-02): "The Always-On Display is terribly dim and basically unusable." — [Reviews API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=0&pageSize=30)
- Reviews on performance: "laggy and needs a few more seconds to wake up with a gesture than the standard Chronos". "A big laggy on my fenix 9 pro inreach". In Chinese: the second hand stutters and moves unnaturally. — [Reviews API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=0&pageSize=30)
- The Forerunner 170 All Stars changelog reads "Fixing watchface lag issue on the Forerunner 970". Lag is a known issue across the series. — [FR170 listing](https://apps.garmin.com/apps/6a53acfa-53c1-4511-aba3-1316aa4cfe9b)

### Inferences
- Burn-in is handled by dimming the AOD and dropping the seconds. There is no mention of pixel shifting or an outline-only AOD. The dim AOD that reviewers complain about is consistent with a dimmed render of the full face, though the screenshots don't show the AOD.

### Gaps
- There are no battery-life figures (hours or % per day) from Garmin or from users.
- No AOD screenshot or burn-in technique is documented.

## What do users praise and complain about?

### Takeaway
Ratings skew positive: 4.4 average, with 107 five-star and 23 four-star reviews out of 153. Users praise the looks, the polish and the depth of customization. Complaints cluster in five areas: progress arcs that don't track their values; a limited data set for $4.99; tedious phone-only configuration, with a settings regression in October 2026; dim AOD and lag; and stale notification counts.

### Cited Findings
- All points below come from the [Reviews API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc/reviews?startPageIndex=0&pageSize=30) (pages 0–150):
  - Rating distribution: 5★ 107, 4★ 23, 3★ 10, 2★ 5, 1★ 8.
  - Praise: "Very customizable!", "Great watch face, very polished", "a background that makes it look expensive", "Very elegant". In Polish: every parameter can be defined, including color, font and hand type. In Dutch: it's nice to "upgrade" a fēnix to the latest model for $5.
  - Data complaints: "for such poor data set it is not worth the price" (no weekly running distance, no training readiness); "So few data to select from - no biking".
  - Config friction: "change on phone > save settings > see change on watch. Tedious". Users want to see a preview of each option in settings. "I wish it can change all the watch face settings in the watch itself." In Dutch, a 1★ review: too many settings, and the user can't reproduce the brown color from the ad.
  - October 2026 regression: several 1★ reviews on v2026.9.2.4 say there are no settings at all. One is in Japanese: the "Settings" mentioned in the quick start can't be found.
  - Notifications: the count doesn't reset once read, unlike the stock fēnix 9 faces. One review says "shocking customer service".
  - Feature requests: separate seconds-hand and seconds-digit toggles; disappearing hands on long-press, a feature on stock faces; 24h in Hybrid; battery % next to the icon; wind direction; timer; calendar; more color themes.

### Inferences
- The most common technical complaint is the static progress arcs. A cloning or comparison project could stand out by scaling each arc to its metric's real range.

### Gaps
- No Reddit discussion specific to Chronos was found. The developer replies field (`replies`) was empty on the reviews I sampled.

## Is source code available?

### Takeaway
No. This is a closed-source, first-party paid Garmin product. No GitHub repository was found. Implementation details can only be inferred from the listing's permissions and behavior.

### Cited Findings
- The listing has no `websiteUrl` and no linked repository. The developer is Garmin. — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- Declared permissions: Positioning, ComplicationSubscriber, SensorHistory, UserProfile. — [Store API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/f22c1ef4-7c51-4943-981f-fd181801f2fc)
- Versions use date strings (2026.7.1 → 2026.9.2 → 2026.9.2.4), and some sister faces ship "_RC" builds, for example quatix 8 at 2026.8.7_RC4 and fēnix 9 Uncharted at 2026.9.2_RC3. — [quatix 8 API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/5bb31fe8-29c6-462d-8d64-0841ef66a90b), [Uncharted API](https://apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/6509de7f-3e4d-40b3-b64b-2337e7d34b41)
- A web search for "All Stars" Chronos returned no GitHub or third-party code, only unrelated Chrono-style faces. — [Garmin forum: Chrono Style Watchface](https://forums.garmin.com/developer/connect-iq/f/showcase/5056/chrono-style-watchface)

### Inferences
- `ComplicationSubscriber` means the face reads data through the CIQ `Toybox.Complications` API, which needs CIQ 4.2 or later. That is likely how it gets weather, sunrise, Body Battery and recovery time. It also fits the series' "Hold data to open glance" feature, which launches a complication's glance on a long press.
- `SensorHistory` likely provides Body Battery, stress and heart-rate history. `Positioning` is for sunrise/sunset location. `UserProfile` is for goals and units.
- The on-watch Time Style and accent-color switching suggests on-device watch-face settings (a menu exposed by the face), alongside phone-side properties.

### Gaps
- No source, decompilation or developer write-up is available. Techniques such as buffered bitmaps or AOD rendering can't be confirmed.
