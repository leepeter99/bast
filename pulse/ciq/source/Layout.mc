import Toybox.Lang;
import Toybox.Math;

// Port of the prototype's layout engine (crossover_965_bast_pulse.html:32-41) plus ADR 0002.
// All geometry is in 454x454 screen pixels, angles in degrees clockwise from 12.
module Layout {
    const CX = 227.0;
    const RING = 133.0;
    const EDGE = 180.0;
    const HOUR_LEN = 117.0;
    const MIN_LEN = 170.0;
    const BLOCK = 60.0;      // = start radius 44 + hand clearance 16
    const HOMES = [0, 2, 4, 6];

    function slotXY(s as Number) as Array<Float> {
        var a = s * Math.PI / 4;
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
        var out = new Array<Boolean>[8];
        for (var s = 0; s < 8; s++) {
            var p = slotXY(s);
            out[s] = clearance(p[0], p[1], m) < BLOCK;
        }
        return out;
    }

    function circularDistance(a as Number, b as Number) as Number {
        var d = (a - b + 8) % 8;
        return d < 8 - d ? d : 8 - d;
    }

    // Slot per field (-1 = hidden or duplicate). `last` is the previous result.
    // Priority is field order: top, right, bottom, left.
    function assign(m as Number, fields as Array<Number>, last as Array<Number>) as Array<Number> {
        var now = blockedAt(m), next = blockedAt(m + 1);
        var used = new Array<Boolean>[8], out = [-1, -1, -1, -1], skip = [false, false, false, false];
        for (var s = 0; s < 8; s++) { used[s] = false; }
        for (var i = 1; i < 4; i++) {
            for (var j = 0; j < i; j++) {
                if (fields[i] == fields[j]) { skip[i] = true; }
            }
        }
        // 1. Home, if clear now and next minute.
        for (var i = 0; i < 4; i++) {
            var h = HOMES[i];
            if (!skip[i] && !now[h] && !next[h] && !used[h]) { out[i] = h; used[h] = true; }
        }
        // 2. Keep the current relocation slot until it is blocked.
        for (var i = 0; i < 4; i++) {
            var s = last[i];
            if (!skip[i] && out[i] < 0 && s >= 0 && s != HOMES[i] && !now[s] && !used[s]) { out[i] = s; used[s] = true; }
        }
        // 3. Nearest slot that is clear now and next minute, or hide.
        for (var i = 0; i < 4; i++) {
            if (skip[i] || out[i] >= 0) { continue; }
            var best = -1, bd = 9;
            for (var s = 0; s < 8; s++) {
                if (used[s] || now[s] || next[s]) { continue; }
                var d = circularDistance(s, HOMES[i]);
                if (d < bd) { bd = d; best = s; }
            }
            if (best >= 0) { out[i] = best; used[best] = true; }
        }
        return out;
    }

    // Grow each gauge from r 44 toward the centre (prototype fitCircles). The edge caps r at 54.
    // Returns [x, y, r] per field, or null when hidden.
    function fit(slots as Array<Number>, m as Number) as Array {
        var cs = new [slots.size()];
        for (var i = 0; i < slots.size(); i++) {
            if (slots[i] >= 0) { var p = slotXY(slots[i]); cs[i] = [p[0], p[1], 44.0]; }
        }
        for (var step = 0; step < 10; step++) {
            for (var i = 0; i < cs.size(); i++) {
                if (cs[i] == null) { continue; }
                var base = slotXY(slots[i]), r = cs[i][2] + 1;
                var ratio = (RING - (r - 44) * 0.7) / RING;
                var x = CX + (base[0] - CX) * ratio, y = CX + (base[1] - CX) * ratio;
                if (Math.sqrt((x - CX) * (x - CX) + (y - CX) * (y - CX)) + r > EDGE) { continue; }
                if (clearance(x, y, m) < r + 16) { continue; }
                var hit = false;
                for (var j = 0; j < cs.size(); j++) {
                    var q = cs[j];
                    if (q == null || j == i) { continue; }
                    if (Math.sqrt((x - q[0]) * (x - q[0]) + (y - q[1]) * (y - q[1])) < r + q[2] + 7) { hit = true; break; }
                }
                if (!hit) { cs[i] = [x, y, r]; }
            }
        }
        return cs;
    }
}
