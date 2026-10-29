# Larger minimum size for the Date gauge

The Date gauge carries the most text of any gauge (day number, month, and a ring of seven weekday letters), and at the shared minimum of 53 px the weekday ring got cramped. The Date field now has a minimum size of 64 px at 454 px; the other fields keep 53. It is tied to the Date field, not to the top home slot, so it follows Date wherever the user puts it. We chose a larger minimum over "never the smallest gauge" (holding the other gauges back whenever Date is squeezed), because the other gauges would shrink for no reason a wearer can see.

## Consequences

- 66 px is the ceiling: above it, Date overlaps a gauge two slots away at 53. 64 leaves 2 px for rounding on rescaled screens.
- Blocking depends on the field: a slot counts as blocked for Date when a hand would come within 12 px of a 64 px gauge, so Date relocates a little earlier and more often than other fields.
- Across 24 hours at 454 px, the mean gauge radius drops from 71.8 to 70.0 px. Date never goes below 64; the overall minimum is still 53. The layout test now checks every gauge against its own minimum, and no field is hidden.
