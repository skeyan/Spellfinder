//
//  DetailCharacterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit

class DetailCharacterViewController: UIViewController {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var characterNameValueLabel: UILabel!
    @IBOutlet weak var classValueLabel: UILabel!
    @IBOutlet weak var levelValueLabel: UILabel!
    @IBOutlet weak var totalNumberOfSpellsValueLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Instance Variables
    // The Character entity to be displayed
    var characterToDisplay: Character?
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = characterToDisplay {
            configure(for: characterToDisplay!)
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
extension DetailCharacterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "TestCell")
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TestCell")
        }
        cell!.detailTextLabel?.text = "I will be a Spell"
        cell!.textLabel?.text = "Spell Name"
        
        return cell!
    }
}
