//
//  AppDelegate.swift
//  Ramazanova1998
//
//  Created by Раисат Рамазанова on 31.08.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        let navigation = UINavigationController(rootViewController: MainViewController())
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
        return true
    }
}

