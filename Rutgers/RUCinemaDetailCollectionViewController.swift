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



final class RUCinemaDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
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
        self.collectionView?.dataSource = nil
        
        configureCollectionView(collectionView!)
        
        
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<MultipleSectionModel>()
        
        skinTableViewDataSource(dataSource)
        
        TmdbAPI.sharedInstance.getTmdbData(movieId: self.movieId)
            .flatMap { general in
                TmdbAPI.sharedInstance.getTmdbCredits(movieId: general.id!)
                    .map { credits in (general, credits)}
            }
            .map { (tmdbData, tmdbCredits) in
                
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
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                cell.titleLabel.text = title
                
                return cell
            case let .VideoContentItem(_, key):
                self.collectionView?.layoutAttributesForItem(at: idxPath)?.size = CGSize(width: 300, height: 300)
                let cell: VideoContentCell = collection.dequeueReusableCell(withReuseIdentifier: "videoContent", for: idxPath) as! VideoContentCell
                
                cell.playerView.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                cell.playerView.load(withVideoId: key)
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
            case let .VideoRatingsItem(title):
                
                let cell: VideoRatingsCell = collection.dequeueReusableCell(withReuseIdentifier: "videoRatings", for: idxPath) as! VideoRatingsCell
                
                cell.titleLabel.text = title
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
                
            case let .ShowtimesItem(showtimes):
                
                let cell: ShowtimesCell = collection.dequeueReusableCell(withReuseIdentifier: "showtimes", for: idxPath) as! ShowtimesCell
                
                cell.showTime1.text = showtimes[0]
                cell.showTime2.text = showtimes[1]
                cell.showTime3.text = showtimes[2]
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
                
            case let .InfoDescriptionItem(description):
                
                let cell: InfoDescriptionCell = collection.dequeueReusableCell(withReuseIdentifier: "infoDescription", for: idxPath) as! InfoDescriptionCell
                
                cell.descriptionText.text = description
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
                
            case let .InfoCastItem(cast):
                
                let cell: InfoCastCell = collection.dequeueReusableCell(withReuseIdentifier: "infoCast", for: idxPath) as! InfoCastCell
                
                let imageWidth: CGFloat = 50
                let imageHeight: CGFloat = 50
                var xPosition: CGFloat = 0
                var scrollViewContentSize: CGFloat = 0
                
                for index in 0..<cast.count {
                    if cast[index].profilePath != nil {
                        TmdbAPI.sharedInstance.getCastProfilePicture(castData: cast[index])
                            .observeOn(MainScheduler.instance)
                            .subscribe(onNext: { image in

                                let castLabel = UILabel(frame: CGRect(x: xPosition, y: imageHeight, width: imageWidth, height: 30))
                                castLabel.font = UIFont(name: "HelveticaNeue", size: 10)
                                castLabel.numberOfLines = 2
                                castLabel.textAlignment = NSTextAlignment.center
                                castLabel.text = cast[index].name
                                castLabel.textColor = .white
                                cell.scrollView.addSubview(castLabel)
                                
                                let myImageView: UIImageView = UIImageView()
                                if let image = image {
                                    myImageView.image = image
                                }
                                
                                
                                myImageView.frame.size.width = imageWidth
                                myImageView.frame.size.height = imageHeight
                                
                                myImageView.layer.cornerRadius = myImageView.frame.size.width/2
                                myImageView.clipsToBounds = true
                                
                                
                                myImageView.frame.origin.x = xPosition
                                myImageView.frame.origin.y = 0
                                
                                cell.scrollView.addSubview(myImageView)
                                
                                xPosition += imageWidth + 20
                                scrollViewContentSize += imageWidth + 20
                                
                                cell.scrollView.contentSize = CGSize(width: scrollViewContentSize, height: imageHeight)
                                
                                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                            }).addDisposableTo(self.disposeBag)
                    } else {
                        break
                    }
                    
                }
                
                return cell
                
            case let .GeneralPurposeItem(title, data):
                let cell: GeneralPurposeCell = collection.dequeueReusableCell(withReuseIdentifier: "general", for: idxPath) as! GeneralPurposeCell
                
                cell.titleLabel.text = title
                cell.dataLabel.text = data
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
            }
            
        
            
        }
        
        //Does not work, doesn't even get called
        dataSource.supplementaryViewFactory = { (
            dataSource: CollectionViewSectionedDataSource<MultipleSectionModel>,
            collection: UICollectionView,
            kind: String,
            idxPath: IndexPath
        ) in
            let header : CinemaHeaderCell = collection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: idxPath) as! CinemaHeaderCell
            
            let model = dataSource.sectionModels[idxPath.section]
            print(model)
            
            header.backgroundColor = .red
            
            header.headerTitle.text = "TITLE"
            
            return header
        }
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        

        
        let width = (self.collectionView?.frame.width)!
        var height = CGFloat(30.0)
        var size = CGSize(width: width, height: height)
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                height = 200
                size = CGSize(width: width, height: height)
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 || indexPath.row == 2 {
                height = 120
                size = CGSize(width: width, height: height)
            }
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func configureCollectionView(_ collectionView: UICollectionView) {
        
//        self.collectionView?.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
        self.collectionView?.backgroundColor = UIColor(red:0.51, green:0.51, blue:0.52, alpha:1.0)
        
//        collectionView.register(UINib(nibName: "CinemaHeaderCell", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell"
//        )
        
        collectionView.register(CinemaHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell")
        
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
            return items
        case .ShowtimesSection(title: _, items: let items):
            return items
        case .InfoSection(title: _, items: let items):
            return items
        case .MovieDataSection(title: _, items: let items):
            return items
        }
    }
    
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


