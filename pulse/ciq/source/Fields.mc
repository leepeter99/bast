import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.UserProfile;
import Toybox.Complications;
import Toybox.Weather;
import Toybox.Position;
import Toybox.WatchUi;

// DataProvider (ADR 0001): complications first, direct APIs otherwise.
// read() returns [text, progress 0..1 or null, caption or null]. Missing data shows "--" (Unavailable).
module Fields {
    enum { HEART, RESTING, RECOVERY, BODY, WEATHER, BATTERY, STEPS, DATE, CALORIES, DISTANCE, SUNRISE, STRESS, ZONE, MOVE, FLOORS, PULSEOX, RESP, HILOW, BIKE, RUN, ALTITUDE, PRESSURE }
    const COUNT = 22;
    // Gauge defaults per position (top, lower right, lower left).
    const DEFAULTS = [DATE, WEATHER, HEART];
    // Corner bar options: Off, Steps, Body Battery, Move, Recovery, Stress, Floors (ADR 0005).
    const BAR_IDS = [-1, STEPS, BODY, MOVE, RECOVERY, STRESS, FLOORS];
    // Upper left, upper right, lower left, lower right.
    const BAR_DEFAULTS = [1, 3, 2, 4];

    // ADR 0004: code, latitude, longitude. UTC has no location.
    const CITIES = [
        ["LON", 51.507, -0.128], ["NYC", 40.713, -74.006], ["TYO", 35.690, 139.692],
        ["SYD", -33.869, 151.209], ["SIN", 1.352, 103.820], ["KUL", 3.139, 101.687],
        ["CCU", 22.573, 88.364], ["DXB", 25.205, 55.271], ["UTC", null, null],
        ["BKK", 13.756, 100.502], ["TPE", 25.033, 121.565]
    ];

    // v if it is a Number in [0, n), else dflt. Settings come from the phone and may be stale.
    function index(v as Object?, n as Number, dflt as Number) as Number {
        return v instanceof Number && v >= 0 && v < n ? v : dflt;
    }

    // Metrics shown only on the corner bars, never as a gauge. Stress and Recovery can be both.
    function fixed(id as Number) as Boolean {
        return id == STEPS || id == BODY || id == MOVE || id == FLOORS;
    }

    // The gauge at position i, falling back to its default for stale or bar-only values.
    function field(i as Number) as Number {
        var v = index(Application.Properties.getValue("field" + i), COUNT, DEFAULTS[i]);
        return fixed(v) ? DEFAULTS[i] : v;
    }

    // Bar option per corner. A metric already on an earlier corner (UL, UR, LL, LR) turns the later one Off.
    function bars() as Array<Number> {
        var out = [0, 0, 0, 0];
        for (var k = 0; k < 4; k++) {
            out[k] = index(Application.Properties.getValue("bar" + k), BAR_IDS.size(), BAR_DEFAULTS[k]);
            for (var j = 0; j < k; j++) {
                if (out[j] == out[k]) { out[k] = 0; }
            }
        }
        return out;
    }

    // Share of the recovery peak worked off, 1.0 = recharged (ADR 0005). The peak is stored as
    // [hours, set at]; one that has run out since it was set, or is below the reading, is replaced.
    function recovered(h as Number) as Float {
        var now = Time.now().value(), saved = Application.Storage.getValue("recoveryPeak") as Array<Number>?;
        if (h <= 0) {
            if (saved != null) { Application.Storage.deleteValue("recoveryPeak"); }
            return 1.0;
        }
        var peak = saved == null || saved[0] < h || saved[1] + saved[0] * 3600 < now ? null : saved[0];
        if (peak == null) {
            peak = h;
            Application.Storage.setValue("recoveryPeak", [h, now]);
        }
        return 1 - h.toFloat() / peak;
    }

    function str(id as ResourceId) as String { return WatchUi.loadResource(id) as String; }

    function name(id as Number) as String {
        return str([
            Rez.Strings.M0, Rez.Strings.M1, Rez.Strings.M2, Rez.Strings.M3, Rez.Strings.M4, Rez.Strings.M5, Rez.Strings.M6,
            Rez.Strings.M7, Rez.Strings.M8, Rez.Strings.M9, Rez.Strings.M10, Rez.Strings.M11, Rez.Strings.M12, Rez.Strings.M13,
            Rez.Strings.M14, Rez.Strings.M15, Rez.Strings.M16, Rez.Strings.M17, Rez.Strings.M18,
            Rez.Strings.M19, Rez.Strings.M20, Rez.Strings.M21
        ][index(id, COUNT, 0)] as ResourceId);
    }

