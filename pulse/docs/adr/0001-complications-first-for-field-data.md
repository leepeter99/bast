# Complications first for field data

Field readings come from `Toybox.Complications` wherever a complication type exists: Body Battery, recovery time, weather/temperature, sunrise, stress and heart rate. Readings without one use direct APIs: `UserProfile` for resting HR, `ActivityMonitor` for steps, calories, distance and the step goal. We chose complications because the docs contradict each other on whether watch faces may use `SensorHistory`, which is the direct Body Battery route. `Weather.getSunrise` needs a location, and the complication doesn't. And a null complication value maps straight onto the Unavailable state.

## Consequences

- Needs the `ComplicationSubscriber` permission and API 4.2+. The FR965 is at 5.2.
- Whether a complication actually returns data depends on device firmware, so check every field on a real FR965.
- Sleep duration has no API on FR965 (Sleep Score needs API 6.0.2), so Stress replaces Sleep.
