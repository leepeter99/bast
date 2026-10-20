# Outline hands in always-on mode

Always-on mode draws the hour and minute hands as 1–2 px outlines with no filled hub. The whole frame shifts through at least 3 offsets, one per minute. Garmin's AMOLED burn-in rule lets a pixel stay lit for at most 3 consecutive once-a-minute updates, and at most 10% of pixels may be lit. The hour hand turns only 0.5° per minute, less than 1 px at its tip. A filled hand about 20 px wide would therefore keep its middle lit far longer than 3 minutes, even with a small shift. Active mode keeps the filled hands. The difference between the two modes is deliberate.

## Consequences

- Always-on mode draws without anti-aliasing. Anti-aliased edges spread about 2 px, so with a 2 px shift an edge pixel could stay lit across 3 consecutive minutes. 1 px lines look slightly jagged; that is accepted.
