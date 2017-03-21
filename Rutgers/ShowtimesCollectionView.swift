//
//  ShowtimesCollectionView.swift
//  Rutgers
//
//  Created by cfw37 on 3/21/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import UIKit

class ShowtimesCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let daysToDisplay: [Int]!
    
    let showtimes: [Showings]!
    
    let showtimeLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        return layout
    }()
    
    init(frame: CGRect, daysToDisplay: [Int], showtimes: [Showings]) {
        self.daysToDisplay = daysToDisplay
        self.showtimes = showtimes
        
        super.init(frame: frame, collectionViewLayout: showtimeLayout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.delegate = self
        self.dataSource = self
        
        self.register(UINib(nibName: "ShowtimesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "showtimesCVCell")
        
        self.backgroundColor = .clear
        
        self.showsHorizontalScrollIndicator = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showtimesCVCell", for: indexPath) as! ShowtimesCollectionViewCell
        
        let string = "\(daysToDisplay[indexPath.row])"
        
        cell.dayLabel.text = string
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected!")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: frame.height)
    }
   
    
}
