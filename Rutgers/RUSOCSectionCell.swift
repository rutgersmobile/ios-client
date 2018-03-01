//
//  RUSOCSectionCell.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/28/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation

class RUSOCSectionCell: UITableViewCell {
    @IBOutlet weak var instructorHeight: NSLayoutConstraint!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var openColor: UIView!
    @IBOutlet weak var sectionNumber: UILabel!
    @IBOutlet weak var instructor: UILabel!
    @IBOutlet weak var sectionIndex: UILabel!
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var buildingRoom1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var buildingRoom2: UILabel!
    @IBOutlet weak var time3: UILabel!
    @IBOutlet weak var buildingRoom3: UILabel!
    @IBOutlet weak var campusCode1: UILabel!
    @IBOutlet weak var campusCode2: UILabel!
    @IBOutlet weak var campusCode3: UILabel!
    @IBOutlet weak var openClosedLabel: UILabel!
    @IBOutlet weak var subHeight: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        subHeight.constant = 0
    }
    
    override func setNeedsUpdateConstraints() {
        super.updateConstraints()
    }
}

class RUSOCSectionCellExtra: UITableViewCell {
    @IBOutlet weak var openColor: UIView!
    @IBOutlet weak var sectionNumber: UILabel!
    @IBOutlet weak var sectionIndex: UILabel!
    @IBOutlet weak var instructor: UILabel!
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var time3: UILabel!
    @IBOutlet weak var time4: UILabel!
    @IBOutlet weak var time5: UILabel!
    @IBOutlet weak var buildingRoom1: UILabel!
    @IBOutlet weak var buildingRoom2: UILabel!
    @IBOutlet weak var buildingRoom3: UILabel!
    @IBOutlet weak var buildingRoom4: UILabel!
    @IBOutlet weak var buildingRoom5: UILabel!
    @IBOutlet weak var campusCode1: UILabel!
    @IBOutlet weak var campusCode2: UILabel!
    @IBOutlet weak var campusCode3: UILabel!
    @IBOutlet weak var campusCode4: UILabel!
    @IBOutlet weak var campusCode5: UILabel!
    @IBOutlet weak var openClosedLabel: UILabel!
}
