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

class RUSOCCourseViewController: UITableViewController {
    var course: Course!
    var options: SOCOptions!

    let cellId = "RUSOCSectionCellId"
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
        
        return me
    }

    func formatMeetingTime(time: MeetingTime) -> String {
        let meetingDay = time.meetingDay ?? ""
        let meetingTime = time.timeFormatted() ?? ""
        return "\(meetingDay) \(meetingTime)"
            .trimmingCharacters(in: .whitespaces)
    }

    func configureSectionCell(
        cell: RUSOCSectionCell,
        section: Section
    ) -> RUSOCSectionCell {
        cell.sectionNumber.text = section.number
        cell.sectionIndex.text = String(format: "%05d", Int(section.sectionIndex)!)
//                section.sectionIndex
        cell.instructor.text = section.instructors.get(0)?.instructorName

        if let time1 = section.meetingTimes.get(0) {
            cell.time1.text = formatMeetingTime(time: time1)
        } else {
            cell.time1.text = ""
        }
        if let time2 = section.meetingTimes.get(1) {
            cell.time2.text = formatMeetingTime(time: time2)
        } else {
            cell.time2.text = ""
        }
        if let time3 = section.meetingTimes.get(2) {
            cell.time3.text = formatMeetingTime(time: time3)
        } else {
            cell.time3.text = ""
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
        cell.textLabel?.text = String(credits)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = self.course.title
        
        let dataSource = RxCourseDataSource()

        dataSource.configureCell = { (
            ds: CourseDataSource,
            tv: UITableView,
            ip: IndexPath,
            item: CourseSectionItem
        ) in
            switch item {
            case .section(let section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.cellId,
                    for: ip
                ) as! RUSOCSectionCell
                return self.configureSectionCell(cell: cell, section: section)
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

//        let notesItems = [
//            self.course.subjectNotes,
//            self.course.notes
//        ].map {
//            $0.trimmingCharacters(in: .whitespacesAndNewlines)
//        }.filter {
//            !$0.isEmpty
//        } +
        
        let subjectNotes = [self.course.subjectNotes].map {$0.trimmingCharacters(in: .whitespacesAndNewlines)}
        
        let subjectNotesSection =
            subjectNotes.isEmpty || subjectNotes.get(0) == "" ? [] : [
            CourseSection(
                header: "Subject Notes",
                items: subjectNotes.map { .notes($0) }
            )]
        
        let courseNotes = [self.course.notes]
            .map {$0.trimmingCharacters(in: .whitespacesAndNewlines)}
        
        let courseNotesSection =
            courseNotes.isEmpty || courseNotes.get(0) == "" ? [] : [
            CourseSection(
                header: "Course Notes",
                items: courseNotes.map { .notes($0)}
            )]
        
        let coreCodes = self.course.coreCodes.map {
            "\($0.coreCode) \($0.coreCodeDescription)"
        }
        
        let coreCodesSection =
            coreCodes.isEmpty ? [] :
            [CourseSection(
                header: "Core Codes",
                items: coreCodes.map {.notes($0)})]
        
        
//        let notesSection = CourseSection(
//            header: "Notes",
//            items: notesItems.map { .notes($0) }
//        )

     
        
        let preReqSection =
            (course.preReqNotes?.isEmpty)! ? [] : [
            CourseSection(
            header: "PreReqs",
            items: [
                course.preReqNotes
            ].filterMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { .prereq($0) }
                )]
        
        let sectionArray: [CourseSection] = subjectNotesSection + courseNotesSection + coreCodesSection + preReqSection

        RutgersAPI.sharedInstance.getSections(
            semester: options.semester,
            campus: options.campus,
            level: options.level,
            course: course
        )
        .map { sections in [CourseSection(
            header: "Sections",
            items: sections.map { .section($0) }
        )]}
//        .map { sections in
//            if preReqSection.items.count == 0 {
//                return sections
//            } else {
//                return [preReqSection] + sections
//            }
//        }
        .map { sectionArray + $0 }
        .asDriver(onErrorJustReturn: [])
        .drive(self.tableView.rx.items(dataSource: dataSource))
        .addDisposableTo(disposeBag)

        self.tableView
            .rx
            .modelSelected(CourseSectionItem.self)
            .subscribe(onNext: { item in
                switch item {
                case .section(let section):
                    
                   var noteDictionary = Dictionary<String, [String]>()
                
                   let preReqItems = [self.course.preReqNotes].filterMap { $0 }
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                   
                    noteDictionary["preReqs"] = preReqItems
                    noteDictionary["subjectNotes"] = [self.course.subjectNotes].map {$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                    noteDictionary["courseNotes"] = [self.course.notes].map {$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                    noteDictionary["coreCodes"] = self.course.coreCodes.map {
                        "\($0.coreCode) \($0.coreCodeDescription)"
                    }
                    
                    let vc = RUSOCSectionDetailTableViewController .instantiate(
                        withStoryboard: self.storyboard!,
                        section: section,
                        notes: noteDictionary
                    )
                    
                    self.navigationController?.pushViewController(
                        vc, animated: true
                    )
                default: break
                }
            }).addDisposableTo(self.disposeBag)
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

public extension String {
    func meetTimeFormatted() -> String {
        if self.characters.count != 4 {
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
