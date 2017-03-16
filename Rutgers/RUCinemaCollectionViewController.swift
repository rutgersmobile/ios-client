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

final class RUCinemaCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
        
        
        typealias Source = JSQDataSourcesKit.DataSource< Section <Cinema> >
        typealias CollectionCellFactory = ViewFactory<Cinema, CinemaCollectionViewCell>
        typealias HeaderViewFactory = TitledSupplementaryViewFactory<Cinema>
        
        var dataSourceProvider: DataSourceProvider<Source, CollectionCellFactory, HeaderViewFactory>?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            configureCollectionView(collectionView!)
            
            let section0 : Section<Cinema> = Section([])
            
            let dataSource : Source = DataSource(sections: section0)
            
            let cellFactory = ViewFactory(reuseIdentifier: CellId) { (cell, model: Cinema?, type, collectionView, indexPath) -> CinemaCollectionViewCell in
                if let name = model?.name {
                    cell.label.text = String(name) + "\n\(indexPath.section), \(indexPath.item)"
                }
                
                cell.accessibilityIdentifier = "\(indexPath.section), \(indexPath.item)"
                return cell
            }
            
            let headerFactory = TitledSupplementaryViewFactory {(header, item: Cinema?, kind, collectionView, indexPath) -> TitledSupplementaryView in
                header.label.text = "Section \(indexPath.section)"
                header.backgroundColor = UIColor.gray
                return header
            }
            
            self.dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellFactory: cellFactory, supplementaryFactory: headerFactory)
            
            collectionView?.dataSource = self.dataSourceProvider?.collectionViewDataSource
            
        }
        
        func configureCollectionView(_ collectionView: UICollectionView) {
            
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: 50)
            
            collectionView.register(UINib(nibName: "CinemaCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: CellId)
            
            collectionView.register(TitledSupplementaryView.self,
                                    forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                    withReuseIdentifier: TitledSupplementaryView.identifier)
            
            collectionView.register(TitledSupplementaryView.self,
                                    forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                    withReuseIdentifier: TitledSupplementaryView.identifier)
        }
        
        
        
        
        
        
        
    
}
