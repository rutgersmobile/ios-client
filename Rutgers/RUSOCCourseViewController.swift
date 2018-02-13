//
//  RUSOCCourseViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/28/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

enum MeetingCodes {
    case hybrid
    case online
    case byArrangement
}

class RUSOCCourseViewController: UITableViewController {
    var course: Course?
    var options: SOCOptions!
    var subjectCode: Int?
    var courseNumber: Int?

    let cellId = "RUSOCSectionCellId"
    let cellExtraId = "RUSOCSectionCellExtraId"
    let defaultCellId = "RUSOCSectionDefaultCellId"
    let disposeBag = DisposeBag()

    typealias RxCourseDataSource =
        RxTableViewSectionedReloadDataSource<CourseSection>
    typealias CourseDataSource =
        TableViewSectionedDataSource<CourseSection>

    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        options: SOCOptions,
        course: Course
    ) -> RUSOCCourseViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCCourseViewController"
        ) as! RUSOCCourseViewController

        me.options = options
        me.course = course
        me.subjectCode = course.subject
        me.courseNumber = course.courseNumber

        return me
    }

    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        options: SOCOptions,
        subjectCode: Int,
        courseNumber: Int
    ) -> RUSOCCourseViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCCourseViewController"
        ) as! RUSOCCourseViewController

        me.options = options
        me.subjectCode = subjectCode
        me.courseNumber = courseNumber

        return me
    }

    override func sharingUrl() -> URL? {
        return course.flatMap { realCourse in
             NSURL.rutgersUrl(withPathComponents: [
                "soc",
                "\(options.semester.term)",
                "\(options.semester.year)",
                "\(options.level)",
                "\(options.campus)",
                "\(realCourse.subject!)",
                "\(realCourse.courseNumber!)"
            ])
        }
    }

    func formatMeetingTime(time: MeetingTime) -> String {
        let meetingDay = time.meetingDay ?? ""
        let meetingTime = time.timeFormatted() ?? ""
        let returnString = meetingDay + " " + meetingTime
        return returnString == " " ? "By Arrangement" : returnString
            .trimmingCharacters(in: .whitespaces)
    }


    func formatRoomAndBuilding(time: MeetingTime) -> String {

        let building = time.buildingCode ?? ""
        let room = time.roomNumber ?? ""
        let returnString = building + " Rm. " + room

        return returnString == " " || returnString == " Rm. " ? "" : returnString
    }

    func formatCampus(time: MeetingTime) -> String {
        return time.campusAbbrev ?? ""
    }

    func setCampusAbbrevLabel(campusAbbrev: String?,
                              cellLabel: UILabel) -> UILabel {

        if let campusAbbrev = campusAbbrev {
        cellLabel.text = campusAbbrev
        cellLabel.backgroundColor = CampusColor.from(string:
            campusAbbrev.lowercased()
            ).color
        } else {
            cellLabel.text = ""
        }

        return cellLabel
    }

    func configureSectionCell<T>(
        cell: T,
        section: Section,
        meetingTimes: [MeetingTime],
        buildings: [Observable<Building>]
    ) -> T {
        
        switch meetingTimes.count {
        case 1...3:
            return configureSmallCell(cell: cell as! RUSOCSectionCell, section: section, meetingTimes: meetingTimes, buildings: buildings) as! T
        default:
            return configureBigCell(cell: cell as! RUSOCSectionCellExtra, section: section, meetingTimes: meetingTimes, buildings: buildings) as! T
        }
    }
    
    func configureSmallCell (cell: RUSOCSectionCell, section: Section, meetingTimes: [MeetingTime], buildings: [Observable<Building>]) -> RUSOCSectionCell {
        
        cell.sectionNumber.text = "Section " + "\(section.number)"
        cell.sectionIndex.text = String(format: "%05d",
                                        Int(section.sectionIndex)!)
        
        cell.instructor.text = section.instructors.get(0)?.instructorName
        
        if let time1 = meetingTimes.get(0) {
            cell.time1.text = formatMeetingTime(time: time1)
            cell.buildingRoom1.text = formatRoomAndBuilding(time: time1)
            
            cell.campusCode1 = setCampusAbbrevLabel(
                campusAbbrev: time1.campusAbbrev,
                cellLabel: cell.campusCode1)
        } else {
            cell.time1.text = ""
            cell.buildingRoom1.text = ""
        }
        if let time2 = meetingTimes.get(1) {
            cell.time2.text = formatMeetingTime(time: time2)
            cell.buildingRoom2.text = formatRoomAndBuilding(time: time2)
            
            cell.campusCode2 = setCampusAbbrevLabel(
                campusAbbrev: time2.campusAbbrev,
                cellLabel: cell.campusCode2)
        } else {
            cell.time2.text = ""
            cell.buildingRoom2.text = ""
        }
        if let time3 = meetingTimes.get(2) {
            cell.time3.text = formatMeetingTime(time: time3)
            cell.buildingRoom3.text = formatRoomAndBuilding(time: time3)
            
            cell.campusCode3 = setCampusAbbrevLabel(
                campusAbbrev: time3.campusAbbrev,
                cellLabel: cell.campusCode3)
        } else {
            cell.time3.text = ""
            cell.buildingRoom3.text = ""
        }
        
        let setColor: UIColor = section.openStatus
            ? RUSOCViewController.openColor
            : RUSOCViewController.closedColor
        
        cell.openColor.backgroundColor = setColor
        
        cell.backgroundColor = setColor.withAlphaComponent(0.2)
        
        cell.openClosedLabel.text = section.openStatus ? "Open" : "Closed"
        cell.setupCellLayout()
        
        return cell
    }
    
    
    func configureBigCell(cell: RUSOCSectionCellExtra, section: Section, meetingTimes: [MeetingTime], buildings: [Observable<Building>]) -> RUSOCSectionCellExtra {
        
        cell.sectionNumber.text = "Section " + "\(section.number)"
        cell.sectionIndex.text = String(format: "%05d",
                                        Int(section.sectionIndex)!)
        
        cell.instructor.text = section.instructors.get(0)?.instructorName
        
        if let time1 = meetingTimes.get(0) {
            cell.time1.text = formatMeetingTime(time: time1)
            cell.buildingRoom1.text = formatRoomAndBuilding(time: time1)
            
            cell.campusCode1 = setCampusAbbrevLabel(
                campusAbbrev: time1.campusAbbrev,
                cellLabel: cell.campusCode1)
        } else {
            cell.time1.text = ""
            cell.buildingRoom1.text = ""
        }
        if let time2 = meetingTimes.get(1) {
            cell.time2.text = formatMeetingTime(time: time2)
            cell.buildingRoom2.text = formatRoomAndBuilding(time: time2)
            
            cell.campusCode2 = setCampusAbbrevLabel(
                campusAbbrev: time2.campusAbbrev,
                cellLabel: cell.campusCode2)
        } else {
            cell.time2.text = ""
            cell.buildingRoom2.text = ""
        }
        if let time3 = meetingTimes.get(2) {
            cell.time3.text = formatMeetingTime(time: time3)
            cell.buildingRoom3.text = formatRoomAndBuilding(time: time3)
            
            cell.campusCode3 = setCampusAbbrevLabel(
                campusAbbrev: time3.campusAbbrev,
                cellLabel: cell.campusCode3)
        } else {
            cell.time3.text = ""
            cell.buildingRoom3.text = ""
        }
        if let time4 = meetingTimes.get(3) {
            cell.time4.text = formatMeetingTime(time: time4)
            cell.buildingRoom4.text = formatRoomAndBuilding(time: time4)
            
            cell.campusCode3 = setCampusAbbrevLabel(
                campusAbbrev: time4.campusAbbrev,
                cellLabel: cell.campusCode4)
        } else {
            cell.time4.text = ""
            cell.buildingRoom4.text = ""
        }
        if let time5 = meetingTimes.get(4) {
            cell.time5.text = formatMeetingTime(time: time5)
            cell.buildingRoom5.text = formatRoomAndBuilding(time: time5)
            
            cell.campusCode5 = setCampusAbbrevLabel(
                campusAbbrev: time5.campusAbbrev,
                cellLabel: cell.campusCode5)
        } else {
            cell.time5.text = ""
            cell.buildingRoom5.text = ""
        }
        
        cell.openColor.backgroundColor = section.openStatus
            ? RUSOCViewController.openColor
            : RUSOCViewController.closedColor
        
        cell.setupCellLayout()
        
        return cell
    }

    func configurePrereqCell(
        cell: UITableViewCell,
        prereq: String
    ) -> UITableViewCell {
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 17)
        cell.textLabel?.setHTMLFromString(text: prereq)
        return cell
    }

    func configureNotesCell(
        cell: UITableViewCell,
        notes: String
    ) -> UITableViewCell {
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = notes
        return cell
    }

    func configureCreditsCell(
        cell: UITableViewCell,
        credits: Float
    ) -> UITableViewCell {
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(credits).0"
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        self.tableView.tableFooterView = UIView()
        if let realCourse = self.course {
            self.navigationItem.title = realCourse.expandedTitle != nil && realCourse.expandedTitle != "" ? realCourse.expandedTitle : realCourse.title
        }

        let dataSource = RxCourseDataSource()
        
//        setupShareButton()
        
        dataSource.configureCell = { [weak self] (
            ds: CourseDataSource,
            tv: UITableView,
            ip: IndexPath,
            item: CourseSectionItem
        ) in
        
            guard let `self` = self else {
                return UITableViewCell()
            }
            
            switch item {
            case .section(let section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.cellId,
                    for: ip
                ) as! RUSOCSectionCell
                
                let sortedMeetingTimes = section.meetingTimes.sorted{$0.asInt() < $1.asInt()}

                return self.configureSectionCell(cell: cell,
                                                 section: section,
                                                 meetingTimes:
                                                    sortedMeetingTimes,
                                                 buildings:
                                                    sortedMeetingTimes
                                                    .map {return RutgersAPI
                                                        .sharedInstance
                                                        .getBuilding(
                                                            buildingCode:
                                                            $0.buildingCode
                                                                ?? "")
                                                    })
            case .sectionExtra(let section):
                let cell = tv.dequeueReusableCell(withIdentifier:
                    self.cellExtraId, for: ip) as! RUSOCSectionCellExtra
                
                let sortedMeetingTimes = section.meetingTimes.sorted{$0.asInt() < $1.asInt()}
                
                return self.configureSectionCell(cell: cell,
                                                 section: section,
                                                 meetingTimes:
                                                 sortedMeetingTimes,
                                                 buildings:
                                                 sortedMeetingTimes
                                                    .map {return RutgersAPI
                                                    .sharedInstance
                                                    .getBuilding(
                                                        buildingCode:
                                                        $0.buildingCode
                                                        ?? "")
                                                })
            case .prereq(let prereq):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.defaultCellId,
                    for: ip
                )
                return self.configurePrereqCell(cell: cell, prereq: prereq)
            case .notes(let notes):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.defaultCellId,
                    for: ip
                )
                return self.configureNotesCell(cell: cell, notes: notes)
            }
        }

        dataSource.titleForHeaderInSection = { (ds, idx) in
            ds.sectionModels[idx].header
        }

        let courseO = getCourse().shareReplay(1)
        courseO.flatMap {[weak self] realCourse -> Observable<[CourseSection]> in
            
            guard let `self` = self else {
                return Observable.empty()
            }
            
            let sectionArray = self.makeSectionArray(course: realCourse)
            
            if self.course == nil {
                self.course = realCourse
            }
            
            return RutgersAPI.sharedInstance.getSections(
                options: self.options,
                subjectNumber: realCourse.subject!,
                courseNumber: realCourse.courseNumber!
            ).map { sections in [CourseSection(
                        header: "Sections",
                        items: sections.map {
                            switch $0.meetingTimes.count {
                            case 1...3:
                                return CourseSectionItem.section($0)
                            default:
                                return CourseSectionItem.sectionExtra($0)
                            }
                }
                )]}.map { sectionArray + $0 }
        }
        .asDriver(onErrorJustReturn: [])
        .drive(self.tableView.rx.items(dataSource: dataSource))
        .addDisposableTo(disposeBag)

        courseO.flatMap {[unowned self] realCourse -> Observable<(Section, [String: [String]])> in
            
            self.tableView.rx.modelSelected(
                CourseSectionItem.self).filterMap { model -> Section? in
                switch model {
                case .section(let section):
                    return section
                case .sectionExtra(let section):
                    return section
                default:
                    return nil
                }
            }.map { section in
               var noteDictionary = Dictionary<String, [String]>()

               let preReqItems = [realCourse.preReqNotes].filterMap { $0 }
                        .map { $0.trimmingCharacters(in:
                            .whitespacesAndNewlines)}

                noteDictionary["preReqs"] = preReqItems
                noteDictionary["subjectNotes"] =
                    [realCourse.subjectNotes?.trimmingCharacters(in:
                        .whitespacesAndNewlines) ?? "",
                     (realCourse.unitNotes?.trimmingCharacters(in:
                        .whitespacesAndNewlines)) ?? ""]
                noteDictionary["courseNotes"] =
                    [realCourse.notes?.trimmingCharacters(in:
                        .whitespacesAndNewlines) ?? ""]
                noteDictionary["coreCodes"] = realCourse.coreCodes.map {
                    "\($0.coreCode) \($0.coreCodeDescription)"
                }

                return (section, noteDictionary)
            }
        }
        .subscribe(onNext: {[weak self] rets in
            
            guard let `self` = self else {
                return
            }
            
            let (section, noteDictionary) = rets
            let vc = RUSOCSectionDetailTableViewController.instantiate(
                withStoryboard: self.storyboard!,
                subjectNumber: self.subjectCode!,
                section: section,
                courseTitle: self.course!.title!,
                courseString: self.course!.string!,
                courseNumber: self.course!.courseNumber!,
                sectionNumber: Int(section.number) ?? 0,
                options: self.options,
                notes: noteDictionary
            )
            self.navigationController?.pushViewController(
                vc, animated: true
            )
        }).addDisposableTo(self.disposeBag)
    }

    func getCourse() -> Observable<Course> {
        return self.course.map { Observable.just($0) } ??
            RutgersAPI.sharedInstance.getCourse(
                options: self.options,
                subjectCode: subjectCode!,
                courseNumber: courseNumber!
            )
    }

    func makeSectionArray(course: Course) -> [CourseSection] {
        var subjectNotes = [course.subjectNotes?.trimmingCharacters(in:
            .whitespacesAndNewlines) ?? ""]
        
        if let unitNotes = course.unitNotes {
            let appendVal = unitNotes.trimmingCharacters(in:
                .whitespacesAndNewlines)
            appendVal != "" ? subjectNotes.append(appendVal)
                : print("Nothing to add")
        }

        let subjectNotesSection =
            subjectNotes.isEmpty || subjectNotes.get(0) == "" ? [] : [
            CourseSection(
                header: "Subject Notes",
                items: subjectNotes.map { .notes($0) }
            )]

        let courseNotes = [course.notes?.trimmingCharacters(in:
            .whitespacesAndNewlines) ?? ""]

        let courseNotesSection =
            courseNotes.isEmpty || courseNotes.get(0) == "" ? [] : [
            CourseSection(
                header: "Course Notes",
                items: courseNotes.map { .notes($0)}
            )]

        let coreCodes = course.coreCodes.map {
            "\($0.coreCode) \($0.coreCodeDescription)"
        }

        let coreCodesSection =
            coreCodes.isEmpty ? [] :
            [CourseSection(
                header: "Core Codes",
                items: coreCodes.map {.notes($0)})]
       
        let preReqItems: [CourseSectionItem] = {
            return course.preReqNotes.flatMap{
                $0 != "" ? [.prereq($0.trimmingCharacters(in: .whitespacesAndNewlines))] : []
            }
        }() ?? []
        
        let preReqSection =
            preReqItems.isEmpty ? [] : [CourseSection(
                                        header: "PreReqs",
                                        items: preReqItems)]

        let returnSection =
            subjectNotesSection + courseNotesSection +
            coreCodesSection + preReqSection
     
        
        return returnSection
    }

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
            .map { (model: CourseSectionItem) -> CGFloat in
                switch model {
                case .section(_):
                    return 108.5
                case .sectionExtra(_):
                    return 178.5
                default:
                    return UITableViewAutomaticDimension
                }
            } ?? UITableViewAutomaticDimension
    }
}

