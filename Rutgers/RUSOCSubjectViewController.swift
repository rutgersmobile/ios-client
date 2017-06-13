//
//  RUSOCSubjectViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift

class RUSOCSubjectViewController : UITableViewController {
    var subject: Subject!
    var courses: [Course]!
    var options: SOCOptions!
    
    let cellId = "RUSOCSubjectViewControllerId"
    
    let disposeBag = DisposeBag()
    
    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        subject: Subject,
        courses: [Course],
        options: SOCOptions
        ) -> RUSOCSubjectViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCSubjectViewController"
            ) as! RUSOCSubjectViewController
        
        me.subject = subject
        me.courses = courses
        me.options = options
        return me
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        
        Observable.of(courses)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(
                cellIdentifier: cellId,
                cellType: RUSOCSubjectCell.self
            )) { idx, model, cell in
                /*
                cell.courseLabel.text = "\(model.courseNumber): \(model.title)"
                cell.creditsLabel.text = "\(model.credits.map { Int($0) } ?? 0)"
                
                cell.sectionsLabel.text =
                "\(model.sectionCheck.open) / \(model.sectionCheck.total)"*/
            }
            .addDisposableTo(disposeBag)
        
        self.tableView.rx.modelSelected(Course.self)
            .subscribe(onNext: { course in
            
                RutgersAPI.sharedInstance.getSections(semester: self.options.semester, campus: self.options.campus, level: self.options.level, course: course).observeOn(MainScheduler.asyncInstance).bind(onNext: { sections in
                    
                    let vc = RUSOCCourseViewController.instantiate(
                        withStoryboard: self.storyboard!,
                        course: course,
                        sections: sections
                    )
                    
                    self.navigationController?
                        .pushViewController(vc, animated: true)
 
                }).addDisposableTo(self.disposeBag)
            }).addDisposableTo(disposeBag)
    }
}
