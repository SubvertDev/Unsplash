//
//  TabBarController.swift
//  Unsplash
//
//  Created by  Subvert on 5/1/22.
//

import UIKit

// Custom UITabBarController with scrolling feature on UITabBar tap

final class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let viewControllers = viewControllers else { return false }
        if viewController == viewControllers[selectedIndex] {
            if let nav = viewController as? UINavigationController {
                guard let topController = nav.viewControllers.last else { return true }
                if !topController.isScrolledToTop {
                    topController.scrollToTop()
                    return false
                } else {
                    nav.popViewController(animated: true)
                }
                return true
            }
        }
        return true
    }
}

extension UIViewController {
    func scrollToTop() {
        func scrollToTop(view: UIView?) {
            guard let view = view else { return }
            
            switch view {
            case let collectionView as UICollectionView:
                if collectionView.scrollsToTop {
                    collectionView.setContentOffset(.zero, animated: true)
                    return
                }
            case let tableView as UITableView:
                if tableView.scrollsToTop {
                    tableView.setContentOffset(.zero, animated: true)
                    return
                }
            default:
                break
            }
            
            for subView in view.subviews {
                scrollToTop(view: subView)
            }
        }
        
        scrollToTop(view: view)
    }
    
    var isScrolledToTop: Bool {
        for subview in view.subviews {
            switch subview {
                
            case let collectionView as UICollectionView:
                return (collectionView.contentOffset.y == 0)
                
            case let tableView as UITableView:
                return (tableView.contentOffset.y == 0)
                
            default:
                break
            }
        }
        return true
    }
}
