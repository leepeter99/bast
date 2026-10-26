import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Test;
import Toybox.Time;

// Fixed gauges stay inside the edge, apart from each other and, in Hybrid, left of the digits.
function check(fields as Array<Number>, maxX as Float) as Void {
    Layout.setup(System.getDeviceSettings().screenWidth);
    var cs = Layout.fit(fields, maxX);
    for (var i = 0; i < 4; i++) {
        var c = cs[i] as Array<Float>?;
        if (fields[i] < 0) { Test.assertMessage(c == null, "gauge for an empty position"); }
        if (c == null) { continue; }
        var dx = c[0] - Layout.CX, dy = c[1] - Layout.CX;
        Test.assertMessage(Math.sqrt(dx * dx + dy * dy) + c[2] <= Layout.EDGE + 0.01, "gauge past the edge");
        Test.assertMessage(c[0] + c[2] <= maxX + 0.01, "gauge over the Hybrid digits");
        for (var j = 0; j < i; j++) {
            var q = cs[j] as Array<Float>?;
            if (q == null) { continue; }
            var ex = c[0] - q[0], ey = c[1] - q[1];
            Test.assertMessage(Math.sqrt(ex * ex + ey * ey) + 0.01 >= c[2] + q[2] + Layout.GAP, "gauges overlap");
        }
    }
}

(:test)
function fixedLayout(logger as Logger) as Boolean {
    check([7, 5, 4, 0], 9999.0);
    check([7, -1, 4, 0], Layout.DIGITS_X);
    var dup = Layout.fit([5, 5, 0, 7], 9999.0)[1] as Array?;
    Test.assertMessage(dup == null, "duplicate gauge shown");
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
