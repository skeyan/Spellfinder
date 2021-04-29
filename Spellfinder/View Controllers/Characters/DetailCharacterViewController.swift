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
    
    // TO-DO: Make custom cell for a spell that's shown in a character's detail screen
    struct TableView {
      struct CellIdentifiers {
        static let spellForCharacterCell = "SpellForCharacterCell"
      }
    }
    
    // The Character entity to be displayed
    var characterToDisplay: Character!
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Favorites Cell Delegate
    func favoritesButtonTapped(cell: SpellForCharacterCell) {
        print("Favorites button tapped in DetailCharacterViewController")
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
        // let cell = tableView.cellForRow(at: indexPath) as? FavoritesCell
        // performSegue(withIdentifier: "ShowFavoritesSpellDetail", sender: cell)
    }
}
