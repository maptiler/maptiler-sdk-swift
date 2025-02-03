//
//  AppDelegate.swift
//  MapTilerMobileDemo
//

import UIKit
import MapTilerSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let placeholderKey = "YOUR_API_KEY_HERE"

        guard let mapTilerAPIKey = Bundle.main.object(forInfoDictionaryKey: "MapTilerAPIKey") as? String, mapTilerAPIKey != placeholderKey else {
            assertionFailure("API Key not entered in Info.plist file. Enter your API Key in Info.plist file under the key 'MapTilerAPIKey' field.")

            return true
        }

        Task {
            await MTConfig.shared.setAPIKey(mapTilerAPIKey)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

