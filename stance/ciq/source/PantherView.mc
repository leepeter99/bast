import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// WatchFace + Renderer: data first, hands last over the fixed gauges. Always-on mode follows ADR 0003, corner bars ADR 0005.
class PantherView extends WatchUi.WatchFace {
    var S as Float = 1.0;
    var CX as Float = 227.0;
    const ACCENTS = [0xbc73ff, 0x9252e3, 0xdcadff, 0xff993d, 0x52dfff, 0xb8ed95];
    const AMBER = 3;
    const WALKING_STEPS = 60;
    const RESET_HOLD = 300;
    // Corner bars UL, UR, LL, LR: [start, end] in whole degrees clockwise from 12, so segments
    // stay even after drawArc truncates. Fill starts at the 3/9 o'clock end; labels read upright.
    const SPANS = [[280, 350], [10, 80], [190, 260], [100, 170]];
    const FROM_START = [true, false, false, true];
    const TOP = [true, true, false, false];
    var BAR_R as Float = 214.0;
    var LABEL_R as Float = 193.0;
    const TRACK = 0x24152f;
    const SHIFTS = [[0, 0], [2, 0], [2, 2], [0, 2]];
    // Hand outlines from the prototype SVG, relative to the centre, pointing at 12.
    const HOUR = [[-9, 6], [-10, -94], [0, -115], [10, -94], [9, 6]];
    const MINUTE = [[-6, 8], [-7, -149], [0, -168], [7, -149], [6, 8]];
    const HOUR_AOD = [[-6, -14], [-10, -94], [0, -115], [10, -94], [6, -14]];
    const MINUTE_AOD = [[-5, -14], [-7, -149], [0, -168], [7, -149], [5, -14]];

    var sleeping as Boolean = false;
    var fields as Array<Number> = [7, 5, 4, 0];
    var bars as Array<Number> = [1, 3, 2, 4];
    var barValues as Array = [null, null, null, null];
    var hybrid as Boolean = false;
    var accentIdx as Number = 0;
    var circles as Array = [];
    var values as Array = [null, null, null, null];
    var cachedMin as Number = -1;
    var fonts as Dictionary<Number, Graphics.VectorFont?> = {};
    var edgeRef as Graphics.BufferedBitmapReference?;
    // Move alert state, sampled once a minute in both modes (ADR 0005). Level -1 = unavailable.
    var moveLevel as Number = -1;
    var moveSteps as Number? = null;
    var moveMin as Number = -1;
    var walking as Boolean = false;
    var resetUntil as Number = 0;

    function initialize() {
        WatchFace.initialize();
        var w = System.getDeviceSettings().screenWidth;
        Layout.setup(w);
        S = Layout.S; CX = Layout.CX; BAR_R = 214.0 * S; LABEL_R = 193.0 * S;
        loadSettings();
    }

    function loadSettings() as Void {
        for (var i = 0; i < 4; i++) { fields[i] = Fields.field(i); }
        bars = Fields.bars();
        // Hybrid: the digits take the right side, so the right gauge goes.
        hybrid = Fields.index(Application.Properties.getValue("timeStyle"), 2, 0) == 1;
        if (hybrid) { fields[1] = -1; }
        accentIdx = Fields.index(Application.Properties.getValue("accent"), ACCENTS.size(), 0);
        circles = Layout.fit(fields, hybrid ? Layout.DIGITS_X : 9999.0);
        cachedMin = -1;
        edgeRef = null;
    }

    function onEnterSleep() as Void { sleeping = true; WatchUi.requestUpdate(); }

    function onExitSleep() as Void { sleeping = false; cachedMin = -1; WatchUi.requestUpdate(); }

