//
//  RUCinemaCollectionViewController.swift
//  Rutgers
//
//  Created by cfw37 on 2/3/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import Foundation

let CellId = "cell"

final class RUCinemaCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout,
    RUChannelProtocol {

    let disposeBag = DisposeBag()
    var cinemaArray: [Cinema]?
    var channel: [NSObject : AnyObject]

    static func channelHandle() -> String! {
        return "cinema";
    }

    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUCinemaCollectionViewController.self)
    }

    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!
    ) -> Any! {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView?.dataSource = nil

        RutgersAPI.sharedInstance.getCinema()
    
            .asDriver(onErrorJustReturn: [])
            .drive((self.collectionView?.rx.items(
                cellIdentifier: CellId,
                cellType: RUCinemaCollectionViewCell.self
            ))!) { (_, result, cell) in
                cell.label.text = result.name
            }.addDisposableTo(disposeBag)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
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
    }
}
