// Saatzeit: Scene-Lebenszyklus. Ab iOS 27 beendet iOS Apps ohne Scenes direkt beim Start
// (die Vorlage von Capacitor 7 hat keine). scripts/ios-setup.rb kopiert diese Datei nach ios/App/App,
// traegt sie im Projekt ein und ergaenzt die Info.plist um UIApplicationSceneManifest.
import UIKit
import Capacitor

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Das Fenster mit Main.storyboard (CAPBridgeViewController) legt iOS selbst an.
        // Plugins, die das Fenster beim AppDelegate suchen, finden es dort weiterhin.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window = window
        }
        if let context = connectionOptions.urlContexts.first {
            _ = ApplicationDelegateProxy.shared.application(UIApplication.shared, open: context.url, options: [:])
        }
        if let activity = connectionOptions.userActivities.first {
            _ = ApplicationDelegateProxy.shared.application(UIApplication.shared, continue: activity, restorationHandler: { _ in })
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            _ = ApplicationDelegateProxy.shared.application(UIApplication.shared, open: context.url, options: [:])
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _ = ApplicationDelegateProxy.shared.application(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
    }
}
