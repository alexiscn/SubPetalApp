//
//  AppDelegate.swift
//  SubPetal
//
//  Created by alexiscn on 2022/5/31.
//

import UIKit
import Tiercel

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if UserDefaults.standard.bool(forKey: "HasRequestedNetworkAccess") == false {
            URLSession.shared.dataTask(with: URL(string: "https://www.baidu.com")!).resume()
            UserDefaults.standard.set(true, forKey: "HasRequestedNetworkAccess")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if Context.current?.sessionManager.identifier == identifier {
            Context.current?.sessionManager.completionHandler = completionHandler
        }
    }
}

