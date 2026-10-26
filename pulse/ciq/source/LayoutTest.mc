import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Test;
import Toybox.Time;

// Sweeps two full 12-hour cycles and checks ADR 0002 plus hand clearance and that no field hides.
function sweep(fields as Array<Number>) as Void {
    Layout.setup(System.getDeviceSettings().screenWidth);
    var last = [0, 4, 8], sum = 0.0, low = 999.0;
    for (var t = 0; t < 1440; t++) {
        var m = t % 720, now = Layout.blockedAt(m), next = Layout.blockedAt(m + 1);
        var out = Layout.assign(m, fields, last), cs = Layout.fit(out, m);
        for (var i = 0; i < 3; i++) {
            var s = out[i], was = last[i], home = Layout.HOMES[i];
            Test.assertMessage(s >= 0, "gauge hidden at " + m);
            var c = cs[i] as Array<Float>;
            Test.assertMessage(Layout.clearance(c[0], c[1], m) >= c[2] + Layout.PAD, "gauge under a hand at " + m);
            sum += c[2]; if (c[2] < low) { low = c[2]; }
            for (var j = 0; j < i; j++) {
                var q = cs[j] as Array<Float>, dx = c[0] - q[0], dy = c[1] - q[1];
                Test.assertMessage(Math.sqrt(dx * dx + dy * dy) >= c[2] + q[2] + Layout.GAP - 0.01, "gauges overlap at " + m);
            }
            if (s == was) { continue; }
            Test.assertMessage(!now[s] && !next[s], "moved into a slot not free at m and m+1, at " + m);
            if (was >= 0 && was != home && s != home) {
                var taken = false;
                // Taken includes a neighbour slot, since gauges one slot apart would overlap.
                for (var j = 0; j < 3; j++) { if (j != i && out[j] >= 0 && Layout.circularDistance(out[j], was) <= 1) { taken = true; } }
                Test.assertMessage(now[was] || taken, "hopped between non-home slots at " + m);
            }
        }
        last = out;
    }
    System.println("gauge radius: mean " + (sum / 4320 / Layout.S).format("%.1f") + ", min " + (low / Layout.S).format("%.1f"));
}

(:test)
function layoutSweep(logger as Logger) as Boolean {
    sweep([7, 4, 0]);
    Test.assertEqual(Layout.assign(0, [5, 5, 0], [0, 4, 8])[1], -1);
    return true;
}

// ADR 0005 recovery peak: top-up below the peak loses ground, above it resets, 0 h clears.
(:test)
function recoveryPeak(logger as Logger) as Boolean {
    Application.Storage.deleteValue("recoveryPeak");
    Test.assertEqual(Fields.recovered(18), 0.0);
    Test.assertEqual(Fields.recovered(9), 0.5);
    Test.assertEqual(Fields.recovered(12), 1 - 12 / 18.0);
    Test.assertEqual(Fields.recovered(30), 0.0);
    Test.assertEqual(Fields.recovered(0), 1.0);
    Test.assertEqual(Fields.recovered(10), 0.0);
    // A peak that ran out while another face was showing is replaced.
    Application.Storage.setValue("recoveryPeak", [40, Time.now().value() - 41 * 3600]);
    Test.assertEqual(Fields.recovered(18), 0.0);
    Application.Storage.deleteValue("recoveryPeak");
    return true;
}
