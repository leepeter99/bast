# Move alert as vibranium charge

This supersedes the Move alert colours in ADR 0005. The bar still drains one segment per idle level, but it now reads as stored vibranium charge instead of a warning light. At level 0 all five segments glow near white and the label reads "CHARGED". Each idle level removes a segment and dims the rest, from lilac to deep violet. At level 5 the single remaining segment and the label turn magenta. While the wearer walks it off, one bright segment runs along the empty part of the bar each second, showing absorbed energy. After the level drops to 0, the label reads "RECHARGED" for 5 minutes.

## Consequences

- The Move alert ignores the accent setting, so the charge colours read the same with every accent.
- Amber and red are gone from this bar, so a high level is shown by fewer, dimmer segments rather than a warmer colour. Magenta is the only alarm colour, and it appears only at level 5.
- The running segment moves only when the face redraws every second. In low-power mode it stays in one place until the next minute.
