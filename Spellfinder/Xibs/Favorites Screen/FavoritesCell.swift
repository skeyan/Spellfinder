//
//  FavoritesCell.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/23/21.
//

import UIKit

protocol FavoritesCellDelegate: class {
    func favoritesButtonTapped(cell: FavoritesCell)
    func addButtonTapped(cell: FavoritesCell)
}
class FavoritesCell: UITableViewCell {

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
    
    // MARK: - Instance Variables
    weak var delegate: FavoritesCellDelegate?
    
    var data: Spell!
        
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
    
    @IBAction func addButtonTapped(sender: UIButton) {
        self.delegate?.addButtonTapped(cell: self)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
         self.delegate = nil
    }

    // MARK: - Helper Methods
    func configure(for favoritedSpell: Spell) {
        spellNameLabel.text = favoritedSpell.name
        levelSchoolLabel.text = favoritedSpell.level! + " " + favoritedSpell.school!
        componentsValueLabel.text = favoritedSpell.components
        durationValueLabel.text = favoritedSpell.duration
        rangeValueLabel.text = favoritedSpell.range
        // Concentration
        if favoritedSpell.isConcentration {
            concentrationValueLabel.textColor = UIColor(named: "AccentColor")
        } else {
            concentrationValueLabel.textColor = UIColor(named: "GreyColor")
        }
        // Ritual
        if favoritedSpell.isRitual {
            ritualValueLabel.textColor = UIColor(named: "AccentColor")
        } else {
            ritualValueLabel.textColor = UIColor(named: "GreyColor")
        }
        // Favorites
        if(favoritedSpell.isFavorited) {
            let image = UIImage(named: "star-filled")
            favoriteButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "star")
            favoriteButton.setImage(image, for: .normal)
        }
    }
}
