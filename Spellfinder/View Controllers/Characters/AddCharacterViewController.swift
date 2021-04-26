//
//  AddCharacterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit
import CoreData

protocol AddCharacterViewControllerDelegate: class {
    func addCharacterViewControllerDidCancel(
        _ controller: AddCharacterViewController
    )
    
    func addCharacterViewController(
        _ controller: AddCharacterViewController,
        didFinishAdding character: Character
    )
    
    func addCharacterViewController(
        _ controller: AddCharacterViewController,
        didFinishEditing character: Character
    )
}
class AddCharacterViewController: UITableViewController {

    @IBOutlet weak var createCharacterButton: UIButton!
    @IBOutlet weak var classValueLabel: UILabel!
    @IBOutlet weak var nameValueTextField: UITextField!
    @IBOutlet weak var levelValueTextField: UITextField!
    @IBOutlet weak var iconTableViewCell: UITableViewCell!
    @IBOutlet weak var iconImage: UIImageView!
    
    // MARK: - Instance Variables
    // Keep track of the chosen icon name
    var iconName = "SwordIcon"
    
    // For editing
    var characterToEdit: Character?
    weak var delegate: AddCharacterViewControllerDelegate?
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Actions
    @IBAction func createButtonWasTouched(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = CGAffineTransform.identity
                    if (self.validateInput(didEnterName: self.nameValueTextField.text!, didEnterLevel: self.levelValueTextField.text!)) {
                        if let character = self.characterToEdit {
                            // TO-DO: Update Character
                            self.delegate?.addCharacterViewController(self, didFinishEditing: character)
                        } else {
                            let character = self.createCharacterEntity()
                            self.delegate?.addCharacterViewController(self, didFinishAdding: character)
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self.presentInvalidInputAlert()
                    }
            }
        })
    }
    
    @IBAction func done() {
        if (self.validateInput(didEnterName: self.nameValueTextField.text!, didEnterLevel: self.levelValueTextField.text!)) {
            // TO-DO: Create/edit character for Core Data with inputted info
            if let character = self.characterToEdit {
                // TO-DO: Update Character
                self.delegate?.addCharacterViewController(self, didFinishEditing: character)
            } else {
                let character = createCharacterEntity()
                self.delegate?.addCharacterViewController(self, didFinishAdding: character)
                navigationController?.popViewController(animated: true)
            }
        } else {
            presentInvalidInputAlert()
        }
    }

    @IBAction func cancel() {
        delegate?.addCharacterViewControllerDidCancel(self)
    }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        createCharacterButton.applyGradient(colors: [Helper.UIColorFromRGB(0x2CD0DD).cgColor, Helper.UIColorFromRGB(0xBB4BD2).cgColor])
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.systemGray6.cgColor
        border.frame = CGRect(x: 0,
                              y: 0,
                              width: iconTableViewCell.frame.size.width,
                              height: 1
        )
        border.borderWidth = width
        iconTableViewCell.layer.addSublayer(border)
        iconTableViewCell.layer.masksToBounds = true
        
        nameValueTextField.becomeFirstResponder()
        
        // Icon
        if let character = characterToEdit {
            // TO-DO: Editing Stuff
            iconName = character.iconName!
        }
        iconImage.image = UIImage(named: iconName)
    }

    // MARK: - Navigation
    override func prepare(
      for segue: UIStoryboardSegue,
      sender: Any?
    ) {
        if segue.identifier == "PickIcon" {
            let controller = segue.destination as! IconPickerViewController
            controller.delegate = self
        }
        if segue.identifier == "PickClass" {
            let controller = segue.destination as! ClassPickerViewController
            controller.delegate = self
        }
    }
    
    // MARK: - Table View
    // UI improvement - Make custom layout for section headers
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white

        let sectionLabel = UILabel(frame: CGRect(x: 20, y: 28, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        sectionLabel.font = UIFont(name: "Retroica", size: 18)
        sectionLabel.textColor = UIColor.black
        sectionLabel.text = ""
        switch section {
        case 0:
            sectionLabel.text = "Name"
        case 1:
            sectionLabel.text = "Class"
        case 2:
            sectionLabel.text = "Level"
        default:
            sectionLabel.text = ""
        }
        
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)

        return headerView
    }
    
    // UI improvement - make the section headers taller
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // UI improvement - animate the deselection of rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // UI improvement - disable highlighting of rows
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Helper Methods
    func validateInput(didEnterName name: String, didEnterLevel level: String) -> Bool {
        let trimmedLevel = level.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return (trimmedLevel != "" && trimmedName != "")
    }
    
    func presentInvalidInputAlert() -> Void {
        let title = "Please complete the fields!"
        let message = "The name and level fields cannot be blank."
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createCharacterEntity() -> Character {
        // Create the character entity
        let character = Character(context: managedObjectContext)
        
        character.name = nameValueTextField.text
        character.iconName = iconName
        character.dndClass = classValueLabel.text
        character.level = String(levelValueTextField.text!)
        
        return character
    }
}

// MARK: - Icon Picker View Controller Delegate
extension AddCharacterViewController: IconPickerViewControllerDelegate {
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String
    ) {
      self.iconName = iconName
      iconImage.image = UIImage(named: iconName)
      navigationController?.popViewController(animated: true)
    }
}

// MARK: - Class Picker View Controller Delegate
extension AddCharacterViewController: ClassPickerViewControllerDelegate {
    func classPicker(_ picker: ClassPickerViewController, didPick chosenClass: String) {
        classValueLabel.text = chosenClass
        navigationController?.popViewController(animated: true)
    }
}
