import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

// WatchFace + Renderer: data first, hands last. Always-on mode follows ADR 0003.
class PantherView extends WatchUi.WatchFace {
    const CX = 227;
    const ACCENTS = [0xbc73ff, 0x9252e3, 0xdcadff, 0xff993d, 0x52dfff, 0xb8ed95];
    const AMBER = 3;
    const SHIFTS = [[0, 0], [2, 0], [2, 2], [0, 2]];
    // Hand outlines from the prototype SVG, relative to the centre, pointing at 12.
    const HOUR = [[-9, 6], [-10, -94], [0, -115], [10, -94], [9, 6]];
    const MINUTE = [[-6, 8], [-7, -149], [0, -168], [7, -149], [6, 8]];
    const HOUR_AOD = [[-6, -14], [-10, -94], [0, -115], [10, -94], [6, -14]];
    const MINUTE_AOD = [[-5, -14], [-7, -149], [0, -168], [7, -149], [5, -14]];

    var sleeping = false;
    var fields as Array<Number> = [5, 6, 0, 7];
    var accentIdx = 0;
    var ringStyle = 0;
    var last as Array<Number> = [0, 2, 4, 6];
    var slots as Array<Number> = [0, 2, 4, 6];
    var circles as Array = [];
    var cachedMin = -1;
    var fonts as Dictionary = {};

    function initialize() {
        WatchFace.initialize();
        loadSettings();
    }

    function loadSettings() as Void {
        var p = Application.Properties;
        for (var i = 0; i < 4; i++) { fields[i] = p.getValue("field" + i) as Number; }
        accentIdx = p.getValue("accent") as Number;
        ringStyle = p.getValue("ringStyle") as Number;
        last = [0, 2, 4, 6];
        cachedMin = -1;
    }

    function onEnterSleep() as Void { sleeping = true; WatchUi.requestUpdate(); }

    function onExitSleep() as Void { sleeping = false; cachedMin = -1; WatchUi.requestUpdate(); }

    function onUpdate(dc as Dc) as Void {
        var ct = System.getClockTime(), m = (ct.hour % 12) * 60 + ct.min;
        dc.setAntiAlias(true);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (sleeping) { drawAlwaysOn(dc, m); return; }
        if (m != cachedMin) {
            slots = Layout.assign(m, fields, last);
            last = slots;
            circles = Layout.fit(slots, m);
            cachedMin = m;
        }
        drawDial(dc);
        for (var i = 0; i < 4; i++) {
            if (slots[i] >= 0) { drawGauge(dc, fields[i], circles[i]); }
        }
        var hs = Layout.hands(m);
        drawHand(dc, HOUR, hs[0][0], CX, CX, true);
        drawHand(dc, MINUTE, hs[1][0], CX, CX, true);
        drawSeconds(dc, ct.sec * 6.0);
        dc.setColor(0xe5caff, -1);
        dc.fillCircle(CX, CX, 10);
        dc.setColor(0x283334, -1);
        dc.setPenWidth(4);
        dc.drawCircle(CX, CX, 10);
    }

    function accent() as Number { return ACCENTS[accentIdx]; }

    function font(size as Number) {
        if (!fonts.hasKey(size)) { fonts[size] = Graphics.getVectorFont({:face => "RobotoCondensedBold", :size => size}); }
        return fonts[size];
    }

