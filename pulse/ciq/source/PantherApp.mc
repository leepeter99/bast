import Toybox.Application;
import Toybox.Complications;
import Toybox.Lang;
import Toybox.WatchUi;

class PantherApp extends Application.AppBase {
    var view as PantherView?;

    function initialize() { AppBase.initialize(); }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var v = new PantherView();
        view = v;
        return [v, new PantherDelegate(v)];
    }

    function getSettingsView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] or Null {
        return [new FieldMenu(), new FieldMenuDelegate()];
    }

    function onSettingsChanged() as Void {
        if (view != null) { view.loadSettings(); }
        WatchUi.requestUpdate();
    }
}

// Hold to launch: pressing and holding the Air quality gauge opens the Atmos app that publishes it.
// Only some watches send the press; elsewhere nothing happens.
class PantherDelegate extends WatchUi.WatchFaceDelegate {
    var view as PantherView;

    function initialize(v as PantherView) {
        WatchFaceDelegate.initialize();
        view = v;
    }

    function onPress(e as WatchUi.ClickEvent) as Boolean {
        var id = Fields.airId, xy = e.getCoordinates();
        if (id == null) { return false; }
        for (var i = 0; i < 3 && i < view.circles.size(); i++) {
            if (view.fields[i] != Fields.AIR || view.slots[i] < 0) { continue; }
            var c = view.circles[i] as Array<Float>, dx = xy[0] - c[0], dy = xy[1] - c[1];
            if (dx * dx + dy * dy > c[2] * c[2]) { continue; }
            try {
                Complications.exitTo(id);
                return true;
            } catch (ex) {
                return false;
            }
        }
        return false;
    }
}

function getApp() as PantherApp {
    return Application.getApp() as PantherApp;
}
