//
//  CustomTabBarViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/27/21.
//

import UIKit

class CustomTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Return to root of nav controller stack for All Spells when tab bar item is selected
    // unless we're in search results view controller
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let navController1 =  self.viewControllers![0] as? UINavigationController
        let vc = navController1?.visibleViewController
        if !(vc is SearchResultsViewController || vc is SearchFilterViewController) {
            navController1?.popToRootViewController(animated: false)
        }
    }
}
