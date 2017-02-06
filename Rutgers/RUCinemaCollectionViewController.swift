//
//  RUCinemaCollectionViewController.swift
//  Rutgers
//
//  Created by cfw37 on 2/3/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import JSQDataSourcesKit

let CellId = "cell"


final class RUCinemaCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, RUChannelProtocol {
    
    
    
    typealias Source = JSQDataSourcesKit.DataSource< Section <Cinema> >
    typealias CollectionCellFactory = ViewFactory<Cinema, RUCinemaCollectionViewCell>
    typealias HeaderViewFactory = TitledSupplementaryViewFactory<Cinema>
    
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
        
        let dummy = Cinema(
            movieId: 1,
            tmdbId: 2,
            name: "Movie",
            rating: "5/5",
            runtime: 3,
            studio: "Studio",
            showings: []
        )
        
        let section0 : Section<Cinema> = Section(items: dummy)
        
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
            
            cell.setNeedsDisplay()
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
            header.label.text = "Section \(indexPath.section)"
            header.backgroundColor = UIColor.gray
            return header
        }
        
        self.dataSourceProvider = DataSourceProvider(
            dataSource: dataSource,
            cellFactory: cellFactory,
            supplementaryFactory: headerFactory
        )
        
        collectionView?.dataSource = self.dataSourceProvider?.collectionViewDataSource
        
        collectionView?.reloadData()
        
        
        //        RutgersAPI.sharedInstance.getCinema()
        //            .subscribe { event in
        //                switch event {
        //                case let .next(data):
        //                    print(type(of:data))
        //                case let .error(error):
        //                    print(error)
        //                default:
        //                    break
        //                }
        //        }.addDisposableTo(disposeBag)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }
    
    func configureCollectionView(_ collectionView: UICollectionView) {
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: 50)
        
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
