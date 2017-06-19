//
//  RUSOCSubjectViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift

class RUSOCCourseCell: UITableViewCell {
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var sectionsLabel: UILabel!
}

class RUSOCSubjectViewController : UITableViewController {
    var subject: Subject!
    var options: SOCOptions!

    let cellId = "RUSOCSubjectViewControllerId"

    let disposeBag = DisposeBag()

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

        RutgersAPI.sharedInstance.getCourses(
            semester: options.semester,
            campus: options.campus,
            level: options.level,
            subject: subject
        ).asDriver(onErrorJustReturn: [])
        .drive(self.tableView.rx.items(
            cellIdentifier: cellId,
            cellType: RUSOCCourseCell.self
        )) { idx, model, cell in
            cell.courseLabel.text = "\(model.courseNumber): \(model.title)"
            cell.creditsLabel.text = "\(model.credits.map { Int($0) } ?? 0)"

            cell.sectionsLabel.text =
            "\(model.sectionCheck.open) / \(model.sectionCheck.total)"
        }
        .addDisposableTo(disposeBag)

        self.tableView.rx.modelSelected(Course.self).flatMap { course in
            RutgersAPI.sharedInstance.getSections(
                semester: self.options.semester,
                campus: self.options.campus,
                level: self.options.level,
                course: course
            ).map { ($0, course) }
        }.subscribe(onNext: { res in
            let (sections, course) = res
            let vc = RUSOCCourseViewController.instantiate(
                withStoryboard: self.storyboard!,
                course: course,
                sections: sections
            )

            self.navigationController?
                .pushViewController(vc, animated: true)
        }).addDisposableTo(disposeBag)
    }
}
