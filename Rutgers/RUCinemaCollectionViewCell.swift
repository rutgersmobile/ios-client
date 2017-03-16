//
//  RUCinemaCollectionViewCell.swift
//  Rutgers
//
//  Created by cfw37 on 2/6/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit

class RUCinemaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var time3: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var posterImage: UIImageView!

    @IBOutlet weak var tagsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.label.textColor = .white
        self.tagsLabel.textColor = .white
        self.time1.isHidden = true
        self.time2.isHidden = true
        self.time3.isHidden = true
        self.time1.textColor = .white
        self.time2.textColor = .white
        self.time3.textColor = .white
       
        
        
        self.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .lightGray
    }


}
