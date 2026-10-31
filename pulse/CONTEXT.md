# Panther watch face

An analog watch face for the Garmin FR965. User-chosen data stays readable by moving out of the way of the hour and minute hands.

## Language

### Layout

**Field**:
One user-chosen metric shown in a gauge, such as heart rate or the date. There are three.
_Avoid_: Complication, widget, metric slot

**Slot**:
One of twelve fixed positions evenly spaced on a ring around the dial centre, like the hours, where a field can sit. Two fields are always at least two slots apart.
_Avoid_: Position, spot

**Home slot**:
A field's preferred slot: top, lower right or lower left. Each field has a different one.
_Avoid_: Default position, direction

**Blocked**:
Describes a slot that the hour or minute hand passes too close to for a given field's gauge to sit there. A field with a larger minimum size is blocked sooner, so the same slot can be blocked for one field and free for another. The seconds hand never blocks a slot.
_Avoid_: Obstructed, covered, unsafe

**Relocation**:
A field moving from its home slot to another slot because its home slot is blocked. It goes to the free slot where the gauges end up largest, not simply the nearest one.
_Avoid_: Reflow, rearrangement

**Hidden field**:
A field that isn't shown because no slot is free and unblocked. When slots run short, fields are hidden from the lower-left home slot first and from the top home slot last.
_Avoid_: Dropped field, collapsed

**Gauge**:
The circle that shows one field's icon and value.
_Avoid_: Badge, bubble, circle

**Minimum size**:
The smallest a gauge shrinks to when the hands or a neighbour crowd it. The Date gauge's minimum size is larger than the other fields', so it never shrinks as small as they can; it can still be smaller than a neighbour that has more room.
_Avoid_: Floor, base radius

**Progress arc**:
The thin ring on a gauge's rim that fills to show a reading against its natural range. Only fields with such a range have one.
_Avoid_: Ring fill, meter

**Sun event**:
What the Sunrise / Sunset field shows: the next sunrise or sunset today, or tomorrow's sunrise once the sun has set. Its caption reads RISE or SET. Without both of today's times, which event is next is unknown, so the field is Unavailable.
_Avoid_: Sunrise time, daylight

**Corner bar**:
A bar along the dial edge in one of four corners, showing one bar metric or turned off. Its fill always tracks the real value: a smooth arc, or five cells for Move alert. A smooth bar gets brighter by quarter as it fills and reaches the accent only when full. Recovery, Steps and Floors climbed shine lilac-white with a halo for a few minutes after filling. Its label is the metric's icon followed by its number. Minute ticks show only where no corner bar is drawn.
_Avoid_: Arc gauge, bezel, side field

**Bar metric**:
What a corner bar shows: Steps, Body Battery, Move alert, Recovery, Stress or Floors climbed. Stress and Recovery are also fields. Every other bar metric is never a field, so it never relocates or hides behind the hands. Each one appears on at most one corner. Every bar reads full = good, so the Stress bar fills as the wearer calms.
_Avoid_: Field, side field

**Move alert**:
The bar metric for Garmin's inactivity warning. It reads as vibranium charge: full and purple, labelled "CHARGED" in white, when the wearer has moved recently, losing a segment and dimming for each step of idleness ("MOVE!"), drained at the last step ("DRAINED": bare empty cells, the first one slowly breathing in the accent), and refilling at once, glowing white for a few minutes, when the wearer walks it off. While the alert is up, its words take a dimmed version of the hands' lilac: "MOVE!", or "KEEP GOING" while the wearer is walking.
_Avoid_: Move bar (Garmin's name), inactivity, idle alert

**Walking**:
The wearer taking a minute's worth of steady steps while the Move alert is up, judged over the past minute only. After a stretch the face didn't see, the wearer is not walking until a full minute has been watched.
_Avoid_: Moving, active

**Recovery peak**:
The highest recovery time seen since recovery last reached zero, or since the latest reading says it would have. A workout that tops recovery up below the peak keeps the peak, so the bar loses ground instead of starting over. The Recovery bar shows how much of the peak has been worked off.
_Avoid_: Max recovery, baseline

**Recharged**:
The state of the Recovery bar at zero hours of recovery: full, with the peak cleared.
_Avoid_: Recovered, ready

**Rest**:
The Body Battery bar's prompt under 10%: "REST" before the number in the alert words. Under 5% the bar's first fifth also breathes in the accent.
_Avoid_: Low battery, drained

**Air quality**:
The field showing the Atmos Air Quality app's AQI. Its ring and caption take the US AQI category colour: green, yellow, orange, red, purple, maroon; the number stays white. Without the app it is Unavailable.
_Avoid_: Pollution, AQI field

### Modes

**Active mode**:
The full face: ticks, corner bars, fields and all three hands.
_Avoid_: Normal mode, high-power mode

**Always-on mode**:
The low-power face shown while the watch sleeps: only the hour and minute hands, no fields.
_Avoid_: AOD (in prose), sleep mode, ambient

### Data

**Unavailable**:
The state of a field or bar metric whose reading is missing. It shows `--`; a field keeps its icon and slot, and a corner bar keeps its place with its track dim.
_Avoid_: Empty, error, no data

**Second zone**:
A field that shows the local time in a chosen city, including daylight saving, or in a custom zone.
_Avoid_: Travel time, world clock, dual time

**Custom zone**:
A second zone defined by the user as a fixed UTC offset plus an optional 3-letter label, with no daylight saving. Without a label, the offset itself is shown, such as `+5:30`.
_Avoid_: Manual offset, other city
