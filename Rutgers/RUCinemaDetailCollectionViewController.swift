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
import YouTubePlayer


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
            .map { (tmdbData, tmdbCredits) in
                
                //https://www.youtube.com/watch?v=KEY(SUXWAEX2jlg)
                
                [
                    .VideoSection(title: tmdbData.title!,
                                  items: [.VideoTitleItem(title: tmdbData.title!),
                                          .VideoContentItem(title: "Video", key: tmdbData.videos!.videoResult[0].key),
                                          .VideoRatingsItem(title: tmdbData.homePage!)])
                  
                ]
                
                
                
                
                
            }
            .do(onError: {error in print(error)})
            .asDriver(onErrorJustReturn: [])
            .drive((self.collectionView?.rx.items(dataSource: dataSource))!)
            .addDisposableTo(disposeBag)
        
    }
    
    func skinTableViewDataSource(_ dataSource: RxCollectionViewSectionedReloadDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { (dataSource, collection, idxPath, _) in
            switch dataSource[idxPath] {
            case let .VideoTitleItem(title):
                let cell: VideoTitleCell = collection.dequeueReusableCell(withReuseIdentifier: "videoTitle", for: idxPath) as! VideoTitleCell
            
                cell.titleLabel.text = title
                
                return cell
            case let .VideoContentItem(_, key):
                let cell: VideoContentCell = collection.dequeueReusableCell(withReuseIdentifier: "videoContent", for: idxPath) as! VideoContentCell
                
                let videoPlayer = YouTubePlayerView(frame: CGRect(x: cell.videoPlayer.center.x, y: cell.videoPlayer.center.y, width: 300, height: 300))
                
                    let myVideoURL = URL(string: "https://www.youtube.com/watch?v=\(key)")
                    print(myVideoURL!)
                    videoPlayer.loadVideoURL(myVideoURL!)
                
                cell.sizeToFit()
                
                cell.videoPlayer = videoPlayer
//                cell.titleLabel.text = title
                
                return cell
            case let .VideoRatingsItem(title):
                let cell: VideoRatingsCell = collection.dequeueReusableCell(withReuseIdentifier: "videoRatings", for: idxPath) as! VideoRatingsCell
                cell.titleLabel.text = title
                
                return cell
                
            }
            
        }
        
        
    }
    
    

    
    func configureCollectionView(_ collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(
            width: (self.collectionView?.frame.width)!,
            height: 300
        )
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.collectionView?.setCollectionViewLayout(layout, animated: false)
        self.collectionView?.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
        
        collectionView.register(
            UINib(nibName: "VideoTitleCell", bundle: nil),
            forCellWithReuseIdentifier: "videoTitle"
        )
        
        collectionView.register(
            UINib(nibName: "VideoContentCell", bundle: nil),
            forCellWithReuseIdentifier: "videoContent"
        )
        
        collectionView.register(
            UINib(nibName: "VideoRatingsCell", bundle: nil),
            forCellWithReuseIdentifier: "videoRatings"
        )
    }
}

enum MultipleSectionModel {
    case VideoSection(title: String, items: [SectionItem])
    case ShowtimesSection(title: String, items: [SectionItem])
    case InfoSection(title: String, items: [SectionItem])
    case MovieDataSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case VideoTitleItem(title: String)
    case VideoContentItem(title: String, key: String)
    case VideoRatingsItem(title: String)
    
    
}

extension MultipleSectionModel: SectionModelType {
    
    
    var items: [SectionItem] {
        switch self {
        case .VideoSection(title: _, items: let items):
            return items.map {$0}
        case .ShowtimesSection(title: _, items: let items):
            return items.map {$0}
        case .InfoSection(title: _, items: let items):
            return items.map {$0}
        case .MovieDataSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSectionModel, items: [SectionItem]) {
        switch original {
        case let .VideoSection(title: title, items: _):
            self = .VideoSection(title: title, items: items)
        case let .ShowtimesSection(title: title, items: _):
            self = .ShowtimesSection(title: title, items: items)
        case let .InfoSection(title: title, items: _):
            self = .InfoSection(title: title, items: items)
        case let .MovieDataSection(title: title, items: _):
            self = .MovieDataSection(title: title, items: items)
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .VideoSection(title: let title, items: _):
            return title
        case .ShowtimesSection(title: let title, items: _):
            return title
        case .InfoSection(title: let title, items: _):
            return title
        case .MovieDataSection(title: let title, items: _):
            return title
        }
    }
}
