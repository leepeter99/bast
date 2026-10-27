import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// On-watch settings: time style, the four gauges and the four corner bars. A picker never offers
// a metric used elsewhere in its group, or a bar metric as a gauge.
// If getSettingsView rejects Menu2InputDelegate on device, delete this file and the
// getSettingsView override; phone settings plus the duplicate rules still apply.
function res(id as ResourceId) as String { return WatchUi.loadResource(id) as String; }

function positionName(i as Number) as String { return res([Rez.Strings.Top, Rez.Strings.Right, Rez.Strings.Bottom, Rez.Strings.Left][i] as ResourceId); }

function cornerName(k as Number) as String { return res([Rez.Strings.Bar0, Rez.Strings.Bar1, Rez.Strings.Bar2, Rez.Strings.Bar3][k] as ResourceId); }

function barName(b as Number) as String { return res([Rez.Strings.B0, Rez.Strings.B1, Rez.Strings.B2, Rez.Strings.B3, Rez.Strings.B4, Rez.Strings.B5, Rez.Strings.B6][b] as ResourceId); }

function styleName(t as Number) as String { return res(t == 1 ? Rez.Strings.T1 : Rez.Strings.T0); }

function timeStyle() as Number { return Fields.index(Application.Properties.getValue("timeStyle"), 2, 0); }

class FieldMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => res(Rez.Strings.Fields)});
        addItem(new WatchUi.MenuItem(res(Rez.Strings.TimeStyle), styleName(timeStyle()), :time, {}));
        addItem(new WatchUi.MenuItem(res(Rez.Strings.Gauges), null, :gauges, {}));
        addItem(new WatchUi.MenuItem(res(Rez.Strings.CornerBars), null, :bars, {}));
    }
}

class FieldMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() { Menu2InputDelegate.initialize(); }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :time) {
            var menu = new WatchUi.Menu2({:title => res(Rez.Strings.TimeStyle)});
            for (var t = 0; t < 2; t++) { menu.addItem(new WatchUi.MenuItem(styleName(t), null, t, {})); }
            WatchUi.pushView(menu, new PickDelegate("timeStyle", item, :style), WatchUi.SLIDE_LEFT);
            return;
        }
        var gauges = id == :gauges, menu = new WatchUi.Menu2({:title => item.getLabel()});
        for (var i = 0; i < 4; i++) {
            menu.addItem(gauges
                ? new WatchUi.MenuItem(positionName(i), Fields.name(Fields.field(i)), i, {})
                : new WatchUi.MenuItem(cornerName(i), barName(Fields.bars()[i]), i, {}));
        }
        WatchUi.pushView(menu, new GroupDelegate(gauges), WatchUi.SLIDE_LEFT);
    }
}

// One position in the gauge or bar group: offer what no other position in the group uses.
class GroupDelegate extends WatchUi.Menu2InputDelegate {
    var gauges as Boolean;

    function initialize(g as Boolean) {
        Menu2InputDelegate.initialize();
        gauges = g;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var pos = item.getId() as Number, bars = Fields.bars();
        var menu = new WatchUi.Menu2({:title => item.getLabel()});
        for (var id = 0; id < (gauges ? Fields.COUNT : Fields.BAR_IDS.size()); id++) {
            var taken = gauges && Fields.fixed(id);
            for (var j = 0; j < 4; j++) {
                // Off (bar 0) may repeat.
                if (j != pos && (gauges ? Fields.field(j) == id : id != 0 && bars[j] == id)) { taken = true; }
            }
            if (!taken) { menu.addItem(new WatchUi.MenuItem(gauges ? Fields.name(id) : barName(id), null, id, {})); }
        }
        WatchUi.pushView(menu, new PickDelegate((gauges ? "field" : "bar") + pos, item, gauges ? :gauge : :bar), WatchUi.SLIDE_LEFT);
    }
}

// Writes the chosen value and refreshes the parent item and the face.
class PickDelegate extends WatchUi.Menu2InputDelegate {
    var key as String;
    var parent as WatchUi.MenuItem;
    var kind as Symbol;

    function initialize(k as String, item as WatchUi.MenuItem, what as Symbol) {
        Menu2InputDelegate.initialize();
        key = k;
        parent = item;
        kind = what;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Number;
        Application.Properties.setValue(key, id);
        parent.setSubLabel(kind == :gauge ? Fields.name(id) : kind == :bar ? barName(id) : styleName(id));
        getApp().onSettingsChanged();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
