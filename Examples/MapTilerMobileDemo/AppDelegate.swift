//
//  AppDelegate.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
    
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let placeholderKey = "YOUR_API_KEY_HERE"

        guard let mapTilerAPIKey = Bundle.main.object(forInfoDictionaryKey: "MapTilerAPIKey") as? String, mapTilerAPIKey != placeholderKey else {
            assertionFailure("API Key not entered in Info.plist file. Enter your API Key in Info.plist file under the key 'MapTilerAPIKey' field.")

            return true
        }

        Task {
            await MTConfig.shared.setAPIKey(mapTilerAPIKey)
            await MTConfig.shared.setLogLevel(.debug(verbose: true))
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
}

