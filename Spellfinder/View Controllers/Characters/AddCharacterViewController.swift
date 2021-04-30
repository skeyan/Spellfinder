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
                        if let temp = self.characterToEdit {
                            let character = temp
                            character.name = self.nameValueTextField.text
                            character.dndClass = self.classValueLabel.text
                            character.level = self.levelValueTextField.text
                            character.iconName = self.iconName
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
            if let temp = self.characterToEdit {
                let character = temp
                character.name = nameValueTextField.text
                character.dndClass = classValueLabel.text
                character.level = levelValueTextField.text
                character.iconName = iconName
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
        
        // Border between Class section rows
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
        
        // Fill in character information if it exists
        if let character = characterToEdit {
            iconName = character.iconName!
            classValueLabel.text = character.dndClass!
            nameValueTextField.text = character.name!
            levelValueTextField.text = character.level!
            title = "Edit Character"
            createCharacterButton.setTitle("Edit", for: .normal)
        } else {
            title = "Add Character"
            createCharacterButton.setTitle("Create", for: .normal)
        }
        iconImage.image = UIImage(named: iconName)
        
        // Gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.cancelsTouchesInView = false // allow row selection
        self.view.addGestureRecognizer(tapGesture)
        
        // Keyboard push
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Done button and toolbar to keyboard
        addDoneButtonOnKeyboard()
    }
    
    // UI improvement - dismiss the keyboard when tapping out of a text field
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
    }
    
    // UI improvement - keyboard push
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }
    
    // Add done button to keybaord
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        doneToolbar.isTranslucent = true

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonAction))

        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)

        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()

        self.levelValueTextField.inputAccessoryView = doneToolbar

    }

    @objc func doneButtonAction()
    {
        self.levelValueTextField.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        return indexPath.section == 1 ? true : false
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
