//
//  SearchResultCell.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/13/21.
//

import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet var spellNameLabel: UILabel!
    @IBOutlet var levelSchoolLabel: UILabel!
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var rangeLabel: UILabel!
    @IBOutlet var concentrationLable: UILabel!
    @IBOutlet var componentsLabel: UILabel!
    
    @IBOutlet var durationValueLabel: UILabel!
    @IBOutlet var rangeValueLabel: UILabel!
    @IBOutlet var concentrationValueLabel: UILabel!
    @IBOutlet var componentsValueLabel: UILabel!
    
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var addToCharacterButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