    function text(dc as Dc, x as Numeric, y as Numeric, size as Number, s as String) as Void {
        var f = font(size);
        if (f != null) {
            dc.drawAngledText(x, y, f, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER, 0);
        } else {
            dc.drawText(x, y, Graphics.FONT_XTINY, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Rings, minute ticks and the chapter ring style (prototype lines 12-13).
    function drawDial(dc as Dc) as Void {
        dc.setPenWidth(2);
        dc.setColor(0x49245c, -1);
        dc.drawCircle(CX, CX, 181);
        dc.setPenWidth(1);
        dc.setColor(0x50325e, -1);
        dc.drawCircle(CX, CX, 204);
        for (var i = 0; i < 60; i++) {
            var major = i % 5 == 0, a = i * Math.PI / 30, s = Math.sin(a), c = Math.cos(a);
            var r0 = major ? 207 : 203, r1 = major ? 187 : 198;
            dc.setPenWidth(major ? 6 : 2);
            dc.setColor(major ? 0xdac5eb : 0x513262, -1);
            dc.drawLine(CX + s * r0, CX - c * r0, CX + s * r1, CX - c * r1);
        }
        if (ringStyle == 2) { return; }
        for (var i = 0; i < 12; i++) {
            var a = i * Math.PI / 6, cardinal = i % 3 == 0, label;
            if (ringStyle == 1) { label = (i == 0 ? 12 : i).toString(); }
            else { label = i == 0 ? "N" : i == 3 ? "E" : i == 6 ? "S" : i == 9 ? "W" : (i * 30).toString(); }
            dc.setColor(cardinal ? 0xe5cff6 : 0x9278a6, -1);
            text(dc, CX + Math.sin(a) * 214, CX - Math.cos(a) * 214, cardinal ? 13 : 10, label);
        }
    }

    function drawGauge(dc as Dc, id as Number, c as Array) as Void {
        var x = c[0], y = c[1], r = c[2], d = Fields.read(id), value = d[0] as String, p = d[1];
        dc.setColor(0x100818, -1);
        dc.fillCircle(x, y, r);
        dc.setPenWidth(2);
        dc.setColor(0x643887, -1);
        dc.drawCircle(x, y, r);
        if (p == null) {
            dc.setPenWidth(1);
            dc.setColor(accent(), -1);
            dc.drawCircle(x, y, r - 5);
        } else {
            dc.setPenWidth(4);
            dc.setColor(0x2a1838, -1);
            dc.drawCircle(x, y, r - 5);
            var col = accent();
            if (id == Fields.STRESS && p > 0.75) { col = accentIdx == AMBER ? 0xff5a5a : 0xff993d; }
            dc.setColor(col, -1);
            if (p >= 1) { dc.drawCircle(x, y, r - 5); }
            else if (p > 0) {
                var end = (90 - p * 360).toNumber();
                dc.drawArc(x, y, r - 5, Graphics.ARC_CLOCKWISE, 90, end < 0 ? end + 360 : end);
            }
        }
        drawIcon(dc, id, x - 7, y - 24);
        var size = 24 * r / 44, fitSize = r * 1.5 / (value.length() * 0.62);
        dc.setColor(0xf5f6f7, -1);
        text(dc, x, y + 9, (size < fitSize ? size : fitSize).toNumber(), value);
        if (d[2] != null) {
            dc.setColor(accent(), -1);
            text(dc, x, y + 28, 11, d[2] as String);
        }
    }

    function drawHand(dc as Dc, shape as Array, deg as Float, cx as Number, cy as Number, filled as Boolean) as Void {
        var a = deg * Math.PI / 180, s = Math.sin(a), c = Math.cos(a), pts = [];
        for (var i = 0; i < shape.size(); i++) {
            var px = shape[i][0], py = shape[i][1];
            pts.add([cx + px * c - py * s, cy + px * s + py * c]);
        }
        if (filled) {
            dc.setColor(0xe5caff, -1);
            dc.fillPolygon(pts);
            dc.setColor(0x553166, -1);
            dc.setPenWidth(3);
        } else {
            dc.setColor(0x84718f, -1);
            dc.setPenWidth(1);
        }
        for (var i = 0; i < pts.size(); i++) {
            var q = pts[(i + 1) % pts.size()];
            dc.drawLine(pts[i][0], pts[i][1], q[0], q[1]);
        }
    }

    function drawSeconds(dc as Dc, deg as Float) as Void {
        var a = deg * Math.PI / 180, s = Math.sin(a), c = Math.cos(a);
        dc.setColor(accent(), -1);
        dc.setPenWidth(2);
        dc.drawLine(CX - s * 25, CX + c * 25, CX + s * 184, CX - c * 184);
        dc.setColor(0x08030d, -1);
        dc.fillCircle(CX - s * 20, CX + c * 20, 4);
        dc.setColor(accent(), -1);
        dc.drawCircle(CX - s * 20, CX + c * 20, 4);
    }

    // ADR 0003: 1 px outlines, no filled hub, frame shifted by minute so no pixel stays lit 3 updates.
    function drawAlwaysOn(dc as Dc, m as Number) as Void {
        var sh = SHIFTS[m % 4], cx = CX + sh[0], cy = CX + sh[1], hs = Layout.hands(m);
        drawHand(dc, HOUR_AOD, hs[0][0], cx, cy, false);
        drawHand(dc, MINUTE_AOD, hs[1][0], cx, cy, false);
        dc.drawCircle(cx, cy, 6);
    }

    // Icons from the prototype's dataIcon, in a 14x14 box at (ox, oy).
    function drawIcon(dc as Dc, id as Number, ox as Numeric, oy as Numeric) as Void {
        dc.setColor(accent(), -1);
        dc.setPenWidth(2);
        if (id == Fields.HEART || id == Fields.RESTING) {
            var heart = [[7, 13], [1, 7], [0, 3], [2, 0], [5, 0], [7, 3], [9, 0], [12, 0], [14, 3], [13, 7]];
            if (id == Fields.HEART) { dc.fillPolygon(offset(heart, ox, oy)); }
            else { poly(dc, heart, ox, oy, true); line(dc, ox, oy, 4, 7, 10, 7); }
        } else if (id == Fields.BATTERY) {
            dc.drawRectangle(ox, oy + 2, 12, 9);
            line(dc, ox, oy, 14, 5, 14, 8);
            line(dc, ox, oy, 3, 5, 3, 8); line(dc, ox, oy, 6, 5, 6, 8); line(dc, ox, oy, 9, 5, 9, 8);
        } else if (id == Fields.STEPS) {
            dc.drawEllipse(ox + 4, oy + 4, 2, 4);
            dc.drawEllipse(ox + 11, oy + 8, 2, 4);
        } else if (id == Fields.RECOVERY) {
            dc.drawCircle(ox + 7, oy + 7, 6);
            poly(dc, [[7, 3], [7, 7], [10, 9]], ox, oy, false);
        } else if (id == Fields.BODY) {
            dc.fillPolygon(offset([[8, 0], [2, 8], [7, 8], [6, 14], [13, 5], [8, 5]], ox, oy));
        } else if (id == Fields.WEATHER || id == Fields.SUNRISE) {
            dc.drawCircle(ox + 7, oy + 6, 3);
            line(dc, ox, oy, 7, 0, 7, 1); line(dc, ox, oy, 7, 11, 7, 12);
            line(dc, ox, oy, 0, 6, 1, 6); line(dc, ox, oy, 13, 6, 14, 6);
            line(dc, ox, oy, 2, 1, 3, 2); line(dc, ox, oy, 11, 10, 12, 11);
            line(dc, ox, oy, 2, 11, 3, 10); line(dc, ox, oy, 11, 2, 12, 1);
            if (id == Fields.SUNRISE) { line(dc, ox, oy, 0, 13, 14, 13); }
        } else if (id == Fields.ZONE) {
            dc.drawCircle(ox + 7, oy + 7, 6);
            dc.drawEllipse(ox + 7, oy + 7, 2, 6);
            line(dc, ox, oy, 1, 7, 13, 7);
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

    function offset(pts as Array, ox as Numeric, oy as Numeric) as Array {
        var out = [];
        for (var i = 0; i < pts.size(); i++) { out.add([ox + pts[i][0], oy + pts[i][1]]); }
        return out;
    }

    function line(dc as Dc, ox as Numeric, oy as Numeric, x1 as Number, y1 as Number, x2 as Number, y2 as Number) as Void {
        dc.drawLine(ox + x1, oy + y1, ox + x2, oy + y2);
    }

    function poly(dc as Dc, pts as Array, ox as Numeric, oy as Numeric, closed as Boolean) as Void {
        var n = pts.size();
        for (var i = 0; i < (closed ? n : n - 1); i++) {
            var q = pts[(i + 1) % n];
            line(dc, ox, oy, pts[i][0], pts[i][1], q[0], q[1]);
        }
    }
}