    function onUpdate(dc as Dc) as Void {
        var ct = System.getClockTime(), m = (ct.hour % 12) * 60 + ct.min;
        // ADR 0003: no anti-aliasing in always-on mode, so edge pixels don't bleed across shifts.
        dc.setAntiAlias(!sleeping);
        var em = Time.now().value() / 60;
        if (em != moveMin) { moveMin = em; trackMove(); }
        if (sleeping) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.clear();
            drawAlwaysOn(dc, m);
            return;
        }
        if (m != cachedMin) {
            for (var i = 0; i < 4; i++) {
                values[i] = fields[i] < 0 ? null : Fields.read(fields[i]);
                barValues[i] = bars[i] == 0 ? null : Fields.read(Fields.BAR_IDS[bars[i]] as Number);
            }
            cachedMin = m;
        }
        dc.drawBitmap(0, 0, edge());
        drawBars(dc, ct.sec);
        for (var i = 0; i < 4; i++) {
            if (circles[i] == null) { continue; }
            if (fields[i] == Fields.HEART) { values[i] = Fields.read(Fields.HEART); }
            drawGauge(dc, fields[i], circles[i] as Array<Float>, values[i] as Array);
        }
        if (hybrid) { drawDigits(dc, ct); }
        var hs = Layout.hands(m);
        drawHand(dc, HOUR, hs[0][0], CX, CX, true);
        drawHand(dc, MINUTE, hs[1][0], CX, CX, true);
        drawSeconds(dc, ct.sec * 6.0);
        dc.setColor(0xe5caff, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(CX, CX, 10 * S);
        dc.setColor(0x283334, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawCircle(CX, CX, 10 * S);
    }

    function accent() as Number { return ACCENTS[accentIdx] as Number; }

    // Ticks and bar tracks only change with settings, so they are drawn once. The graphics pool may purge it.
    function edge() as Graphics.BufferedBitmap {
        var b = edgeRef != null ? edgeRef.get() as Graphics.BufferedBitmap? : null;
        if (b == null) {
            edgeRef = Graphics.createBufferedBitmap({:width => (454 * S).toNumber(), :height => (454 * S).toNumber()});
            b = edgeRef.get() as Graphics.BufferedBitmap;
            var bdc = b.getDc();
            bdc.setAntiAlias(true);
            bdc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            bdc.clear();
            drawEdge(bdc);
        }
        return b;
    }

    function font(size as Number) as Graphics.VectorFont? {
        if (!fonts.hasKey(size)) { fonts[size] = Graphics.getVectorFont({:face => "RobotoCondensedBold", :size => size}); }
        return fonts[size];
    }

    function text(dc as Dc, x as Numeric, y as Numeric, size as Number, s as String) as Void {
        size = (size * S).toNumber();
        var f = font(size);
        if (f != null) {
            dc.drawAngledText(x, y, f, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER, 0);
        } else {
            dc.drawText(x, y, Graphics.FONT_XTINY, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // No bezel or numerals: minute ticks where no corner bar is shown, plus the dim bar tracks.
    function drawEdge(dc as Dc) as Void {
        for (var i = 0; i < 60; i++) {
            var deg = i * 6, covered = false;
            for (var k = 0; k < 4; k++) {
                if (bars[k] != 0 && deg >= SPANS[k][0] - 3 && deg <= SPANS[k][1] + 3) { covered = true; }
            }
            if (covered) { continue; }
            var cardinal = i % 15 == 0, major = i % 5 == 0, a = deg * Math.PI / 180, s = Math.sin(a), c = Math.cos(a);
            var r0 = (cardinal ? 225 : major ? 224 : 223) * S, r1 = (cardinal ? 200 : major ? 208 : 216) * S;
            dc.setPenWidth(((cardinal ? 6 : major ? 4 : 2) * S + 0.5).toNumber());
            dc.setColor(cardinal ? 0xe5cff6 : major ? 0x9a80ad : 0x4a2f5a, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(CX + s * r0, CX - c * r0, CX + s * r1, CX - c * r1);
        }
        for (var k = 0; k < 4; k++) {
            if (bars[k] == 0) { continue; }
            var n = segments(k);
            for (var j = 0; j < n; j++) { drawSegment(dc, k, j, n, TRACK); }
        }
    }

    function segments(k as Number) as Number { return Fields.BAR_IDS[bars[k]] == Fields.MOVE ? 5 : 10; }

    // Segment j of bar k, counted from the bar's fill end. 1 degree gap on each side.
    function drawSegment(dc as Dc, k as Number, j as Number, n as Number, col as Number) as Void {
        var a = SPANS[k][0], w = (SPANS[k][1] - a) / n, idx = FROM_START[k] ? j : n - 1 - j;
        dc.setPenWidth((16 * S).toNumber());
        dc.setColor(col, Graphics.COLOR_TRANSPARENT);
        // Clockwise-from-12 to the Dc's counter-clockwise-from-3 degrees.
        dc.drawArc(CX, CX, BAR_R, Graphics.ARC_CLOCKWISE, (450 - a - idx * w - 1) % 360, (450 - a - (idx + 1) * w + 1) % 360);
    }

    // Garmin exposes only the level, never its reset rule. Walking = enough steps in the last minute
    // while the alert is up; a drop to 0 shows RESET for a few minutes.
    function trackMove() as Void {
        var info = ActivityMonitor.getInfo(), lvl = info.moveBarLevel, st = info.steps, now = Time.now().value();
        if (lvl == null) { moveLevel = -1; return; }
        if (moveLevel > 0 && lvl == 0) { resetUntil = now + RESET_HOLD; }
        walking = lvl > 0 && st != null && moveSteps != null && st - moveSteps >= WALKING_STEPS;
        moveLevel = lvl;
        moveSteps = st;
    }

    // Lit segments and the label inside each bar. Every bar reads full = good, so Move drains.
    function drawBars(dc as Dc, sec as Number) as Void {
        var f = font((13 * S).toNumber());
        for (var k = 0; k < 4; k++) {
            var d = barValues[k] as Array?;
            if (bars[k] == 0 || d == null) { continue; }
            var id = Fields.BAR_IDS[bars[k]] as Number, n = segments(k), p = d[1] as Float?, col = accent(), textCol = 0xf5f6f7, label = "";
            var lit = p == null ? 0 : (p * n).toNumber();
            if (id == Fields.STEPS) {
                label = Fields.str(Rez.Strings.LSteps) + " " + d[(d.size() > 3 ? 3 : 0)];
            } else if (id == Fields.BODY) {
                label = Fields.str(Rez.Strings.LBody) + " " + d[0];
            } else if (id == Fields.STRESS) {
                // Full = calm, like the other bars.
                lit = p == null ? 0 : ((1 - p) * n).toNumber();
                label = Fields.str(Rez.Strings.LStress) + " " + d[0];
                if (p != null && p > 0.75) { col = accentIdx == AMBER ? 0xff5a5a : 0xff993d; }
            } else if (id == Fields.FLOORS) {
                label = Fields.str(Rez.Strings.LFloors) + " " + d[0];
            } else if (id == Fields.MOVE) {
                if (moveLevel < 0) { lit = 0; label = Fields.str(Rez.Strings.LMove) + " --"; }
                else if (moveLevel == 0) {
                    lit = n;
                    label = Fields.str(Time.now().value() < resetUntil ? Rez.Strings.Reset : Rez.Strings.Active);
                } else {
                    lit = n - moveLevel < 1 ? 1 : n - moveLevel;
                    col = moveLevel >= n ? 0xff5a5a : 0xff993d;
                    textCol = col;
                    label = Fields.str(walking ? Rez.Strings.KeepGoing : Rez.Strings.MoveAlert);
                    // Blink the last segment while walking it off; high-power mode only, as this path is.
                    if (walking && sec % 2 == 1) { lit -= 1; }
                }
            } else if (p != null && p >= 1) {
                label = Fields.str(Rez.Strings.Recharged);
                col = 0xe5caff;
            } else {
                label = Fields.str(Rez.Strings.LRecovery) + " " + d[0];
            }
            for (var j = 0; j < lit && j < n; j++) { drawSegment(dc, k, j, n, col); }
            if (f == null) { continue; }
            dc.setColor(textCol, Graphics.COLOR_TRANSPARENT);
            dc.drawRadialText(CX, CX, f, label as String, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
                (450 - (SPANS[k][0] + SPANS[k][1]) / 2) % 360, LABEL_R,
                TOP[k] ? Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE : Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE);
        }
    }

    // Hybrid: stacked hours, minutes and seconds right of centre, under the hands.
    function drawDigits(dc as Dc, ct as System.ClockTime) as Void {
        dc.setColor(0xf5f6f7, Graphics.COLOR_TRANSPARENT);
        text(dc, 345 * S, 178 * S, 92, Fields.hour(ct.hour));
        text(dc, 345 * S, 262 * S, 92, ct.min.format("%02d"));
        text(dc, 345 * S, 322 * S, 36, ct.sec.format("%02d"));
    }

    // Chronos-style subdial: a flat plate inside a darker rim, thin progress ring.
    function drawGauge(dc as Dc, id as Number, c as Array<Float>, d as Array) as Void {
        var x = c[0], y = c[1], r = c[2], value = d[0] as String, p = d[1] as Float?;
        dc.setColor(0x0b0710, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r);
        dc.setColor(0x1a1224, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r - 5 * S);
        if (p != null) {
            dc.setPenWidth(3);
            dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, r - 3);
            dc.setColor(id == Fields.STRESS && p > 0.75 ? (accentIdx == AMBER ? 0xff5a5a : 0xff993d) : accent(), Graphics.COLOR_TRANSPARENT);
            if (p >= 1) { dc.drawCircle(x, y, r - 3); }
            else if (p > 0) {
                var end = (90 - p * 360).toNumber();
                dc.drawArc(x, y, r - 3, Graphics.ARC_CLOCKWISE, 90, end < 0 ? end + 360 : end);
            }
        }
        if (id == Fields.DATE) {
            // Weekday ring turns so today sits at the top (day_of_week: 1 = Sunday).
            var today = (d[3] as Number) - 1, days = "SMTWTFS";
            for (var i = 0; i < 7; i++) {
                var a = i * 2 * Math.PI / 7, k = (today + i) % 7;
                dc.setColor(i == 0 ? accent() : 0x9278a6, Graphics.COLOR_TRANSPARENT);
                text(dc, x + Math.sin(a) * (r - 14 * S), y - Math.cos(a) * (r - 14 * S), (r * 0.2 / S + 6).toNumber() / 2 * 2, days.substring(k, k + 1) as String);
            }
            dc.setColor(0xf5f6f7, Graphics.COLOR_TRANSPARENT);
            text(dc, x, y - r * 0.2, (r * 0.66 / S).toNumber() / 2 * 2, value);
            dc.setColor(0xb9a6c9, Graphics.COLOR_TRANSPARENT);
            text(dc, x, y + r * 0.27, (r * 0.34 / S).toNumber() / 2 * 2, d[2] as String);
            return;
        }
        // Icon, value, then the optional second line, stacked like the Chronos subdials.
        var sub = d[2] != null;
        drawIcon(dc, id, x - 7, y - r * (sub ? 0.62 : 0.55) - 4);
        var size = r * (sub ? 0.56 : 0.64) / S, fitSize = r * 1.5 / S / (value.length() * 0.62);
        dc.setColor(0xf5f6f7, Graphics.COLOR_TRANSPARENT);
        // Even sizes only, to bound the font cache.
        text(dc, x, y + (sub ? -r * 0.04 : 2 * S), (size < fitSize ? size : fitSize).toNumber() / 2 * 2, value);
        if (sub) {
            dc.setColor(id == Fields.WEATHER ? 0xf5f6f7 : accent(), Graphics.COLOR_TRANSPARENT);
            text(dc, x, y + r * 0.5, (r * 0.34 / S).toNumber() / 2 * 2, d[2] as String);
        }
    }

    function drawHand(dc as Dc, shape as Array<Array<Number>>, deg as Float, cx as Numeric, cy as Numeric, filled as Boolean) as Void {
        var a = deg * Math.PI / 180, s = Math.sin(a), c = Math.cos(a), pts = [] as Array<[Numeric, Numeric]>;
        for (var i = 0; i < shape.size(); i++) {
            var px = shape[i][0] * S, py = shape[i][1] * S;
            pts.add([cx + px * c - py * s, cy + px * s + py * c]);
        }
        if (filled) {
            dc.setColor(0xe5caff, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(pts);
            dc.setColor(0x553166, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(3);
        } else {
            dc.setColor(0x84718f, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
        }
        for (var i = 0; i < pts.size(); i++) {
            var q = pts[(i + 1) % pts.size()];
            dc.drawLine(pts[i][0], pts[i][1], q[0], q[1]);
        }
    }

    function drawSeconds(dc as Dc, deg as Float) as Void {
        var a = deg * Math.PI / 180, s = Math.sin(a), c = Math.cos(a);
        dc.setColor(accent(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(CX - s * 25 * S, CX + c * 25 * S, CX + s * 184 * S, CX - c * 184 * S);
        dc.setColor(0x08030d, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(CX - s * 20 * S, CX + c * 20 * S, 4 * S);
        dc.setColor(accent(), Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(CX - s * 20 * S, CX + c * 20 * S, 4 * S);
    }

    // ADR 0003: 1 px outlines, no filled hub, frame shifted by minute so no pixel stays lit 3 updates.
    function drawAlwaysOn(dc as Dc, m as Number) as Void {
        var sh = SHIFTS[m % 4], cx = CX + sh[0], cy = CX + sh[1], hs = Layout.hands(m);
        drawHand(dc, HOUR_AOD, hs[0][0], cx, cy, false);
        drawHand(dc, MINUTE_AOD, hs[1][0], cx, cy, false);
        dc.drawCircle(cx, cy, 6 * S);
    }

    // Icons from the prototype's dataIcon, in a 14x14 box at (ox, oy).
    function drawIcon(dc as Dc, id as Number, ox as Numeric, oy as Numeric) as Void {
        dc.setColor(accent(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        if (id == Fields.HEART || id == Fields.RESTING) {
            var heart = [[7, 13], [1, 7], [0, 3], [2, 0], [5, 0], [7, 3], [9, 0], [12, 0], [14, 3], [13, 7]];
            if (id == Fields.HEART) { dc.fillPolygon(offset(heart, ox, oy)); }
            else { poly(dc, heart, ox, oy, true); line(dc, ox, oy, 4, 7, 10, 7); }
        } else if (id == Fields.BATTERY) {
            dc.drawRectangle(ox, oy + 2, 12, 9);
            line(dc, ox, oy, 14, 5, 14, 8);
            line(dc, ox, oy, 3, 5, 3, 8); line(dc, ox, oy, 6, 5, 6, 8); line(dc, ox, oy, 9, 5, 9, 8);
        } else if (id == Fields.WEATHER) {
            // Sun behind a cloud, as on the Chronos weather subdial.
            dc.drawCircle(ox + 5, oy + 5, 3);
            line(dc, ox, oy, 5, -1, 5, 0); line(dc, ox, oy, -1, 5, 0, 5); line(dc, ox, oy, 1, 1, 2, 2); line(dc, ox, oy, 9, 1, 8, 2);
            dc.setColor(0x1c1426, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(ox + 2, oy + 7, 13, 7, 3);
            dc.setColor(accent(), Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(ox + 2, oy + 7, 13, 7, 3);
        } else if (id == Fields.SUNRISE) {
            dc.drawCircle(ox + 7, oy + 6, 3);
            line(dc, ox, oy, 7, 0, 7, 1); line(dc, ox, oy, 7, 11, 7, 12);
            line(dc, ox, oy, 0, 6, 1, 6); line(dc, ox, oy, 13, 6, 14, 6);
            line(dc, ox, oy, 2, 1, 3, 2); line(dc, ox, oy, 11, 10, 12, 11);
            line(dc, ox, oy, 2, 11, 3, 10); line(dc, ox, oy, 11, 2, 12, 1);
            line(dc, ox, oy, 0, 13, 14, 13);
        } else if (id == Fields.ZONE) {
            dc.drawCircle(ox + 7, oy + 7, 6);
            dc.drawEllipse(ox + 7, oy + 7, 2, 6);
            line(dc, ox, oy, 1, 7, 13, 7);
        } else if (id == Fields.FLOORS) {
            poly(dc, [[0, 13], [4, 13], [4, 9], [8, 9], [8, 5], [12, 5], [12, 1], [14, 1]], ox, oy, false);
        } else if (id == Fields.PULSEOX) {
            poly(dc, [[7, 0], [12, 7], [12, 10], [10, 13], [4, 13], [2, 10], [2, 7]], ox, oy, true);
        } else if (id == Fields.RESP) {
            poly(dc, [[0, 4], [4, 1], [8, 4], [12, 1]], ox, oy, false);
            poly(dc, [[0, 10], [4, 7], [8, 10], [12, 7]], ox, oy, false);
        } else if (id == Fields.HILOW) {
            dc.drawRoundedRectangle(ox + 5, oy, 4, 10, 2);
            dc.drawCircle(ox + 7, oy + 11, 3);
        } else if (id == Fields.BIKE) {
            dc.drawCircle(ox + 3, oy + 10, 3); dc.drawCircle(ox + 11, oy + 10, 3);
            poly(dc, [[3, 10], [6, 3], [11, 10]], ox, oy, false);
        } else if (id == Fields.RUN) {
            dc.drawCircle(ox + 8, oy + 2, 2);
            poly(dc, [[7, 5], [4, 9], [0, 10]], ox, oy, false);
            poly(dc, [[7, 5], [10, 8], [13, 7]], ox, oy, false);
            poly(dc, [[7, 5], [7, 9], [10, 13]], ox, oy, false);
        } else if (id == Fields.ALTITUDE) {
            poly(dc, [[0, 13], [5, 4], [8, 9], [10, 6], [14, 13]], ox, oy, true);
        } else if (id == Fields.PRESSURE) {
            dc.drawCircle(ox + 7, oy + 7, 6);
            line(dc, ox, oy, 7, 7, 10, 3);
        } else if (id == Fields.STRESS) {
            poly(dc, [[0, 7], [3, 7], [5, 2], [8, 12], [10, 7], [14, 7]], ox, oy, false);
        } else if (id == Fields.CALORIES) {
            poly(dc, [[7, 0], [12, 6], [12, 10], [9, 14], [4, 14], [1, 10], [2, 6], [5, 3], [5, 8]], ox, oy, false);
        } else if (id == Fields.DISTANCE) {
            poly(dc, [[1, 13], [5, 1], [9, 1], [13, 13]], ox, oy, false);
            line(dc, ox, oy, 7, 3, 7, 5); line(dc, ox, oy, 7, 8, 7, 10);
        } else {
            dc.drawRectangle(ox, oy + 1, 14, 12);
            line(dc, ox, oy, 0, 5, 14, 5); line(dc, ox, oy, 4, -1, 4, 3); line(dc, ox, oy, 10, -1, 10, 3);
        }
    }

    function offset(pts as Array<Array<Number>>, ox as Numeric, oy as Numeric) as Array<[Numeric, Numeric]> {
        var out = [] as Array<[Numeric, Numeric]>;
        for (var i = 0; i < pts.size(); i++) { out.add([ox + pts[i][0], oy + pts[i][1]]); }
        return out;
    }

    function line(dc as Dc, ox as Numeric, oy as Numeric, x1 as Number, y1 as Number, x2 as Number, y2 as Number) as Void {
        dc.drawLine(ox + x1, oy + y1, ox + x2, oy + y2);
    }

    function poly(dc as Dc, pts as Array<Array<Number>>, ox as Numeric, oy as Numeric, closed as Boolean) as Void {
        var n = pts.size();
        for (var i = 0; i < (closed ? n : n - 1); i++) {
            var q = pts[(i + 1) % n];
            line(dc, ox, oy, pts[i][0], pts[i][1], q[0], q[1]);
        }
    }
}
