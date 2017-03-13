//
//  RUMealCollectionViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 2/24/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class RUMealViewController: UITableViewController {
    var meal: Meal!

    let cellId = "MealCellId"
    let disposeBag = DisposeBag()

    typealias RxMealDataSource =
        RxTableViewSectionedReloadDataSource<GenreSection>
    typealias MealDataSource = TableViewSectionedDataSource<GenreSection>

    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        meal: Meal
    ) -> RUMealViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUMealViewController"
        ) as! RUMealViewController

        me.meal = meal

        return me
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil

        let dataSource = RxMealDataSource()

        dataSource.configureCell = { [unowned self] (
            ds: MealDataSource,
            tv: UITableView,
            ip: IndexPath,
            item: String
        ) in
            let cell = tv.dequeueReusableCell(
                withIdentifier: self.cellId,
                for: ip
            )

            cell.textLabel?.text = item

            return cell
        }

        dataSource.titleForHeaderInSection = { (ds, ip) in
            ds.sectionModels[ip].header
        }

        Observable.from(meal.genres)
            .map { GenreSection( header: $0.name, items: $0.items) }
            .toArray()
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }
}

struct GenreSection {
    var header: String
    var items: [Item]

    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

extension GenreSection: SectionModelType {
    typealias Item = String

    init(original: GenreSection, items: [Item]) {
        self = original
        self.items = items
    }
}
