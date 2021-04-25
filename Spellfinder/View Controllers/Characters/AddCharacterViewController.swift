//
//  AddCharacterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit

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
                        // TO-DO: "Done" action - create character with inputted info
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.presentInvalidInputAlert()
                    }
            }
        })
    }
    
    @IBAction func done() {
        if (self.validateInput(didEnterName: self.nameValueTextField.text!, didEnterLevel: self.levelValueTextField.text!)) {
            // TO-DO: Create character for Core Data with inputted info
            navigationController?.popViewController(animated: true)
        } else {
            presentInvalidInputAlert()
        }
    }

    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
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
}

// MARK: - Icon Picker View Controller Delegate
extension AddCharacterViewController: IconPickerViewControllerDelegate {
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String
    ) {
      self.iconName = iconName
      iconImage.image = UIImage(named: iconName)
      navigationController?.popViewController(animated: true)
    }

    func presentInvalidInputAlert() -> Void {
        let title = "Please complete the fields!"
        let message = "The name and level fields cannot be blank."
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
