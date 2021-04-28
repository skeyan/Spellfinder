//
//  DetailCharacterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit
import CoreData

class DetailCharacterViewController: UIViewController, NSFetchedResultsControllerDelegate, FavoritesCellDelegate {
    
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
        static let favoritesCell = "FavoritesCell"
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
        let cellNib = UINib(nibName: TableView.CellIdentifiers.favoritesCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.favoritesCell)
        
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
    func addButtonTapped(cell: FavoritesCell) {
        print("Add button tapped in DetailCharacterViewController")
    }
    
    func favoritesButtonTapped(cell: FavoritesCell) {
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
}

// TO-DO: Table View load the character's spells with nsfetchedresultscontroller
// MARK: - Table View Delegates
extension DetailCharacterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TableView.CellIdentifiers.favoritesCell,
            for: indexPath) as! FavoritesCell
        
        cell.delegate = self
        
        // Get the data to display in the cell from Core Data
        let favoritedSpell = fetchedResultsController.object(at: indexPath)
        cell.configure(for: favoritedSpell)
        cell.data = favoritedSpell
        
        return cell
    }
}
