//
//  VideoContentCell.swift
//  Rutgers
//
//  Created by cfw37 on 2/17/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import YouTubePlayer


class VideoContentCell: UICollectionViewCell {

    @IBOutlet weak var videoPlayer: YouTubePlayerView!
    
    var isHeightCalculated: Bool = false
    
    
    /* FROM:
    http://stackoverflow.com/questions/25895311/uicollectionview-self-sizing-cells-with-auto-layout
     Needs some change in autolayout to make this work I believe
    */
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        //Exhibit A - We need to cache our calculation to prevent a crash.
        if !isHeightCalculated {
            setNeedsLayout()
            layoutIfNeeded()
            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
            var newFrame = layoutAttributes.frame
            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
            layoutAttributes.frame = newFrame
            isHeightCalculated = true
        }
        return layoutAttributes
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.autoresizingMask = UIViewAutoresizing()
        self.videoPlayer.bounds = self.contentView.bounds
    }

}
