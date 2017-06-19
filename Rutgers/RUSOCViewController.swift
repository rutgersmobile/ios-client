//
//  RUSOCViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/16/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxSegue
import RxDataSources

class RUSOCSubjectCell: UITableViewCell {
    @IBOutlet weak var subjectTitle: UILabel!
    @IBOutlet weak var schoolTitle: UILabel!
    @IBOutlet weak var subjectCode: UILabel!
    
}

class RUSOCViewController
    : UITableViewController
    , RUChannelProtocol
{
    var channel: [NSObject : AnyObject]!
    
    let disposeBag = DisposeBag()
    let cellId = "RUSOCCellId"
    let searchController = UISearchController(searchResultsController: nil)
    let activityIndicator = UIActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 40, height: 40)
    )
    
    var courses: [Course] = []
    var passOptions: SOCOptions!
    
    static func channelHandle() -> String! {
        return "soc"
    }
    
    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUSOCViewController.self)
    }
    
    static func getStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "RUSOCStoryboard", bundle: nil)
    }
    
    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!
        ) -> Any! {
        let storyboard = RUSOCViewController.getStoryBoard()
        let me = storyboard.instantiateInitialViewController()
            as! RUSOCViewController
        
        me.channel = channelConfiguration as [NSObject : AnyObject]
        
        return me
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func socOptions(
        semesters: [Semester]
        ) -> (RUSOCOptionsViewController, Observable<SOCOptions>) {
        let vc = RUSOCOptionsViewController.instantiate(
            withStoryboard: RUSOCViewController.getStoryBoard(),
            semesters: semesters
        )
        let observable = Observable<SOCOptions>.create { observer in
            vc.observer = observer
            return Disposables.create()
        }
        return (vc, observable)
    }
    
    fileprivate func skinTableViewDataSource(
        dataSource: RxTableViewSectionedReloadDataSource<SubjectSection>) {
        
        dataSource.configureCell = {
            (dataSource: TableViewSectionedDataSource<SubjectSection>,
            tableView: UITableView,
            idxPath: IndexPath,
            item: SubjectItem)
            
            in
            
            let model = dataSource[idxPath]
            
            let cell: RUSOCSubjectCell =
                tableView.dequeueReusableCell(withIdentifier: self.cellId,
                                              for: idxPath) as! RUSOCSubjectCell
            
            cell.subjectTitle.text = model.subject.subjectDescription
            cell.schoolTitle.text = "School Name Goes Here"
            cell.subjectCode.text = String(model.subject.code)
            
            return cell
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
        
        self.activityIndicator.activityIndicatorViewStyle = .gray
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        
        self.tableView?.dataSource = nil
        
        let dataSource = RxTableViewSectionedReloadDataSource<SubjectSection>()
        
        skinTableViewDataSource(dataSource: dataSource)
        
        let settingsViewButton = UIButton(
            frame: CGRect(x: 0, y: 0, width: 30, height: 30)
        )
        settingsViewButton.setBackgroundImage(#imageLiteral(resourceName: "gear"), for: .normal)
        
        let settingsButtonItem = UIBarButtonItem(customView: settingsViewButton)
        self.navigationItem
            .setRightBarButton(settingsButtonItem, animated: false)
        
        RutgersAPI.sharedInstance.networkStatus
            .subscribe(onNext: { [weak self] change in
                switch change {
                case .began:
                    self?.activityIndicator.startAnimating()
                case .ended:
                    self?.activityIndicator.stopAnimating()
                }
            })
            .addDisposableTo(disposeBag)
        
        let getOptions =
            RutgersAPI
                .sharedInstance
                .getSOCInit()
                .flatMap { initObj -> Observable<SOCOptions> in
                    let currentSemester = initObj.semesters[0]
                    
                    let socOptionsSelected = settingsViewButton.rx.tap.flatMap
                    { [unowned self] () -> Observable<SOCOptions> in
                        let (vc, options) =
                            self.socOptions(semesters: initObj.semesters)
                        self.navigationController?
                            .pushViewController(vc, animated: true)
                        return options
                    }
                    
                    let socOptions = Observable.of(
                        Observable.of(RUSOCOptionsViewController.defaultOptions(
                            semester: currentSemester
                        )),
                        socOptionsSelected
                        ).merge()
                    
                    return socOptions}
        
        let initialLoad =
            getOptions.flatMap { options -> Observable<[SubjectSection]> in
                return RutgersAPI
                    .sharedInstance
                    .getSubjects(semester: options.semester,
                                 campus: options.campus,
                                 level: options.level)
                    .map{ subjectArr in
                        [SubjectSection(items: subjectArr.map {
                            SubjectItem(subject: $0)
                        })
                        ]
                }
        }
        
        let searchResults = self.searchController
            .searchBar
            .rx
            .text
            .changed
            .debounce(RxTimeInterval.init(0.5),
                      scheduler: MainScheduler.asyncInstance)
            .flatMap { text -> Observable<(String, SOCOptions)> in
                return getOptions.map{(text!, $0)}
            }.flatMap { deConn -> Observable<[SubjectSection]> in
                let (text, options) = deConn
                return RutgersAPI
                    .sharedInstance
                    .getSearch(semester: options.semester,
                               campus: options.campus,
                               level: options.level,
                               query: text)
                    .map {eventSubject in
                        [SubjectSection(
                            items: eventSubject.subjects.map {
                                SubjectItem(subject: $0)
                            }
                            )
                        ]
                }
        }
        
        Observable.merge(initialLoad, searchResults)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView!.rx.items(dataSource: dataSource))
            .addDisposableTo(self.disposeBag)
        
        self.tableView.rx.modelSelected(SubjectItem.self)
            .flatMap{ model -> Observable<(Subject,SOCOptions)> in
                return getOptions.map{(model.subject, $0)}
            }.subscribe(onNext: { deConn in
                let (subject, options) = deConn
                let vc = RUSOCSubjectViewController.instantiate(
                    withStoryboard: self.storyboard!,
                    subject: subject,
                    options: options
                )
                
                self.navigationController?
                    .pushViewController(vc, animated: true)
            }).addDisposableTo(self.disposeBag)
    }
}


private struct SubjectSection {
    var items: [SubjectItem]
    
    init(items: [SubjectItem]) {
        self.items = items
    }
    
}

private struct SubjectItem {
    let subject: Subject
}

extension SubjectSection: SectionModelType {
    init(original: SubjectSection, items: [SubjectItem]) {
        self = original
        self.items = items
    }
}

