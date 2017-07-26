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

class RUSOCNotesCell: UITableViewCell {
}

class RUMeetingTimesAndLocationCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet weak var campusAbbrev: UILabel!
    @IBOutlet weak var roomNumber: UILabel!
    
    @IBOutlet weak var buildingCode: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var buildingCodeHeight: NSLayoutConstraint!
    @IBOutlet weak var campusAbbrevHeight: NSLayoutConstraint!

    @IBOutlet weak var roomNumberHeight: NSLayoutConstraint!
    
    @IBOutlet weak var locationImage: UIImageView!
    
    var expanded: Bool = false {
        didSet {
            if !expanded {
                self.imageHeight.constant = 0.0
                self.buildingCodeHeight.constant = 0.0
                self.campusAbbrevHeight.constant = 0.0
                self.roomNumberHeight.constant = 0.0
            } else {
                self.imageHeight.constant = 100.0
                self.buildingCodeHeight.constant = 20
                self.campusAbbrevHeight.constant = 20
                self.roomNumberHeight.constant = 20
            }
        }
    }
}

class RUSOCSectionDetailCell: UITableViewCell {
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var openClosedDisplay: UIView!
    @IBOutlet weak var sectionNumber: UILabel!
}

class RUSOCSectionDetailTableViewController: UITableViewController {
    var section: Section!
    let disposeBag = DisposeBag()
    var notes: [String]!
    var preReqItems: [String]!
    
    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        section: Section,
        notes: [String],
        preReq: [String]
        ) -> RUSOCSectionDetailTableViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCSectionDetailViewController"
            ) as! RUSOCSectionDetailTableViewController
        
        me.preReqItems = preReq
        me.notes = notes
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
            case let .noteSectionItem(notes):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "notesCell",
                    for: idxPath
                ) as! RUSOCNotesCell

                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = notes
            
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
                
                cell.sectionNumber.text = "\(section.sectionIndex)"
                
               
                cell.setupCellLayout()
                return cell
            case let .instructorItem(item):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "defaultCell",
                    for: idxPath
                ) as! RUSOCDetailCell
                
                cell.leftLabel?.text = "Instructor"
                cell.rightLabel?.text = "\(item.instructorName)"
                
                cell.setupCellLayout()
                return cell
            case let .meetingTimesItem(item, building):
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
                
                cell.campusAbbrev.text = item.campusAbbrev
                
                cell.timesLabel?.text = "\(startTime)-\(endTime)"

                if let _ = item.buildingCode {
                    cell.buildingCode.text = building.name
                } else {
                    cell.buildingCode.text = "Not available"
                }
                
                if let roomNumber = item.roomNumber {
                    cell.roomNumber.text = "Room " + roomNumber
                } else {
                    cell.roomNumber.text = ""
                }
                
                let url =
                    "http://rumobile-gis-prod-asb.ei.rutgers.edu/buildings/"
                
                let image =
                    item.buildingCode
                        .flatMap{
                            URL(string: url + "\($0).jpeg")
                        }
                        .flatMap{try? Data(contentsOf: $0)}
                        .flatMap{UIImage(data: $0)}

                let defaultImage = UIImage(named: "ic_panorama_3x")
                
                cell.accessoryType = .disclosureIndicator
                
                cell.locationImage.image = image ??
                    defaultImage
                
                cell.locationImage.contentMode = .scaleAspectFit

                cell.setupCellLayout()
                
                return cell
            }
        }
        
        dataSource.titleForHeaderInSection = { (ds, idxPath) in
            //This needs to stay in order for the app to not crash
            ds.sectionModels[idxPath].title
        }
        
        var noteSectionItem: [SOCSectionDetailItem] =
            self.section.sectionNotes.flatMap {
                $0.isEmpty ? nil : [.noteSectionItem(notes: $0)]
            } ?? []
        
        let selfNotes: [SOCSectionDetailItem] =
            self.notes.map {
                .noteSectionItem(notes: $0)
            }
        
        noteSectionItem.append(contentsOf: selfNotes)
        
        let preReqSectionItem: [SOCSectionDetailItem] =
            self.preReqItems.map {
                .noteSectionItem(notes: $0)
        }
        
        let preReqSection: [MultiSection] =
            [.PreReqSection(items: preReqSectionItem)]
        
        
        let meetingSectionO: Observable<[MultiSection]> =
            Observable.from(self.section.meetingTimes)
                .flatMap { meetingTime -> Observable<SOCSectionDetailItem> in
                    let buildingO: () -> Observable<Building> = {
                        if let buildingCode = meetingTime.buildingCode {
                            return RutgersAPI.sharedInstance.getBuilding(
                                buildingCode: buildingCode
                            )
                        } else {
                            return Observable.just(Building(
                                code: "",
                                campus: meetingTime.campusAbbrev ?? "",
                                name: "",
                                id: ""
                            ))
                        }
                    }

                    return buildingO().map { building in
                        .meetingTimesItem(item: meetingTime, building: building)
                    }
                }
                .toArray()
                .map {
                    [.MeetingTimesSection( title: "Meeting Times", items: $0)]
                }
        
        let sectionItem: [SOCSectionDetailItem] =
            [.sectionItem(section: self.section)]
        
        let detailSectionItems: [SOCSectionDetailItem] =
            self.section.instructors.isEmpty ? sectionItem :
            sectionItem +
            self.section.instructors.map {
                .instructorItem(item: $0)
            }

        let instructorSection: [MultiSection] =
             [.InstructorSection(
                title: "Detail",
                items: detailSectionItems
            )]

        self.tableView.rx.itemSelected.filterMap {
            self.tableView.cellForRow(at: $0) as? RUMeetingTimesAndLocationCell
        }.subscribe(onNext: { cell in
            cell.expanded = !cell.expanded
            
            if !cell.expanded {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }

            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }).addDisposableTo(disposeBag)

        meetingSectionO.map { meetingSection in
            [.HeaderSection(
                items: noteSectionItem
                )] + preReqSection + instructorSection + meetingSection
        }
        .asDriver(onErrorJustReturn: [])
        .drive(self.tableView!.rx.items(dataSource: dataSource))
        .addDisposableTo(self.disposeBag)
    } //End of ViewDidLoad

    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return (try? self.tableView.rx.model(at: indexPath))
            .map { (model: SOCSectionDetailItem) -> CGFloat in
                switch model {
                case .meetingTimesItem(_):
                    return UITableViewAutomaticDimension
                default:
                    return UITableViewAutomaticDimension
                }
            } ?? UITableViewAutomaticDimension
    }
} //End of class

private enum MultiSection {
    case HeaderSection(items: [SOCSectionDetailItem])
    case PreReqSection(items: [SOCSectionDetailItem])
    case MeetingTimesSection(title: String, items: [SOCSectionDetailItem])
    case InstructorSection(title: String, items: [SOCSectionDetailItem])
}

private enum SOCSectionDetailItem {
    case noteSectionItem(notes: String)
    case sectionItem(section: Section)
    case instructorItem(item: Instructor)
    case meetingTimesItem(item: MeetingTime, building: Building)
}

extension MultiSection: SectionModelType {
    
    var items: [SOCSectionDetailItem] {
        switch self {
        case .HeaderSection(items: let items):
            return items
        case .PreReqSection(items: let items):
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
            return "Notes"
        case .PreReqSection(items: _):
            return "PreReqs"
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
        case let .PreReqSection(items: items):
            self = .PreReqSection(items: items)
        case let .MeetingTimesSection(title: title, items: _):
            self = .MeetingTimesSection(title: title, items: items)
        case let .InstructorSection(title: title, items: _):
            self = .InstructorSection(title: title, items: items)
        }
    }
}
