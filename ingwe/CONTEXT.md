# Ingwe watch face

A Garmin watch face whose user-chosen data sits at four fixed places on the dial, with the time shown by hands, digits, or both. Every term not defined here (Corner bar, Bar metric, Move alert, Rest, Air quality, Recovery peak, Sun event, Unavailable, Always-on mode, Second zone and the rest) means what [Pulse's glossary](../pulse/CONTEXT.md) says.

## Language

### Layout

**Field**:
One user-chosen metric shown in a gauge. There are four, one per home.
_Avoid_: Complication, widget, metric slot

**Gauge**:
The circle that shows one field's icon and value.
_Avoid_: Badge, bubble, circle

**Home**:
Where a field sits: top, right, bottom or left. A field never leaves its home; the hands pass over it.
_Avoid_: Slot, position, spot

### Time

**Time style**:
How the face shows the time: Analog, Hybrid or Digital.
_Avoid_: Mode, watch type

**Analog**:
The time style with hour, minute and seconds hands only.
_Avoid_: Classic, normal

**Hybrid**:
The time style with hands plus stacked hours, minutes and seconds right of centre. The digits take the right home, so the right field and the two right corner bars aren't shown; a battery icon, its body filled to the charge, sits above the digits.
_Avoid_: Combo, digital-analog

**Digital**:
The time style with Hybrid's stacked digits and no hands. The right field and right corner bars aren't shown. Always-on mode still shows the outlined hands.
_Avoid_: Digits only, no-hands mode
