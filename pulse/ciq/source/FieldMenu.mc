import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// On-watch settings for the four fields. Metrics used by another position are not offered.
// If getSettingsView rejects Menu2InputDelegate on device, delete this file and the
// getSettingsView override; phone settings plus the duplicate rule still apply.
function positionName(i as Number) as String {
    return WatchUi.loadResource([Rez.Strings.Top, Rez.Strings.Right, Rez.Strings.Bottom, Rez.Strings.Left][i]) as String;
}

function fieldAt(i as Number) as Number {
    return Application.Properties.getValue("field" + i) as Number;
}

class FieldMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => WatchUi.loadResource(Rez.Strings.Fields) as String});
        for (var i = 0; i < 4; i++) { addItem(new WatchUi.MenuItem(positionName(i), Fields.name(fieldAt(i)), i, {})); }
    }
}

class FieldMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() { Menu2InputDelegate.initialize(); }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var pos = item.getId() as Number;
        var menu = new WatchUi.Menu2({:title => positionName(pos)});
        for (var id = 0; id < Fields.COUNT; id++) {
            var taken = false;
            for (var j = 0; j < 4; j++) {
                if (j != pos && fieldAt(j) == id) { taken = true; }
            }
            if (!taken) { menu.addItem(new WatchUi.MenuItem(Fields.name(id), null, id, {})); }
        }
        WatchUi.pushView(menu, new MetricPickDelegate(pos, item), WatchUi.SLIDE_LEFT);
    }
}

class MetricPickDelegate extends WatchUi.Menu2InputDelegate {
    var pos as Number;
    var parent as WatchUi.MenuItem;

    function initialize(p as Number, item as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        pos = p;
        parent = item;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Number;
        Application.Properties.setValue("field" + pos, id);
        parent.setSubLabel(Fields.name(id));
        getApp().onSettingsChanged();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
