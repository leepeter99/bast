import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PantherApp extends Application.AppBase {
    var view as PantherView?;

    function initialize() { AppBase.initialize(); }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        view = new PantherView();
        return [view];
    }

    function getSettingsView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] or Null {
        return [new FieldMenu(), new FieldMenuDelegate()];
    }

    function onSettingsChanged() as Void {
        if (view != null) { view.loadSettings(); }
        WatchUi.requestUpdate();
    }
}

function getApp() as PantherApp {
    return Application.getApp() as PantherApp;
}
