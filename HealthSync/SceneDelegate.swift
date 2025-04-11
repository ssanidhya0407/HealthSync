//
//  SceneDelegate.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window with the correct frame that matches the scene
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // Ensure proper safe area usage and bounds
        window?.safeAreaLayoutGuide.owningView?.frame = windowScene.coordinateSpace.bounds
        
        // Set up the root view controller
        setRootViewController()
        
        window?.makeKeyAndVisible()
    }
    
    private func setRootViewController() {
        let loginSelectionVC = LoginSelectionViewController()
        loginSelectionVC.modalPresentationStyle = .fullScreen
        
        let navigationController = UINavigationController(rootViewController: loginSelectionVC)
        navigationController.modalPresentationStyle = .fullScreen
        
        // Configure navigation bar to use the full width
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        
        window?.rootViewController = navigationController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}