extension MeetingTime {
    func timeFormatted() -> String? {
        return self.startTime.flatMap { start in
            self.endTime.flatMap { end in
                self.pmCode.flatMap { code in
                    let amPM = { () -> String in  switch code {
                    case "A":
                        return "AM"
                    default:
                        return "PM"
                    }}()
                    let formattedStart = start.meetTimeFormatted()
                    let formattedEnd = end.meetTimeFormatted()
                    return "\(formattedStart)-\(formattedEnd) \(amPM)"
                }
            }
        }
    }
}
// What a mess
public extension String {
    func meetTimeFormatted() -> String {
        if self.count != 4 {
            return self
        }

        let hourIndexE = self.index(self.startIndex, offsetBy: 1)
        let hour = self[self.startIndex...hourIndexE]
        let minuteIndexS = self.index(self.startIndex, offsetBy: 2)
        let minuteIndexE = self.index(self.startIndex, offsetBy: 3)
        let minutes = self[minuteIndexS...minuteIndexE]
        return "\(hour):\(minutes)"
    }
}

struct CourseSection {
    var header: String
    var items: [Item]

    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

enum CourseSectionItem {
    case section(Section)
    case sectionExtra(Section)
    case prereq(String)
    case notes(String)
}

extension CourseSection: SectionModelType {
    typealias Item = CourseSectionItem

    init(original: CourseSection, items: [Item]) {
        self = original
        self.items = items
    }
}
