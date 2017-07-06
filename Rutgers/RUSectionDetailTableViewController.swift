//
//  RUSectionDetailTableViewController.swift
//  Rutgers
//
//  Created by Colin Walsh on 6/26/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class RUSOCDetailCell: UITableViewCell {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
}

class RUSOCLocationCell: UITableViewCell {
    
    @IBOutlet weak var buildingTitle: UILabel!
    @IBOutlet weak var buildingImage: UIImageView!
}

class RUSOCSectionDetailCell: UITableViewCell {
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var openClosedDisplay: UIView!
    
    
}

class RUSOCSectionDetailTableViewController: UITableViewController {
    
    var section: Section!
    let disposeBag = DisposeBag()
    var images: [UIImage?] = []
    
    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        section: Section
        ) -> RUSOCSectionDetailTableViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCSectionDetailViewController"
            ) as! RUSOCSectionDetailTableViewController
        
        me.section = section
        
        return me
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = nil
        self.tableView.layoutIfNeeded()
        self.tableView.tableFooterView = UIView()
        
        self.images =
            self.section
                .meetingTimes
                .map {
                    $0.buildingCode.flatMap{
                        URL(string:
                            "http://rumobile-gis-prod-asb.ei.rutgers.edu/buildings/\($0).jpeg")}
                        .flatMap{try? Data.init(contentsOf: $0)}
                        .flatMap{UIImage.init(data: $0)}
        }
        
        let dataSource = RxTableViewSectionedReloadDataSource<MultiSection>()
        
        self.tableView.allowsSelection = false
        
        dataSource.configureCell = { (
            ds: TableViewSectionedDataSource<MultiSection>,
            tv: UITableView,
            idxPath: IndexPath,
            item: SOCSectionDetailItem
            ) in
            switch dataSource[idxPath] {
            case let .noteSectionItem(section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "notesCell",
                    for: idxPath
                ) as! RUSOCDetailCell
                
                cell.leftLabel?.text = section.sectionNotes
                
                self.tableView.rowHeight = 50
                
                cell.backgroundColor = .lightGray
                cell.setupCellLayout()
                return cell
            case let .sectionItem(section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "sectionCell",
                    for: idxPath
                    ) as! RUSOCSectionDetailCell
                
                cell.sectionLabel?.text = "Section \(section.number)"
                cell.openClosedDisplay.backgroundColor = section.openStatus
                    ? RUSOCViewController.openColor
                    : RUSOCViewController.closedColor
                
                cell.openClosedDisplay.layer.cornerRadius = 0.8
                
                self.tableView.rowHeight = 50
                cell.setupCellLayout()
                return cell
            case let .defaultItem(item):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "defaultCell",
                    for: idxPath
                ) as! RUSOCDetailCell
                
                switch item{
                case is MeetingTime:
                    let item = item as! MeetingTime
                    
                    if var day = item.meetingDay {
                        switch day {
                        case "M":
                            day = "Monday"
                        case "T":
                            day = "Tuesday"
                        case "W":
                            day = "Wednesday"
                        case "TH":
                            day = "Thursday"
                        case "F":
                            day = "Friday"
                        default:
                            day = "Saturday"
                        }
                        cell.leftLabel?.text = day
                    }
                    
                    if let startTime = item.startTime {
                        cell.rightLabel?.text =
                        "\(startTime.meetTimeFormatted())-\(item.endTime!.meetTimeFormatted())"
                    } else {
                        cell.rightLabel?.text = ""
                    }
                case is Instructor:
                    let item = item as! Instructor
                    cell.leftLabel?.text = "Instructor"
                    cell.rightLabel?.text = "\(item.instructorName)"
                default:
                    cell.leftLabel?.text = ""
                }
                
                self.tableView.rowHeight = 50
                cell.setupCellLayout()
                return cell
            case let .locationItem(image):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "locationCell",
                    for: idxPath
                ) as! RUSOCLocationCell
                
                self.tableView.rowHeight = 220
                
                cell.buildingImage.image = image.flatMap {$0}
                cell.setupCellLayout()
                
                return cell
            }
            
        }
        
        dataSource.titleForHeaderInSection = { (ds, idxPath) in
            ds.sectionModels[idxPath].title
        }
        
        let noteSectionItem: [SOCSectionDetailItem] = {
            switch self.section.sectionNotes.flatMap({$0.isEmpty}) {
            case let boolVal where boolVal == true:
                return []
            default:
                 return
                    [SOCSectionDetailItem.noteSectionItem(section: self
                                                                   .section)]
            }
        }()
        
        let meetingSection: [MultiSection] = { () -> [MultiSection] in
            
            switch self.section.meetingTimes[0].endTime.flatMap({$0}) {
            case nil:
                return []
            default:
                return
                    [MultiSection
                        .MeetingTimesSection(
                            title: "Meeting Times",
                            items:
                            self.section
                                .meetingTimes
                                .map {
                                    SOCSectionDetailItem
                                        .defaultItem(item:$0)})]
            }
            }()
        
        let locationSection: [MultiSection] = {
            
            switch self.images[0] {
            case nil:
                return []
            default:
                return [MultiSection
                        .LocationSection(
                            title: "Locations",
                            items:
                            self.images
                                .map {SOCSectionDetailItem
                                      .locationItem(images: $0)}
                                    )]
            }
        }()
        
        let toDrive: [MultiSection] =
            [
            .HeaderSection(
                items: noteSectionItem + [.sectionItem(section: self.section)] +
                        self.section
                           .instructors
                        .map {.defaultItem(item: $0)}
            )
            ] + meetingSection + locationSection
        
        Observable.just(toDrive)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView!.rx.items(dataSource: dataSource))
            .addDisposableTo(self.disposeBag)
        }
    }


private enum MultiSection {
    case HeaderSection(items: [SOCSectionDetailItem])
    case MeetingTimesSection(title: String, items: [SOCSectionDetailItem])
    case LocationSection(title: String, items: [SOCSectionDetailItem])
}

private enum SOCSectionDetailItem {
    case noteSectionItem(section: Section)
    case sectionItem(section: Section)
    case defaultItem(item: Any)
    case locationItem(images: UIImage?)
}

extension MultiSection: SectionModelType {
    
    var items: [SOCSectionDetailItem] {
        switch self {
        case .HeaderSection(items: let items):
            return items
        case .MeetingTimesSection(title: _, items: let items):
            return items
        case .LocationSection(title: _, items: let items):
            return items
        }
    }
    
    var title: String {
        switch self {
        case .HeaderSection(items: _):
            return ""
        case .MeetingTimesSection(title: let title, items: _):
            return title
        case .LocationSection(title: let title, items: _):
            return title
        }
    }
    
    init(original: MultiSection, items: [SOCSectionDetailItem]) {
        switch original {
        case let .HeaderSection(items: items):
            self = .HeaderSection(items: items)
        case let .MeetingTimesSection(title: title, items: _):
            self = .MeetingTimesSection(title: title, items: items)
        case let .LocationSection(title: title, items: _):
            self = .LocationSection(title: title, items: items)
        }
    }
}
