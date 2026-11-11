# Fixed homes, with Pulse's bars and data

Ingwe keeps four fields at fixed homes (top, right, bottom, left) and lets the hands pass over them, unlike Pulse, whose three fields relocate out of the hands' way. A face whose data never moves is the point of Ingwe, so Pulse's slots, relocation and hidden fields are deliberately not ported. Everything else Pulse has learned is: smooth corner bars with icon labels, bars brightening and shining as they fill, Stress filling with stress, the drained Move cell breathing, Rest, Recovery and Air quality as gauges, the accent picker on the watch, the whole-face accent recolour, the no-duplicate fallback for stale settings, and the recovery peak and sun event fixes. Ingwe keeps its own purple and plum palette on plain black.

## Consequences

- Pulse ADRs 0001, 0003, 0004, 0005 (corner bars, and the Hybrid digits Pulse later dropped), 0007, 0008, 0010, 0011, 0013, 0014 and 0015 apply to Ingwe as written. Pulse ADRs 0002, 0006, 0009 and 0012 (slots and relocation) don't.
- Stored `field0`–`field3`, `timeStyle` and `bar0`–`bar3` keep their meaning across the upgrade.
