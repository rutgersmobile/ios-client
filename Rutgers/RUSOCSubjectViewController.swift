//
//  RUSOCSubjectViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class RUSOCCourseCell: UITableViewCell {
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var openSectionsBG: UIView!
    @IBOutlet weak var openSectionsCount: UILabel!
}

class RUSOCSubjectViewController : UITableViewController {
    var subject: Subject!
    var options: SOCOptions!

    let cellId = "RUSOCSubjectViewControllerId"
    let noteCellId = "NoteCellId"

    let disposeBag = DisposeBag()

    typealias RxSubjectDataSource =
        RxTableViewSectionedReloadDataSource<SOCSubjectSection>
    typealias SubjectDataSource =
        TableViewSectionedDataSource<SOCSubjectSection>

    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        subject: Subject,
        options: SOCOptions
    ) -> RUSOCSubjectViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCSubjectViewController"
        ) as! RUSOCSubjectViewController

        me.subject = subject
        me.options = options
        return me
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        self.tableView.tableFooterView = UIView()

        let dataSource = RxSubjectDataSource()

        dataSource.configureCell = { (
            ds: SubjectDataSource,
            tv: UITableView,
            ip: IndexPath,
            item: SOCSubjectItem
        ) in
            let cell: UITableViewCell = { switch (item) {
            case .course(let model):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.cellId,
                    for: ip
                ) as! RUSOCCourseCell
                cell.courseLabel.text = model.title
                cell.creditsLabel.text = "\(model.credits.map { Int($0) } ?? 0)"
                cell.codeLabel.text = model.string

                cell.openSectionsBG.backgroundColor =
                    model.sectionCheck.open > 0
                        ? RUSOCViewController.openColor
                        : RUSOCViewController.closedColor

                cell.openSectionsCount.text =
                "\(model.sectionCheck.open)/\(model.sectionCheck.total)"
                
                cell.setupCellLayout()
                return cell
            case .note(let note):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.noteCellId,
                    for: ip
                )
                cell.textLabel?.text = note
                cell.textLabel?.numberOfLines = 0
                return cell
            }}()

            return cell
        }

        dataSource.titleForHeaderInSection = { (ds, idx) in
            ds.sectionModels[idx].header
        }

        RutgersAPI.sharedInstance.getCourses(
            semester: options.semester,
            campus: options.campus,
            level: options.level,
            subject: subject
        )
        .map { courses in
            let subjectNotes = Array(Set(courses.map {
                $0.subjectNotes.trimmingCharacters(in: .whitespacesAndNewlines)
            })).filter { !$0.isEmpty }
            let notesSection = SOCSubjectSection(
                header: "Notes",
                items: subjectNotes.map { .note($0) }
            )
            let courses = SOCSubjectSection(
                header: "Courses",
                items: courses.map { .course($0) }
            )
            if (notesSection.items.isEmpty) {
                return [courses]
            } else {
                return [notesSection, courses]
            }
        }
        .asDriver(onErrorJustReturn: [])
        .drive(self.tableView.rx.items(dataSource: dataSource))
        .addDisposableTo(disposeBag)

        self.tableView.rx.modelSelected(SOCSubjectItem.self)
            .subscribe(onNext: { item in
                switch (item) {
                case .course(let course):
                    let vc = RUSOCCourseViewController.instantiate(
                        withStoryboard: self.storyboard!,
                        options: self.options,
                        course: course
                    )

                    self.navigationController?
                        .pushViewController(vc, animated: true)
                default: break
                }
            }).addDisposableTo(disposeBag)
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
            .map { (model: SOCSubjectItem) -> CGFloat in
                switch model {
                case .course(_):
                    return 103
                case .note(_):
                    return UITableViewAutomaticDimension
                }
            } ?? UITableViewAutomaticDimension
    }
}

enum SOCSubjectItem {
    case course(Course)
    case note(String)
}

struct SOCSubjectSection {
    var header: String
    var items: [Item]

    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

extension SOCSubjectSection: SectionModelType {
    typealias Item = SOCSubjectItem

    init(original: SOCSubjectSection, items: [Item]) {
        self = original
        self.items = items
    }
}
