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
    
    @IBOutlet weak var locationImage: UIImageView!
    
}

class RUSOCSectionDetailCell: UITableViewCell {
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var openClosedDisplay: UIView!
    @IBOutlet weak var sectionNumber: UILabel!
}

class RUSOCSectionDetailTableViewController: UITableViewController {
    //var section: Section!
    var courseTitle: String!
    var courseString: String!
    var courseNumber: Int!
    var subjectNumber: Int!
    var sectionNumber: Int!
    //var section: Section!
    var options: SOCOptions!
    let disposeBag = DisposeBag()
    var noteDictionary: [String: [String]]!
    
    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        //section: Section,
        subjectNumber: Int,
        courseTitle: String,
        courseString: String,
        courseNumber: Int,
        sectionNumber: Int,
        options: SOCOptions,
        notes: [String : [String]]
        ) -> RUSOCSectionDetailTableViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCSectionDetailViewController"
            ) as! RUSOCSectionDetailTableViewController
        
        me.subjectNumber = subjectNumber
        me.courseTitle = courseTitle
        me.courseString = courseString
        me.courseNumber = courseNumber
        me.sectionNumber = sectionNumber
        me.options = options
        me.noteDictionary = notes
//        me.section = section
        
        return me
    }

    override func sharingUrl() -> URL? {
        return NSURL.rutgersUrl(withPathComponents: [
            "soc",
            "\(options.semester.term)",
            "\(options.semester.year)",
            "\(options.level)",
            "\(options.campus)",
            "\(courseNumber!)",
            courseTitle,
            courseString,
            "\(sectionNumber!)"
        ])
    }
    
    func getSection() -> Observable<[Section]> {
        return RutgersAPI
            .sharedInstance
            .getSection(semester: options.semester,
                        campus: options.campus,
                        level: options.level,
                        subjectNumber: subjectNumber!,
                        courseNumber: courseNumber,
                        sectionNumber: sectionNumber!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title =
            self.courseString + ":" +
            String(format: "%02d", self.sectionNumber!) +
            " " + self.courseTitle

        self.tableView.dataSource = nil
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        let dataSource = RxTableViewSectionedReloadDataSource<MultiSection>()
        
        setupShareButton()
        
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
                
                cell.sectionNumber.text = String(format: "%05d",
                                                 Int(section.sectionIndex)!)
                
               
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
                
            case let .preReqSectionItem(preReqNotes):
                let cell =
                    tv.dequeueReusableCell(withIdentifier: "notesCell",
                                           for: idxPath) as! RUSOCNotesCell
                
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont(name: "Helvetica", size: 17)
                cell.textLabel?.setHTMLFromString(text: preReqNotes)
                
                
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
                
                if let campusAbbrev = item.campusAbbrev {
                cell.campusAbbrev.text = campusAbbrev
                cell.campusAbbrev.backgroundColor =
                    CampusColor.from(string: campusAbbrev.lowercased()).color
                }
                cell.campusAbbrev.textAlignment = .center
                
                cell.timesLabel?.text = item.timeFormatted() ?? ""

                if let _ = item.buildingCode {
                    cell.buildingCode.text = building.name
                } else {
                    cell.buildingCode.text = "TBD"
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

                let defaultImage = UIImage(named: "image-not-found")
                
                cell.locationImage.image = image ?? defaultImage
                
                cell.locationImage.contentMode = .scaleToFill

                cell.setupCellLayout()
                
                return cell
            }
        }
        
        dataSource.titleForHeaderInSection = { (ds, idxPath) in
            //This needs to stay in order for the app to not crash
            ds.sectionModels[idxPath].title
        }
        
        let sectionO = getSection()
        
        sectionO
            .subscribe(onNext: {section in
            print(
                "***********************SECTION***********************\n\(section)"
                )}).addDisposableTo(self.disposeBag)
        
        //A bunch of ternary operators ahead
        let subjectNotesItem: [SOCSectionDetailItem] =
            self.noteDictionary["subjectNotes"]?.flatMap {
                $0.isEmpty ? nil : .noteSectionItem(notes: $0)
        } ?? [] // nil coalescing operator - essentially if the
                // result from the closure is [nil], return an empty array
        
        let subjectSection: [MultiSection] =
            subjectNotesItem.isEmpty ? [] :
            [.NoteSection(title: "Subject Notes", items: subjectNotesItem)]
        
        let courseNotesItem: [SOCSectionDetailItem] =
            self.noteDictionary["courseNotes"]?.flatMap {
                $0.isEmpty ? nil : .noteSectionItem(notes: $0)
        } ?? []
        
        let courseSection: [MultiSection] =
            courseNotesItem.isEmpty ? [] :
            [.NoteSection(title: "Course Notes", items: courseNotesItem)]
        
        let coreCodesNotesItem: [SOCSectionDetailItem] =
            self.noteDictionary["coreCodes"]?.flatMap {
                $0.isEmpty ? nil : .noteSectionItem(notes: $0)
            } ?? []
        
        let coreCodesSection: [MultiSection] =
            coreCodesNotesItem.isEmpty ? [] :
                [.NoteSection(title: "Core Codes", items: coreCodesNotesItem)]
        
        let preReqSectionItems: [SOCSectionDetailItem] =
            self.noteDictionary["preReqs"]?.flatMap {
                $0.isEmpty ? nil : .preReqSectionItem(notes: $0)
            } ?? []
        
        let preReqSection: [MultiSection] =
            preReqSectionItems.isEmpty ? [] :
            [.PreReqSection(items: preReqSectionItems)]
    
        /*
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
                title: "Details",
                items: detailSectionItems
                )]
        */
        
        let sectionArray: [MultiSection] =
            subjectSection +
                courseSection +
                preReqSection +
                coreCodesSection

        
        sectionO.flatMap {realSections -> Observable<[MultiSection]> in
            let sectionItem: [SOCSectionDetailItem] =
                [.sectionItem(section: realSections[0])]
            
            let detailSectionItems: [SOCSectionDetailItem] =
                realSections[0].instructors.isEmpty ? sectionItem :
                    sectionItem +
                    realSections[0].instructors.map {
                        .instructorItem(item: $0)
            }
            
            let instructorSection: [MultiSection] =
                [.InstructorSection(
                    title: "Details",
                    items: detailSectionItems
                    )]
            
            return SOCHelperFunctions
                .getBuildings(meetingTimes: realSections[0].meetingTimes)
                .map {(meetingTime, building) in
                    .meetingTimesItem(item: meetingTime, building: building)
                }
                .toArray()
                .map {
                    [.MeetingTimesSection(title: "Meeting Times", items: $0)]
                }.map {sectionArray + instructorSection + $0}
            }.asDriver(onErrorJustReturn: [])
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
    case NoteSection(title: String, items: [SOCSectionDetailItem])
    case PreReqSection(items: [SOCSectionDetailItem])
    case MeetingTimesSection(title: String, items: [SOCSectionDetailItem])
    case InstructorSection(title: String, items: [SOCSectionDetailItem])
}

private enum SOCSectionDetailItem {
    case noteSectionItem(notes: String)
    case preReqSectionItem(notes: String)
    case sectionItem(section: Section)
    case instructorItem(item: Instructor)
    case meetingTimesItem(item: MeetingTime, building: Building)
}

extension MultiSection: SectionModelType {
    
    var items: [SOCSectionDetailItem] {
        switch self {
        case .NoteSection(title: _, items: let items):
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
        case .NoteSection(title: let title, items: _):
            return title
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
        case let .NoteSection(title: title, items: items):
            self = .NoteSection(title: title, items: items)
        case let .PreReqSection(items: items):
            self = .PreReqSection(items: items)
        case let .MeetingTimesSection(title: title, items: _):
            self = .MeetingTimesSection(title: title, items: items)
        case let .InstructorSection(title: title, items: _):
            self = .InstructorSection(title: title, items: items)
        }
    }
}
