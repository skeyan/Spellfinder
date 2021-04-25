//
//  ClassPickerViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/25/21.
//

import UIKit

protocol ClassPickerViewControllerDelegate: class {
  func classPicker(
    _ picker: ClassPickerViewController,
    didPick chosenClass: String)
}

class ClassPickerViewController: UITableViewController {
    weak var delegate: ClassPickerViewControllerDelegate?
    
    let classes = [
        "Artificer", "Barbarian", "Bard", "Blood Hunter", "Cleric",
        "Druid", "Fighter", "Monk", "Paladin",
        "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard"
    ]
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int
    ) -> Int {
      return classes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(
        withIdentifier: "ClassCell",
        for: indexPath)
      let chosenClass = classes[indexPath.row]
      cell.textLabel!.text = chosenClass
      // cell.imageView!.image = UIImage(named: iconName)
      return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
    ) {
      if let delegate = delegate {
        let chosenClass = classes[indexPath.row]
        delegate.classPicker(self, didPick: chosenClass)
      }
    }
}
