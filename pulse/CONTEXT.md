# Panther watch face

An analog watch face for the Garmin FR965. User-chosen data stays readable by moving out of the way of the hour and minute hands.

## Language

### Layout

**Field**:
One user-chosen metric shown in a gauge, such as heart rate or the date. There are three.
_Avoid_: Complication, widget, metric slot

**Slot**:
One of six fixed positions evenly spaced on a ring around the dial centre where a field can sit.
_Avoid_: Position, spot

**Home slot**:
A field's preferred slot: top, lower right or lower left. Each field has a different one.
_Avoid_: Default position, direction

**Blocked**:
Describes a slot that the hour or minute hand passes too close to for a field to sit there. The seconds hand never blocks a slot.
_Avoid_: Obstructed, covered, unsafe

**Relocation**:
A field moving from its home slot to another slot because its home slot is blocked.
_Avoid_: Reflow, rearrangement

**Hidden field**:
A field that isn't shown because no slot is free and unblocked. When slots run short, fields are hidden from the lower-left home slot first and from the top home slot last.
_Avoid_: Dropped field, collapsed

**Gauge**:
The circle that shows one field's icon and value.
_Avoid_: Badge, bubble, circle

**Progress arc**:
The thin ring on a gauge's rim that fills to show a reading against its natural range. Only fields with such a range have one.
_Avoid_: Ring fill, meter

**Sun event**:
What the Sunrise / Sunset field shows: the next sunrise or sunset today, or tomorrow's sunrise once the sun has set. Its caption reads RISE or SET.
_Avoid_: Sunrise time, daylight

**Corner bar**:
A segmented bar along the dial edge in one of four corners, showing one bar metric or turned off. Its fill always tracks the real value. Minute ticks show only where no corner bar is drawn.
_Avoid_: Arc gauge, bezel, side field

**Bar metric**:
What a corner bar shows: Steps, Body Battery, Move alert, Recovery, Stress or Floors climbed. Stress is also a field. Every other bar metric is never a field, so it never relocates or hides behind the hands. Each one appears on at most one corner. Every bar reads full = good, so the Stress bar fills as the wearer calms.
_Avoid_: Field, side field

**Move alert**:
The bar metric for Garmin's inactivity warning. It reads as vibranium charge: full and near white when the wearer has moved recently ("CHARGED"), losing a segment and dimming for each step of idleness ("MOVE!", magenta at the last step), and refilling at once when the wearer walks it off ("RECHARGED", held a few minutes). While the alert is up and the wearer is walking, it shows "KEEP GOING".
_Avoid_: Move bar (Garmin's name), inactivity, idle alert

**Recovery peak**:
The highest recovery time seen since recovery last reached zero. The Recovery bar shows how much of the peak has been worked off.
_Avoid_: Max recovery, baseline

**Recharged**:
The state of the Recovery bar at zero hours of recovery: full, with the peak cleared.
_Avoid_: Recovered, ready

### Modes

**Active mode**:
The full face: ticks, corner bars, fields and all three hands.
_Avoid_: Normal mode, high-power mode

**Always-on mode**:
The low-power face shown while the watch sleeps: only the hour and minute hands, no fields.
_Avoid_: AOD (in prose), sleep mode, ambient

### Data

**Unavailable**:
The state of a field or bar metric whose reading is missing. It shows `--`; a field keeps its icon and slot, and a corner bar keeps its place with every segment dim.
_Avoid_: Empty, error, no data

**Second zone**:
A field that shows the local time in a chosen city, including daylight saving, or in a custom zone.
_Avoid_: Travel time, world clock, dual time

**Custom zone**:
A second zone defined by the user as a fixed UTC offset plus an optional 3-letter label, with no daylight saving. Without a label, the offset itself is shown, such as `+5:30`.
_Avoid_: Manual offset, other city
