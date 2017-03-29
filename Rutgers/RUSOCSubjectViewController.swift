//
//  RUSOCSubjectViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift

class RUSOCSubjectViewController : UITableViewController {
    var subject: Subject!
    var courses: [Course]!

    let cellId = "RUSOCSubjectViewControllerId"

    let disposeBag = DisposeBag()

    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        subject: Subject,
        courses: [Course]
    ) -> RUSOCSubjectViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCSubjectViewController"
        ) as! RUSOCSubjectViewController

        me.subject = subject
        me.courses = courses

        return me
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil

        Observable.of(courses)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(
                cellIdentifier: cellId,
                cellType: RUSOCSubjectCell.self
            )) { idx, model, cell in
                cell.courseLabel.text = "\(model.courseNumber): \(model.title)"
                cell.creditsLabel.text = "\(model.credits.map { Int($0) } ?? 0)"

                let openSectionCount = model.sections.filter {
                    $0.openStatus
                }.count
                cell.sectionsLabel.text =
                    "\(openSectionCount)/\(model.sections.count)"
            }
            .addDisposableTo(disposeBag)

        self.tableView.rx.modelSelected(Course.self)
            .subscribe(onNext: { course in
                let vc = RUSOCCourseViewController.instantiate(
                    withStoryboard: self.storyboard!,
                    course: course
                )

                self.navigationController?
                    .pushViewController(vc, animated: true)
            })
            .addDisposableTo(disposeBag)
    }
}
