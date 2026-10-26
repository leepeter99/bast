import Toybox.Lang;
import Toybox.Math;

// Port of the prototype's layout engine (crossover_965_bast_pulse.html:32-41) plus ADR 0002.
// Three fields on a twelve-slot ring (ADR 0009). All geometry is in 454x454 screen pixels,
// angles in degrees clockwise from 12.
module Layout {
    const HOMES = [0, 4, 8];
    const N = 12;
    // Design values at 454 px, rescaled by setup() to the real screen width.
    var S as Float = 1.0;
    var CX as Float = 227.0;
    var RING as Float = 133.0;
    var EDGE as Float = 186.0;     // just inside the corner-bar labels (ADR 0005)
    var HOUR_LEN as Float = 117.0;
    var MIN_LEN as Float = 170.0;
    var BLOCK as Float = 65.0;      // = start radius 53 + hand clearance 12
    var R0 as Float = 53.0;      // gauges sit two slots (133 px) apart or more; RING + R0 = EDGE exactly
    var PAD as Float = 12.0;
    var GAP as Float = 7.0;

    function setup(width as Number) as Void {
        S = width / 454.0;
        CX = 227.0 * S; RING = 133.0 * S; EDGE = 186.0 * S; HOUR_LEN = 117.0 * S; MIN_LEN = 170.0 * S;
        R0 = 53.0 * S; PAD = 12.0 * S; GAP = 7.0 * S; BLOCK = R0 + PAD;
    }

    function slotXY(s as Number) as Array<Float> {
        var a = s * Math.PI / 6;
        return [CX + Math.sin(a) * RING, CX - Math.cos(a) * RING] as Array<Float>;
    }

    // [[deg, len], [deg, len]] for hour and minute hands; m = minute of the 12-hour dial.
    function hands(m as Number) as Array<Array<Float>> {
        m = m % 720;
        return [[m * 0.5, HOUR_LEN], [(m % 60) * 6.0, MIN_LEN]] as Array<Array<Float>>;
    }

    // Distance from point to the hand segment from the centre.
    function handDistance(x as Float, y as Float, deg as Float, len as Float) as Float {
        var a = deg * Math.PI / 180, dx = Math.sin(a) * len, dy = -Math.cos(a) * len;
        var t = ((x - CX) * dx + (y - CX) * dy) / (len * len);
        t = t < 0 ? 0.0 : t > 1 ? 1.0 : t;
        var ex = x - CX - t * dx, ey = y - CX - t * dy;
        return Math.sqrt(ex * ex + ey * ey).toFloat();
    }

    function clearance(x as Float, y as Float, m as Number) as Float {
        var hs = hands(m), d = 9999.0;
        for (var k = 0; k < 2; k++) {
            var h = handDistance(x, y, hs[k][0], hs[k][1]);
            if (h < d) { d = h; }
        }
        return d;
    }

    function blockedAt(m as Number) as Array<Boolean> {
        var out = new Array<Boolean>[N];
        for (var s = 0; s < N; s++) {
            var p = slotXY(s);
            out[s] = clearance(p[0], p[1], m) < BLOCK;
        }
        return out;
    }

    function circularDistance(a as Number, b as Number) as Number {
        var d = (a - b + N) % N;
        return d < N - d ? d : N - d;
    }

    // Marks s and both neighbours used: gauges one slot apart would overlap.
    function take(used as Array<Boolean>, s as Number) as Void {
        used[s] = true; used[(s + 1) % N] = true; used[(s + N - 1) % N] = true;
    }

