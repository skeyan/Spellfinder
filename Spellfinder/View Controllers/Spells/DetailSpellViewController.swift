//
//  DetailSpellViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/14/21.
//

import UIKit

class DetailSpellViewController: UIViewController {
    
    @IBOutlet var higherLevelValueLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var spellNameLabel: UILabel!
    @IBOutlet var levelMagicClassLabel: UILabel!
    @IBOutlet var concentrationLabel: UILabel!
    @IBOutlet var ritualLabel: UILabel!
    
    @IBOutlet var castingTimeLabel: UILabel!
    @IBOutlet var castingTimeValueLabel: UILabel!
    @IBOutlet var rangeLabel: UILabel!
    @IBOutlet var rangeValueLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var durationValueLabel: UILabel!
    @IBOutlet var classesLabel: UILabel!
    @IBOutlet var classesValueLabel: UILabel!
    @IBOutlet var componentsLabel: UILabel!
    @IBOutlet var componentsValueLabel: UILabel!
    
    @IBOutlet var extraMaterialsLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var higherLevelLabel: UILabel!

    
    // The search result that will be displayed
    var searchResultToDisplay: SearchResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let _ = searchResultToDisplay {
            configure(for: searchResultToDisplay!)
        }
    }

    // MARK: - Helper Methods
    func configure(for searchResult: SearchResult) -> Void {
        spellNameLabel.text = searchResult.name
        levelMagicClassLabel.text = searchResult.level! + " " + searchResult.school!
        
        if searchResult.isConcentration {
            concentrationLabel.textColor = UIColor(named: "AccentColor")
        } else {
            concentrationLabel.textColor = UIColor(named: "GreyColor")
        }
        if searchResult.isRitual {
            ritualLabel.textColor = UIColor(named: "AccentColor")
        } else {
            ritualLabel.textColor = UIColor(named: "GreyColor")
        }
        
        castingTimeValueLabel.text = searchResult.castingTime
        rangeValueLabel.text = searchResult.range
        durationValueLabel.text = searchResult.duration
        classesValueLabel.text = searchResult.dndClass
        componentsValueLabel.text=searchResult.components
        
        extraMaterialsLabel.text = searchResult.material
        extraMaterialsLabel.sizeToFit()
        descriptionLabel.text = searchResult.desc
        descriptionLabel.sizeToFit()
        
        if searchResult.higherLevelDesc!.isEmpty {
            higherLevelValueLabel.isHidden = true
            higherLevelLabel.isHidden = true
        } else {
            higherLevelValueLabel.text = searchResult.higherLevelDesc
            higherLevelLabel.isHidden = false
            higherLevelValueLabel.isHidden = false
        }
    }
}
