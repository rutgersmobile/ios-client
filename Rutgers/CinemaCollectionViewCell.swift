//
//  CinemaCollectionViewCell.swift
//  Rutgers
//
//  Created by cfw37 on 2/3/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit

class CinemaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .lightGray
    }

}
