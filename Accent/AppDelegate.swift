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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self, Digits.self])
        
        if Language.savedLanguage() != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let avc = storyboard.instantiateViewControllerWithIdentifier("ArticlesViewController") as! ArticlesViewController
            
            let navController = UINavigationController()
            window?.rootViewController = navController
            
            navController.pushViewController(avc, animated: false)
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        guard let host = url.host else {
            return true
        }
        
        switch host {
        case "auth":
            if let component = url.pathComponents?[1] {
                switch component {
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
