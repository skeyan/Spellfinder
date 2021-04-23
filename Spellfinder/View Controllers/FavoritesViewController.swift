//
//  FavoritesViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, SearchResultCellDelegate {
    // MARK: - Instance Variables
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    var coreDataSpells = [Spell]()
    
    
    // MARK: - View
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
    
    
    // MARK: - Core Data
    func favoritesButtonTapped(cell: SearchResultCell) {
        <#code#>
    }

}
