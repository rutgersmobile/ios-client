//
//  RUSectionDetailTableViewController.swift
//  Rutgers
//
//  Created by Colin Walsh on 6/26/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class RUSOCSectionDetailTableViewController: UITableViewController {
    
    var section: Section!
    
    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        section: Section
        ) -> RUSOCSectionDetailTableViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCSectionDetailViewController"
            ) as! RUSOCSectionDetailTableViewController
        
        me.section = section
        
        return me
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = nil
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionDetailSection>()
        
        dataSource.configureCell = { (
            ds: TableViewSectionedDataSource<SectionDetailSection>,
            tv: UITableView,
            ip: IndexPath,
            item: SectionDetailItem
            ) in
            switch item {
            case .section(let section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "sectionCell",
                    for: ip
                    )
                
                cell.setupCellLayout()
                return cell
            case .detail(let section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "defaultCell",
                    for: ip
                )
                
                cell.detailTextLabel?.text = section.instructors[0].instructorName 
                cell.textLabel?.text = "Intructors"
                
                cell.setupCellLayout()
                return cell
            case .location(let section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "locationCell",
                    for: ip
                )
                cell.setupCellLayout()
                return cell
            }
        }
        
        
    }
}

struct SectionDetailSection {
    var title: String
    var items: [Item]
    
    init(title: String, items: [Item]) {
        self.title = title
        self.items = items
    }
}

enum SectionDetailItem {
    case section(Section)
    case detail(Section)
    case location(Section)
}

extension SectionDetailSection: SectionModelType {
    typealias Item = SectionDetailItem
    
    init(original: SectionDetailSection, items: [Item]) {
        self = original
        self.items = items
    }
}
