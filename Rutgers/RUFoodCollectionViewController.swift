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

class RUFoodCollectionViewController
    : UICollectionViewController
    , RUChannelProtocol
{
    var channel: [NSObject : AnyObject]!

    let cellId = "FoodCellId"
    let headerId = "FoodHeaderId"

    let disposeBag = DisposeBag()

    typealias RxDiningHallDataSource =
        RxCollectionViewSectionedReloadDataSource<DiningHallSection>
    typealias DiningHallDataSource =
        CollectionViewSectionedDataSource<DiningHallSection>
    typealias DiningHallSectionObserver = AnyObserver<DiningHallSectionItem>

    static func channelHandle() -> String! {
        return "food";
    }

    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUFoodCollectionViewController.self)
    }

    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!
    ) -> Any! {
        let storyboard = UIStoryboard(name: "RUFoodStoryboard", bundle: nil)
        let me = storyboard.instantiateInitialViewController()
            as! RUFoodCollectionViewController

        me.channel = channelConfiguration as [NSObject : AnyObject]

        return me
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.dataSource = nil

        let dataSource = RxDiningHallDataSource()

        dataSource.configureCell = {(
            ds: DiningHallDataSource,
            cv: UICollectionView,
            ip: IndexPath,
            item: DiningHallSectionItem
        ) in
            let cell = cv.dequeueReusableCell(
                withReuseIdentifier: self.cellId,
                for: ip
            ) as! RUFoodCollectionViewCell

            cell.label.text = {
                switch item {
                case .fullMenu(let diningHall):
                    return diningHall.name
                case .stubMenu(let stub):
                    return stub
                }
            }()

            return cell
        }

        dataSource.supplementaryViewFactory = {(
            ds: DiningHallDataSource,
            cv: UICollectionView,
            kind: String,
            ip: IndexPath
        ) in
            let header = cv.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: self.headerId,
                for: ip
            ) as! RUFoodCollectionViewHeaderView

            let model = ds.sectionModels[ip.section]

            header.label.text = model.header

            return header
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
            .drive(self.collectionView!.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        let diningHallSegue: DiningHallSectionObserver = NavigationSegue(
            fromViewController: self.navigationController!,
            toViewControllerFactory: { (sender, model) in
                switch (model) {
                case .fullMenu(let diningHall):
                    return RUDiningHallTabBarController.instantiate(
                        fromStoryboard: self.storyboard!,
                        diningHall: diningHall
                    )
                case .stubMenu(let hallDescription):
                    return RUDiningHallStubViewController.instantiate(
                        withStoryboard: self.storyboard!,
                        hallDescription: hallDescription
                    )
                }
            }
        ).asObserver()

        self.collectionView?.rx.modelSelected(DiningHallSectionItem.self)
            .bindTo(diningHallSegue)
            .addDisposableTo(disposeBag)
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
