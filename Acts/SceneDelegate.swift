//
//  SceneDelegate.swift
//  Acts
//
//  Created by maiyama on 2022/06/18.
//

import App
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var rootViewControllerSwitcher: RootViewControllerSwitcher?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let rootViewControllerSwitcher = RootViewControllerSwitcher(window: window)
        rootViewControllerSwitcher.setup()
        self.rootViewControllerSwitcher = rootViewControllerSwitcher

        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {}

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {}
}
