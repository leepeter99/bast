# Move alert as vibranium charge

_The drained look at level 5 is superseded by ADR 0013._

This supersedes the Move alert colours in ADR 0005. The bar still drains one segment per idle level, but it now reads as stored vibranium charge instead of a warning light. At level 0 all five segments are vibranium purple and the label reads "CHARGED". Each idle level removes a segment and dims the rest toward deep violet. At level 5 the bar is drained: all five segments are empty, black cells with electric violet outlines. During any alert, from level 1, the words take a dimmed version of the hands' lilac; the mask keeps the accent colour like the other bar icons. While the wearer walks it off, one white segment runs along the empty part of the bar each second, showing absorbed energy. After the level drops to 0, the full bar glows white for 5 minutes, then it returns to purple. The label reads "CHARGED" in white, like the other bars, whenever no alert is up.

## Consequences

- White is kept for fresh energy (a recharge or the running segment), so a full purple bar matches the neighbouring bars and stays quiet.
- The Move alert ignores the accent setting, so the charge colours read the same with every accent.
- Amber and red are gone from this bar, so a high level is shown by fewer, dimmer segments rather than a warmer colour. Electric violet marks only the drained cells at level 5. The alert words use a dimmed version of the hands' lilac, which keeps the hands' hue at about the brightness of the old alarm colour, so it stays in the theme without outshining the face. The outlines keep a drained bar visible, where plain black segments would look like a bar that is switched off.
- The running segment moves only when the face redraws every second. In low-power mode it stays in one place until the next minute.
