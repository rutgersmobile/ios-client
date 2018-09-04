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
    
    //Passed from previous view controller - used for TmdbAPI credits request
    var movieId : Int!
    
    //Also passed from previous view controller, displays most recent showtimes
    var showTimes : [String]!
    
    var tmdbData : TmdbData!
    
    var movie: Cinema!
    
    //Sets up dispose bag for Rx pods - all observables within disposeBag will
    //be dealloc when viewcontroller gets dealloc
    let disposeBag = DisposeBag()
    
    
    init(movie: Cinema, data: TmdbData) {
        self.tmdbData = data
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    /*
     Required when subclassing UITableViewController - compiler yells at you when
     removed
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Standard viewDidLoad method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Sets the tableView datasource to nil, otherwise when you try to set
         the dataSource with the Rx version the compiler will get confused and
         crash - warns you that there is already a datasource set somewhere
         previously.  Most likely a default dataSource used by apple
         */
        
        self.tableView?.dataSource = nil
        
        configureTableView(self.tableView!)
        
        let dataSource =
            RxTableViewSectionedReloadDataSource<MultipleSectionModel>()

        skinTableViewDataSource(dataSource)
        
        
        TmdbAPI.sharedInstance.getTmdbCredits(movieId: self.tmdbData.id!)
            .map { [weak self] (tmdbCredits) in
                var tableViewSections: [MultipleSectionModel] = [
                    .VideoSection(
                        title: self!.tmdbData.title ?? "",
                        items: [
                            .VideoContentItem(
                                title: "Video",
                                key: self!.tmdbData.videos!.videoResult[0].key
                            ),
                            .VideoRatingsItem(
                                title:
                                String(self!.tmdbData.voteAverage ?? 0.0)
                            )
                        ]
                    )
                ]
                
                if self!.movie.showings.count != 0 {
                    let showTimesSection: [MultipleSectionModel] = [
                        .ShowtimesSection(
                            title: "Showtimes",
                            items: [
                                .ShowtimesItem(
                                    showTimes: self!.movie.showings
                                )
                            ]
                        )
                    ]
                    tableViewSections.append(contentsOf: showTimesSection)
                }

                let generalSection: [MultipleSectionModel] = [
                    .InfoSection(
                        title: "Info",
                        items: [
                            .InfoDescriptionItem(
                                description: self!.tmdbData.overview ?? ""
                            ),
                            .GeneralPurposeItem(
                                title: "Director:",
                                data: "David Yates"
                            ),
                            .InfoCastItem(cast: tmdbCredits.cast)
                        ]
                    ),
                    .MovieDataSection(
                        title: "Movie Data",
                        items: [
                            .GeneralPurposeItem(
                                title: "Status:",
                                data: self!.tmdbData.status ?? ""
                            ),
                            .GeneralPurposeItem(
                                title: "Original Language:",
                                data: "English"
                            ),
                            .GeneralPurposeItem(
                                title: "Runtime:",
                                data: self!.getFormattedRuntime(
                                runtime: self!.tmdbData.runtime ?? 0)
                            ),
                            .GeneralPurposeItem(
                                title: "Budget:",
                                data: self!.getFormattedBudget(
                                budget: self!.tmdbData.budget ?? 0)
                            ),
                            .GeneralPurposeItem(
                                title: "Release Date:",
                                data: self!.getFormattedReleaseInfo(
                                date: self!.tmdbData.releaseDate ?? "") )
                        ]
                    )
                ]
                
                tableViewSections.append(contentsOf: generalSection)
                
                return tableViewSections
            }
            .do(onError: {error in print(error)})
            .asDriver(onErrorJustReturn: [])
            .drive((self.tableView?.rx.items(dataSource: dataSource))!)
            .addDisposableTo(disposeBag)
    
    }
    
    /*
     Gets the movie runtime and does some 'fancy' math to format 
     it into a human readable format
     */
    
    func getFormattedRuntime (runtime: Int) -> String {
        let runtimeAsNumber : Double = Double(runtime)
        
        let getInitialValue = runtimeAsNumber/60
        
        //Gets numbers before and after decimal
        var intPart : Double = 0;
        let fractPart = modf(getInitialValue, &intPart)
        
        let hours = Int(getInitialValue - fractPart)
        let minutes = Int(60 * fractPart)
        
        var formatString : String = ""
        
        switch hours {
        case 1:
            formatString.append("\(hours) hour")
        default:
            formatString.append("\(hours) hours")
        }
        
        switch minutes {
        case 0:
            return formatString
        case 1:
            formatString.append(" and \(minutes) minute")
        default:
            formatString.append(" and \(minutes) minutes")
        }

        return formatString
    }
    
    /*
     Uses the extension on String, stringFormattedWithSeparator, in order to
     format the number into something understandable see extension at end of
     file to see how it works
     */
    
    func getFormattedBudget (budget: Int) -> String {
        let formattedNum = budget.stringFormattedWithSeparator
        return "$\(formattedNum)"
    }
    
    
    /*
     Formats the release date
     */
    
    func getFormattedReleaseInfo (date: String) -> String {
        
        var dateString = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let dateObj = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        dateString = dateFormatter.string(from: dateObj!)
        
        return dateString
    }
    
    /*
     Function to reduce some of the boilerplate making the cells:
     Takes in a type of tableView cell, converts it to UITableViewCell (so the
     compilier knows what methods/properties to access) and returns the inital
     cell type
     */
    
    func skinTableViewCells<T>(cell: T) -> T {
        let cell = cell as! UITableViewCell
        cell.backgroundColor =
            UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell as! T
    }
    
    /*
     This method configures the dataSource based off what enum cell value you
     put under the enum secion identifier when you map the TMDB data to the
     cells in the viewDidLoad method. 
    
     TL;DR - sets the cells and sections up
     */
    
    fileprivate func skinTableViewDataSource(_
        dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>
        ) {
        dataSource.configureCell = {[weak self] (
            dataSource: TableViewSectionedDataSource<MultipleSectionModel>,
            table: UITableView,
            idxPath: IndexPath,
            _
        ) in
            switch dataSource[idxPath] {
            case let .VideoContentItem(_, key):
                let cell: VideoContentCell = table.dequeueReusableCell(
                    withIdentifier: "videoContent",
                    for: idxPath) as! VideoContentCell
                
                cell.playerView.backgroundColor =
                    UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
               
                cell.playerView.load(withVideoId: key)
                
                return self!.skinTableViewCells(cell: cell)
            case let .VideoRatingsItem(title):
                
                let cell: VideoRatingsCell =
                    table.dequeueReusableCell(
                        withIdentifier: "videoRatings",
                        for: idxPath) as! VideoRatingsCell
            
                let starImage = UIImage(named: "rating")
                
                cell.starImage.image = starImage
                cell.starImage.contentMode = UIViewContentMode.scaleAspectFit
                cell.starImage.image =
                    cell.starImage.image!
                        .withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.starImage.tintColor = .white
            
                cell.ratingsBorder.layer.borderWidth = 1.5
                cell.ratingsBorder.layer.cornerRadius = 8.0
                cell.ratingsBorder.layer.masksToBounds = true
                cell.ratingsBorder.layer.borderColor = UIColor.white.cgColor
                
                cell.titleLabel.text = title
                
                return self.map{ unwrappedSelf in
                    unwrappedSelf.skinTableViewCells(cell: cell)
                } ?? VideoContentCell()
                
            case let .ShowtimesItem(showtimes):
                
                let cell = table.dequeueReusableCell(withIdentifier: "showtimes",
                                                     for: idxPath
                                                     ) as! ShowtimesCell
                
                let calendar = Calendar.current
                
                let dateFormatter = DateFormatter()
                    
                    dateFormatter.timeStyle = .short
                
                let formattedArray = showtimes.map{
                                        calendar.component(
                                            .day,
                                            from: $0.dateTime
                                        )
                                    }
                
                var noDuplicates : [Int] = []
                
                for index in 0..<formattedArray.count {
                
                    let checkItem = formattedArray[index]
            
                    let nextItem = formattedArray.get(index+1) ?? 0
                    
                    if checkItem != nextItem {
                        noDuplicates.append(checkItem)
                    }
                    
                    if nextItem == 0 {
                        break;
                    }
                    
                }
                
                let frame: CGRect = CGRect(x: 0,
                                           y: 0,
                                           width: cell.frame.width,
                                           height: cell.frame.height/2
                                           )
                
                let showtimesCollectionView =
                    ShowtimesCollectionView.init(frame: frame,
                                                 daysToDisplay: noDuplicates,
                                                 showtimes: showtimes
                                                 )
                
                cell.addSubview(showtimesCollectionView)
                
                cell.showtime1.text = "8--pm"
                cell.showtime2.text = "8--pm"
                cell.showtime3.text = "8--pm"
                cell.showtime4.text = "8--pm"
                
                showtimesCollectionView.rx.itemSelected
                    .subscribe {
                        idxObservable in
                        idxObservable.map {
                            idxPath in
                            
                            let filteredArray =
                                showtimes.filter{
                                calendar.component(.day,
                                                   from: $0.dateTime
                                ) == noDuplicates[idxPath.row]
                            }
                        
                            let timesArray = filteredArray.map{
                                dateFormatter.string(from: $0.dateTime)
                            }
                        
                            cell.showtime1.text = timesArray.get(0) ?? ""
                            cell.showtime2.text = timesArray.get(1) ?? ""
                            cell.showtime3.text = timesArray.get(2) ?? ""
                            cell.showtime4.text = timesArray.get(3) ?? ""
                        
                            }.element
                    }.addDisposableTo(self!.disposeBag)
                
                return self?.skinTableViewCells(cell: cell) ?? ShowtimesCell()
                
            case let .InfoDescriptionItem(description):
                
                let cell: InfoDescriptionCell =
                    table.dequeueReusableCell(
                        withIdentifier: "infoDescription",
                        for: idxPath) as! InfoDescriptionCell
                
                cell.descriptionText.text = description
                
                return
                    self?.skinTableViewCells(cell: cell) ?? InfoDescriptionCell()
                
            case let .InfoCastItem(cast):
                
                let cell: InfoCastCell =
                    table.dequeueReusableCell(
                        withIdentifier: "infoCast",
                        for: idxPath) as! InfoCastCell
                
                let filteredCast = cast.filter{$0.profilePath != nil}
                
                self!.populateCastScrollView(cell: cell, castArray: filteredCast)
                
                return self?.skinTableViewCells(cell: cell) ?? InfoCastCell()
                
            case let .GeneralPurposeItem(title, data):
                let cell: GeneralPurposeCell =
                    table.dequeueReusableCell(withIdentifier: "general",
                                              for: idxPath)
                                              as! GeneralPurposeCell
                
                cell.titleLabel.text = title
                cell.dataLabel.text = data
                
                
                return
                    self?.skinTableViewCells(cell: cell) ?? GeneralPurposeCell()
            }
            
            
            
        }
        
        dataSource.titleForHeaderInSection = {dataSource, index in
            dataSource[index].title
        }
    }
    
    /*
     Populates the scrollview with all the cast members' headshots
     of a given movie cast.  If a headshot (profilePath) is null, it breaks 
     out of the loop and returns any/all available profile shots.
     The constraints just for setting the
     position of the scrollView are set in IB while everything else is 
     done here programatically.
     */
    
    func getCastPhoto(castMember: Cast) -> UIImageView {
        let castImageView: UIImageView = UIImageView()
        castImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        TmdbAPI.sharedInstance.getCastProfilePicture(castData: castMember)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {image in
                //Initializes ImageView for UIImage
                
                //Optional mapping so it ignores nil values
                image.map {unwrappedImage in
                    castImageView.image = unwrappedImage
                }
            }).addDisposableTo(self.disposeBag)
        
        return castImageView
    }
    
    func populateCastScrollView(cell: InfoCastCell, castArray: [Cast]) {
        
        let imageWidth: CGFloat = 50
        let imageHeight: CGFloat = 50
        var xPosition: CGFloat = 0
        var scrollViewContentSize: CGFloat = 0
 
        let castPhotoAndNamesDict =
            castArray
                .map{$0}
                .reduce([String : UIImageView]()) {[weak self] in
                    var finalDict:[String : UIImageView] = $0
            
                    finalDict[$1.name] = self!.getCastPhoto(castMember: $1)
            
                    return finalDict
            }
            
        
        for index in 0..<castPhotoAndNamesDict.count {
            cell.scrollView.addSubview(
                self.createCastLabel(
                    name: castArray[index].name,
                    x: xPosition,
                    imageHeight: imageHeight,
                    imageWidth: imageWidth
                )
            )

            let castImageView: UIImageView =
                castPhotoAndNamesDict[castArray[index].name]!
            
            //Sets the frame of the imageView's width and height
            castImageView.frame.size.width = imageWidth
            castImageView.frame.size.height = imageHeight
            
            //This makes the circle effect for the photos, only
            //works on square photos
            castImageView.layer.cornerRadius =
            castImageView.frame.size.width/2
            
            castImageView.clipsToBounds = true
            
            //Sets the x origin for photo
            castImageView.frame.origin.x = xPosition
            castImageView.frame.origin.y = 0
                                    
            //Adds the castPhoto to the scrollView
            cell.scrollView.addSubview(castImageView)
            
            let iterativeSize = imageWidth + 20
                xPosition += iterativeSize
                scrollViewContentSize += iterativeSize
            
            //Sets the new contentSize for the scrollView
                cell.scrollView.contentSize =
                    CGSize(width: scrollViewContentSize,
                           height: imageHeight)
        
        
        }
    
    }
    
    /*
     Used in populateScrollView - reduces some of the extraneous lines of code
     Essentially just creates the name label under each cast member's photo
    */
    
    func createCastLabel(name: String,
                         x: CGFloat,
                         imageHeight: CGFloat,
                         imageWidth: CGFloat) -> UILabel {
        
        let castLabel =
            UILabel(
                frame: CGRect(
                    x: x,
                    y: imageHeight,
                    width: imageWidth,
                    height: 30)
        )
        
        castLabel.font =
            UIFont(name: "HelveticaNeue", size: 10)
        castLabel.numberOfLines = 2
        castLabel.textAlignment = NSTextAlignment.center
        castLabel.text = name
        castLabel.textColor = .white
        
        return castLabel
        
    }
    
    /*
     This method just creates some grey space underneath the last section,
     purely for style
     */
    
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 3:
            return 30
        default:
            return 0
        }
    }
    
    
    /*
     This method changes the size of certain cells - for example the videoCell
     and the descriptionCell.  You can't specify the height of the cells in
     skinDataSource, that's why this method is used
     */
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt
                            indexPath: IndexPath) -> CGFloat {
        
                var height = CGFloat(30.0)
        
        switch tableView.numberOfSections {
        case 4: //If there are showtimes available, do this layout
            switch indexPath.section {
            case 0: //VideoSection
                switch indexPath.row {
                case 0: //VideoCell
                    height = 200
                case 1: //RatingsCell
                    height = 45
                default:
                    height = 30
                }
            case 1: //ShowtimesSection
                height = 120
            case 2: //InfoSection
                switch indexPath.row {
                case 0: //DescriptionCell
                    height = 120
                case 2: //CastCell
                    height = 120
                default:
                    height = 30
                }
            default: //GeneralCells
                height = 30
            }
        default: //Otherwise do this layout
            switch indexPath.section {
            case 0: //VideoSection
                switch indexPath.row {
                case 0: //VideoCell
                    height = 200
                case 1: //RatingsCell
                    height = 45
                default:
                    height = 30
                }
            case 1: //InfoSection
                switch indexPath.row {
                case 0: //DescriptionCell
                    height = 120
                case 2: //CastCell
                    height = 120
                default:
                    height = 30
                }
            default: //GeneralCells
                height = 30
            }
        }
        
        return height
        
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplayFooterView view: UIView,
                            forSection section: Int) {
        
        view.tintColor = UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView,
                            forSection section: Int){
        
        view.tintColor = UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        
        let font = UIFont(name: "HelveticaNeue-Light", size: 14)
        header.textLabel?.font = font
    }
    
    func configureTableView(_ tableView: UITableView) {
        tableView.backgroundColor =
            UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
        tableView.sectionIndexBackgroundColor =
            UIColor(red:0.23, green:0.23, blue:0.24, alpha:1.0)
        
        tableView.separatorColor =
            UIColor(red:0.51, green:0.51, blue:0.52, alpha:1.0)
        
        tableView.allowsSelection = false
        
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

/*
 Struct and extension used to format large numbers, essentially makes a Struct
 with a computed property using NumberFormatter, then uses Number in an extension
 on Integer to create a String out of whatever numberFormatter created.  Then it
 formats a string by passing itself as an NSNumber for the final result.
 Pretty cool stuff
 
 For more info check out this stackoverflow:
 http://stackoverflow.com/questions/29999024/adding-thousand-separator-to-int-in-swift
 
 */

struct Number {
    static let formatterWithSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension BinaryInteger {
    var stringFormattedWithSeparator: String {
        return Number
            .formatterWithSeparator
            .string(from: self as! NSNumber) ?? ""
    }
}

/*
 This are the enums used to specify the different sections, what they hold,
 what they are called, and how they should be implemented.
 */

//Specifies the different sections within MSM
private enum MultipleSectionModel {
    case VideoSection(title: String, items: [CinemaSectionItem])
    case ShowtimesSection(title: String, items: [CinemaSectionItem])
    case InfoSection(title: String, items: [CinemaSectionItem])
    case MovieDataSection(title: String, items: [CinemaSectionItem])
}

//Specifies the cells and whatever data they are going to display

private enum CinemaSectionItem {
    case VideoContentItem(title: String, key: String)
    case VideoRatingsItem(title: String)
    case ShowtimesItem(showTimes: [Showings])
    case InfoDescriptionItem(description: String)
    case InfoCastItem(cast: [Cast])
    case GeneralPurposeItem(title: String, data: String)
    
}

/* 
 This extension essentially has all of the initializers for MSM.
 It specifies what cells and what titles are going to be used in each section by
 using computed properties with switch statements.  Then it initalizes whatever
 Section is being called with the result of the computed property.
 */
extension MultipleSectionModel: SectionModelType {
    
    var items: [CinemaSectionItem] {
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
    
    init(original: MultipleSectionModel, items: [CinemaSectionItem]) {
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
