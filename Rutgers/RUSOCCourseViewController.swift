//
//  RUSOCCourseViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/28/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift

class RUSOCCourseViewController: UITableViewController {
    var course: Course!

    let cellId = "RUSOCSectionCellId"
    let disposeBag = DisposeBag()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil

        Observable.of(course.sections)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: self.cellId))
            { idx, model, cell in
                cell.textLabel?.text = model.index
            }
            .addDisposableTo(disposeBag)
    }
}
