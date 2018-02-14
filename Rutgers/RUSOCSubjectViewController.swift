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
    @IBOutlet weak var openClosedLabel: UILabel!
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

    override func sharingUrl() -> URL? {
        return NSURL.rutgersUrl(withPathComponents: [
            "soc",
            "\(options.semester.term)",
            "\(options.semester.year)",
            "\(options.level)",
            "\(options.campus.description)",
            "\(subject.code)"
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = self.subject.subjectDescription

        let dataSource = RxSubjectDataSource()
        
//        self.setupShareButton()

        dataSource.configureCell = {[weak self] (
            ds: SubjectDataSource,
            tv: UITableView,
            ip: IndexPath,
            item: SOCSubjectItem
        ) in
            
            guard let `self` = self else {return UITableViewCell()}
            
            let cell: UITableViewCell = { switch (item) {
            case .course(let model):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: self.cellId,
                    for: ip
                ) as! RUSOCCourseCell
                cell.courseLabel.text = model.expandedTitle != nil && model.expandedTitle != "" ? model.expandedTitle : model.title //make extension for this
                let credits = model.credits.map {$0} ?? 0.0
                cell.creditsLabel.text = credits == 0.0 ? "BA" : "\(credits)"
                cell.codeLabel.text = model.string
                
                let checkColor: UIColor = model.sectionCheck.open > 0
                    ? RUSOCViewController.openColor
                    : RUSOCViewController.closedColor
                
                cell.openClosedLabel.text = model.sectionCheck.open > 0 ? "Open" : "Closed"
                
                cell.openSectionsBG.backgroundColor = checkColor
                
                cell.backgroundColor = checkColor.withAlphaComponent(0.2)

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
            options: options,
            subjectCode: subject.code
        ).map { courses in
            
            let subjectNotes = Array(Set(courses.map {
            $0.subjectNotes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            })).filter {!$0.isEmpty}
            
            let unitNotes = Array(Set(courses.map {
                $0.unitNotes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            })).filter { !$0.isEmpty }
            
            let notes = subjectNotes + unitNotes
            let subjectTitle = SOCSubjectSection(header: "Subject Title", items: [self.subject.subjectDescription].map{.note($0)})
            
            let notesSection = SOCSubjectSection(
                header: "Subject Notes",
                items: notes.map { .note($0) }
            )
            let courses = SOCSubjectSection(
                header: "Courses",
                items: courses.map { .course($0) }
            )
            if (notesSection.items.isEmpty) {
                return [courses]
            } else {
                return [subjectTitle, notesSection, courses]
            }
        }
        .asDriver(onErrorJustReturn: [])
        .drive(self.tableView.rx.items(dataSource: dataSource))
        .addDisposableTo(disposeBag)

        self.tableView.rx.modelSelected(SOCSubjectItem.self)
            .subscribe(onNext: {[weak self] item in
                guard let `self` = self else {return}
                
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
