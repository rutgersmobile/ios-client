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
    
    var showTimes : [String] = []
    
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
        
        print(self.showTimes)
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
                                          .VideoRatingsItem(title: String(tmdbData.voteAverage!))]),
                    
                    .ShowtimesSection(title: "Showtimes",
                                      items: [.ShowtimesItem(showTimes: self.showTimes)]),
                    
                    .InfoSection(title: "Info",
                                 items: [.InfoDescriptionItem(description: tmdbData.overview!),
                                         .GeneralPurposeItem(title: "Director:", data: "David Yates"),
                                         .InfoCastItem(cast: tmdbCredits.cast)]),
                    
                    
                    .MovieDataSection(title: "Data",
                                      items: [.GeneralPurposeItem(title: "Status:", data: tmdbData.status!),
                                              .GeneralPurposeItem(title: "Original Language:", data: "English"),
                                              .GeneralPurposeItem(title: "Runtime:", data: String(describing: tmdbData.runtime!)),
                                              .GeneralPurposeItem(title: "Budget:", data: String(describing: tmdbData.budget!)),
                                              .GeneralPurposeItem(title: "Release Information:", data: tmdbData.releaseDate!)])
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
                self.collectionView?.layoutAttributesForItem(at: idxPath)?.size = CGSize(width: 300, height: 300)
                let cell: VideoContentCell = collection.dequeueReusableCell(withReuseIdentifier: "videoContent", for: idxPath) as! VideoContentCell
                
//                let videoPlayer = YouTubePlayerView(frame: CGRect(x: cell.videoPlayer.center.x, y: cell.videoPlayer.center.y, width: 300, height: 300))
//                
//                let myVideoURL = URL(string: "https://www.youtube.com/watch?v=\(key)")
//                print(myVideoURL!)
//                videoPlayer.loadVideoURL(myVideoURL!)
//                
//                cell.sizeToFit()
//                
//                cell.videoPlayer = videoPlayer
                //                cell.titleLabel.text = title
                
                return cell
            case let .VideoRatingsItem(title):
                
                let cell: VideoRatingsCell = collection.dequeueReusableCell(withReuseIdentifier: "videoRatings", for: idxPath) as! VideoRatingsCell
                
                cell.titleLabel.text = title
                
                return cell
                
            case let .ShowtimesItem(showtimes):
                
                let cell: ShowtimesCell = collection.dequeueReusableCell(withReuseIdentifier: "showtimes", for: idxPath) as! ShowtimesCell
                
                cell.showTime1.text = showtimes[0]
                cell.showTime2.text = showtimes[1]
                cell.showTime3.text = showtimes[2]
                
                return cell
                
            case let .InfoDescriptionItem(description):
                
                let cell: InfoDescriptionCell = collection.dequeueReusableCell(withReuseIdentifier: "infoDescription", for: idxPath) as! InfoDescriptionCell
                
                cell.descriptionText.text = description
                
                return cell
                
            case let .InfoCastItem(cast):
                
                let cell: InfoCastCell = collection.dequeueReusableCell(withReuseIdentifier: "infoCast", for: idxPath) as! InfoCastCell
                
                return cell
                
            case let .GeneralPurposeItem(title, data):
                let cell: GeneralPurposeCell = collection.dequeueReusableCell(withReuseIdentifier: "general", for: idxPath) as! GeneralPurposeCell
                
                cell.titleLabel.text = title
                cell.dataLabel.text = data
                
                return cell
            }
            
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //Seems to be the answer to fixing the layout
        let width : CGFloat
        let height : CGFloat
        
        if indexPath.section == 0 {
            // First section
            width = collectionView.frame.width/7
            height = 50
            return CGSize(width: width, height: height)
        } else {
            // Second section
            width = collectionView.frame.width/3
            height = 50
            return CGSize(width: width, height: height)
        }
    }

    
    func configureCollectionView(_ collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        //        layout.estimatedItemSize = CGSize(width: (self.collectionView?.frame.width)!, height: 50)
//        layout.itemSize = CGSize(
//            width: (self.collectionView?.frame.width)!,
//            height: 50
//        )
        layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0)
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
        
        collectionView.register(
            UINib(nibName: "ShowtimesCell", bundle: nil),
            forCellWithReuseIdentifier: "showtimes"
        )
        
        collectionView.register(
            UINib(nibName: "InfoDescriptionCell", bundle: nil),
            forCellWithReuseIdentifier: "infoDescription"
        )
        
        collectionView.register(
            UINib(nibName: "InfoCastCell", bundle: nil),
            forCellWithReuseIdentifier: "infoCast"
        )
        
        collectionView.register(
            UINib(nibName: "GeneralPurposeCell", bundle: nil),
            forCellWithReuseIdentifier: "general"
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
    case ShowtimesItem(showTimes: [String])
    case InfoDescriptionItem(description: String)
    case InfoCastItem(cast: [Cast])
    case GeneralPurposeItem(title: String, data: String)
    
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
