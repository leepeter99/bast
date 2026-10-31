# Bars brighten as they fill, goal bars shine briefly

This changes the smooth bar colours in ADR 0011. Below full, Steps, Body Battery, Recovery, Stress and Floors climbed fill in the accent dimmed by quarter: 50%, 65%, 80% and 90% brightness. Only a full bar reaches the accent itself. When the face sees Recovery, Steps or Floors climbed go from below full to full, the bar shines for 5 minutes, the same hold as the Move alert's recharge: lilac-white over a wider, dim accent halo. After that it settles to the accent. Recovery keeps its "RECHARGED" label but no longer stays white for as long as it is full.

Body Battery and Stress never shine, because 100 and 0 come and go from minute to minute and each crossing would restart the shine. Instead they dim as they drain. Body Battery under 10% reads "REST n" in the alert words, and under 5% the bar's first fifth breathes from the track to the accent, like a drained Move cell. Stress above 75% still turns orange (red on amber), in the bar and in the Stress gauge's ring.

## Consequences

- A bar that is already full when the face loads, or when the settings change, does not shine. Neither does one that fills while the watch is in always-on mode: it shines from the next wake instead.
- The shine is static, so it needs no once-a-second redraw. The Body Battery breathing holds one brightness in low-power mode until the next minute.
- The dimmest quarter is 50%, not lower, so the deep violet accent stays clear of the track colour.
