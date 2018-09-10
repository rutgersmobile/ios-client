//
//  RUFoodViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 2/13/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxSegue

@objcMembers
class RUFoodMainViewController
    : UITableViewController
    , RUChannelProtocol
{
    var channel: [NSObject : AnyObject]!

    let cellId = "FoodCellId"

    let disposeBag = DisposeBag()

    typealias RxDiningHallDataSource =
        RxTableViewSectionedReloadDataSource<DiningHallSection>
    typealias DiningHallDataSource =
        TableViewSectionedDataSource<DiningHallSection>
    typealias DiningHallSectionObserver = AnyObserver<DiningHallSectionItem>

    static func channelHandle() -> String! {
        return "food"
    }

    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUFoodMainViewController.self)
    }

    static func getStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "RUFoodStoryboard", bundle: nil)
    }

    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!
    ) -> Any! {
        let storyboard = RUFoodMainViewController.getStoryboard()
        let me = storyboard.instantiateInitialViewController()
            as! RUFoodMainViewController

        me.channel = channelConfiguration as [NSObject : AnyObject]

        return me
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil

        let dataSource = RxDiningHallDataSource()

        dataSource.configureCell = { (
            ds: DiningHallDataSource,
            tv: UITableView,
            ip: IndexPath,
            item: DiningHallSectionItem
        ) in
            let cell = tv.dequeueReusableCell(
                withIdentifier: self.cellId,
                for: ip
            )

            cell.textLabel?.text = {
                switch item {
                case .fullMenu(let diningHall):
                    return diningHall.name
                case .stubMenu(let stub):
                    return stub
                }
            }()

            return cell
        }

        dataSource.titleForHeaderInSection = { (ds, ip) in
            ds.sectionModels[ip].header
        }

        let newarkSection = DiningHallSection(
            header: "Newark",
            items: [.stubMenu("Newark Menu")]
        )

        let camdenSection = DiningHallSection(
            header: "Camden",
            items: [.stubMenu("Camden Menu")]
        )

        RutgersAPI.sharedInstance.getDiningHalls()
            .map { halls in DiningHallSection(
                header: "New Brunswick",
                items: halls.map { .fullMenu($0) }
            )}
            .toArray()
            .map { sections in sections + [newarkSection, camdenSection] }
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView!.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        let diningHallSegue: DiningHallSectionObserver = NavigationSegue(
            fromViewController: self.navigationController!,
            toViewControllerFactory: { [unowned self] (sender, model) in
                switch (model) {
                case .fullMenu(let diningHall):
                    return RUDiningHallTabBarController.instantiate(
                        fromStoryboard: self.storyboard!,
                        diningHall: .fullDiningHall(diningHall)
                    )
                case .stubMenu(let hallDescription):
                    return RUDiningHallStubViewController.instantiate(
                        withStoryboard: self.storyboard!,
                        hallDescription: hallDescription
                    )
                }
            }
        ).asObserver()

        self.tableView.rx.modelSelected(DiningHallSectionItem.self)
            .bind(to: diningHallSegue)
            .addDisposableTo(disposeBag)
    }

    static func viewControllers(
        withPathComponents pathComponents: [Any]!,
        destinationTitle title: String!
    ) -> [Any]! {
        if
            let hall = pathComponents.first as? String,
            let fullName = RUDiningHallTabBarController.nameShortToLong[hall] {
            return [RUDiningHallTabBarController.instantiate(
                fromStoryboard: getStoryboard(),
                diningHall: .serializedDiningHall(fullName)
            )]
        }
        return []
    }
}

struct DiningHallSection {
    var header: String
    var items: [Item]

    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

enum DiningHallSectionItem {
    case fullMenu(DiningHall)
    case stubMenu(String)
}

extension DiningHallSection: SectionModelType {
    typealias Item = DiningHallSectionItem

    init(original: DiningHallSection, items: [Item]) {
        self = original
        self.items = items
    }
}
