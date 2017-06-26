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
        let startTime = time.startTime ?? ""
        let endTime = time.endTime ?? ""
        return "\(meetingDay) \(startTime)-\(endTime)"
            .trimmingCharacters(in: .whitespaces)
    }

    func configureSectionCell(
        cell: RUSOCSectionCell,
        section: Section
    ) -> RUSOCSectionCell {
        cell.sectionNumber.text = section.number
        cell.sectionIndex.text = section.sectionIndex
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
        cell.textLabel?.text = prereq
        return cell
    }

    func configureCreditsCell(
        cell: UITableViewCell,
        credits: Float
    ) -> UITableViewCell {
        cell.textLabel?.text = String(credits)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil

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
            case .credits(let credits):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.defaultCellId,
                    for: ip
                )
                return self.configureCreditsCell(cell: cell, credits: credits)
            case .notes(let notes):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.defaultCellId,
                    for: ip
                )
                return self.configurePrereqCell(cell: cell, prereq: notes)
            }
        }
        
        let preReqSection = CourseSection(
            header: "Info",
            items: [
                course.preReqNotes.map { .prereq($0) }
            ].filterMap { $0 }
        )

        RutgersAPI.sharedInstance.getSections(
            semester: options.semester,
            campus: options.campus,
            level: options.level,
            course: course
        ).map { sections in CourseSection(
            header: "Sections",
            items: sections.map { .section($0) }
        )}
        .toArray()
            
        .map { sections in
            if preReqSection.items.count == 0 {
                return sections
            } else {
                return [preReqSection] + sections
            }
        }
        .asDriver(onErrorJustReturn: [])
        .drive(self.tableView.rx.items(dataSource: dataSource))
        .addDisposableTo(disposeBag)
        
        self.tableView.rx.modelSelected()
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return (try? self.tableView.rx.model(at: indexPath))
            .flatMap { (model: CourseSectionItem) -> CGFloat? in
                switch model {
                case .section(_):
                    return 108.5
                default:
                    return nil
                }
            } ?? 44
    }
}

fileprivate extension MeetingTime {
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

fileprivate extension String {
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
    case credits(Float)
}

extension CourseSection: SectionModelType {
    typealias Item = CourseSectionItem

    init(original: CourseSection, items: [Item]) {
        self = original
        self.items = items
    }
}
