//
//  AppDelegate.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/26/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        identifyCurrentUserOrSignInAnonymously()

        
        return true
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

    

}


extension AppDelegate {
    func identifyCurrentUserOrSignInAnonymously() {
        let defaults = UserDefaults.standard


        if Auth.auth().currentUser != nil,
            let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
            User.setCurrent(user)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                assertionFailure("Error signing out: \(error.localizedDescription)")
            }
            
            Auth.auth().signInAnonymously { (user, error) in
                
                guard let firUser = user else {
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                
                DataManager.createUser(firUser, completion: { (user) in
                    guard let user = user else {
                        return
                    }
                    
                    User.setCurrent(user, writeToUserDefaults: true)
                    
                    dispatchGroup.leave()
                    print("Created new user: \(user.uid)")
                    
                })
                dispatchGroup.notify(queue: .main, execute: {
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                })
                
                
                
                
            }
        }

    }
}

