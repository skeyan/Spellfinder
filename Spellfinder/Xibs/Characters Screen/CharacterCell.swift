//
//  CharacterCell.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit

class CharacterCell: UITableViewCell {

    @IBOutlet weak var characterIcon: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var classValueLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var levelValueLabel: UILabel!
    @IBOutlet weak var spellsKnownLabel: UILabel!
    @IBOutlet weak var spellsKnownValueLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK:- Helper Methods
    func configure(for character: Character) {
        characterIcon.image = UIImage(named: character.iconName!)
        characterNameLabel.text = character.name
        classValueLabel.text = character.dndClass
        levelValueLabel.text = character.level
        
        if let spells = character.spells {
            spellsKnownValueLabel.text = String(spells.count)
        } else {
            spellsKnownValueLabel.text = "0"
        }
    }
}
