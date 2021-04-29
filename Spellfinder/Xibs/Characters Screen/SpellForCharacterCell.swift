//
//  SpellForCharacterCell.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/28/21.
//

import UIKit

protocol SpellForCharacterCellDelegate: class {
    func favoritesButtonTapped(cell: SpellForCharacterCell)
}
class SpellForCharacterCell: UITableViewCell {
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var spellNameValueLabel: UILabel!
    @IBOutlet weak var levelSchoolValueLabel: UILabel!
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var componentsValueLabel: UILabel!
    @IBOutlet weak var concentrationValueLabel: UILabel!
    @IBOutlet weak var ritualValueLabel: UILabel!
    @IBOutlet weak var rangeValueLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func animateButton(_ sender: UIButton) {
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
    
    @IBAction func favoritesButtonTapped(sender: UIButton) {
        self.delegate?.favoritesButtonTapped(cell: self)
    }
    
    // MARK: - Instance Variables
    weak var delegate: SpellForCharacterCellDelegate?
    
    var data: Spell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    // MARK: - Helper Methods
    func configure(for spell: Spell) {
        spellNameValueLabel.text = spell.name
        levelSchoolValueLabel.text = spell.level! + " " + spell.school!
        componentsValueLabel.text = spell.components
        durationValueLabel.text = spell.duration
        rangeValueLabel.text = spell.range
        // Concentration
        if spell.isConcentration {
            concentrationValueLabel.textColor = UIColor(named: "AccentColor")
        } else {
            concentrationValueLabel.textColor = UIColor(named: "GreyColor")
        }
        // Ritual
        if spell.isRitual {
            ritualValueLabel.textColor = UIColor(named: "AccentColor")
        } else {
            ritualValueLabel.textColor = UIColor(named: "GreyColor")
        }
        // Favorites
        if(spell.isFavorited) {
            let image = UIImage(named: "star-filled")
            favoriteButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "star")
            favoriteButton.setImage(image, for: .normal)
        }
    }
}
