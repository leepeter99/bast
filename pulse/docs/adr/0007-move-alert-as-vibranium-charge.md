# Move alert as vibranium charge

This supersedes the Move alert colours in ADR 0005. The bar still drains one segment per idle level, but it now reads as stored vibranium charge instead of a warning light. At level 0 all five segments are vibranium purple and the label reads "CHARGED". Each idle level removes a segment and dims the rest toward deep violet. At level 5 the bar is drained: all five segments are empty, black cells with magenta outlines, and the label turns magenta. While the wearer walks it off, one white segment runs along the empty part of the bar each second, showing absorbed energy. After the level drops to 0, the full bar glows white and the label reads "RECHARGED" for 5 minutes, then it returns to purple.

## Consequences

- White is kept for fresh energy (a recharge or the running segment), so a full purple bar matches the neighbouring bars and stays quiet.
- The Move alert ignores the accent setting, so the charge colours read the same with every accent.
- Amber and red are gone from this bar, so a high level is shown by fewer, dimmer segments rather than a warmer colour. Magenta is the only alarm colour, and it appears only at level 5. The outlines keep a drained bar visible, where plain black segments would look like a bar that is switched off.
- The running segment moves only when the face redraws every second. In low-power mode it stays in one place until the next minute.
