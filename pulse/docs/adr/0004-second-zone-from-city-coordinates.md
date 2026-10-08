# Second zone from city coordinates, with a custom-offset escape hatch

Connect IQ has no API that takes an IANA zone ID. So each second-zone city is stored as a code plus a latitude/longitude, and the watch gets the local time and daylight saving from `Gregorian.localMoment(location, moment)` (API 3.3, FR965 supported). We rejected two alternatives: bundling and maintaining a DST rules table, and offering only a user-set offset, which goes wrong twice a year. For cities not on the list, a "Use custom zone" switch overrides the city with a fixed offset in minutes (−720 to +840) and a 3-character label, without daylight saving. If `localMoment` returns null, the field shows Unavailable.

## Consequences

- The docs don't say how accurate `localMoment` is or whether it works offline. Before release, test each city across its DST changeover dates on a real FR965.
- Adding a city means one list entry plus a coordinate.
