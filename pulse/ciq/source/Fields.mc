import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.UserProfile;
import Toybox.Complications;
import Toybox.Position;
import Toybox.WatchUi;

// DataProvider (ADR 0001): complications first, direct APIs otherwise.
// read() returns [text, progress 0..1 or null, caption or null]. Missing data shows "--" (Unavailable).
module Fields {
    enum { HEART, RESTING, RECOVERY, BODY, WEATHER, BATTERY, STEPS, DATE, CALORIES, DISTANCE, SUNRISE, STRESS, ZONE }
    const COUNT = 13;

    // ADR 0004: code, latitude, longitude. UTC has no location.
    const CITIES = [
        ["LON", 51.507, -0.128], ["NYC", 40.713, -74.006], ["TYO", 35.690, 139.692],
        ["SYD", -33.869, 151.209], ["SIN", 1.352, 103.820], ["KUL", 3.139, 101.687],
        ["CCU", 22.573, 88.364], ["DXB", 25.205, 55.271], ["UTC", null, null]
    ];

    function name(id as Number) as String {
        return WatchUi.loadResource([
            Rez.Strings.M0, Rez.Strings.M1, Rez.Strings.M2, Rez.Strings.M3, Rez.Strings.M4, Rez.Strings.M5, Rez.Strings.M6,
            Rez.Strings.M7, Rez.Strings.M8, Rez.Strings.M9, Rez.Strings.M10, Rez.Strings.M11, Rez.Strings.M12
        ][id]) as String;
    }

    function complication(type as Complications.Type) as Numeric or Null {
        try {
            var v = Complications.getComplication(new Complications.Id(type)).value;
            return v instanceof Number || v instanceof Float || v instanceof Double ? v as Numeric : null;
        } catch (e) {
            return null;
        }
    }

    function hhmm(h as Number, m as Number) as String {
        if (!System.getDeviceSettings().is24Hour) { h = h % 12 == 0 ? 12 : h % 12; }
        return h.format("%02d") + ":" + m.format("%02d");
    }

    function read(id as Number) as Array {
        var none = ["--", null, null];
        if (id == HEART) {
            var v = complication(Complications.COMPLICATION_TYPE_HEART_RATE);
            return v == null ? none : [v.toNumber().toString(), null, null];
        } else if (id == RESTING) {
            var v = UserProfile.getProfile().averageRestingHeartRate;
            return v == null ? none : [v.toString(), null, null];
        } else if (id == RECOVERY) {
            // ActivityMonitor documents hours; the complication's unit is unverified.
            var v = ActivityMonitor.getInfo().timeToRecovery;
            return v == null ? none : [v + "h", null, null];
        } else if (id == BODY || id == STRESS) {
            var v = complication(id == BODY ? Complications.COMPLICATION_TYPE_BODY_BATTERY : Complications.COMPLICATION_TYPE_STRESS);
            return v == null ? none : [v.toNumber().toString(), v / 100.0, null];
        } else if (id == WEATHER) {
            var v = complication(Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE);
            return v == null ? none : [Math.round(v).toNumber() + "°", null, null];
        } else if (id == BATTERY) {
            var b = System.getSystemStats().battery;
            return [Math.round(b).toNumber() + "%", b / 100.0, null];
        } else if (id == STEPS) {
            var info = ActivityMonitor.getInfo(), s = info.steps, g = info.stepGoal;
            if (s == null) { return none; }
            var p = g == null || g <= 0 ? null : (s >= g ? 1.0 : s.toFloat() / g);
            return [s >= 1000 ? (s / 1000.0).format("%.1f") + "K" : s.toString(), p, null];
        } else if (id == DATE) {
            return [Gregorian.info(Time.now(), Time.FORMAT_SHORT).day.toString(), null, null];
        } else if (id == CALORIES) {
            var c = ActivityMonitor.getInfo().calories;
            return c == null ? none : [c.toString(), null, null];
        } else if (id == DISTANCE) {
            var cm = ActivityMonitor.getInfo().distance;
            if (cm == null) { return none; }
            var mi = System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE;
            return [(cm / (mi ? 160934.4 : 100000.0)).format("%.1f") + (mi ? "mi" : "km"), null, null];
        } else if (id == SUNRISE) {
            // Assumed seconds since local midnight; verify in the simulator.
            var v = complication(Complications.COMPLICATION_TYPE_SUNRISE);
            if (v == null) { return none; }
            var t = v.toNumber();
            return [hhmm(t / 3600 % 24, t / 60 % 60), null, null];
        }
        return zone();
    }

    // ADR 0004: city via localMoment, or a custom fixed offset without DST.
    function zone() as Array {
        var props = Application.Properties, now = Time.now(), info = null, code = null;
        if (props.getValue("useCustomZone") as Boolean) {
            var off = props.getValue("customOffset") as Number;
            info = Gregorian.utcInfo(now.add(new Time.Duration(off * 60)), Time.FORMAT_SHORT);
            code = props.getValue("customLabel") as String;
        } else {
            var city = CITIES[props.getValue("city") as Number];
            code = city[0];
            if (city[1] == null) {
                info = Gregorian.utcInfo(now, Time.FORMAT_SHORT);
            } else {
                var lm = Gregorian.localMoment(new Position.Location({:latitude => city[1], :longitude => city[2], :format => :degrees}), now);
                if (lm != null) { info = Gregorian.info(lm, Time.FORMAT_SHORT); }
            }
        }
        if (info == null) { return ["--", null, code]; }
        var here = Gregorian.info(now, Time.FORMAT_SHORT);
        var a = (info.year as Number) * 10000 + (info.month as Number) * 100 + info.day;
        var b = (here.year as Number) * 10000 + (here.month as Number) * 100 + here.day;
        return [hhmm(info.hour, info.min), null, code + (a > b ? " +1d" : a < b ? " -1d" : "")];
    }
}
