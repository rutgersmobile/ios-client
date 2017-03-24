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

class RUSOCOptionsViewController: UITableViewController, UIActionSheetDelegate {
    let cellId = "RUSOCOptionsViewControllerId"
    let disposeBag = DisposeBag()

    var semesters: [Semester]!
    var observer: AnyObserver<SOCOptions>!

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

        Observable.of(["Some", "Test", "Values"])
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: cellId))
            { idx, model, cell in
                cell.textLabel?.text = model
            }
            .addDisposableTo(disposeBag)

        self.tableView.rx.modelSelected(String.self)
            .flatMap { (value: String) -> ControlEvent<Int> in
                let actionSheet = self.actionSheet(
                    with: ["Couple", "Of", "Sheet", "Values", "And", value]
                )
                actionSheet.show(in: self.tableView)
                return actionSheet.rx.buttonClickedIndex
            }
            .subscribe(onNext: { clicked in
                print(clicked)
            })
            .addDisposableTo(disposeBag)
    }

    func actionSheet(with titles: [String]) -> UIActionSheet {
        let actionSheet = UIActionSheet()
        for title in titles {
            actionSheet.addButton(withTitle: title)
        }
        actionSheet.cancelButtonIndex =
            actionSheet.addButton(withTitle: "Cancel")
        return actionSheet
    }
}

struct SOCOptions {
    let semester: Semester
    let campus: Campus
    let level: Level
}
