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
    var courseTitle: String!
    var courseString: String!
    var courseNumber: Int!
    var section: Section!
    var subjectNumber: Int!
    var sectionNumber: Int!
    var options: SOCOptions!
    let disposeBag = DisposeBag()
    var noteDictionary: [String: [String]]!
    
    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        subjectNumber: Int,
        section: Section,
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
        me.section = section
        
        return me
    }
    
    override func sharingUrl() -> URL? {
        return NSURL.rutgersUrl(withPathComponents: [
            "soc",
            "\(options.semester.term)",
            "\(options.semester.year)",
            "\(options.level)",
            "\(options.campus)",
            "\(subjectNumber)",
            "\(courseNumber!)",
            "\(sectionNumber!)"
            ])
    }
    
    /*
    func getSection() -> Observable<[Section]> {
        return RutgersAPI
            .sharedInstance
            .getSection(options: options,
                        subjectNumber: subjectNumber!,
                        courseNumber: courseNumber,
                        sectionNumber: sectionNumber!)
    }*/
    
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
        if let sectionEligibility = section.sectionEligibility {
            self.noteDictionary["sectionEligibility"] = [sectionEligibility]
        }
        let dataSource = RxTableViewSectionedReloadDataSource<MultiSection>()
        
        // setupShareButton()
        
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
                    cell.buildingCode.text = "By Arrangement"
                }
                
                if let roomNumber = item.roomNumber {
                    cell.roomNumber.text = "Room " + roomNumber
                } else {
                    cell.roomNumber.text = ""
                }
                
                let url = RUNetworkManager.baseURL()
                
                
             
                DispatchQueue.global(qos: .background).async {
                let image =
                    item.buildingCode
                        .flatMap{
                            let urlString = String.init(describing: url) + "\($0).jpeg"
                            return URL(string: urlString)
                        }
                        .flatMap{try? Data(contentsOf: $0)}
                        .flatMap{UIImage(data: $0)}
                
                    DispatchQueue.main.async {
                    
                        let defaultImage = UIImage(named: "image-not-found")
                
                        cell.locationImage.image = image ?? defaultImage
                    }
                }
                cell.setupCellLayout()
                
                return cell
            }
        }
        
        dataSource.titleForHeaderInSection = { (ds, idxPath) in
            //This needs to stay in order for the app to not crash
            ds.sectionModels[idxPath].title
        }
        
        //A bunch of ternary operators ahead
        let subjectNotesItem: [SOCSectionDetailItem] =
            self.noteDictionary["subjectNotes"]?.flatMap {
                $0.isEmpty ? nil : .noteSectionItem(notes: $0)
                } ?? [] // nil coalescing operator - essentially if the
        // result from the closure is nil, return an empty array
        
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
        
        let sectionEligibilityItem: [SOCSectionDetailItem] = self.noteDictionary["sectionEligibility"]?.flatMap{
                $0.isEmpty ? nil : .noteSectionItem(notes: $0)
            } ?? []
        let sectionEligibility: [MultiSection] = sectionEligibilityItem.isEmpty ? [] :
        [.NoteSection(title: "Section Eligibility", items: sectionEligibilityItem)]
        
        
        let sectionNotesItem: [SOCSectionDetailItem] = {
            return self.section.sectionNotes.flatMap{
                $0 != "" ? [.noteSectionItem(notes: "Section \(section.number) notes: " + $0)] : []
            }
        }() ?? []
        
        let commentsText: [SOCSectionDetailItem] = {
            return self.section.commentsText.flatMap {
                $0 != "" ? [.noteSectionItem(notes: "Section \(section.number) comments: " + $0)] : []
            }
        }() ?? []
        
        let sectionNotesSection: [MultiSection] =
        sectionNotesItem.isEmpty && commentsText.isEmpty ? [] :
        [.NoteSection(title: "Section Notes", items: sectionNotesItem + commentsText)]
        
        let sectionArray: [MultiSection] =
                subjectSection +
                courseSection +
                preReqSection +
                coreCodesSection +
                sectionEligibility +
                sectionNotesSection
        
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
        
        let sortedMeetingTimes = self.section.meetingTimes.sorted{$0.asInt() < $1.asInt()}
        
        return SOCHelperFunctions
            .getBuildings(meetingTimes: sortedMeetingTimes)
            .map {(meetingTime, building) in
                .meetingTimesItem(item: meetingTime, building: building)
            }
            .toArray()
            .map {
                    [.MeetingTimesSection(title: "Meeting Times", items: $0)]
                
            }.map {sectionArray + instructorSection + $0}
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView!.rx.items(dataSource: dataSource))
            .addDisposableTo(self.disposeBag)
    } //End of ViewDidLoad
    
    
    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
        ) -> CGFloat {
        return (try? self.tableView.rx.model(at: indexPath))
            .map { (model: SOCSectionDetailItem) -> CGFloat in
                switch model {
                case .noteSectionItem(notes: _):
                    return UITableViewAutomaticDimension
                case .meetingTimesItem(_):
                    return 180
                default:
                    return 44
                }
            } ?? UITableViewAutomaticDimension
    }
    
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
        ) -> CGFloat {
        return (try? self.tableView.rx.model(at: indexPath))
            .map { (model: SOCSectionDetailItem) -> CGFloat in
                switch model {
                case .noteSectionItem(notes: _):
                    return UITableViewAutomaticDimension
                case .meetingTimesItem(_):
                    return 180
                default:
                    return 44
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

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func setDefault() {
        self.image = UIImage(named: "image-not-found")
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
