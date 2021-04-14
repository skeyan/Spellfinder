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
    @IBOutlet var componentsLabel: UILabel!
    
    @IBOutlet var durationValueLabel: UILabel!
    @IBOutlet var rangeValueLabel: UILabel!
    @IBOutlet var componentsValueLabel: UILabel!
    @IBOutlet var concentrationValueLabel: UILabel!
    @IBOutlet var ritualValueLabel: UILabel!
    
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var addToCharacterButton: UIButton!
    
    // MARK: - Actions
    // TO-DO: Implement favoriting
    @IBAction func favoriteSpell(_ sender: UIButton) {
        // Animate the tap on the favorites button
        sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.4,
           delay: 0,
           usingSpringWithDamping: 0.5,
           initialSpringVelocity: 3,
           options: [.curveEaseInOut, .allowUserInteraction],
           animations: {
                sender.transform = CGAffineTransform.identity }, completion: nil)
    }
    
    // MARK: - Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
