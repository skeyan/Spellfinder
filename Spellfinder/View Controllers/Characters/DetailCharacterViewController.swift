//
//  DetailCharacterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit
import CoreData

class DetailCharacterViewController: UIViewController, NSFetchedResultsControllerDelegate, SpellForCharacterCellDelegate {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var characterNameValueLabel: UILabel!
    @IBOutlet weak var classValueLabel: UILabel!
    @IBOutlet weak var levelValueLabel: UILabel!
    @IBOutlet weak var totalNumberOfSpellsValueLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Instance Variables
    struct TableView {
      struct CellIdentifiers {
        static let spellForCharacterCell = "SpellForCharacterCell"
      }
    }
    
    // The Character entity to be displayed
    var characterToDisplay: Character!
    
    var allSpellsViewController = AllSpellsViewController()
    
    // The Character's spells
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    // Get the spells that belong to the character
    lazy var fetchedResultsController: NSFetchedResultsController<Spell> = {
        let fetchRequest = NSFetchRequest<Spell>()
        
        let entity = Spell.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(
            key: "name",
            ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "%@ IN character", characterToDisplay)
        fetchRequest.predicate = predicate
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "SpellsForCharacter"
        )

        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let _ = characterToDisplay {
            configure(for: characterToDisplay!)
        }
        
        // Register nibs
        let cellNib = UINib(nibName: TableView.CellIdentifiers.spellForCharacterCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.spellForCharacterCell)
        
        // Get character's spells from Core Data
        fetchSpells()
    }
    
    deinit {
        fetchedResultsController.delegate = nil
        NSFetchedResultsController<Spell>.deleteCache(withName: "SpellsForCharacter")
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Detail spell view
        if (segue.identifier == "ShowCharacterDetailSpellDetail" && sender != nil) {
            // Pass data to next view
            let controller = segue.destination as! DetailSpellViewController
            if tableView.indexPath(for: sender as! SpellForCharacterCell) != nil {
                let cell = sender as! SpellForCharacterCell
                controller.searchResultToDisplay = allSpellsViewController.search.searchResultsDict[cell.data.slug!]
            }
        }
    }
    
    // MARK: - Favorites Cell Delegate
    func favoritesButtonTapped(cell: SpellForCharacterCell) {
        let indexPath = tableView.indexPath(for: cell)
        let favoritedSpell = fetchedResultsController.object(at: indexPath!)
        
        // Update instance spells array
        allSpellsViewController.search.searchResultsDict[favoritedSpell.slug!]!.isFavorited = !allSpellsViewController.search.searchResultsDict[favoritedSpell.slug!]!.isFavorited
        allSpellsViewController.tableView.reloadData()
        
        // Update in Core Data
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
        
        // Update the UI
        if(cell.data.isFavorited) {
            let image = UIImage(named: "star-filled")
            cell.favoriteButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "star")
            cell.favoriteButton.setImage(image, for: .normal)
        }
    }

    // MARK: - Helper Methods
    func configure(for character: Character) -> Void {
        iconImage.image = UIImage(named: character.iconName!)
        characterNameValueLabel.text = character.name
        classValueLabel.text = character.dndClass
        levelValueLabel.text = character.level
        if let spells = character.spells {
            totalNumberOfSpellsValueLabel.text = String(spells.count)
        } else {
            totalNumberOfSpellsValueLabel.text = "0"
        }
    }
    
    // MARK: - NSFetchedResultsController Delegate
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
          let characterSpell = controller.object(
            at: indexPath!) as! Spell
          cell.configure(for: characterSpell)
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

// MARK: - Table View Delegates
extension DetailCharacterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TableView.CellIdentifiers.spellForCharacterCell,
            for: indexPath) as! SpellForCharacterCell
        
        cell.delegate = self
        
        // Get the data to display in the cell from Core Data
        let characterSpell = fetchedResultsController.object(at: indexPath)
        cell.configure(for: characterSpell)
        cell.data = characterSpell
        
        return cell
    }
    
    // UI improvement - deselection animation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Perform segue to Spell Detail
        let cell = tableView.cellForRow(at: indexPath) as? SpellForCharacterCell
        performSegue(withIdentifier: "ShowCharacterDetailSpellDetail", sender: cell)
    }
    
    // TO-DO: Delete style, delete spell from character's spells
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let spell = fetchedResultsController.object(at: indexPath)

            // Update in Core Data
            if let character = spell.character {
                spell.removeFromCharacter(character)
                // Delete from Core Data if there's no reason to keep it there
                if (!spell.isFavorited && character.count == 0) {
                    managedObjectContext.delete(spell)
                }
            }
            
            // Save context
            do {
              try managedObjectContext.save()
            } catch {
              fatalCoreDataError(error)
            }
        }
    }
}
