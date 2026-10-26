# Three fields on six slots, and no Hybrid time style

This supersedes the Hybrid part of ADR 0005. The face now shows three fields instead of four, on a ring of six slots instead of eight. Their home slots are top, lower right and lower left (0, 120 and 240 degrees). The Hybrid time style is gone, along with the `timeStyle` setting, so the time is always shown by the hands alone. With one field fewer and nothing closing the right side, the gauges have room to grow, and the corner-bar labels are larger (17 px). The Move alert label also shows the level, such as "MOVE! 3/5".

## Consequences

- Gauges start at r 53 instead of 47. Adjacent slots are 133 px apart, so two gauges in adjacent slots still fit with the 7 px gap, and the others grow toward the centre to about r 80.
- A gauge moves one pixel inward for every pixel it grows, so its outer edge stays at RING + 53 = 186, exactly `Layout.EDGE`. The edge check allows 0.01 px of float error. Without it, rounding alone would decide whether a gauge grows.
- When slots run short, fields are hidden from the lower-left home first and from the top home last.
- The `field1` and `field2` properties keep their ids but now mean lower right and lower left, and `field3` is removed. An existing install keeps its stored values, so its old right and bottom fields move to lower right and lower left, and its old left field is dropped.
