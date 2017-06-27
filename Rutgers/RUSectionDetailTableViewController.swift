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

class RUSOCDetailCell: UITableViewCell {
    
}

class RUSOCLocationCell: UITableViewCell {
    
}

class RUSOCSectionDetailCell: UITableViewCell {
    
}

class RUSOCSectionDetailTableViewController: UITableViewController {
    
    var section: Section!
    let disposeBag = DisposeBag()
    
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
        
        
        let dataSource = RxTableViewSectionedReloadDataSource<MultiSection>()
        
        dataSource.configureCell = { (
            ds: TableViewSectionedDataSource<MultiSection>,
            tv: UITableView,
            idxPath: IndexPath,
            item: SOCSectionDetailItem
            ) in
            switch dataSource[idxPath] {
            case let .noteSectionItem(section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "notesCell",
                    for: idxPath
                )
                
                print(section)
                cell.textLabel?.text = "Section notes go here"
                
                cell.setupCellLayout()
                return cell
            case let .sectionItem(section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "sectionCell",
                    for: idxPath
                    )
                
                cell.textLabel!.text = "Section \(section.number)"
                
                
                cell.setupCellLayout()
                return cell
            case let .defaultItem(item):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "defaultCell",
                    for: idxPath
                )
                
                switch item{
                case is MeetingTime:
                    let item = item as! MeetingTime
                    
                    if let day = item.meetingDay {
                        cell.textLabel?.text = day
                    }
                    
                    if let startTime = item.startTime {
                        cell.detailTextLabel?.text = "\(startTime)-\(item.endTime!)"
                    } else {
                        cell.detailTextLabel?.text = ""
                    }
                    
                default:
                    cell.textLabel?.text = "\(item)"
                }
                cell.setupCellLayout()
                return cell
            case let .locationItem(section):
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "locationCell",
                    for: idxPath
                )
                
                cell.textLabel?.text = "\(section.sectionIndex)"
                
                cell.setupCellLayout()
                return cell
            }
            
        }
        
        dataSource.titleForHeaderInSection = { (ds, idxPath) in
            ds.sectionModels[idxPath].title
        }
        
        let toDrive: [MultiSection] =
            [
            .HeaderSection(
                items: [.noteSectionItem(section: self.section),
                        .sectionItem(section: self.section)]),
            .MeetingTimesSection(title: "Meeting Times",
                                 items:
                                    self.section
                                        .meetingTimes
                                        .map{.defaultItem(item:$0)}),
            .LocationSection(title: "Locations",
                              items: [.locationItem(section: self.section)])
            
            ]
        
        Observable.just(toDrive)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView!.rx.items(dataSource: dataSource))
            .addDisposableTo(self.disposeBag)
        }
    }


private enum MultiSection {
    case HeaderSection(items: [SOCSectionDetailItem])
    case MeetingTimesSection(title: String, items: [SOCSectionDetailItem])
    case LocationSection(title: String, items: [SOCSectionDetailItem])
}

private enum SOCSectionDetailItem {
    case noteSectionItem(section: Section)
    case sectionItem(section: Section)
    case defaultItem(item: Any)
    case locationItem(section: Section)
}

extension MultiSection: SectionModelType {
    
    var items: [SOCSectionDetailItem] {
        switch self {
        case .HeaderSection(items: let items):
            return items
        case .MeetingTimesSection(title: _, items: let items):
            return items
        case .LocationSection(title: _, items: let items):
            return items
        }
    }
    
    var title: String {
        switch self {
        case .HeaderSection(items: _):
            return ""
        case .MeetingTimesSection(title: let title, items: _):
            return title
        case .LocationSection(title: let title, items: _):
            return title
        }
    }
    
    init(original: MultiSection, items: [SOCSectionDetailItem]) {
        switch original {
        case let .HeaderSection(items: items):
            self = .HeaderSection(items: items)
        case let .MeetingTimesSection(title: title, items: _):
            self = .MeetingTimesSection(title: title, items: items)
        case let .LocationSection(title: title, items: _):
            self = .LocationSection(title: title, items: items)
        }
    }
}
