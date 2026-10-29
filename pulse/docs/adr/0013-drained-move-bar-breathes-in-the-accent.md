# Drained Move bar breathes in the accent

This replaces the level-5 look in ADR 0007. A fully drained Move bar used to show five black cells with electric violet (#c44dff) outlines, labelled "MOVE! 5/5". The violet leaned pink, was the only colour outside the accent's palette, and the outlines read as a bar that was drawn wrong rather than empty. Now the drained cells show the bare track, like any other empty bar, and the first cell breathes from the track colour up to the accent and back, one step a second. The label reads "DRAINED", the opposite of "CHARGED". Levels 1 to 4 keep "MOVE! n/5".

## Consequences

- The whole Move bar now follows the accent, including the drained state. The orange or red fallback for non-purple accents is gone.
- Walking it off is unchanged: the white running segment takes over from the breathing cell, and the label reads "KEEP GOING n/5".
- The breathing needs the once-a-second redraw. In low-power mode the cell holds one brightness until the next minute.
