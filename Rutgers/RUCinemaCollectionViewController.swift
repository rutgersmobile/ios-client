//
//  RUCinemaCollectionViewController.swift
//  Rutgers
//
//  Created by cfw37 on 2/3/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import JSQDataSourcesKit
import RxSwift
import Foundation

let CellId = "cell"

final class RUCinemaCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout,
    RUChannelProtocol {

    let disposeBag = DisposeBag()

    typealias Source = JSQDataSourcesKit.DataSource<Section<Cinema>>
    typealias CollectionCellFactory =
        ViewFactory<Cinema, RUCinemaCollectionViewCell>
    typealias HeaderViewFactory = TitledSupplementaryViewFactory<Cinema>

    var cinemaArray: [Cinema]?

    var channel: [NSObject : AnyObject]
    var dataSourceProvider:
        DataSourceProvider<Source, CollectionCellFactory, HeaderViewFactory>?

    static func channelHandle() -> String! {
        return "cinema";
    }

    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUCinemaCollectionViewController.self)
    }

    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!) -> Any!
    {
        return RUCinemaCollectionViewController(
            channel: channelConfiguration as [NSObject : AnyObject]
        )
    }

    init(channel: [NSObject: AnyObject]) {
        self.channel = channel

        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView(collectionView!)

        let section0 = Section(self.cinemaArray ?? [])

        let dataSource : Source = DataSource(sections: section0)

        let cellFactory = ViewFactory(reuseIdentifier: CellId) {(
            cell,
            model: Cinema?,
            type,
            collectionView,
            indexPath
        ) -> RUCinemaCollectionViewCell in
            if let name = model?.name {
                cell.label.text
                    = String(name)
                    + "\n\(indexPath.section), \(indexPath.item)"
            }

            cell.accessibilityIdentifier =
                "\(indexPath.section), \(indexPath.item)"
            return cell
        }

        let headerFactory = TitledSupplementaryViewFactory {(
            header,
            item: Cinema?,
            kind,
            collectionView,
            indexPath
        ) -> TitledSupplementaryView in
            return header
        }

        self.dataSourceProvider = DataSourceProvider(
            dataSource: dataSource,
            cellFactory: cellFactory,
            supplementaryFactory: headerFactory
        )

        collectionView?.dataSource =
            self.dataSourceProvider?.collectionViewDataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RutgersAPI.sharedInstance.getCinema()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { data in
                self.cinemaArray = data
                self.viewDidLoad()
            }, onError: { err in
                print(err)
            }).addDisposableTo(disposeBag)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width, height: 0)
    }

    func configureCollectionView(_ collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(
            width: (self.collectionView?.frame.width)!,
            height: 100
        )
        layout.sectionInset = UIEdgeInsetsMake(30, 0, 10, 10)
        self.collectionView?.setCollectionViewLayout(layout, animated: false)

        collectionView.register(
            UINib(nibName: "RUCinemaCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: CellId
        )

        collectionView.register(
            TitledSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: TitledSupplementaryView.identifier
        )

        collectionView.register(
            TitledSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
            withReuseIdentifier: TitledSupplementaryView.identifier
        )
    }
}
