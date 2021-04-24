//
//  FavoritesViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, FavoritesCellDelegate {
    
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
    
    var allSpellsViewController = AllSpellsViewController()
    
    struct TableView {
      struct CellIdentifiers {
        static let favoritesCell = "FavoritesCell"
        static let noFavoritesCell = "NoFavoritesCell"
      }
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register nibs
        var cellNib = UINib(nibName: TableView.CellIdentifiers.favoritesCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.favoritesCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.noFavoritesCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.noFavoritesCell)
        
        // Get favorited spells from Core Data
        fetchSpells()
        
        // Debug only
        print(allSpellsViewController.search.hasSearched)
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
    
    func favoritesButtonTapped(cell: FavoritesCell) {
        // TO-DO: Core Data favoriting logic for favorites page
        print("-- in favorites button on Favorites screen")
        let indexPath = tableView.indexPath(for: cell)
        let favoritedSpell = fetchedResultsController.object(at: indexPath!)
        
        // Update instance spells array
        allSpellsViewController.search.searchResultsDict[favoritedSpell.slug!]!.isFavorited = !allSpellsViewController.search.searchResultsDict[favoritedSpell.slug!]!.isFavorited
        allSpellsViewController.tableView.reloadData()
        
        managedObjectContext.delete(favoritedSpell)
        
        // Save context
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        // TO-DO: Update the UI
        if(cell.data.isFavorited) {
            let image = UIImage(systemName: "star.fill")
            cell.favoriteButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(systemName: "star")
            cell.favoriteButton.setImage(image, for: .normal)
        }
    }
}

// MARK: - Table View Delegate
extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (fetchedResultsController.sections![indexPath.section].numberOfObjects == 0) {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.noFavoritesCell,
                for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.favoritesCell,
                for: indexPath) as! FavoritesCell
            
            cell.delegate = self
            
            // Get the data to display in the favorites cell from Core Data
            let favoritedSpell = fetchedResultsController.object(at: indexPath)
            cell.configure(for: favoritedSpell)
            cell.data = favoritedSpell
            
            return cell
        }
    }

    // Swipe to delete
    func tableView(
      _ tableView: UITableView,
      commit editingStyle: UITableViewCell.EditingStyle,
      forRowAt indexPath: IndexPath
    ) {
      if editingStyle == .delete {
        let favoritedSpell = fetchedResultsController.object(
          at: indexPath)
        
        // Update instance spells array
        allSpellsViewController.search.searchResultsDict[favoritedSpell.slug!]!.isFavorited = !allSpellsViewController.search.searchResultsDict[favoritedSpell.slug!]!.isFavorited
        allSpellsViewController.tableView.reloadData()
        
        managedObjectContext.delete(favoritedSpell)
        
        // Save context
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
      }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        /*
        // Perform segue to Spell Detail
        let cell = tableView.cellForRow(at: indexPath) as? SearchResultCell
        performSegue(withIdentifier: "ShowSpellDetail", sender: cell)
         */
    }
    
    // UI improvement - Prevent selection in certain cases
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (fetchedResultsController.sections![indexPath.section].numberOfObjects == 0) {
            return nil
        } else {
            return indexPath
        }
    }
}


// MARK: - NSFetchedResultsController Delegate Extension
extension FavoritesViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>
  ) {
    print("*** controllerWillChangeContent")
    tableView.beginUpdates()
  }

  func controller(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>,
    didChange anObject: Any,
    at indexPath: IndexPath?,
    for type: NSFetchedResultsChangeType,
    newIndexPath: IndexPath?
  ) {
    switch type {
    case .insert:
      print("*** NSFetchedResultsChangeInsert (object)")
      tableView.insertRows(at: [newIndexPath!], with: .fade)

    case .delete:
      print("*** NSFetchedResultsChangeDelete (object)")
      tableView.deleteRows(at: [indexPath!], with: .fade)

    case .update:
      print("*** NSFetchedResultsChangeUpdate (object)")
      if let cell = tableView.cellForRow(
        at: indexPath!) as? FavoritesCell {
        let favoritedSpell = controller.object(
          at: indexPath!) as! Spell
        cell.configure(for: favoritedSpell)
      }

    case .move:
      print("*** NSFetchedResultsChangeMove (object)")
      tableView.deleteRows(at: [indexPath!], with: .fade)
      tableView.insertRows(at: [newIndexPath!], with: .fade)
      
    @unknown default:
      print("*** NSFetchedResults unknown type")
    }
  }

  func controller(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>,
    didChange sectionInfo: NSFetchedResultsSectionInfo,
    atSectionIndex sectionIndex: Int,
    for type: NSFetchedResultsChangeType
  ) {
    switch type {
    case .insert:
      print("*** NSFetchedResultsChangeInsert (section)")
      tableView.insertSections(
        IndexSet(integer: sectionIndex), with: .fade)
    case .delete:
      print("*** NSFetchedResultsChangeDelete (section)")
      tableView.deleteSections(
        IndexSet(integer: sectionIndex), with: .fade)
    case .update:
      print("*** NSFetchedResultsChangeUpdate (section)")
    case .move:
      print("*** NSFetchedResultsChangeMove (section)")
    @unknown default:
      print("*** NSFetchedResults unknown type")
    }
  }

  func controllerDidChangeContent(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>
  ) {
    print("*** controllerDidChangeContent")
    tableView.endUpdates()
  }
}
 
