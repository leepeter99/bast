# Larger gauges and bar labels, and a battery icon over the digits

Ingwe's gauges never move, so they no longer need to stay inside Pulse's label ring. This replaces the sizes in Pulse ADR 0005 and 0010 for Ingwe. `Layout.EDGE` moves from r 186 to r 198, just inside the cardinal ticks that start at r 200. The gauge radius goes from 74 to 79, the largest at which four gauges 90 degrees apart still keep `GAP` between them. Gauge icons scale with the gauge (about 33 px instead of 16 px), and values are about 12% larger. Hybrid and Digital gauges stay at r 71, limited by the digits.

The corner-bar labels move to r 190. Each label is as large as fits a 135 px budget for icon, gap and text at half an em per glyph, capped at 32 px. Short labels get 32 px, "CHARGED" 30 px and "KEEP GOING 3/5" 16 px. The budget leaves the longest labels about 2 px clear of the neighbouring gauges, measured with real uppercase at 0.55 em. Bar icons sit 3 px inside the bar's inner edge, so they never touch the bar.

Hybrid and Digital also drop the two right corner bars (top right and bottom right), so the digits have the right side to themselves and the minute ticks show there. The stored `bar1` and `bar3` are kept and come back in Analog. Above the digits sits the battery icon, at the size it has in a gauge beside the digits (about 30 px).

The battery icon's body fills with the charge everywhere it's drawn, in Ingwe and Pulse. Like the bars (Pulse ADR 0014), the fill takes the accent dimmed by quarter and reaches the full accent only at 100%.

## Consequences

- Long Move alert labels ("KEEP GOING n/5") are smaller than Pulse's 24 px.
- The battery icon reads the charge every redraw, while the Battery gauge's number and ring refresh once a minute, so the two can differ for up to a minute.
