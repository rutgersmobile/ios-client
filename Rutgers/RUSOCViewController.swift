//
//  RUSOCViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/16/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift

class RUSOCViewController
    : UITableViewController
    , RUChannelProtocol
{
    var channel: [NSObject : AnyObject]!

    let disposeBag = DisposeBag()
    let cellId = "RUSOCCellId"
    let searchController = UISearchController(searchResultsController: nil)

    static func channelHandle() -> String! {
        return "soc"
    }

    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUSOCViewController.self)
    }

    static func getStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "RUSOCStoryboard", bundle: nil)
    }

    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!
    ) -> Any! {
        let storyboard = RUSOCViewController.getStoryBoard()
        let me = storyboard.instantiateInitialViewController()
            as! RUSOCViewController

        me.channel = channelConfiguration as [NSObject : AnyObject]

        return me
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil

        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar

        SOCAPI.instance.getInit()
            .map { $0.subjects }
            .flatMap { subjects in
                self.searchController.searchBar.rx.text.orEmpty
                    .throttle(0.3, scheduler: MainScheduler.instance)
                    .distinctUntilChanged()
                    .map { search in
                        subjects.filter {
                            $0.description
                                .lowercased()
                                .hasPrefix(search.lowercased())
                        }
                    }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: cellId))
            { idx, model, cell in
                cell.textLabel?.text = model.description
            }
            .addDisposableTo(disposeBag)
    }
}