    function complication(type as Complications.Type) as Numeric or Null {
        try {
            var v = Complications.getComplication(new Complications.Id(type)).value;
            return v instanceof Number || v instanceof Float || v instanceof Double ? v as Numeric : null;
        } catch (e) {
            return null;
        }
    }

    function hour(h as Number) as String {
        // hourFormat: 0 = watch setting, 1 = 12 h, 2 = 24 h.
        var f = index(Application.Properties.getValue("hourFormat"), 3, 0);
        if (f == 1 || f == 0 && !System.getDeviceSettings().is24Hour) { h = h % 12 == 0 ? 12 : h % 12; }
        return h.format("%02d");
    }

    function hhmm(h as Number, m as Number) as String { return hour(h) + ":" + m.format("%02d"); }

    // Celsius in, device units out, as "NN°".
    function temp(c as Numeric) as String {
        if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) { c = c * 9 / 5.0 + 32; }
        return Math.round(c).toNumber() + "°";
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
            // The complication reports minutes; show whole hours, rounded up.
            var v = complication(Complications.COMPLICATION_TYPE_RECOVERY_TIME);
            if (v == null) { return none; }
            var h = (v.toNumber() + 59) / 60;
            return [h + "h", recovered(h), null];
        } else if (id == BODY || id == STRESS) {
            var v = complication(id == BODY ? Complications.COMPLICATION_TYPE_BODY_BATTERY : Complications.COMPLICATION_TYPE_STRESS);
            return v == null ? none : [v.toNumber().toString(), v / 100.0, null];
        } else if (id == WEATHER) {
            var v = complication(Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE);
            if (v == null) { return none; }
            // The complication is always Celsius; low|high comes from Weather, which may be null.
            var cc = Weather.getCurrentConditions(), cap = null;
            if (cc != null && cc.lowTemperature != null && cc.highTemperature != null) {
                cap = temp(cc.lowTemperature as Numeric) + "|" + temp(cc.highTemperature as Numeric);
            }
            return [temp(v), null, cap];
        } else if (id == BATTERY) {
            var b = System.getSystemStats().battery;
            return [Math.round(b).toNumber() + "%", b / 100.0, null];
        } else if (id == STEPS) {
            var info = ActivityMonitor.getInfo(), s = info.steps, g = info.stepGoal;
            if (s == null) { return none; }
            var p = g == null || g <= 0 ? null : (s >= g ? 1.0 : s.toFloat() / g);
            return [s >= 1000 ? (s / 1000.0).format("%.1f") + str(Rez.Strings.Thousands) : s.toString(), p, null, s];
        } else if (id == DATE) {
            // [day, null, month, weekday 1 = Sunday] for the weekday ring.
            var now = Time.now(), d = Gregorian.info(now, Time.FORMAT_MEDIUM);
            return [d.day.format("%02d"), null, (d.month as String).toUpper(), Gregorian.info(now, Time.FORMAT_SHORT).day_of_week];
        } else if (id == CALORIES) {
            var c = ActivityMonitor.getInfo().calories;
            return c == null ? none : [c.toString(), null, null];
        } else if (id == DISTANCE) {
            var cm = ActivityMonitor.getInfo().distance;
            if (cm == null) { return none; }
            var mi = System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE;
            return [(cm / (mi ? 160934.4 : 100000.0)).format("%.1f") + str(mi ? Rez.Strings.Miles : Rez.Strings.Km), null, null];
        } else if (id == SUNRISE) {
            // Next sun event today, else tomorrow's sunrise. Both are seconds since local midnight.
            var up = complication(Complications.COMPLICATION_TYPE_SUNRISE), down = complication(Complications.COMPLICATION_TYPE_SUNSET);
            var ct = System.getClockTime(), now = ct.hour * 3600 + ct.min * 60;
            var rise = up != null && (down == null || now < up || now >= down);
            var v = rise ? up : down;
            if (v == null) { return none; }
            var t = v.toNumber();
            return [hhmm(t / 3600 % 24, t / 60 % 60), null, str(rise ? Rez.Strings.Rise : Rez.Strings.Set)];
        } else if (id == FLOORS) {
            var info = ActivityMonitor.getInfo(), f = info.floorsClimbed, g = info.floorsClimbedGoal;
            if (f == null) { return none; }
            return [f.toString(), g == null || g <= 0 ? null : (f >= g ? 1.0 : f.toFloat() / g), null];
        } else if (id == PULSEOX) {
            var v = complication(Complications.COMPLICATION_TYPE_PULSE_OX);
            return v == null ? none : [v.toNumber() + "%", null, "SpO2"];
        } else if (id == RESP) {
            var v = complication(Complications.COMPLICATION_TYPE_RESPIRATION_RATE);
            return v == null ? none : [v.toNumber().toString(), null, "BR/M"];
        } else if (id == HILOW) {
            var cc = Weather.getCurrentConditions();
            if (cc == null || cc.lowTemperature == null || cc.highTemperature == null) { return none; }
            return [temp(cc.lowTemperature as Numeric) + "/" + temp(cc.highTemperature as Numeric), null, "LO/HI"];
        } else if (id == BIKE || id == RUN) {
            // The complications report metres.
            var v = complication(id == BIKE ? Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE : Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE);
            if (v == null) { return none; }
            var mi = System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE;
            return [(v / (mi ? 1609.344 : 1000.0)).format("%.1f") + str(mi ? Rez.Strings.Miles : Rez.Strings.Km), null, "WEEK"];
        } else if (id == ALTITUDE) {
            var v = complication(Complications.COMPLICATION_TYPE_ALTITUDE);
            if (v == null) { return none; }
            var ft = System.getDeviceSettings().elevationUnits == System.UNIT_STATUTE;
            return [Math.round(ft ? v * 3.28084 : v).toNumber() + (ft ? "ft" : "m"), null, "ALT"];
        } else if (id == PRESSURE) {
            // Pascals on current firmware; a small value is taken to be hPa already.
            var v = complication(Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE);
            return v == null ? none : [Math.round(v > 2000 ? v / 100.0 : v).toNumber().toString(), null, "hPa"];
        } else if (id == MOVE) {
            // Move bar: 0 = active, 1+ = alert (first segment after 1 h idle), 5 = full. The view tracks resets.
            var v = ActivityMonitor.getInfo().moveBarLevel;
            if (v == null) { return none; }
            return [v.toString(), v.toFloat() / ActivityMonitor.MOVE_BAR_LEVEL_MAX, null];
        }
        return zone();
    }

    // ADR 0004: city via localMoment, or a custom fixed offset without DST.
    function zone() as Array {
        var now = Time.now(), info = null as Gregorian.Info?, code = "";
        if (Application.Properties.getValue("useCustomZone") as Boolean) {
            var off = (Application.Properties.getValue("customOffset") as Numeric).toNumber();
            info = Gregorian.utcInfo(now.add(new Time.Duration(off * 60)), Time.FORMAT_SHORT);
            var label = Application.Properties.getValue("customLabel") as String?;
            code = label != null && label.length() > 0 ? label : offsetLabel(off);
        } else {
            var city = CITIES[index(Application.Properties.getValue("city"), CITIES.size(), 0)];
            code = city[0] as String;
            if (city[1] == null) {
                info = Gregorian.utcInfo(now, Time.FORMAT_SHORT);
            } else {
                var lm = Gregorian.localMoment(new Position.Location({:latitude => city[1] as Float, :longitude => city[2] as Float, :format => :degrees}), now);
                if (lm != null) { info = Gregorian.info(lm, Time.FORMAT_SHORT); }
            }
        }
        if (info == null) { return ["--", null, code]; }
        var here = Gregorian.info(now, Time.FORMAT_SHORT);
        var a = (info.year as Number) * 10000 + (info.month as Number) * 100 + info.day;
        var b = (here.year as Number) * 10000 + (here.month as Number) * 100 + here.day;
        return [hhmm(info.hour, info.min), null, code + (a > b ? " +1d" : a < b ? " -1d" : "")];
    }

    // Caption for a custom zone without a label: +8, +5:30, -3:30, or UTC.
    function offsetLabel(off as Number) as String {
        if (off == 0) { return "UTC"; }
        var a = off < 0 ? -off : off, mm = a % 60;
        return (off < 0 ? "-" : "+") + a / 60 + (mm == 0 ? "" : ":" + mm.format("%02d"));
    }
}
