//
//  AppDelegate.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import Crashlytics
import DigitsKit
import Fabric
import UIKit

let AccentApplicationWillEnterForeground = "AccentApplicationWillEnterForeground"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self, Digits.self])
        
        UserDefaults(suiteName: "group.io.tinypixels.Accent")?.set(UserDefaults(suiteName: "group.io.tinypixels.Accent")?.stringArray(forKey: "AccentArticlesToRetrieve") ?? [String](), forKey: "AccentArticlesToRetrieve")
        
        if Language.savedLanguage() != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let avc = storyboard.instantiateViewController(withIdentifier: "ArticlesViewController") as! ArticlesViewController
            
            let navController = UINavigationController()
            window?.rootViewController = navController
            
            navController.pushViewController(avc, animated: false)
        }
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AccentApplicationWillEnterForeground), object: nil)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        guard let host = url.host else {
            return true
        }
        
        switch host {
        case "auth":
            if url.pathComponents.count > 0 {
                switch url.pathComponents[1] {
                case "quizlet":
                    Quizlet.sharedInstance.handleAuthorizationResponse(url)
                default:
                    break
                }
            }
        default:
            break
        }
        
        return true
    }
}
