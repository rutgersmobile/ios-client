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
    
    //Self explanatory
    let CellId = "cell"
    //Dispose bag used by Rx in order to dealloc all objects used by Rx
    let disposeBag = DisposeBag()
    
    //Used for the left sidebar
    var channel: [NSObject : AnyObject]!
    
    //Defines the channel handle
    static func channelHandle() -> String! {
        return "cinema";
    }
    
    //Registers the viewController so the channel manager knows what vc to init
    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUCinemaCollectionViewController.self)
    }
    
    //Initializes viewController with channel
    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!
        ) -> Any! {
        return RUCinemaCollectionViewController(
            channel: channelConfiguration as [NSObject : AnyObject]
        )
    }
    
    //Defines init
    init(channel: [NSObject : AnyObject]) {
        self.channel = channel
        super.init(collectionViewLayout: .init())
    }
    
    //Used so IB knows what to deserialize
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Most things happen here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        Resets the collectionView.dataSource to nil - otherwise the app will
        crash since RxDataSource tries to implement it's own datasource.
        */
        
        self.collectionView?.dataSource = nil
        
        /*
        Essentially configues everything with collectionView programatically
        See method for more info
        */
        
        configureCollectionView(collectionView!)
        
        /*
         Defines dataSource to be used by RxDataSource - specifies type as 
         CinemaSection
         */
        let dataSource =
            RxCollectionViewSectionedReloadDataSource<CinemaSection>()
        
        /*
         Does all the heavy lifting specifying how and what the cells will
         display
         */
        
        skinCollectionViewDataSource(dataSource: dataSource)
        
        /*
         Does the main API request to get both Rutgers cinema data and tmdb data
         */
        
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
                /*
                Initializes the CinemaSection with a header, and dafaultItem
                cell, which, in turn, takes two arguments in order for the
                cell to display necessary information
                 
                 CinemaSection struct is at the end of the file for more info
                */
                CinemaSection(header: "Movies",
                              items: [
                                .defaultItem(
                                    movieItem: movie,
                                    tmdbItem: tmdbMovie)
                    ]
                )
            }
            .toArray()
            .asDriver(onErrorJustReturn: [])
            .drive(self.collectionView!.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        /*
        Passes necessary info to next view controller, and then displays it
        when a user taps a cell
        */
        
        self.collectionView?.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(self.tap)
            )
        )
    }
    
    // MARK: HELPER FUNCTIONS
    
        /*
        Helper function for the posterImage api request.  Upon completion 
        returns either the image we want or an initialized (blank) UIImage.
        */
    
    func getPosterImage(data: TmdbData,
                        completion: @escaping (_ result: UIImage) -> Void){
        
        var returnImage: UIImage!
        
        TmdbAPI.sharedInstance.getPosterImage(data: data)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { image in
                 returnImage = image ?? UIImage()
                 completion(returnImage)
            }).addDisposableTo(self.disposeBag)
    }
    
    /*
    Mainly described from before, but essentially just prevents viewDidLoad
    from being an absolutely incomprehensible mess - used primarily to set up
    how the cells will display data
    */
    
    fileprivate func skinCollectionViewDataSource(
        dataSource: RxCollectionViewSectionedReloadDataSource<CinemaSection>) {
        dataSource.configureCell = {(
             dataSource: CollectionViewSectionedDataSource<CinemaSection>,
             collectionView: UICollectionView,
             idxPath: IndexPath,
             item: CVCinemaSectionItem
        ) in
            switch dataSource[idxPath] {
            case let .defaultItem(movieItem: movie, tmdbItem: tmdbMovie):
                
                let cell: RUCinemaCollectionViewCell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: self.CellId,
                        for: idxPath) as! RUCinemaCollectionViewCell
                
                self.getPosterImage(data: tmdbMovie, completion: { image in
                    cell.posterImage.image = image
                })
                
                let genreString = tmdbMovie.genres.map { genres in
                    genres.map { $0.name }.joined(separator: ", ")
                    } ?? ""
                
                var showingArray: [Showings] = []
                
                var cellLabelDictionary : [String : String] = [
                    "label1": "",
                    "label2": "",
                    "label3": ""
                ]
                
                if (movie.showings.count != 0) {
                    //Used for date formatting
                    let calendar = Calendar.current
                    
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.timeStyle = .short
                    
                    let sortedArray =
                        movie.showings.sorted { $0.dateTime > $1.dateTime }
                    
                    let baseDay = calendar.component(
                                            .day,
                                            from:
                                            sortedArray[0].dateTime as Date)
                    
                    showingArray = sortedArray.filter({
                            calendar.component(
                                .day,
                                from:
                                $0.dateTime as Date
                            ) == baseDay
                    })
                    
                    showingArray = showingArray.reversed()
                    
                    for i in 0..<showingArray.count {
                        cellLabelDictionary["label\(i+1)"] =
                            dateFormatter.string(
                                from: showingArray[i].dateTime
                        )
                    }
                
                }
                
                cell.time1.text = cellLabelDictionary["label1"]
                cell.time2.text = cellLabelDictionary["label2"]
                cell.time3.text = cellLabelDictionary["label3"]
                
                let index =
                    tmdbMovie.releaseDate?.index(
                        (tmdbMovie.releaseDate?.startIndex)!,
                        offsetBy: 4
                    )
                
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
        if let indexPath = self.collectionView?.indexPathForItem(
            at: sender.location(
                in: self.collectionView)
            ) {

            let cell : RUCinemaCollectionViewCell =
                self.collectionView?
                    .cellForItem(at: indexPath) as! RUCinemaCollectionViewCell
            
            let vc = RUCinemaDetailTableViewController.init(
                movieId: cell.movieId,
                showTimes:
                    [cell.time1.text ?? "",
                     cell.time2.text ?? "",
                     cell.time3.text ?? ""]
            )
 
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func configureCollectionView(_ collectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(
            width: (self.collectionView?.frame.width)!,
            height: 150
        )
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        self.collectionView?.backgroundColor =
            UIColor(red:0.33, green:0.32, blue:0.33, alpha:1.0)
        
        collectionView.register(
            UINib(nibName: "RUCinemaCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: CellId
        )
    }
}

private struct CinemaSection {
    var header: String
    var items : [CVCinemaSectionItem]
    
    init(header: String, items: [CVCinemaSectionItem]) {
        self.header = header
        self.items = items
    }
}

private enum CVCinemaSectionItem {
    case defaultItem(movieItem: Cinema, tmdbItem: TmdbData)
}

extension CinemaSection: SectionModelType {
    typealias Item = CVCinemaSectionItem
    
    init(original: CinemaSection, items: [Item]) {
        self = original
        self.items = items
    }
}
