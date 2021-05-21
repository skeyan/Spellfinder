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
        // Get the current view controller of the Spells tab
        let navController1 =  self.viewControllers![0] as? UINavigationController
        let vc = navController1?.visibleViewController
        
        if (vc is SearchFilterViewController) {
            // If we're in search FILTERING, pop back one
            navController1?.popViewController(animated: false)
        } else if (vc is SelectCharacterViewController || vc is DetailSpellViewController) {
            // If we're selecting a character or in a detail, pop back one
            navController1?.popViewController(animated: false)
        } else if !(vc is SearchResultsViewController) {
            // If we're not looking at search results, pop back to the beginning
            // because we want to stay at search results if we are
            // so the user can reference the search results
            navController1?.popToRootViewController(animated: false)
        }
    }
}
