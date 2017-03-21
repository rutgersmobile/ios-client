//
//  ShowtimesCollectionViewCell.swift
//  Rutgers
//
//  Created by cfw37 on 3/17/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit

class ShowtimesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var showtime1: UILabel!
    @IBOutlet weak var showtime2: UILabel!
    @IBOutlet weak var showtime3: UILabel!
    @IBOutlet weak var showtime4: UILabel!
    
    @IBOutlet weak var monthDayView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

}
