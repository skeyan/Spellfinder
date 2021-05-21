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

        let predicate = NSPredicate(format: "isFavorited == %@", NSNumber(value: true))
        fetchRequest.predicate = predicate

        fetchRequest.fetchBatchSize = 20

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "Spells"
        )

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
    }
    
    deinit {
      fetchedResultsController.delegate = nil
    }
    
    // MARK: - Core Data
    // Get spells from CoreData
    func fetchSpells() {
      do {
        try fetchedResultsController.performFetch()
      } catch {
        fatalCoreDataError(error)
      }
    }
    
    // MARK: - Favorites Cell Delegate
    func addButtonTapped(cell: FavoritesCell) {
        performSegue(withIdentifier: "FavoritesToAddToCharacter", sender: cell)
    }
    
    func favoritesButtonTapped(cell: FavoritesCell) {
        let indexPath = tableView.indexPath(for: cell)
        let favoritedSpell = fetchedResultsController.object(at: indexPath!)
        
        // Update instance spells array
        allSpellsViewController.search.searchResultsDict[favoritedSpell.slug!]!.isFavorited = !allSpellsViewController.search.searchResultsDict[favoritedSpell.slug!]!.isFavorited
        allSpellsViewController.tableView.reloadData()
        
        // Update search results array, if necessary
        let navController1 = (tabBarController?.viewControllers![0]) as! UINavigationController
        var vc: SearchResultsViewController?
        for controller in navController1.viewControllers {
            if controller is SearchResultsViewController {
                vc = (controller as! SearchResultsViewController)
            }
        }
        if let searchResultsViewController = vc {
            if (searchResultsViewController.search.searchResultsDict[cell.data.slug!] != nil) {
                searchResultsViewController.search.searchResultsDict[cell.data.slug!]!.isFavorited = !searchResultsViewController.search.searchResultsDict[cell.data.slug!]!.isFavorited
                
                searchResultsViewController.tableView.reloadData()
            }
        }
        
        // Update in Core Data
        if let character = favoritedSpell.character { // Character is not nil
            if (character.count == 0 && favoritedSpell.isFavorited) {
                // Unfavorite by deleting
                managedObjectContext.delete(favoritedSpell)
            } else {
                favoritedSpell.isFavorited = !favoritedSpell.isFavorited
            }
        } else { // Character is nil
            favoritedSpell.isFavorited = !favoritedSpell.isFavorited
        }
        
        // Save context
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        // Update the UI
        if(cell.data.isFavorited) {
            let image = UIImage(named: "star-filled")
            cell.favoriteButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "star")
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
        
        if let character = favoritedSpell.character {
            if (character.count == 0) {
                managedObjectContext.delete(favoritedSpell)
            } else {
                favoritedSpell.isFavorited = !favoritedSpell.isFavorited
            }
        } else {
            favoritedSpell.isFavorited = !favoritedSpell.isFavorited
        }
        
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
        
        // Perform segue to Spell Detail
        let cell = tableView.cellForRow(at: indexPath) as? FavoritesCell
        performSegue(withIdentifier: "ShowFavoritesSpellDetail", sender: cell)
         
    }
    
    // UI improvement - Prevent selection in certain cases
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (fetchedResultsController.sections![indexPath.section].numberOfObjects == 0) {
            return nil
        } else {
            return indexPath
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Detail spell view
        if (segue.identifier == "ShowFavoritesSpellDetail" && sender != nil) {
            // Pass data to next view
            let controller = segue.destination as! DetailSpellViewController
            if tableView.indexPath(for: sender as! FavoritesCell) != nil {
                let cell = sender as! FavoritesCell
                controller.searchResultToDisplay = allSpellsViewController.search.searchResultsDict[cell.data.slug!]
            }
        }
        // Select character screen
        if (segue.identifier == "FavoritesToAddToCharacter" && sender != nil) {
            // Pass data to next view
            let controller = segue.destination as! SelectCharacterViewController
            
            // Spell to add
            if tableView.indexPath(for: sender as! FavoritesCell) != nil {
                let cell = sender as! FavoritesCell
                controller.spellToAdd = allSpellsViewController.search.searchResultsDict[cell.data.slug!]
            }
            
            // Core data and Characters
            controller.managedObjectContext = managedObjectContext
            var currentCharacters: [Character] = []
            do {
                // Get all current Character objects in Core Data
                currentCharacters = try managedObjectContext.fetch(Character.fetchRequest())
            } catch {
                fatalCoreDataError(error)
            }
            controller.currentCharacters = currentCharacters
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
 
