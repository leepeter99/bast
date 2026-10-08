import Toybox.Lang;
import Toybox.Test;

// Sweeps two full 12-hour cycles and checks ADR 0002 plus hand clearance.
(:test)
function layoutSweep(logger as Logger) as Boolean {
    var fields = [5, 6, 0, 7], last = [0, 2, 4, 6];
    for (var t = 0; t < 1440; t++) {
        var m = t % 720, now = Layout.blockedAt(m), next = Layout.blockedAt(m + 1);
        var out = Layout.assign(m, fields, last), cs = Layout.fit(out, m);
        for (var i = 0; i < 4; i++) {
            var s = out[i], was = last[i], home = Layout.HOMES[i];
            if (s < 0) { continue; }
            var c = cs[i] as Array;
            Test.assertMessage(Layout.clearance(c[0], c[1], m) >= c[2] + 16, "gauge under a hand at " + m);
            if (s == was) { continue; }
            Test.assertMessage(!now[s] && !next[s], "moved into a slot not free at m and m+1, at " + m);
            if (was >= 0 && was != home && s != home) {
                var taken = false;
                for (var j = 0; j < 4; j++) { if (j != i && out[j] == was) { taken = true; } }
                Test.assertMessage(now[was] || taken, "hopped between non-home slots at " + m);
            }
        }
        last = out;
    }
    Test.assertEqual(Layout.assign(0, [5, 5, 0, 7], [0, 2, 4, 6])[1], -1);
    return true;
}
