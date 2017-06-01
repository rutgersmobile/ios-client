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

    let cellId = "RUSOCSectionCellId"
    let defaultCellId = "RUSOCSectionDefaultCellId"
    let disposeBag = DisposeBag()

    let openColor = UIColor(
        red: 217/255,
        green: 242/255,
        blue: 213/255,
        alpha: 1
    )
    let closedColor = UIColor(
        red: 243/255,
        green: 181/255,
        blue: 181/255,
        alpha: 1
    )

    typealias RxCourseDataSource =
        RxTableViewSectionedReloadDataSource<CourseSection>
    typealias CourseDataSource =
        TableViewSectionedDataSource<CourseSection>

    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        course: Course
    ) -> RUSOCCourseViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCCourseViewController"
        ) as! RUSOCCourseViewController

        me.course = course

        return me
    }

    func configureSectionCell(
        cell: RUSOCSectionCell,
        section: Section
    ) -> RUSOCSectionCell {
        cell.codeLabel.text = section.index
        cell.instructorLabel.text = section.instructors.get(0)?.name
        cell.dayLabel.text = section.meetingTimes.map { time in
            time.meetingDay
        }.filterMap { $0 }.joined(separator: "\n")
        cell.timeLabel.text = section.meetingTimes.map { time in
            time.timeFormatted()
        }.filterMap { $0 }.joined(separator: "\n")
        cell.locationLabel.text = section.meetingTimes.map { time in
            [ time.campusAbbrev
                , time.buildingCode
                , time.roomNumber
                ].filterMap { $0 }.joined(separator: " ")
        }.joined(separator: "\n")

        cell.backgroundColor = section.openStatus
            ? self.openColor
            : self.closedColor

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
            }
        }

        let creditsSection = CourseSection(
            header: "Info",
            items: [
                course.credits.map { .credits($0) },
                course.preReqNotes.map { .prereq($0) }
            ].filterMap { $0 }
        )

        Observable.of(course.sections)
            .map { sections in CourseSection(
                header: "Sections",
                items: sections.map { .section($0) }
            )}
            .toArray()
            .map { sections in
                if creditsSection.items.count == 0 {
                    return sections
                } else {
                    return [creditsSection] + sections
                }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
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
    case credits(Float)
}

extension CourseSection: SectionModelType {
    typealias Item = CourseSectionItem

    init(original: CourseSection, items: [Item]) {
        self = original
        self.items = items
    }
}
