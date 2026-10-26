# Black Panther icons, and icons in place of words on the bars

Every gauge and bar icon is redrawn from Black Panther's world: the heart-shaped herb for heart rate, a herb sprout for recovery, a solid vibranium cell with a lightning bolt cut out for Body Battery, a paw print with clearly separated toes for steps, the mask for the Move alert, the necklace fangs for stress, Warrior Falls for floors, a spear for distance, Kimoyo beads for the second zone and pressure, and Mount Bashenga for altitude. The corner bars drop their words (STEPS, BODY BATTERY and so on). Each one shows its icon followed by the number, at 24 px instead of 17 px, with the icon at about 22 px. Steps shows the full count, not a rounded "4.2k". The Move alert shows the mask with "CHARGED" in white, or with "MOVE! n/5" or "KEEP GOING n/5" in magenta while an alert is up. Recovery still reads "RECHARGED" at 0 h.

## Consequences

- Icons are drawn on a 16 px grid from lines, filled polygons and circles only. `drawIcon` takes a centre, scale and rotation, so the same icon serves a gauge (upright, accent colour) and a bar (turned with the arc, in the label colour).
- The number's width on a bar is estimated at half an em per glyph, not measured, so a label can sit a few pixels off-centre.
- The bar label strings (`LSteps`, `LBody`, `LStress`, `LFloors`, `LRecovery`, `LMove`) are removed. A new user has to learn the icons, but the gauges use the same ones.
