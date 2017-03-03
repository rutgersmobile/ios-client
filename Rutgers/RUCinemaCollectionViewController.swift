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



final class RUCinemaCollectionViewController:
    UICollectionViewController,
RUChannelProtocol {
    
    let CellId = "cell"
    
    let disposeBag = DisposeBag()
    
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
        
        self.collectionView?.dataSource = nil
        
        RutgersAPI.sharedInstance.getCinema()
            .flatMap { movies in Observable.from(movies) }
            .flatMap { movie in
                TmdbAPI.sharedInstance.getTmdbData(movieId: movie.tmdbId)
                    .map { tmdbMovie in (movie, tmdbMovie) }
            }
            .toArray()
            .asDriver(onErrorJustReturn: [])
            .drive((self.collectionView?.rx.items(
                cellIdentifier: CellId,
                cellType: RUCinemaCollectionViewCell.self
                ))!) { (idxPath, result, cell) in
                    let (movie, tmdbMovie) = result
                
                    TmdbAPI.sharedInstance.getPosterImage(data: tmdbMovie)
                        .observeOn(MainScheduler.instance)
                        .subscribe(onNext: { image in
                            cell.posterImage.image = image ?? UIImage(named: "bus_pin")
                        }).addDisposableTo(self.disposeBag)
                    
//                    var genreString = ""
//                    
//                    if let genres = tmdbMovie.genres {
//                        for genre in genres {
//                            
//                            if (genre.name != (genres.last!).name) {
//                                genreString.append(genre.name + ", ")}
//                            else {
//                                genreString.append(genre.name)
//                            }
//                        }
//                    }

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
                    
                    self.collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap)))
                    
                    
                    
            }.addDisposableTo(disposeBag)
        
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
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
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
