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

/*
class RUMeetingTimesAndLocationContent {
    var day: String?
    var times: String?
    var image: UIImage?
    var expanded: Bool
    
    init(day: String, times: String, image: UIImage) {
        self.day = day
        self.times = times
        self.image = image
        self.expanded = false
    }
}*/

class RUMeetingTimesAndLocationCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var locationImage: UIImageView!
    
    var expanded: Bool = false
    {
        didSet {
            if expanded == false {
                self.imageHeight.constant = 0.0
            } else {
                self.imageHeight.constant = 145.0
            }
        }
    }
    
}

class RUSOCSectionDetailCell: UITableViewCell {
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var openClosedDisplay: UIView!
    
    
}

class RUSOCSectionDetailTableViewController: UITableViewController {
    
    var section: Section!
    let disposeBag = DisposeBag()
    //var images: [UIImage?] = []
    
    
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
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        let dataSource = RxTableViewSectionedReloadDataSource<MultiSection>()
        
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
                
                //self.tableView.rowHeight = 50
                
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
                
                //self.tableView.rowHeight = 50
                cell.setupCellLayout()
                return cell
            case let .defaultItem(item):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "defaultCell",
                    for: idxPath
                ) as! RUSOCDetailCell
                
                let item = item as! Instructor
                cell.leftLabel?.text = "Instructor"
                cell.rightLabel?.text = "\(item.instructorName)"
                
                cell.setupCellLayout()
                return cell
            case let .meetingTimesItem(item):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "meetingLocations",
                    for: idxPath) as! RUMeetingTimesAndLocationCell
                
                
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
                    cell.dayLabel?.text = day
                }
                
                let startTime = item.startTime?.meetTimeFormatted() ?? ""
                let endTime = item.endTime?.meetTimeFormatted() ?? ""
                
                cell.timesLabel?.text = "\(startTime)-\(endTime)"
                
                let url =
                "http://rumobile-gis-prod-asb.ei.rutgers.edu/buildings/"
                
                let image =
                    item.buildingCode
                        .flatMap{
                            URL(string: url + "\($0).jpeg")
                        }
                        .flatMap{try? Data.init(contentsOf: $0)}
                        .flatMap{UIImage.init(data: $0)}
                
                cell.locationImage.image =
                                   image ??
                                   UIImage(cgImage: #imageLiteral(resourceName: "Not_available").cgImage!) //PLACEHOLDER! REPLACE IT!
                
                cell.setupCellLayout()
                
                return cell
            }
            
        }
        
        dataSource.titleForHeaderInSection = { (ds, idxPath) in
            //This needs to stay in order for the app to not crash
            if idxPath != 0 {
                return ds.sectionModels[idxPath].title
            } else {
                return ""
            }
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
                                .flatMap { SOCSectionDetailItem
                                           .meetingTimesItem(item: $0)
                                         }
                       )
                    ]
            }
        }()
        
        let instructorSection: [MultiSection] = {
           [MultiSection
            .InstructorSection(title: "Instructors",
                              items: self.section.instructors.map {
                                SOCSectionDetailItem.defaultItem(item: $0)
            })]
        }()
        
        let toDrive: [MultiSection] =
            [
            .HeaderSection(
                items: noteSectionItem +
                    [.sectionItem(section:
                                  self.section)]
            )
            ] + instructorSection + meetingSection
        
        Observable.just(toDrive)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView!.rx.items(dataSource: dataSource))
            .addDisposableTo(self.disposeBag)
        } //End of ViewDidLoad
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        guard let cell =
            tableView
            .cellForRow(at: indexPath)
                as? RUMeetingTimesAndLocationCell
            else {return}
        
        cell.expanded = !cell.expanded
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
} //End of class
    

private enum MultiSection {
    case HeaderSection(items: [SOCSectionDetailItem])
    case MeetingTimesSection(title: String, items: [SOCSectionDetailItem])
    case InstructorSection(title: String, items: [SOCSectionDetailItem])
}

private enum SOCSectionDetailItem {
    case noteSectionItem(section: Section)
    case sectionItem(section: Section)
    case defaultItem(item: Any)
    case meetingTimesItem(item: MeetingTime)
}

extension MultiSection: SectionModelType {
    
    var items: [SOCSectionDetailItem] {
        switch self {
        case .HeaderSection(items: let items):
            return items
        case .MeetingTimesSection(title: _, items: let items):
            return items
        case .InstructorSection(title: _, items: let items):
            return items
        }
    }
    
    var title: String {
        switch self {
        case .HeaderSection(items: _):
            return ""
        case .MeetingTimesSection(title: let title, items: _):
            return title
        case .InstructorSection(title: let title, items: _):
            return title
        }
    }
    
    init(original: MultiSection, items: [SOCSectionDetailItem]) {
        switch original {
        case let .HeaderSection(items: items):
            self = .HeaderSection(items: items)
        case let .MeetingTimesSection(title: title, items: _):
            self = .MeetingTimesSection(title: title, items: items)
        case let .InstructorSection(title: title, items: _):
            self = .InstructorSection(title: title, items: items)
        }
    }
}
