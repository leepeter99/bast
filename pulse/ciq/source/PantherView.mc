import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// WatchFace + Renderer: data first, hands last. Always-on mode follows ADR 0003, corner bars ADR 0005.
class PantherView extends WatchUi.WatchFace {
    var S as Float = 1.0;
    var CX as Float = 227.0;
    const ACCENTS = [0x9d7bff, 0x6a4cff, 0xd6ccff, 0xff993d, 0x52dfff, 0xb8ed95];
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
    const TRACK = 0x221a4a;
    // Move alert as vibranium charge by level 0-5: purple when charged, dimmer per idle level, then drained:
    // five empty cells outlined in electric violet, the alarm colour. GLOW is the hands' lilac: a fresh recharge and absorbed energy.
    // ALERT is that lilac's hue, dimmed for the alert words so they don't outshine the face.
    const CHARGE = [0x9d7bff, 0x8c68f5, 0x7a55e8, 0x6845d8, 0x5a38c8, 0xc44dff];
    const GLOW = 0xe9e3ff;
    const ALERT = 0x9585e6;
    const SHIFTS = [[0, 0], [2, 0], [2, 2], [0, 2]];
    // Hand outlines from the prototype SVG, relative to the centre, pointing at 12.
    const HOUR = [[-9, 6], [-10, -94], [0, -115], [10, -94], [9, 6]];
    const MINUTE = [[-6, 8], [-7, -149], [0, -168], [7, -149], [6, 8]];
    const HOUR_AOD = [[-6, -14], [-10, -94], [0, -115], [10, -94], [6, -14]];
    const MINUTE_AOD = [[-5, -14], [-7, -149], [0, -168], [7, -149], [5, -14]];

    var sleeping as Boolean = false;
    var fields as Array<Number> = [7, 4, 0];
    var bars as Array<Number> = [1, 3, 2, 4];
    var barValues as Array = [null, null, null, null];
    var accentIdx as Number = 0;
    var last as Array<Number> = [0, 4, 8];
    var slots as Array<Number> = [0, 4, 8];
    var circles as Array = [];
    var values as Array = [null, null, null];
    var cachedMin as Number = -1;
    var fonts as Dictionary<Number, Graphics.VectorFont?> = {};
    var edgeRef as Graphics.BufferedBitmapReference?;
    // Move alert state, sampled once a minute in both modes (ADR 0005). Level -1 = unavailable.
    var moveLevel as Number = -1;
    var moveSteps as Number? = null;
    var moveMin as Number = -1;
    var walking as Boolean = false;
    var resetUntil as Number = 0;
    // Icon transform (centre, scale, rotation), set by drawIcon for its helpers.
    var icX as Float = 0.0;
    var icY as Float = 0.0;
    var icK as Float = 1.0;
    var icS as Float = 0.0;
    var icC as Float = 1.0;

    function initialize() {
        WatchFace.initialize();
        var w = System.getDeviceSettings().screenWidth;
        Layout.setup(w);
        S = Layout.S; CX = Layout.CX; BAR_R = 214.0 * S; LABEL_R = 193.0 * S;
        loadSettings();
    }

