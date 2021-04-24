//
//  FavoritesViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, SearchResultCellDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Instance Variables
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController<Spell> = {
      let fetchRequest = NSFetchRequest<Spell>()

      let entity = Spell.entity()
      fetchRequest.entity = entity

      let sortDescriptor = NSSortDescriptor(
        key: "name",
        ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor]

      fetchRequest.fetchBatchSize = 20

      let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: self.managedObjectContext,
        sectionNameKeyPath: nil,
        cacheName: "Spells")

      fetchedResultsController.delegate = self
      return fetchedResultsController
    }()
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
      }
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register nibs
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        // TO-DO: Make new nib for no favorites to replace nothing found cell
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        // Get favorited spells from Core Data
        // fetchSpells()
        
    }
    
    deinit {
      fetchedResultsController.delegate = nil
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
    // Get spells from CoreData
    func fetchSpells() {
      do {
        try fetchedResultsController.performFetch()
      } catch {
        fatalCoreDataError(error)
      }
    }
    
    func favoritesButtonTapped(cell: SearchResultCell) {
        // TO-DO: Core Data favoriting logic for favorites page
        print("-- in favorites button on Favorites screen")
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let sectionInfo = fetchedResultsController.sections![section]
//        return sectionInfo.numberOfObjects
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SearchResultCell",
            for: indexPath) as! SearchResultCell

      //  cell.delegate = self

        // Get the data to display in the search result cell
    // let searchResult = fetchedResultsController.object(at: indexPath)
//        cell.configure(for: searchResult)
//        cell.data = searchResult
        return cell
    }


}
