import Toybox.Lang;
import Toybox.Math;

// Fixed gauges: each field stays at its home (top, right, bottom, left) and the hands pass over it.
// All geometry is in 454x454 screen pixels, angles in degrees clockwise from 12.
module Layout {
    // Design values at 454 px, rescaled by setup() to the real screen width.
    var S as Float = 1.0;
    var CX as Float = 227.0;
    var EDGE as Float = 186.0;     // just inside the corner-bar labels (ADR 0005)
    var HOUR_LEN as Float = 117.0;
    var MIN_LEN as Float = 170.0;
    var R as Float = 74.0;         // largest whole r with neighbours 90 degrees apart: (EDGE - r) * sqrt 2 >= 2r + GAP
    var GAP as Float = 7.0;
    var DIGITS_X as Float = 298.0; // Hybrid digits start at x ~305

    function setup(width as Number) as Void {
        S = width / 454.0;
        CX = 227.0 * S; EDGE = 186.0 * S; HOUR_LEN = 117.0 * S; MIN_LEN = 170.0 * S;
        R = 74.0 * S; GAP = 7.0 * S; DIGITS_X = 298.0 * S;
    }

    // [[deg, len], [deg, len]] for hour and minute hands; m = minute of the 12-hour dial.
    function hands(m as Number) as Array<Array<Float>> {
        m = m % 720;
        return [[m * 0.5, HOUR_LEN], [(m % 60) * 6.0, MIN_LEN]] as Array<Array<Float>>;
    }

    // [x, y, r] per field touching the edge, or null for field < 0 or a duplicate of an earlier one.
    // `maxX` shrinks every gauge so top and bottom stay left of the Hybrid digits (pass 9999 when there are none).
    function fit(fields as Array<Number>, maxX as Float) as Array {
        var r = maxX - CX < R ? maxX - CX : R, d = EDGE - r, cs = new [fields.size()];
        for (var i = 0; i < fields.size(); i++) {
            var dup = fields[i] < 0;
            for (var j = 0; j < i; j++) {
                if (fields[i] == fields[j]) { dup = true; }
            }
            if (dup) { continue; }
            var a = i * Math.PI / 2;
            cs[i] = [CX + Math.sin(a) * d, CX - Math.cos(a) * d, r];
        }
        return cs;
    }
}
