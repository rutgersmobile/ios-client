//
//  RUSOCOptionsViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/21/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class RUSOCOptionsViewController: UITableViewController, UIActionSheetDelegate {
    /*
    let cellId = "RUSOCOptionsViewControllerId"

    static let SOCDataSemesterKey = "SOCDataSemesterKey"
    static let SOCDataCampusKey = "SOCDataCampusKey"
    static let SOCDataLevelKey = "SOCDataLevelKey"

    let disposeBag = DisposeBag()

    var semesters: [Semester]!
    var observer: AnyObserver<SOCOptions>?

    typealias RxSOCOptionsDataSource =
        RxTableViewSectionedReloadDataSource<SOCOptionsSection>
    typealias SOCOptionsDataSource =
        TableViewSectionedDataSource<SOCOptionsSection>

    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        semesters: [Semester]
    ) -> RUSOCOptionsViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCOptionsViewController"
        ) as! RUSOCOptionsViewController

        me.semesters = semesters

        return me
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil

        let dataSource = RxSOCOptionsDataSource()

        dataSource.configureCell = { [unowned self] (
            ds: SOCOptionsDataSource,
            tv: UITableView,
            ip: IndexPath,
            item: SOCOptionsSectionItem
        ) in
            let cell = tv.dequeueReusableCell(
                withIdentifier: self.cellId,
                for: ip
            )

            cell.textLabel?.text = {
                switch item {
                case .semester:
                    let semester = RUSOCOptionsViewController.storedSemester(
                        semester: self.semesters[0]
                    )
                    return "\(semester)"
                case .campus:
                    return "\(RUSOCOptionsViewController.storedCampus())"
                case .level:
                    return "\(RUSOCOptionsViewController.storedLevel())"
                }
            }()

            return cell
        }

        dataSource.titleForHeaderInSection = { (ds, ip) in
            ds.sectionModels[ip].header
        }

        let sections = [
            SOCOptionsSection(header: "Semester", items: [.semester]),
            SOCOptionsSection(header: "Campus", items: [.campus]),
            SOCOptionsSection(header: "Level", items: [.level])
        ]

        Observable.of(sections)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        self.tableView.rx.modelSelected(SOCOptionsSectionItem.self)
            .flatMap { [unowned self]
            (value: SOCOptionsSectionItem) -> Observable<SOCOptions> in
                switch value {
                case .semester:
                    return self.semesterAction()
                case .campus:
                    return self.campusAction()
                case .level:
                    return self.levelAction()
                }
            }
            .subscribe(onNext: { [unowned self] options in
                self.tableView.reloadData()
                self.observer?.onNext(options)
            })
            .addDisposableTo(disposeBag)
    }
/*
    static func defaultOptions(semester: Semester) -> SOCOptions {
        return SOCOptions(
            semester: storedSemester(semester: semester),
            campus: RUSOCOptionsViewController.storedCampus(),
            level: storedLevel()
        )
    }*/
/*
    static func storedSemester(semester: Semester) -> Semester {
        let dictSemester = UserDefaults.standard
            .dictionary(forKey: RUSOCOptionsViewController.SOCDataSemesterKey)
        return dictSemester.flatMap {
            Semester.fromDict(dict: $0)
        } ?? semester
    }*/
/*
    func semesterAction() -> Observable<SOCOptions> {
        let actionSheetDS = ActionSheetDataSource(
            data: self.semesters.map { semester in
                ActionSheetModel(title: semester.description, datum: semester)
            }
        )
        actionSheetDS.actionSheet.show(in: self.tableView)
        return actionSheetDS.modelSelected().map { semester in
            UserDefaults.standard.set(
                semester.toDict(),
                forKey: RUSOCOptionsViewController.SOCDataSemesterKey
            )
            return SOCOptions(
                semester: semester,
                campus: RUSOCOptionsViewController.storedCampus(),
                level: RUSOCOptionsViewController.storedLevel()
            )
        }
    }
*/
    static func storedCampus() -> Campus {
        let stringCampus = UserDefaults.standard
            .string(forKey: RUSOCOptionsViewController.SOCDataCampusKey)
        return stringCampus.flatMap {
            Campus.from(string: $0)
        } ?? .newBrunswick
    }

    func campusAction() -> Observable<SOCOptions> {
        let actionSheetDS = ActionSheetDataSource(data: Campus.allValues.map {
            ActionSheetModel(title: $0.title, datum: $0)
        })
        actionSheetDS.actionSheet.show(in: self.tableView)
        return actionSheetDS.modelSelected().map { [unowned self] campus in
            UserDefaults.standard.set(
                campus.description,
                forKey: RUSOCOptionsViewController.SOCDataCampusKey
            )
            return SOCOptions(
                semester: RUSOCOptionsViewController.storedSemester(
                    semester: self.semesters[0]
                ),
                campus: campus,
                level: RUSOCOptionsViewController.storedLevel()
            )
        }
    }

    static func storedLevel() -> Level {
        let stringLevel = UserDefaults.standard
            .string(forKey: RUSOCOptionsViewController.SOCDataLevelKey)

        return stringLevel.flatMap {
            Level.from(string: $0)
        } ?? .u
    }

    func levelAction() -> Observable<SOCOptions> {
        let actionSheetDS = ActionSheetDataSource(data: Level.allValues.map {
            ActionSheetModel(title: $0.title, datum: $0)
        })
        actionSheetDS.actionSheet.show(in: self.tableView)
        return actionSheetDS.modelSelected().map { [unowned self] level in
            UserDefaults.standard.set(
                level.description,
                forKey: RUSOCOptionsViewController.SOCDataLevelKey
            )
            return SOCOptions(
                semester: RUSOCOptionsViewController.storedSemester(
                    semester: self.semesters[0]
                ),
                campus: RUSOCOptionsViewController.storedCampus(),
                level: level
            )
        }
    }*/
}

struct SOCOptionsSection {
    var header: String
    var items: [Item]

    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

enum SOCOptionsSectionItem {
    case semester
    case campus
    case level
}

extension SOCOptionsSection: SectionModelType {
    typealias Item = SOCOptionsSectionItem

    init(original: SOCOptionsSection, items: [Item]) {
        self = original
        self.items = items
    }
}

struct SOCOptions {
    let semester: Semester
    let campus: Campus
    let level: Level
}
