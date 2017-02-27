//
//  RUCinemaDetailTableViewController.swift
//  Rutgers
//
//  Created by cfw37 on 2/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import Foundation
import Alamofire

final class RUCinemaDetailTableViewController: UITableViewController {
    
    let movieId : Int!
    
    var showTimes : [String] = []
    
    let disposeBag = DisposeBag()
    
    init(movieId: Int) {
        self.movieId = movieId
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.dataSource = nil
        
        configureTableView(self.tableView!)
        
        
        
        let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()
        
        skinTableViewDataSource(dataSource)
        
        TmdbAPI.sharedInstance.getTmdbData(movieId: self.movieId)
            .flatMap { general in
                TmdbAPI.sharedInstance.getTmdbCredits(movieId: general.id!)
                    .map { credits in (general, credits)}
            }
            .map { (tmdbData, tmdbCredits) in
                
                [
                    .VideoSection(title: tmdbData.title!,
                                  items: [.VideoContentItem(title: "Video", key: tmdbData.videos!.videoResult[0].key),
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
            .drive((self.tableView?.rx.items(dataSource: dataSource))!)
            .addDisposableTo(disposeBag)
        
    }
    
    func skinTableViewDataSource(_ dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { (dataSource, table, idxPath, _) in
            switch dataSource[idxPath] {
            case let .VideoContentItem(_, key):
                let cell: VideoContentCell = table.dequeueReusableCell(withIdentifier: "videoContent", for: idxPath) as! VideoContentCell
                
                
                
                cell.playerView.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
               
                cell.playerView.load(withVideoId: key)
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
            case let .VideoRatingsItem(title):
                
                let cell: VideoRatingsCell = table.dequeueReusableCell(withIdentifier: "videoRatings", for: idxPath) as! VideoRatingsCell
                
                cell.titleLabel.text = title
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
                
            case let .ShowtimesItem(showtimes):
                
                let cell: ShowtimesCell = table.dequeueReusableCell(withIdentifier: "showtimes", for: idxPath) as! ShowtimesCell
                
                cell.showTime1.text = showtimes[0]
                cell.showTime2.text = showtimes[1]
                cell.showTime3.text = showtimes[2]
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
                
            case let .InfoDescriptionItem(description):
                
                let cell: InfoDescriptionCell = table.dequeueReusableCell(withIdentifier: "infoDescription", for: idxPath) as! InfoDescriptionCell
                
                cell.descriptionText.text = description
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
                
            case let .InfoCastItem(cast):
                
                let cell: InfoCastCell = table.dequeueReusableCell(withIdentifier: "infoCast", for: idxPath) as! InfoCastCell
                
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
                let cell: GeneralPurposeCell = table.dequeueReusableCell(withIdentifier: "general", for: idxPath) as! GeneralPurposeCell
                
                cell.titleLabel.text = title
                cell.dataLabel.text = data
                
                cell.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
                
                return cell
            }
            
            
            
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            
            let section = dataSource[index]
            
            return section.title
        }
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
                var height = CGFloat(30.0)
        
        
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        height = 200
                        
                    }
                }
        
                if indexPath.section == 2 {
                    if indexPath.row == 0 || indexPath.row == 2 {
                        height = 120
                  
                    }
                }
                
                return height
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
       
            headerView.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
        
        return headerView
 
    }
    
    func configureTableView(_ tableView: UITableView) {
        
        tableView.backgroundColor = UIColor(red:0.51, green:0.51, blue:0.52, alpha:1.0)
        tableView.sectionIndexBackgroundColor = UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
    
        tableView.register(UINib(nibName: "VideoContentCell", bundle: nil),
                           forCellReuseIdentifier: "videoContent"
        )
        tableView.register(UINib(nibName: "VideoRatingsCell", bundle: nil),
                           forCellReuseIdentifier: "videoRatings"
        )
        tableView.register(UINib(nibName: "ShowtimesCell", bundle: nil),
                           forCellReuseIdentifier: "showtimes"
        )
        tableView.register(UINib(nibName: "InfoDescriptionCell", bundle: nil),
                           forCellReuseIdentifier: "infoDescription"
        )
        tableView.register(UINib(nibName: "InfoCastCell", bundle: nil),
                           forCellReuseIdentifier: "infoCast"
        )
        tableView.register(UINib(nibName: "GeneralPurposeCell", bundle: nil),
                           forCellReuseIdentifier: "general"
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
