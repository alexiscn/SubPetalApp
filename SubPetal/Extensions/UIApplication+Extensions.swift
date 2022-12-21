//
//  UIApplication+Extensions.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/5.
//

import UIKit

extension UIApplication {
    
    class var topViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootVC = windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
        return _topViewController(of: rootVC)
    }
    
    private class func _topViewController(of viewController: UIViewController?) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return _topViewController(of: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selectedVC = tab.selectedViewController {
                return _topViewController(of: selectedVC)
            }
        }
        if let presented = viewController?.presentedViewController {
            return _topViewController(of: presented)
        }
        if let splitVC = viewController as? UISplitViewController {
            return splitVC
        }
        return viewController
    }
}
