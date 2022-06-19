//
//  AppDelegate.swift
//  Acts
//
//  Created by maiyama on 2022/06/18.
//

import UIKit
import PKHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupHUD()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {}
    
    private func setupHUD() {
        PKHUD.sharedHUD.gracePeriod = 0.3
    }
}
