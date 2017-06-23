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

public extension UITableViewCell {
    func setupCellLayout() {
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

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

    static let openColor = UIColor(
        red:0.70,
        green:0.92,
        blue:0.44,
        alpha:1.0
    )
    static let closedColor = UIColor(
       red:0.92,
       green:0.44,
       blue:0.30,
       alpha:1.0
    )
    
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
        dataSource: RxTableViewSectionedReloadDataSource<MultiSection>) {
        
        dataSource.configureCell = {
            (dataSource: TableViewSectionedDataSource<MultiSection>,
            tableView: UITableView,
            idxPath: IndexPath,
            item: SOCSectionItem)
            
            in
            
            switch dataSource[idxPath] {
            case let .SubjectItem(subject):
                let cell: RUSOCSubjectCell =
                    tableView.dequeueReusableCell(
                        withIdentifier: self.cellId,
                       for: idxPath) as! RUSOCSubjectCell
                
                cell.subjectTitle.text = subject.subjectDescription
                cell.schoolTitle.text = "School Name Goes Here"
                cell.subjectCode.text = String(subject.code)
                cell.setupCellLayout()
                
                return cell
            case let .CourseItem(course):
                let cell: RUSOCCourseCell =
                    tableView.dequeueReusableCell(
                        withIdentifier: "RUSOCCourseCell",
                        for: idxPath) as! RUSOCCourseCell
                
                cell.courseLabel.text = course.title
                cell.creditsLabel.text = "\(course.credits.map { Int($0) } ?? 0)"
                cell.codeLabel.text = course.string
                
                cell.openSectionsBG.backgroundColor = course.sectionCheck.open > 0 ?
                    RUSOCViewController.openColor : RUSOCViewController.closedColor
                cell.openSectionsCount.text =
                "\(course.sectionCheck.open)/\(course.sectionCheck.total)"
                cell.setupCellLayout()
                
                return cell
            }
            
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            
            return section.title
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
        
        self.tableView.separatorInset = UIEdgeInsetsMake(0,0,0,0)
        
        let dataSource = RxTableViewSectionedReloadDataSource<MultiSection>()
        
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
                .flatMapLatest { initObj -> Observable<SOCOptions> in
                    
                    let currentSemester = initObj.semesters[0]
                    
                    let socOptionsSelected = settingsViewButton.rx.tap.flatMapLatest
                    {() -> Observable<SOCOptions> in
                        let (vc, options) =
                            self.socOptions(semesters: initObj.semesters)
                        self.navigationController?
                            .pushViewController(vc, animated: true)
                        
                        return options
                    }
                    
                    let socOptions = Observable.of(
                        Observable.of(
                            RUSOCOptionsViewController
                                .defaultOptions(
                                    semester: currentSemester)
                        ),
                        socOptionsSelected
                        ).merge()
                    
                    return socOptions
        }.shareReplay(1)
        
        let initialLoad =
            getOptions.flatMapLatest { options -> Observable<[MultiSection]> in
                RutgersAPI
                    .sharedInstance
                    .getSubjects(semester: options.semester,
                                 campus: options.campus,
                                 level: options.level)
                    .map{ subjectArr in
                        let sections: [MultiSection] =
                            [.SubjectSection(title: "", items:
                                subjectArr.map {
                                    .SubjectItem(subject: $0)
                                }
                              )
                            ]
                        return sections
                }
                
                }
        
        
        let searchResults = getOptions.flatMap { options in
            self.searchController
                .searchBar
                .rx
                .text
                .changed
                .debounce(
                    RxTimeInterval.init(0.5),
                    scheduler: MainScheduler.asyncInstance
                ).map {
                    ($0 ?? "", options)
                }
        }.flatMap { deConn -> Observable<[MultiSection]> in
            let (text, options) = deConn
            
            if (text != "") {
            return RutgersAPI
                .sharedInstance
                .getSearch(semester: options.semester,
                           campus: options.campus,
                           level: options.level,
                           query: text)
                .map {eventSubject in
                    [
                        .SubjectSection (
                            title: "Subjects",
                            items: eventSubject.subjects.map {
                                    .SubjectItem(subject: $0)
                        }),
                        .CourseSection(
                            title: "Courses",
                            items: eventSubject.courses.map {
                            .CourseItem(course: $0)
                        })
                    ]
                }
            } else {
                return initialLoad
            }
        }
        
        let cancelTapped =
            self.searchController
            .searchBar
            .rx
            .cancelButtonClicked
            .flatMapLatest { event -> Observable<[MultiSection]> in
                return initialLoad
            }
        
        Observable.merge(initialLoad, searchResults, cancelTapped).do(onError: {error in
            print(error)
        })
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView!.rx.items(dataSource: dataSource))
            .addDisposableTo(self.disposeBag)
        
        getOptions
            .flatMapLatest { options in
                self.tableView
                    .rx
                    .modelSelected(MultiSection.Item.self)
                    .map { item -> (Any, SOCOptions) in
                        switch item {
                        case .SubjectItem(subject: let subject):
                            return (subject, options)
                        case .CourseItem(course: let course):
                            return (course, options)
                        }
                    }
            }.subscribe(onNext: {
                deConn in
                
                let (item, options) = deConn
                
                
                switch item {
                case is Subject:
                    let vc =
                        RUSOCSubjectViewController
                            .instantiate(
                                withStoryboard: self.storyboard!,
                                subject: item as! Subject,
                                options: options
                    )
                    
                    self.navigationController?
                        .pushViewController(vc, animated: true)
                default:
                    let vc =
                        RUSOCCourseViewController
                            .instantiate(
                                withStoryboard: self.storyboard!,
                                options: options,
                                course: item as! Course
                        )
                    
                    self.navigationController?
                        .pushViewController(vc, animated: true)
                }
                
                
                
                }
            ).addDisposableTo(self.disposeBag)
    }
}


private enum MultiSection {
    case SubjectSection(title: String, items: [SOCSectionItem])
    case CourseSection(title: String, items: [SOCSectionItem])
}

private enum SOCSectionItem {
    case SubjectItem(subject: Subject)
    case CourseItem(course: Course)
}

extension MultiSection: SectionModelType {
    
    var items: [SOCSectionItem] {
        switch self {
        case .SubjectSection(title: _, items: let items):
            return items
        case .CourseSection(title: _, items: let items):
            return items
        }
    }
    
    var title: String {
        switch self {
        case .SubjectSection(title: let title, items: _):
                return title
        case .CourseSection(title: let title, items: _):
                return title
        }
    }
    
    init(original: MultiSection, items: [SOCSectionItem]) {
        switch original {
        case let .SubjectSection(title: title, items: _):
            self = .SubjectSection(title: title, items: items)
        case let .CourseSection(title: title, items: _):
            self = .CourseSection(title: title, items: items)
        }
    }
}
/*
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
*/