    // Slot per field (-1 = hidden, duplicate or field < 0). `last` is the previous result.
    // Priority is field order: top, lower right, lower left.
    function assign(m as Number, fields as Array<Number>, last as Array<Number>) as Array<Number> {
        var now = blockedAt(m), next = blockedAt(m + 1);
        var used = new Array<Boolean>[N], out = [-1, -1, -1], skip = [false, false, false];
        for (var s = 0; s < N; s++) { used[s] = false; }
        for (var i = 0; i < 3; i++) {
            skip[i] = fields[i] < 0;
            for (var j = 0; j < i; j++) {
                if (fields[i] == fields[j]) { skip[i] = true; }
            }
        }
        // 1. Home, if clear now and next minute.
        for (var i = 0; i < 3; i++) {
            var h = HOMES[i];
            if (!skip[i] && !now[h] && !next[h] && !used[h]) { out[i] = h; take(used, h); }
        }
        // 2. Keep the current relocation slot until it is blocked.
        for (var i = 0; i < 3; i++) {
            var s = last[i];
            if (!skip[i] && out[i] < 0 && s >= 0 && s < N && s != HOMES[i] && !now[s] && !used[s]) { out[i] = s; take(used, s); }
        }
        // 3. The slot clear now and next minute where the gauges placed so far grow largest in total, or hide. Slots are tried
        // nearest home first, and a farther one wins only by more than 3 px, so a move is worth the jump.
        for (var i = 0; i < 3; i++) {
            if (skip[i] || out[i] >= 0) { continue; }
            var best = -1, br = 0.0;
            for (var d = 0; d <= N / 2; d++) {
                for (var sign = -1; sign <= 1; sign += 2) {
                    var s = (HOMES[i] + sign * d + N) % N;
                    if (used[s] || now[s] || next[s] || d == 0 && sign > 0 || d == N / 2 && sign > 0) { continue; }
                    out[i] = s;
                    var r = 0.0;
                    for (var j = 0; j < 3; j++) { if (out[j] >= 0) { r += grow(out, j, m); } }
                    if (best < 0 || r > br + 3 * S) { best = s; br = r; }
                }
            }
            out[i] = best;
            if (best >= 0) { take(used, best); }
        }
        return out;
    }

    // Grow each gauge from r 53 toward the centre (prototype fitCircles), one pixel per pass, until it
    // meets the edge, a hand or a neighbour. Two gauges two slots apart stay at 53; others grow to ~80.
    // Returns [x, y, r] per field, or null when hidden.
    function fit(slots as Array<Number>, m as Number) as Array {
        var cs = place(slots, R0);
        for (var step = 0; step < 40; step++) {
            for (var i = 0; i < cs.size(); i++) {
                if (cs[i] == null) { continue; }
                var r = (cs[i] as Array<Float>)[2] + S, c = place(slots, r)[i] as Array<Float>, x = c[0], y = c[1];
                if (Math.sqrt((x - CX) * (x - CX) + (y - CX) * (y - CX)) + r > EDGE + 0.01 * S) { continue; }  // RING + R0 == EDGE, so allow float noise
                if (clearance(x, y, m) < r + PAD) { continue; }
                var hit = false;
                for (var j = 0; j < cs.size(); j++) {
                    var q = cs[j] as Array<Float>?;
                    if (q == null || j == i) { continue; }
                    if (Math.sqrt((x - q[0]) * (x - q[0]) + (y - q[1]) * (y - q[1])) < r + q[2] + GAP) { hit = true; break; }
                }
                if (!hit) { cs[i] = c; }
            }
        }
        return cs;
    }

    // Largest radius for field i with the other gauges held at R0, by binary search: a cheap stand-in for
    // fit() when comparing slots, as running fit() per candidate trips the watchdog on device.
    function grow(slots as Array<Number>, i as Number, m as Number) as Float {
        var cs = place(slots, R0), p = cs[i] as Array<Float>, lo = R0, hi = R0 + 40 * S;
        for (var k = 0; k < 6; k++) {
            var r = (lo + hi) / 2, f = (RING - (r - R0)) / RING, x = CX + (p[0] - CX) * f, y = CX + (p[1] - CX) * f;
            var ok = clearance(x, y, m) >= r + PAD;
            for (var j = 0; ok && j < cs.size(); j++) {
                var q = cs[j] as Array<Float>?;
                if (q != null && j != i && Math.sqrt((x - q[0]) * (x - q[0]) + (y - q[1]) * (y - q[1])) < r + q[2] + GAP) { ok = false; }
            }
            if (ok) { lo = r; } else { hi = r; }
        }
        return lo;
    }

    // Gauges of radius r, pulled toward the centre one pixel per pixel of growth past R0.
    function place(slots as Array<Number>, r as Float) as Array {
        var cs = new [slots.size()], ratio = (RING - (r - R0)) / RING;
        for (var i = 0; i < slots.size(); i++) {
            if (slots[i] < 0) { continue; }
            var p = slotXY(slots[i]);
            cs[i] = [CX + (p[0] - CX) * ratio, CX + (p[1] - CX) * ratio, r];
        }
        return cs;
    }
}
