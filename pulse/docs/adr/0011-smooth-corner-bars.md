# Smooth corner bars, cells only for Move alert

This changes the bar shape in ADR 0005. Steps, Body Battery, Recovery, Stress and Floors climbed now fill one smooth arc instead of ten cells, so the fill shows the real value to the nearest degree of the span rather than in 10% steps. Move alert keeps its five cells, because Garmin reports it as a level from 0 to 5 and ADR 0007 uses the cells themselves (the drained outlines and the running white segment).

## Consequences

- The fill is still drawn in whole degrees, because `drawArc` truncates: about 1.5% of a 68 degree track.
- The Move alert level is now read on every update, so the bar drops as soon as Garmin's own alert fires. Steps for "KEEP GOING" are still sampled once a minute.
