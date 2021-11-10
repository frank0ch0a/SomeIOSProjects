//
//  AppDelegate.swift
//  Simpsons Quotes
//
//  Created by Francisco Ochoa on 11/10/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        window = UIWindow()
        window?.backgroundColor = .white
        window?.rootViewController = QuotesRouter.createModule()
        window?.makeKeyAndVisible()
        
        return true
    }



   


}

