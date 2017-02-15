//
//  RUCinemaDetailCollectionViewController.swift
//  Rutgers
//
//  Created by cfw37 on 2/13/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import Foundation
import Alamofire

final class RUCinemaDetailCollectionViewController: UICollectionViewController {
    
    let CellId = "cell"
    
    let movieId : Int!
    
    let disposeBag = DisposeBag()
    
    init(movieId: Int) {
        self.movieId = movieId
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView(collectionView!)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.dataSource = nil
        
        /* SECTIONS:
         VIDEO - CustomVideoCell
         INFO - InfoCell
         DIRECTOR - DefaultCell
         CAST - CastCell
         MOVIE DATA - Array of DefaultCells
         - Status
         - Original Language
         - Runtime
         - Budget
         - Release Information
         */
        
        TmdbAPI.sharedInstance.getTmdbData(movieId: self.movieId)
            .toArray()
            .asDriver(onErrorJustReturn: [])
            .drive((self.collectionView?.rx.items(
                cellIdentifier: CellId,
                cellType: RUCinemaDetailCollectionViewCell.self
            ))!) { (idxPath, result, cell) in
                    return cell
            }.addDisposableTo(disposeBag)
    }
    
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderInSection section: Int
            ) -> CGSize {
            return CGSize(width: collectionView.frame.size.width, height: 0)
        }
        
        func configureCollectionView(_ collectionView: UICollectionView) {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            layout.itemSize = CGSize(
                width: (self.collectionView?.frame.width)!,
                height: 150
            )
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self.collectionView?.setCollectionViewLayout(layout, animated: false)
            self.collectionView?.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
            
            collectionView.register(
                UINib(nibName: "RUCinemaDetailCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: CellId
            )
        }
}
