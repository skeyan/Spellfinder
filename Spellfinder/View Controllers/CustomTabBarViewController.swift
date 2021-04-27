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

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Return to root of nav controller stack for All Spells when tab bar item is selected
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let navController1 =  self.viewControllers![0] as? UINavigationController
        navController1?.popToRootViewController(animated: false)
    }
}
