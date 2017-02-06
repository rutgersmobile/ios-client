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


final class RUCinemaCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, RUChannelProtocol {
    
    let disposeBag = DisposeBag()
    
    typealias Source = JSQDataSourcesKit.DataSource< Section <Cinema> >
    typealias CollectionCellFactory = ViewFactory<Cinema, RUCinemaCollectionViewCell>
    typealias HeaderViewFactory = TitledSupplementaryViewFactory<Cinema>
    
    var cinemaArray : [Cinema]?
    
    var channel : [NSObject : AnyObject]
    
    static func channelHandle() -> String!
    {
        return "cinema";
    }
    
    static func registerClass()
    {
        RUChannelManager.sharedInstance().register(RUCinemaCollectionViewController.self)
    }
    
    static func channel(withConfiguration channelConfiguration: [AnyHashable : Any]!) -> Any!
    {
        return RUCinemaCollectionViewController(channel: channelConfiguration as [NSObject : AnyObject])
    }
    
    
    var dataSourceProvider: DataSourceProvider<Source, CollectionCellFactory, HeaderViewFactory>?
    
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
        
//        let dummy = Cinema(
//            movieId: 1,
//            tmdbId: 2,
//            name: "Movie",
//            rating: "5/5",
//            runtime: 3,
//            studio: "Studio",
//            showings: []
//        )
        
        let section0 : Section<Cinema>?
        
        if let dataArray = self.cinemaArray {
            section0 = Section(dataArray)
        } else {
            section0 = Section([Cinema]())
        }
        
        let dataSource : Source = DataSource(sections: section0!)
        
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
            
            //            cell.setNeedsDisplay()
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
        
        collectionView?.dataSource = self.dataSourceProvider?.collectionViewDataSource
        
        //        collectionView?.reloadData()
        
        
     
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        RutgersAPI.sharedInstance.getCinema()
            .subscribe { event in
                switch event {
                case let .next(data):
                    self.cinemaArray = data as [Cinema]
                    
                    OperationQueue.main.addOperation {
                        self.viewDidLoad()
                    }
                case let .error(error):
                    print(error)
                default:
                    break
                }
            }.addDisposableTo(disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        
        
        return CGSize(width: collectionView.frame.size.width, height: 0)
    }
    
    func configureCollectionView(_ collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(width: (self.collectionView?.frame.width)!, height: 100)
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
