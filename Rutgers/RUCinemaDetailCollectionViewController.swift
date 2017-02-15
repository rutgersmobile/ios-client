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
        //
        //        /* SECTIONS:
        //         VIDEO - CustomVideoCell
        //         INFO - InfoCell
        //         DIRECTOR - DefaultCell
        //         CAST - CastCell
        //         MOVIE DATA - Array of DefaultCells
        //         - Status
        //         - Original Language
        //         - Runtime
        //         - Budget
        //         - Release Information
        //         */
        //
        
        //        let sections: [MultipleSectionModel] = [
        //            .VideoSection(title: "Section 1",
        //                                    items: [.VideoSectionItem(title: "Video")]),
        //            .GeneralSection(title: "Section 2",
        //                               items: [.GeneralSectionItem(title: "General")]),
        //
        //        ]
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<MultipleSectionModel>()
        
        skinTableViewDataSource(dataSource)
        
        TmdbAPI.sharedInstance.getTmdbData(movieId: self.movieId)
            .flatMap { general in
                TmdbAPI.sharedInstance.getTmdbCredits(movieId: general.id!)
                    .map { credits in (general, credits)}
            }
            .map { stupidSyntax in
                let (tmdbData, tmdbCredits) = stupidSyntax
                return [.GeneralSection(
                    title: tmdbData.title!,
                    items: [
                        .GeneralSectionItem(title: tmdbData.title!)
                    ]
                )]
            }
            .asDriver(onErrorJustReturn: [])
            .drive((self.collectionView?.rx.items(dataSource: dataSource))!)
            .addDisposableTo(disposeBag)
        
    }
    
    func skinTableViewDataSource(_ dataSource: RxCollectionViewSectionedReloadDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { (dataSource, collection, idxPath, _) in
            switch dataSource[idxPath] {
            case let .VideoSectionItem(title):
                let cell: VideoItemCell = collection.dequeueReusableCell(withReuseIdentifier: "videoCell", for: idxPath) as! VideoItemCell
                cell.titleLabel.text = title
                
                
                return cell
            case let .GeneralSectionItem(title):
                let cell: GeneralItem = collection.dequeueReusableCell(withReuseIdentifier: "generalCell", for: idxPath) as! GeneralItem
                cell.titleLabel.text = title
                
                return cell
            }
        }
        
        
        
        //        dataSource.titleForHeaderInSection = { dataSource, index in
        //            let section = dataSource[index]
        //
        //            return section.title
        //        }
        
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
            UINib(nibName: "VideoItemCell", bundle: nil),
            forCellWithReuseIdentifier: "videoCell"
        )
        
        collectionView.register(UINib(nibName: "GeneralItem", bundle: nil), forCellWithReuseIdentifier: "generalCell")
    }
}

enum MultipleSectionModel {
    case VideoSection(title: String, items: [SectionItem])
    case GeneralSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case VideoSectionItem(title: String)
    case GeneralSectionItem(title: String)
}

extension MultipleSectionModel: SectionModelType {
    
    
    var items: [SectionItem] {
        switch self {
        case .VideoSection(title: _, items: let items):
            return items.map {$0}
        case .GeneralSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSectionModel, items: [SectionItem]) {
        switch original {
        case let .VideoSection(title: title, items: _):
            self = .VideoSection(title: title, items: items)
        case let .GeneralSection(title: title, items: _):
            self = .GeneralSection(title: title, items: items)
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .VideoSection(title: let title, items: _):
            return title
        case .GeneralSection(title: let title, items: _):
            return title
        }
    }
}
