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
    // TO-DO: Configure function that takes in a Character Entity 
}
