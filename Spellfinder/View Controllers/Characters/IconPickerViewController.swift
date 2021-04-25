//
//  IconPickerViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/25/21.
//

import UIKit

protocol IconPickerViewControllerDelegate: class {
  func iconPicker(
    _ picker: IconPickerViewController,
    didPick iconName: String)
}

class IconPickerViewController: UITableViewController {
    weak var delegate: IconPickerViewControllerDelegate?
    
    // Icon names from Assets.xcassets
    let icons = [
      "AbacusIcon", "CatIcon", "ChickIcon", "DiceIcon",
      "DinoIcon", "DollIcon", "FirstAidIcon", "MicrophoneIcon", "PencilIcon", "SwordIcon"
    ]
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int
    ) -> Int {
      return icons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(
        withIdentifier: "IconCell",
        for: indexPath)
      let iconName = icons[indexPath.row]
      cell.textLabel!.text = iconName
      cell.imageView!.image = UIImage(named: iconName)
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
        let iconName = icons[indexPath.row]
        delegate.iconPicker(self, didPick: iconName)
      }
    }
}

