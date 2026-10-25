# Corner bars at the edge, and a Hybrid time style

The face drops its bezel rings and chapter ring, including the compass style, which never tracked heading. Four segmented bars now run along the edge, in the spans 280–350, 10–80, 190–260 and 100–170 degrees clockwise from 12. Each corner shows Steps, Body Battery, Move alert or Recovery, or nothing. These four metrics only appear on bars, so the gauge picker no longer offers them. The layout follows Garmin's fēnix 9 Chronos, where steps and Body Battery sit on bezel arcs. Unlike Chronos, the fill always tracks the real value. Minute ticks show only where no bar is drawn.

The Hybrid time style draws stacked hours, minutes and seconds right of centre, under the hands. The right gauge is dropped, and `Layout.assign` treats slots 1–3 as closed, so the three remaining gauges never relocate onto the digits. ADR 0002 still holds inside the open slots.

## Consequences

- Recovery fills as it runs down, against its peak: the highest recovery seen since it last reached 0 h. A top-up below the peak makes the bar lose ground; a top-up above it becomes the new peak and empties the bar. The peak is saved with its time, so a reload doesn't fake a fresh workout, and a saved peak below the current reading is replaced. At 0 h the bar is full, the label reads RECHARGED, and the peak clears. A fixed 96 h scale was rejected because 18 h of recovery would already show 8/10 full right after a workout.
- Move alert drains instead of filling, so every bar reads full = good: 5 purple segments at level 0, then one fewer per level, amber, with a single red segment at level 5. Garmin's own bar fills red; we chose consistency with the neighbouring bars over familiarity. Garmin exposes only the level (0–5), never its reset rule, so "KEEP GOING" is inferred from at least 60 steps in the last minute while the level is above 0, and "RESET" is shown for 5 minutes after the level drops to 0.
- Spans and segment widths are whole degrees, because `drawArc` truncates its angles.
- The bars sit at the screen edge (r 206–222), with their labels at r 193. Gauges may grow up to `Layout.EDGE` (r 186) in 20 steps, as far as the hands and their neighbours allow, so gauges and labels never need to dodge each other.
- Stored `field` values that point at a bar metric fall back to that position's default gauge.
