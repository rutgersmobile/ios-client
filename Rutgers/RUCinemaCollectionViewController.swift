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
import Alamofire
import RxSegue



final class RUCinemaCollectionViewController:
    UICollectionViewController,
RUChannelProtocol {
    
    let CellId = "cell"
    
    let disposeBag = DisposeBag()
    
    var channel: [NSObject : AnyObject]!
    
    static func channelHandle() -> String! {
        return "cinema";
    }
    
    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUCinemaCollectionViewController.self)
    }
    
    static func getStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "RUCinemaStoryboard", bundle: nil)
    }

    
    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!
        ) -> Any! {
        
        let storyboard = RUCinemaCollectionViewController.getStoryboard()
        let me = storyboard.instantiateInitialViewController() as! RUCinemaCollectionViewController
        
        me.channel = channelConfiguration as [NSObject : AnyObject]
        
        return me
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.dataSource = nil
        
        configureCollectionView(collectionView!)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<CinemaSection>()
        
        skinCollectionViewDataSource(dataSource: dataSource)
        
        
        RutgersAPI.sharedInstance.getCinema()
            .flatMap { movies in
                Observable.from(movies)}
            .flatMap{ movie in
                TmdbAPI.sharedInstance.getTmdbData(movieId: movie.tmdbId)
                    .map { tmdbMovie in
                        (movie, tmdbMovie)
                }
            }
            .map { (movie, tmdbMovie) in
                CinemaSection(header: "Movies", items: [.defaultItem(movieItem: movie, tmdbItem: tmdbMovie)])
            }
            .toArray()
            .asDriver(onErrorJustReturn: [])
            .drive(self.collectionView!.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
     
//        let cinemaDetailSegue: AnyObserver<CinemaSectionItem> = NavigationSegue(fromViewController: self.navigationController!) { (destinationVC, (sender, receiver)) ->
//           
//        }
        
        self.collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap)))
    }
    
        
    
    
    
    func skinCollectionViewDataSource(dataSource: RxCollectionViewSectionedReloadDataSource<CinemaSection>) {
        dataSource.configureCell = {[unowned self](dataSource, collectionView, idxPath, item) in
            
            switch dataSource[idxPath] {
            case let .defaultItem(movieItem: movie, tmdbItem: tmdbMovie):
                
                let cell: RUCinemaCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.CellId, for: idxPath) as! RUCinemaCollectionViewCell
                
                TmdbAPI.sharedInstance.getPosterImage(data: tmdbMovie)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { image in
                        cell.posterImage.image = image ?? UIImage(named: "bus_pin")
                    }).addDisposableTo(self.disposeBag)
                
                
                let genreString = tmdbMovie.genres.map { genres in
                    genres.map { $0.name }.joined(separator: ", ")
                    } ?? ""
                
                if (movie.showings.count != 0) {
                    let calendar = Calendar.current
                    
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.timeStyle = .short
                    
                    let sortedArray = movie.showings.sorted { $0.dateTime > $1.dateTime }
                    
                    let baseDay = calendar.component(.day, from: sortedArray[0].dateTime as Date)
                    
                    var showingArray = [Date]()
                    
                    for i in 0..<sortedArray.count {
                        let day = calendar.component(.day, from: sortedArray[i].dateTime as Date)
                        
                        if (day == baseDay) {
                            showingArray.append(sortedArray[i].dateTime)
                        } else {
                            break
                        }
                    }
                    
                    showingArray.reverse()
                    
                    var timeStamp1 = ""
                    var timeStamp2 = ""
                    var timeStamp3 = ""
                    
                    if showingArray.count < 3 && showingArray.count >= 2 {
                        cell.time1.isHidden = false
                        cell.time2.isHidden = false
                        
                        timeStamp1 = dateFormatter.string(from: showingArray[0])
                        timeStamp2 = dateFormatter.string(from: showingArray[1])
                    } else {
                        
                        cell.time1.isHidden = false
                        cell.time2.isHidden = false
                        cell.time3.isHidden = false
                        
                        timeStamp1 = dateFormatter.string(from: showingArray[0])
                        timeStamp2 = dateFormatter.string(from: showingArray[1])
                        timeStamp3 = dateFormatter.string(from: showingArray[2])
                    }
                    
                    cell.time1.text = timeStamp1
                    cell.time2.text = timeStamp2
                    cell.time3.text = timeStamp3
                    
                    showingArray.removeAll()
                    
                    
                }
                
                let index = tmdbMovie.releaseDate?.index((tmdbMovie.releaseDate?.startIndex)!, offsetBy: 4)
                
                let currentYear = tmdbMovie.releaseDate!.substring(to: index!)
                
                cell.descriptionLabel.textColor = .white
                cell.tagsLabel.text = genreString
                cell.descriptionLabel.text = tmdbMovie.overview
                cell.label.text = "\(tmdbMovie.title!) (\(currentYear))"
                cell.movieId = Int(tmdbMovie.id!)
                
                return cell
                
                
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
        ) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 0)
    }
    
    func tap(sender: UITapGestureRecognizer) {
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            let cell : RUCinemaCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! RUCinemaCollectionViewCell
            
            let vc = RUCinemaDetailTableViewController.init(movieId: cell.movieId)
            
            vc.showTimes = [cell.time1.text ?? "", cell.time2.text ?? "", cell.time3.text ?? ""]
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            print("collection view was tapped")
        }
    }
    
    
    
    func configureCollectionView(_ collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        layout.itemSize = CGSize(
            width: (self.collectionView?.frame.width)!,
            height: 150
        )
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.collectionView?.setCollectionViewLayout(layout, animated: false)
        self.collectionView?.backgroundColor = UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
        
        collectionView.register(
            UINib(nibName: "RUCinemaCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: CellId
        )
    }
}

struct CinemaSection {
    var header: String
    var items : [CVCinemaSectionItem]
    
    init(header: String, items: [CVCinemaSectionItem]) {
        self.header = header
        self.items = items
    }
}

enum CVCinemaSectionItem {
    case defaultItem(movieItem: Cinema, tmdbItem: TmdbData)
}

extension CinemaSection: SectionModelType {
    typealias Item = CVCinemaSectionItem
    
    init(original: CinemaSection, items: [Item]) {
        self = original
        self.items = items
    }
}