    function loadSettings() as Void {
        for (var i = 0; i < 3; i++) { fields[i] = Fields.field(i); }
        bars = Fields.bars();
        accentIdx = Fields.index(Application.Properties.getValue("accent"), ACCENTS.size(), 0);
        last = [0, 4, 8];
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
            slots = Layout.assign(m, fields, last);
            last = slots;
            circles = Layout.fit(slots, m);
            for (var i = 0; i < 3; i++) { values[i] = Fields.read(fields[i]); }
            for (var i = 0; i < 4; i++) {
                barValues[i] = bars[i] == 0 ? null : Fields.read(Fields.BAR_IDS[bars[i]] as Number);
            }
            cachedMin = m;
        }
        dc.drawBitmap(0, 0, edge());
        drawBars(dc, ct.sec);
        for (var i = 0; i < 3; i++) {
            if (slots[i] < 0) { continue; }
            if (fields[i] == Fields.HEART) { values[i] = Fields.read(Fields.HEART); }
            drawGauge(dc, fields[i], circles[i] as Array<Float>, values[i] as Array);
        }
        var hs = Layout.hands(m);
        drawHand(dc, HOUR, hs[0][0], CX, CX, true);
        drawHand(dc, MINUTE, hs[1][0], CX, CX, true);
        drawSeconds(dc, ct.sec * 6.0);
        dc.setColor(tint(0xe9e3ff), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(CX, CX, 10 * S);
        dc.setColor(tint(0x2a1f5c), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawCircle(CX, CX, 10 * S);
    }

    function accent() as Number { return ACCENTS[accentIdx] as Number; }

    // Recolours the purple theme to the accent: same lightness, accent hue, brightest shades toward white.
    // Accent 0 is the purple the theme was drawn in, so it passes through untouched.
    function tint(c as Number) as Number {
        if (accentIdx == 0) { return c; }
        var a = accent(), r = (c >> 16) & 0xff, g = (c >> 8) & 0xff, b = c & 0xff;
        var f = (r > g ? (r > b ? r : b) : (g > b ? g : b)) / 255.0, w = f > 0.8 ? (f - 0.8) * 2.5 : 0.0;
        var out = 0;
        for (var sh = 16; sh >= 0; sh -= 8) {
            var v = ((a >> sh) & 0xff) * f;
            out = out << 8 | (v + (255 - v) * w).toNumber();
        }
        return out;
    }

    function dim(c as Number, f as Float) as Number {
        return (((c >> 16) & 0xff) * f).toNumber() << 16 | (((c >> 8) & 0xff) * f).toNumber() << 8 | ((c & 0xff) * f).toNumber();
    }

    // The drained-Move alarm: violet on the purple accents, otherwise orange (red on amber).
    function alarm() as Number { return accentIdx < 3 ? CHARGE[5] as Number : accentIdx == AMBER ? 0xff5a5a : 0xff993d; }

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
        // Poster backdrop: an indigo glow at the centre, eased to black under the ticks.
        for (var i = 1; i <= 20; i++) {
            var v = i * i;
            dc.setColor(tint((0x26 * v / 400) << 16 | (0x1b * v / 400) << 8 | 0x58 * v / 400), Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(CX, CX, (21 - i) * 10 * S);
        }
        for (var i = 0; i < 60; i++) {
            var deg = i * 6, covered = false;
            for (var k = 0; k < 4; k++) {
                if (bars[k] != 0 && deg >= SPANS[k][0] - 3 && deg <= SPANS[k][1] + 3) { covered = true; }
            }
            if (covered) { continue; }
            var cardinal = i % 15 == 0, major = i % 5 == 0, a = deg * Math.PI / 180, s = Math.sin(a), c = Math.cos(a);
            var r0 = (cardinal ? 225 : major ? 224 : 223) * S, r1 = (cardinal ? 200 : major ? 208 : 216) * S;
            dc.setPenWidth(((cardinal ? 6 : major ? 4 : 2) * S + 0.5).toNumber());
            dc.setColor(tint(cardinal ? 0xece6ff : major ? 0x9a8fd8 : 0x3b3178), Graphics.COLOR_TRANSPARENT);
            dc.drawLine(CX + s * r0, CX - c * r0, CX + s * r1, CX - c * r1);
        }
        for (var k = 0; k < 4; k++) {
            if (bars[k] == 0) { continue; }
            var n = segments(k);
            for (var j = 0; j < n; j++) { drawSegment(dc, k, j, n, tint(TRACK)); }
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

    // An empty cell: the segment in col with a black centre, leaving a rim about 3 px wide.
    function drawHollow(dc as Dc, k as Number, j as Number, n as Number, col as Number) as Void {
        var a = SPANS[k][0], w = (SPANS[k][1] - a) / n, idx = FROM_START[k] ? j : n - 1 - j;
        drawSegment(dc, k, j, n, col);
        dc.setPenWidth((10 * S).toNumber());
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(CX, CX, BAR_R, Graphics.ARC_CLOCKWISE, (450 - a - idx * w - 2) % 360, (450 - a - (idx + 1) * w + 2) % 360);
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
        var f = font((24 * S).toNumber());
        for (var k = 0; k < 4; k++) {
            var d = barValues[k] as Array?;
            if (bars[k] == 0 || d == null) { continue; }
            var id = Fields.BAR_IDS[bars[k]] as Number, n = segments(k), p = d[1] as Float?, col = accent(), textCol = 0xf5f6f7, pulse = -1, hollow = false;
            var num = "" as String;
            var lit = p == null ? 0 : (p * n).toNumber();
            if (id == Fields.STEPS) {
                num = (d[(d.size() > 3 ? 3 : 0)] as Object).toString();
            } else if (id == Fields.BODY) {
                num = d[0] as String;
            } else if (id == Fields.STRESS) {
                // Full = calm, like the other bars.
                lit = p == null ? 0 : ((1 - p) * n).toNumber();
                num = d[0] as String;
                if (p != null && p > 0.75) { col = accentIdx == AMBER ? 0xff5a5a : 0xff993d; }
            } else if (id == Fields.FLOORS) {
                num = d[0] as String;
            } else if (id == Fields.MOVE) {
                if (moveLevel < 0) { lit = 0; num = "--"; }
                else if (moveLevel == 0) {
                    var fresh = Time.now().value() < resetUntil;
                    lit = n;
                    col = fresh ? tint(GLOW) : accent();
                    // White CHARGED like the other bars' labels; during an alert the words take a dimmed hand lilac.
                    num = Fields.str(Rez.Strings.Active);
                } else {
                    var lv = moveLevel < n ? moveLevel : n;
                    lit = n - lv;
                    col = lv == 5 ? alarm() : accentIdx == 0 ? CHARGE[lv] as Number : dim(accent(), 1.0 - lv * 0.1);
                    textCol = tint(ALERT);
                    hollow = lit == 0;
                    num = Fields.str(walking ? Rez.Strings.KeepGoing : Rez.Strings.MoveAlert) + " " + moveLevel + "/5";
                    // Walking it off: absorbed energy runs along the empty segments, one per second in high-power mode.
                    if (walking) { pulse = lit + sec % (n - lit); }
                }
            } else if (p != null && p >= 1) {
                num = Fields.str(Rez.Strings.Recharged);
                col = tint(0xe9e3ff);
            } else {
                num = d[0] as String;
            }
            for (var j = 0; j < lit && j < n; j++) { drawSegment(dc, k, j, n, col); }
            for (var j = 0; hollow && j < n; j++) { drawHollow(dc, k, j, n, col); }
            if (pulse >= 0) { drawSegment(dc, k, pulse, n, tint(GLOW)); }
            // Icon, then the number, centred on the bar's middle along the label arc. The icon turns with the
            // arc so it stands upright beside the text, which reads clockwise on top and counter-clockwise below.
            // ponytail: text width estimated at 0.5 em per glyph; measure it if labels look off-centre.
            var mid = (SPANS[k][0] + SPANS[k][1]) / 2.0, dir = TOP[k] ? 1 : -1, deg = 180 / Math.PI / LABEL_R;
            var iw = 24 * S, tw = num.length() * 12 * S, gap = num.length() > 0 ? 6 * S : 0, w = iw + gap + tw;
            var ia = mid + dir * (iw - w) / 2 * deg, ta = mid + dir * (iw + gap + tw / 2 - w / 2) * deg, a = ia * Math.PI / 180;
            // Icons always take the accent; only the words carry an alert colour.
            drawIcon(dc, id, CX + Math.sin(a) * LABEL_R, CX - Math.cos(a) * LABEL_R, 1.4 * S, TOP[k] ? ia : ia + 180, accent(), Graphics.COLOR_BLACK);
            if (f == null || num.length() == 0) { continue; }
            dc.setColor(textCol, Graphics.COLOR_TRANSPARENT);
            dc.drawRadialText(CX, CX, f, num, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
                (450 - ta).toNumber() % 360, LABEL_R,
                TOP[k] ? Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE : Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE);
        }
    }

    // Chronos-style subdial: a flat plate inside a darker rim, thin progress ring.
    function drawGauge(dc as Dc, id as Number, c as Array<Float>, d as Array) as Void {
        var x = c[0], y = c[1], r = c[2], value = d[0] as String, p = d[1] as Float?;
        dc.setColor(tint(0x0a0820), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r);
        dc.setColor(tint(0x1a1542), Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r - 5 * S);
        if (p != null) {
            dc.setPenWidth(3);
            dc.setColor(tint(TRACK), Graphics.COLOR_TRANSPARENT);
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
                dc.setColor(i == 0 ? accent() : tint(0x8a7fc8), Graphics.COLOR_TRANSPARENT);
                text(dc, x + Math.sin(a) * (r - 14 * S), y - Math.cos(a) * (r - 14 * S), (r * 0.2 / S + 6).toNumber() / 2 * 2, days.substring(k, k + 1) as String);
            }
            dc.setColor(0xf5f6f7, Graphics.COLOR_TRANSPARENT);
            text(dc, x, y - r * 0.2, (r * 0.66 / S).toNumber() / 2 * 2, value);
            dc.setColor(tint(0xb5abe6), Graphics.COLOR_TRANSPARENT);
            text(dc, x, y + r * 0.27, (r * 0.34 / S).toNumber() / 2 * 2, d[2] as String);
            return;
        }
        // Icon, value, then the optional second line, stacked like the Chronos subdials.
        var sub = d[2] != null;
        drawIcon(dc, id, x, y - r * (sub ? 0.62 : 0.55) + 3, S, 0.0, accent(), tint(0x1a1542));
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
            dc.setColor(tint(0xe9e3ff), Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(pts);
            dc.setColor(tint(0x2e2370), Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(3);
        } else {
            dc.setColor(tint(0x8a80c0), Graphics.COLOR_TRANSPARENT);
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
        dc.setColor(tint(0x0a0820), Graphics.COLOR_TRANSPARENT);
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

    // Black Panther icons on a 16 px grid, centred at (cx, cy), scaled by k and turned rot degrees clockwise.
    // col draws the icon; bg is the surface behind it, for cut lines and filled outlines.
    function drawIcon(dc as Dc, id as Number, cx as Numeric, cy as Numeric, k as Float, rot as Float, col as Number, bg as Number) as Void {
        var a = rot * Math.PI / 180;
        icX = cx.toFloat(); icY = cy.toFloat(); icK = k; icS = Math.sin(a).toFloat(); icC = Math.cos(a).toFloat();
        dc.setColor(col, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth((2 * k + 0.5).toNumber());
        if (id == Fields.HEART) {
            // The heart-shaped herb, its veins cut out.
            fp(dc, [[8, 15], [1, 8], [0, 4], [2, 1], [5, 1], [8, 4], [11, 1], [14, 1], [16, 4], [15, 8]]);
            dc.setColor(bg, Graphics.COLOR_TRANSPARENT);
            pl(dc, [[8, 5], [8, 12]], false); pl(dc, [[8, 8], [5, 6]], false); pl(dc, [[8, 10], [11, 8]], false);
        } else if (id == Fields.RESTING) {
            pl(dc, [[8, 15], [1, 8], [0, 4], [2, 1], [5, 1], [8, 4], [11, 1], [14, 1], [16, 4], [15, 8]], true);
            pl(dc, [[8, 6], [8, 12]], false);
        } else if (id == Fields.RECOVERY) {
            // A herb sprout.
            pl(dc, [[8, 16], [8, 7]], false);
            pl(dc, [[8, 9], [4, 9], [1, 6], [2, 3], [5, 3], [8, 7]], true);
            pl(dc, [[8, 7], [11, 2], [14, 2], [16, 5], [13, 8], [8, 8]], true);
        } else if (id == Fields.BODY) {
            // A solid vibranium cell with a lightning bolt cut out: stored energy.
            fp(dc, [[8, 0], [14, 4], [14, 12], [8, 16], [2, 12], [2, 4]]);
            dc.setColor(bg, Graphics.COLOR_TRANSPARENT);
            fp(dc, [[10, 1], [4, 9], [8, 9], [6, 15], [12, 7], [8, 7]]);
        } else if (id == Fields.STEPS) {
            // A panther paw print: a wide pad and four toes, with clear gaps so it reads at bar size.
            fp(dc, [[8, 9], [12, 11], [14, 14], [12, 16], [4, 16], [2, 14], [4, 11]]);
            ci(dc, 1.5, 8, 1.8, true); ci(dc, 5.5, 3.5, 1.8, true); ci(dc, 10.5, 3.5, 1.8, true); ci(dc, 14.5, 8, 1.8, true);
        } else if (id == Fields.MOVE) {
            // The panther mask.
            pl(dc, [[1, 0], [5, 4], [11, 4], [15, 0], [15, 8], [8, 16], [1, 8]], true);
            fp(dc, [[3, 8], [7, 9], [6, 11]]); fp(dc, [[13, 8], [9, 9], [10, 11]]);
        } else if (id == Fields.STRESS) {
            // The fangs of the panther necklace.
            pl(dc, [[0, 2], [4, 4], [8, 5], [12, 4], [16, 2]], false);
            fp(dc, [[2, 3], [5, 4], [3, 11]]); fp(dc, [[6, 5], [10, 5], [8, 14]]); fp(dc, [[11, 4], [14, 3], [13, 11]]);
        } else if (id == Fields.FLOORS) {
            // Warrior Falls.
            pl(dc, [[0, 16], [0, 11], [4, 11], [4, 6], [8, 6], [8, 1], [11, 1]], false);
            pl(dc, [[11, 3], [11, 16]], false); pl(dc, [[14, 1], [14, 16]], false);
        } else if (id == Fields.WEATHER) {
            ci(dc, 6, 5, 3, false);
            pl(dc, [[6, 0], [6, 1]], false); pl(dc, [[0, 5], [1, 5]], false); pl(dc, [[2, 1], [3, 2]], false); pl(dc, [[10, 1], [9, 2]], false);
            plate(dc, [[2, 15], [0, 12], [3, 9], [7, 9], [9, 7], [13, 8], [16, 12], [15, 15]], col, bg);
        } else if (id == Fields.BATTERY) {
            pl(dc, [[0, 4], [13, 4], [13, 12], [0, 12]], true);
            pl(dc, [[15, 6], [15, 10]], false); fp(dc, [[3, 10], [7, 6], [10, 10]]);
        } else if (id == Fields.CALORIES) {
            pl(dc, [[8, 0], [13, 7], [13, 11], [9, 16], [5, 16], [2, 11], [3, 7], [6, 9]], true);
            fp(dc, [[6, 14], [8, 10], [10, 14]]);
        } else if (id == Fields.DISTANCE) {
            // A vibranium spear.
            pl(dc, [[2, 14], [12, 4]], false); fp(dc, [[16, 0], [9, 3], [13, 7]]);
            pl(dc, [[3, 10], [6, 13]], false); pl(dc, [[0, 16], [2, 14]], false);
        } else if (id == Fields.SUNRISE) {
            ci(dc, 11, 6, 3, false);
            plate(dc, [[0, 15], [5, 6], [8, 10], [10, 8], [16, 15]], col, bg);
        } else if (id == Fields.ZONE) {
            // A Kimoyo bead with the Wakandan triangle.
            ci(dc, 8, 8, 7, false); pl(dc, [[8, 3], [13, 11], [3, 11]], true);
        } else if (id == Fields.PULSEOX) {
            pl(dc, [[8, 0], [14, 8], [14, 11], [11, 15], [5, 15], [2, 11], [2, 8]], true);
            fp(dc, [[8, 7], [10, 10], [8, 13], [6, 10]]);
        } else if (id == Fields.RESP) {
            pl(dc, [[0, 4], [10, 4], [13, 1]], false); pl(dc, [[0, 9], [13, 9], [16, 12]], false); pl(dc, [[3, 14], [9, 14]], false);
        } else if (id == Fields.HILOW) {
            pl(dc, [[6, 9], [6, 3], [8, 0], [10, 3], [10, 9]], false); ci(dc, 8, 12, 3, true);
        } else if (id == Fields.BIKE) {
            ci(dc, 3, 11, 3, false); ci(dc, 13, 11, 3, false);
            pl(dc, [[3, 11], [7, 4], [13, 11]], true); pl(dc, [[6, 4], [9, 4]], false);
        } else if (id == Fields.RUN) {
            fp(dc, [[8, 15], [7, 12], [9, 10], [13, 10], [15, 12], [14, 15]]);
            ci(dc, 8, 7, 1.5, true); ci(dc, 11, 5, 1.5, true); ci(dc, 15, 7, 1.5, true);
            pl(dc, [[0, 8], [4, 8]], false); pl(dc, [[1, 11], [5, 11]], false); pl(dc, [[0, 14], [4, 14]], false);
        } else if (id == Fields.ALTITUDE) {
            // Mount Bashenga.
            pl(dc, [[0, 15], [6, 3], [9, 8], [11, 5], [16, 15]], true); fp(dc, [[6, 3], [4, 7], [8, 7]]);
        } else if (id == Fields.PRESSURE) {
            ci(dc, 8, 8, 7, false); pl(dc, [[8, 8], [12, 4]], false); ci(dc, 8, 8, 1.5, true);
        }
    }

    // Icon grid point to screen.
    function ip(x as Numeric, y as Numeric) as [Numeric, Numeric] {
        var dx = (x - 8) * icK, dy = (y - 8) * icK;
        return [icX + dx * icC - dy * icS, icY + dx * icS + dy * icC];
    }

    function pl(dc as Dc, pts as Array, closed as Boolean) as Void {
        var n = pts.size();
        for (var i = 0; i < (closed ? n : n - 1); i++) {
            var p = pts[i] as Array<Numeric>, q = pts[(i + 1) % n] as Array<Numeric>, a = ip(p[0], p[1]), b = ip(q[0], q[1]);
            dc.drawLine(a[0], a[1], b[0], b[1]);
        }
    }

    function fp(dc as Dc, pts as Array) as Void {
        var out = [] as Array<[Numeric, Numeric]>;
        for (var i = 0; i < pts.size(); i++) { var p = pts[i] as Array<Numeric>; out.add(ip(p[0], p[1])); }
        dc.fillPolygon(out);
    }

    function ci(dc as Dc, x as Numeric, y as Numeric, r as Numeric, filled as Boolean) as Void {
        var c = ip(x, y);
        if (filled) { dc.fillCircle(c[0], c[1], r * icK); } else { dc.drawCircle(c[0], c[1], r * icK); }
    }

    // A shape filled with the background, then outlined, so it covers what is behind it.
    function plate(dc as Dc, pts as Array, col as Number, bg as Number) as Void {
        dc.setColor(bg, Graphics.COLOR_TRANSPARENT);
        fp(dc, pts);
        dc.setColor(col, Graphics.COLOR_TRANSPARENT);
        pl(dc, pts, true);
    }
}
