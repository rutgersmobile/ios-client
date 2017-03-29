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

        let settingsViewButton = UIButton(
            frame: CGRect(x: 0, y: 0, width: 30, height: 30)
        )
        settingsViewButton.setBackgroundImage(#imageLiteral(resourceName: "gear"), for: .normal)

        let settingsButtonItem = UIBarButtonItem(customView: settingsViewButton)
        self.navigationItem
            .setRightBarButton(settingsButtonItem, animated: false)

        SOCAPI.instance.networkStatus
            .subscribe(onNext: { [weak self] change in
                switch change {
                case .began:
                    self?.activityIndicator.startAnimating()
                case .ended:
                    self?.activityIndicator.stopAnimating()
                }
            })
            .addDisposableTo(disposeBag)

        SOCAPI.instance.getInit()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { (socInit: Init) -> Observable<[Subject]> in
                let currentSemester = socInit.currentTermDate.asSemester()
                let socOptionsSelected = settingsViewButton.rx.tap.flatMap
                    { [unowned self] () -> Observable<SOCOptions> in
                        let (vc, options) = self.socOptions(
                            semesters: currentSemester.previousSemesters(
                                number: 9
                            )
                        )
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

                return socOptions.flatMap { options in
                    SOCAPI.instance.getCourses(
                        semester: options.semester,
                        campus: options.campus,
                        level: options.level
                    ).map { courses in
                        self.courses = courses
                        return SOCAPI.getSubjects(
                            for: courses,
                            from: socInit.subjects
                        )
                    }
                }
            }

            .flatMap { [unowned self] subjects in
                self.searchController.searchBar.rx.text.orEmpty
                    .throttle(0.3, scheduler: MainScheduler.instance)
                    .distinctUntilChanged()
                    .map { search in
                        subjects.filter { subject in
                            subject.subjectDescription
                                .lowercased()
                                .hasPrefix(
                                    search.lowercased()
                                        .trimmingCharacters(in: .whitespaces)
                                )
                        }
                    }
            }

            .do(onError: { print($0) })
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: cellId))
            { idx, model, cell in
                cell.textLabel?.text = model.subjectDescription
            }
            .addDisposableTo(disposeBag)

        self.tableView.rx.modelSelected(Subject.self)
            .subscribe(onNext: { subject in
                let vc = RUSOCSubjectViewController.instantiate(
                    withStoryboard: self.storyboard!,
                    subject: subject,
                    courses: self.courses.filter { $0.subject == subject.code }
                )
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .addDisposableTo(disposeBag)
    }
}
