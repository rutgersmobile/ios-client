//
//  RUEditMenuItemsDataSource.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

class RUEditMenuItemsDataSource: DataSource, UITableViewDelegate {
    //let activeMenuItemsDataSource = RUMenuBasicDataSource()
    //let inactiveMenuItemsDataSource = RUMenuBasicDataSource()
    
    override init() {
        super.init()
        
        visible = RUMenuItemManager.sharedManager.menuItems
        
        let allItems = RUChannelManager.sharedInstance().contentChannels
        
        let allItemsSet = NSMutableOrderedSet(array: allItems!)
        let activeItemsSet = NSOrderedSet(array: visible)
        
        allItemsSet.minus(activeItemsSet)
        
        hidden = allItemsSet.array as [AnyObject]
    }
    
    var visible = [AnyObject]()
    var hidden = [AnyObject]()
    
    func registerReuseableViewsWithTableView(tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override var numberOfSections: Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Visible"
        } else {
            return "Hidden"
        }
    }
    
    override func numberOfItems(inSection section: Int) -> Int {
        if section == 0 {
            return visible.count
        } else {
            return hidden.count
        }
    }
    
    override func item(at indexPath: IndexPath!) -> Any! {
        if indexPath.section == 0 {
            return visible[indexPath.row]
        } else {
            return hidden[indexPath.row]
        }
    }
    
    override func registerReusableViews(with tableView: UITableView!) {
        super.registerReusableViews(with: tableView)
        tableView.register(RUMenuTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(RUMenuTableViewCell.self))
    }
    
    override func reuseIdentifierForRow(at indexPath: IndexPath!) -> String! {
        return NSStringFromClass(RUMenuTableViewCell.self)
    }
    
    override func configureCell(_ cell: Any!, forRowAt indexPath: IndexPath!) {
        let indexItem = item(at: indexPath as IndexPath!)
        let menuCell = cell as! RUMenuTableViewCell
        
        //warning move this into the cell
        switch indexItem {
        case let favorite as RUFavorite:
            if let handle = favorite.channelHandle, let channel = RUChannelManager.sharedInstance().channel(withHandle: handle) {
                menuCell.setup(forChannel: channel)
                menuCell.channelTitleLabel.text = favorite.title
            }
        case let channel as [NSObject : AnyObject]:
            menuCell.setup(forChannel: channel)
        default: return
        }
    }
    
    ///Editing
    
    func removeItemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        if indexPath.section == 0 {
            return visible.remove(at: indexPath.row)
        } else {
            return hidden.remove(at: indexPath.row)
        }
    }
    
    func insertItem(item: AnyObject, atIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            visible.insert(item, at: indexPath.row)
        } else {
            hidden.insert(item, at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .delete
        } else {
            return .insert
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }

        let item = removeItemAtIndexPath(indexPath: sourceIndexPath as NSIndexPath)
        insertItem(item: item, atIndexPath: destinationIndexPath as NSIndexPath)
        
        tableView.reloadData()
        
        invalidateCachedHeights()
        saveChanges()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        switch editingStyle {
        case .insert:
            let item = removeItemAtIndexPath(indexPath: indexPath as NSIndexPath)
            visible.append(item)
            tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            
            let indexPath = IndexPath(row: visible.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .fade)
            
        case .delete:
            let item = removeItemAtIndexPath(indexPath: indexPath as NSIndexPath)
            tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            
            if !(item is RUFavorite) {
                hidden.insert(item, at: 0)
                let indexPath = IndexPath(row: 0, section: 1)
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            
        case .none: fatalError()
        }
        
        tableView.endUpdates()
        
        invalidateCachedHeights()
        saveChanges()
    }
    
    
    func saveChanges() {
        RUMenuItemManager.sharedManager.menuItems = visible
    }
}
