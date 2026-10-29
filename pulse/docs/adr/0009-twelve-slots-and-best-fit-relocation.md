# Twelve slots, and relocation to the slot where gauges grow largest

This supersedes the six-slot ring in ADR 0006. The ring now has twelve slots, one per hour position, and the homes are slots 0, 4 and 8 (still top, lower right and lower left). A relocated field used to go to the nearest free slot, often next to a neighbour where both gauges stayed at the minimum size, while a wide gap between the hands stayed empty. Now it tries each free slot, nearest home first, and picks the one where the gauges placed so far grow largest in total. A farther slot wins only by more than 3 px. ADR 0002 still holds: home first, keep the current relocation slot until it is blocked, and count a slot as free only if it is clear this minute and the next.

## Consequences

- Taking a slot also closes both neighbours, so gauges are always at least two slots (133 px) apart and never overlap at r 53.
- Across a full 24 hours, the mean gauge radius rises from 67.4 to 71.8 px at 454 px. The minimum is still 53 (ADR 0012 later raised it to 64 for the Date gauge). The layout test now checks that gauges never overlap and prints these figures.
- Candidate slots are scored with `Layout.grow`, a 6-step binary search per gauge, not the full `fit`. Running `fit` once per candidate tripped the device watchdog in the simulator. The new code ran in the simulator across about 120 different minutes without tripping it.
- Stored `last` slots from before the change are numbered for six slots. They are read as slots on the twelve-slot ring, so the first update after an upgrade may move a gauge once.
