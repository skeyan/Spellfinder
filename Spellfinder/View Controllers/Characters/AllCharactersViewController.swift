//
//  AllCharactersViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit
import CoreData

class AllCharactersViewController: UIViewController, NSFetchedResultsControllerDelegate, AddCharacterViewControllerDelegate {

    @IBOutlet weak var addCharacterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Instance Variables
    struct TableView {
      struct CellIdentifiers {
        static let characterCell = "CharacterCell"
      }
    }
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController<Character> = {
      let fetchRequest = NSFetchRequest<Character>()

      let entity = Character.entity()
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
        cacheName: "Characters")

      fetchedResultsController.delegate = self
      return fetchedResultsController
    }()
    
    // MARK: - Actions
    @IBAction func addCharacterWasPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = CGAffineTransform.identity
                    self.performSegue(withIdentifier: "AddCharacter", sender: self)
            }
        })
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register nibs
        let cellNib = UINib(nibName: TableView.CellIdentifiers.characterCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.characterCell)

        // UI
        addCharacterButton.applyGradient(colors: [Helper.UIColorFromRGB(0x2CD0DD).cgColor, Helper.UIColorFromRGB(0xBB4BD2).cgColor])
        
        // Get characters from Core Data
        fetchCharacters()
    }
    
    deinit {
      fetchedResultsController.delegate = nil
    }
    
    // MARK: - Core Data
    func fetchCharacters() {
      do {
        try fetchedResultsController.performFetch()
      } catch {
        fatalCoreDataError(error)
      }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddCharacter" && sender != nil) {
            // Pass data to next view
            let controller = segue.destination as! AddCharacterViewController
            controller.managedObjectContext = managedObjectContext
            controller.delegate = self
        }
        
        if (segue.identifier == "ShowCharacterDetail" && sender != nil) {
            // Pass data to next view
            let controller = segue.destination as! DetailCharacterViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(
                  for: sender as! CharacterCell) {
                controller.characterToDisplay = fetchedResultsController.object(at: indexPath)
            }
        }
    }
    
    // MARK: - Add Character View Controller Delegate
    func addCharacterViewControllerDidCancel(_ controller: AddCharacterViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addCharacterViewController(_ controller: AddCharacterViewController, didFinishAdding character: Character) {
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func addCharacterViewController(_ controller: AddCharacterViewController, didFinishEditing character: Character) {
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - NSFetchedResults Controller Delegate
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
      case .update:
        print("*** NSFetchedResultsChangeUpdate (object)")
        if let cell = tableView.cellForRow(
          at: indexPath!) as? CharacterCell {
          let character = controller.object(
            at: indexPath!) as! Character
          cell.configure(for: character)
        }
        
      case .insert:
        print("*** NSFetchedResultsChangeInsert (object)")
        tableView.insertRows(at: [newIndexPath!], with: .fade)

      case .delete:
        print("*** NSFetchedResultsChangeDelete (object)")
        tableView.deleteRows(at: [indexPath!], with: .fade)
        
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

// MARK: - Table View Delegate
extension AllCharactersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.characterCell) as! CharacterCell
        
        // Get the data to display in the character cell from Core Data
        let character = fetchedResultsController.object(at: indexPath)
        cell.configure(for: character)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as? CharacterCell
        self.performSegue(withIdentifier: "ShowCharacterDetail", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(
        _ tableView: UITableView,
        accessoryButtonTappedForRowWith indexPath: IndexPath
    ) {
        // Create the view controller object for the Add/Edit Character screen
        // and push onto navigation stack. We added the storyboardID (identifier)
        // via the storyboard
        let controller = storyboard!.instantiateViewController(
            withIdentifier: "AddCharacterViewController") as! AddCharacterViewController
        
        controller.delegate = self
        
        // Pass along the character to edit
        let character = fetchedResultsController.object(at: indexPath)
        controller.characterToEdit = character
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete character from Core Data
            let character = fetchedResultsController.object(at: indexPath)
            
            managedObjectContext.delete(character)
            
            // Save context
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
}


