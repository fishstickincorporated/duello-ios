import UIKit
import Capacitor

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // v208 (Jeff, Nov 27, 2026): the open Duo MUST stay portrait.
    // v207's check (exact 669x951 ±1pt) MISSED — Jeff's Nov 27
    // screenshot showed the open Duo rendering in LANDSCAPE. The
    // likely cause: the Duo reports the .pad idiom (a foldable's
    // inner display) and/or a screen size a few points off 669x951,
    // so the size check failed and the .pad idiom hit the .all
    // fallback; the iPad plist key (UISupportedInterfaceOrientations
    // ~ipad) also lists all four orientations, so once the delegate
    // returned .all, landscape was fully allowed. The robust fix
    // discriminates by SIZE, not idiom: the Duo inner display is the
    // only Apple display with a short side under ~700pt (669); every
    // iPad is 744pt or wider on its short side (iPad mini 744,
    // Air/Pro 820+). So any screen with short side <= 700pt and long
    // side <= 1000pt is a phone/foldable and stays portrait-only,
    // whatever idiom it reports; only a genuinely iPad-sized screen
    // (short side >= 744) gets all four. The window's own screen is
    // checked first (it is the screen these orientations are for),
    // then every connected scene's screen, then the main screen as a
    // last resort. The check reads SCREEN bounds, not window bounds,
    // so an iPad Split View window still reports the full iPad
    // screen and keeps all four. iPhone stays portrait-only.
    // Must be verified in the sim: open the Duo, rotate to
    // landscape, and confirm the app stays portrait.
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        var sizes: [CGSize] = []
        if let s = window?.screen.bounds.size { sizes.append(s) }
        for scene in application.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            sizes.append(windowScene.screen.bounds.size)
        }
        if sizes.isEmpty { sizes.append(UIScreen.main.bounds.size) }
        for size in sizes {
            let shortSide = min(size.width, size.height)
            let longSide = max(size.width, size.height)
            if shortSide <= 700 && longSide <= 1000 {
                return .portrait
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }
        return .portrait
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: .capacitorDidRegisterForRemoteNotifications, object: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: .capacitorDidFailToRegisterForRemoteNotifications, object: error)
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration",
                                          sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
