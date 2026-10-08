# Panther watch face

An analog watch face for the Garmin FR965. User-chosen data stays readable by moving out of the way of the hour and minute hands.

## Language

### Layout

**Field**:
One user-chosen metric shown on the dial, such as heart rate or steps. There are exactly four.
_Avoid_: Complication, widget, metric slot

**Slot**:
One of eight fixed positions evenly spaced on a ring around the dial centre where a field can sit.
_Avoid_: Position, spot

**Home slot**:
A field's preferred slot: top, right, bottom or left. Each field has a different one.
_Avoid_: Default position, direction

**Blocked**:
Describes a slot that the hour or minute hand passes too close to for a field to sit there. The seconds hand never blocks a slot.
_Avoid_: Obstructed, covered, unsafe

**Relocation**:
A field moving from its home slot to another slot because its home slot is blocked.
_Avoid_: Reflow, rearrangement

**Hidden field**:
A field that isn't shown because no slot is free and unblocked. When slots run short, fields are hidden from the left home slot first and from the top home slot last.
_Avoid_: Dropped field, collapsed

**Gauge**:
The circle that shows one field's icon and value.
_Avoid_: Badge, bubble, circle

**Progress arc**:
The part of a gauge's ring that fills to show a reading against its natural range. Only fields with such a range have one. Fields without one show a plain ring.
_Avoid_: Ring fill, meter

**Chapter ring**:
The ring of markings around the dial edge. Its style is compass, hour numerals or ticks only.
_Avoid_: Bezel, scale, compass ring

**Compass style**:
The chapter ring style with decorative N/E/S/W and degree labels. It doesn't measure heading.
_Avoid_: Compass, bezel

### Modes

**Active mode**:
The full face: dial markings, fields, all three hands.
_Avoid_: Normal mode, high-power mode

**Always-on mode**:
The low-power face shown while the watch sleeps: only the hour and minute hands, no fields.
_Avoid_: AOD (in prose), sleep mode, ambient

### Data

**Unavailable**:
The state of a field whose reading is missing. It shows `--` and keeps its icon and slot.
_Avoid_: Empty, error, no data

**Second zone**:
A field that shows the local time in a chosen city, including daylight saving, or in a custom zone.
_Avoid_: Travel time, world clock, dual time

**Custom zone**:
A second zone defined by the user as a fixed UTC offset plus a 3-letter label, with no daylight saving.
_Avoid_: Manual offset, other city
