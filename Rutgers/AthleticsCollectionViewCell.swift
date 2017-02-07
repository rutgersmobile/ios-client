//
//  AthleticsCollectionViewCell.swift
//  Rutgers
//
//  Created by scm on 9/1/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import UIKit

class AthleticsCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    @IBOutlet weak var homeScore: UILabel!
    @IBOutlet weak var awayScore: UILabel!
    @IBOutlet weak var sideIndicator: UIImageView!
    @IBOutlet weak var schoolIcon: UIImageView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var scoreDivider: UILabel!

    override func prepareForReuse() {
        homeScore.text = nil ;
        homeScore.textColor = UIColor.grayColor()
        homeScore.hidden = false
        
        awayScore.text = nil ;
        awayScore.textColor = UIColor.grayColor()
        awayScore.hidden = false
        sideIndicator.backgroundColor = nil ;
        schoolIcon.image = nil ;
        schoolNameLabel.text = nil ;
        locationLabel.text = nil ;
        dateTimeLabel.text = nil ;

        scoreDivider.hidden = false
    }
    
}
