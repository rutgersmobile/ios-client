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
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var openSectionsBG: UIView!
    @IBOutlet weak var openSectionsCount: UILabel!
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
            cell.courseLabel.text = model.title
            cell.creditsLabel.text = "\(model.credits.map { Int($0) } ?? 0)"
            cell.codeLabel.text = model.string

            cell.openSectionsBG.backgroundColor = model.sectionCheck.open > 0 ?
                RUSOCViewController.openColor : RUSOCViewController.closedColor
            cell.openSectionsCount.text =
            "\(model.sectionCheck.open)/\(model.sectionCheck.total)"
            
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        .addDisposableTo(disposeBag)

        self.tableView.rx.modelSelected(Course.self)
            .subscribe(onNext: { course in
                let vc = RUSOCCourseViewController.instantiate(
                    withStoryboard: self.storyboard!,
                    options: self.options,
                    course: course
                )

                self.navigationController?
                    .pushViewController(vc, animated: true)
            }).addDisposableTo(disposeBag)
    }
}
