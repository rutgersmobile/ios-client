//
//  ShowtimesCollectionView.swift
//  Rutgers
//
//  Created by cfw37 on 3/21/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources

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
        
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeStyle = .short
        
        let filteredArray = showtimes.filter{calendar.component(.day, from: $0.dateTime) == daysToDisplay[indexPath.row]}
        
        let monthArray = filteredArray.map{calendar.component(.month, from: $0.dateTime)}
        
        let dayString = "\(daysToDisplay[indexPath.row])"
        
        let month = monthArray.get(0) ?? 0
        
        let monthString = dateFormatter.shortMonthSymbols.get(month-1)
        
        cell.dayLabel.text = dayString
        cell.monthLabel.text = monthString
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: frame.height)
    }
}

private struct ScrollingSection {
    var items: [ScrollingSectionItem]
    
    init(items: [ScrollingSectionItem]) {
        self.items = items
    }
}

private struct ScrollingSectionItem {
    let day: String
    let month: String
}

extension ScrollingSection: SectionModelType {
    fileprivate typealias Item = ScrollingSectionItem
    
    init(original: ScrollingSection, items: [Item]) {
        self = original
        self.items = items
    }
}
