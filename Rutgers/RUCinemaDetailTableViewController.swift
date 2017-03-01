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
        super.init(nibName: nil, bundle: nil)
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.dataSource = nil
        
        configureTableView(self.tableView!)
        
        
        
        let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()
        
        self.tableView.allowsSelection = false
    
        
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
                    
                    
                    .MovieDataSection(title: "Movie Data",
                                      items: [.GeneralPurposeItem(title: "Status:", data: tmdbData.status!),
                                              .GeneralPurposeItem(title: "Original Language:", data: "English"),
                                              .GeneralPurposeItem(title: "Runtime:", data: self.getFormattedRuntime(runtime: tmdbData.runtime!)),
                                              .GeneralPurposeItem(title: "Budget:", data: self.getFormattedBudget(budget: tmdbData.budget!)),
                                              .GeneralPurposeItem(title: "Release Date:", data: self.getFormattedReleaseInfo(date: tmdbData.releaseDate!))])
                ]
                
                
                
                
                
            }
            .do(onError: {error in print(error)})
            .asDriver(onErrorJustReturn: [])
            .drive((self.tableView?.rx.items(dataSource: dataSource))!)
            .addDisposableTo(disposeBag)
        
    }
    
    func getFormattedRuntime (runtime: Int) -> String {
        let runtimeAsNumber : Double = Double(runtime)
        
        let getInitialValue = runtimeAsNumber/60
        
        //Gets numbers before and after decimal
        var intPart : Double = 0;
        let fractPart = modf(getInitialValue, &intPart)
        
        let hours = Int(getInitialValue - fractPart)
        let minutes = Int(60 * fractPart)
        
        var formatString : String = ""
        
        if hours == 1 {
            formatString.append("\(hours) hour")
        } else {
            formatString.append("\(hours) hours")
        }
        
        if minutes == 0 {
            return formatString
        } else if minutes == 1 {
            formatString.append(" and \(minutes) minute")
        } else {
            formatString.append(" and \(minutes) minutes")
        }

        return formatString
    }
    
    func getFormattedBudget (budget: Int) -> String {
        let formattedNum = budget.stringFormattedWithSeparator
        
        
        return "$\(formattedNum)"
    }
    
    func getFormattedReleaseInfo (date: String) -> String {
        
        var dateString = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let dateObj = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        print("Dateobj: \(dateFormatter.string(from: dateObj!))")
        
        dateString = dateFormatter.string(from: dateObj!)
        
        return dateString
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
            
                let starImage = UIImage(named: "rating")
                
                
                cell.starImage.image = starImage
                
               
                cell.starImage.contentMode = UIViewContentMode.scaleAspectFit
                
                cell.starImage.image = cell.starImage.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.starImage.tintColor = .white
                
    
                
                cell.ratingsBorder.layer.borderWidth = 1.5
                cell.ratingsBorder.layer.cornerRadius = 8.0
                cell.ratingsBorder.layer.masksToBounds = true
                cell.ratingsBorder.layer.borderColor = UIColor.white.cgColor
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
                                if let newImage = image {
               
                                    
                                    myImageView.image = newImage
                                    myImageView.contentMode = UIViewContentMode.scaleAspectFill
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
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 30
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
                var height = CGFloat(30.0)
        
        
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        height = 200
                        
                    }
                    
                    if indexPath.row == 1 {
                        height = 45
                    }
                    
                  
                }
        
                if indexPath.section == 2 {
                    if indexPath.row == 0 || indexPath.row == 2 {
                        height = 120
                  
                    }
                }
                
                return height
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        
        let font = UIFont(name: "HelveticaNeue-Light", size: 14)
        
        header.textLabel?.font = font
    }
    
    
    func configureTableView(_ tableView: UITableView) {
        
        tableView.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
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

//From stack overflow http://stackoverflow.com/questions/29999024/adding-thousand-separator-to-int-in-swift
struct Number {
    static let formatterWithSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Integer {
    var stringFormattedWithSeparator: String {
        return Number.formatterWithSeparator.string(from: self as! NSNumber) ?? ""
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
