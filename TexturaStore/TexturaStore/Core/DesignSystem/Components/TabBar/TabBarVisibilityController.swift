//
//  TabBarVisibilityController.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import UIKit

enum TabBarVisibilityController {
    
    static func setHidden(_ hidden: Bool) {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let root = scene.windows.first?.rootViewController,
            let tabBarController = findTabBarController(from: root)
        else { return }
        
        tabBarController.tabBar.isHidden = hidden
    }
    
    private static func findTabBarController(from controller: UIViewController) -> UITabBarController? {
        if let tab = controller as? UITabBarController {
            return tab
        }
        
        for child in controller.children {
            if let found = findTabBarController(from: child) {
                return found
            }
        }
        
        if let presented = controller.presentedViewController {
            return findTabBarController(from: presented)
        }
        
        return nil
    }
}
