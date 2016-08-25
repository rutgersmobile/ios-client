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
        
        let allItemsSet = NSMutableOrderedSet(array: allItems)
        let activeItemsSet = NSOrderedSet(array: visible)
        
        allItemsSet.minusOrderedSet(activeItemsSet)
        
        hidden = allItemsSet.array
    }
    
    var visible = [AnyObject]()
    var hidden = [AnyObject]()
    
    func registerReuseableViewsWithTableView(tableView: UITableView) {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override var numberOfSections: Int {
        return 2
    }
    
  

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Visible"
        } else {
            return "Hidden"
        }
    }
    
    override func numberOfItemsInSection(section: Int) -> Int {
        if section == 0 {
            return visible.count
        } else {
            return hidden.count
        }
    }
    
    override func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        if indexPath.section == 0 {
            return visible[indexPath.row]
        } else {
            return hidden[indexPath.row]
        }
    }
    
    override func registerReusableViewsWithTableView(tableView: UITableView!) {
        super.registerReusableViewsWithTableView(tableView)
        tableView.registerClass(RUMenuTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(RUMenuTableViewCell.self))
    }
    
    override func reuseIdentifierForRowAtIndexPath(indexPath: NSIndexPath!) -> String! {
        return NSStringFromClass(RUMenuTableViewCell.self)
    }
    
    override func configureCell(cell: AnyObject!, forRowAtIndexPath indexPath: NSIndexPath!) {
        let item = itemAtIndexPath(indexPath)
        let menuCell = cell as! RUMenuTableViewCell
        
        //warning move this into the cell
        switch item {
        case let favorite as RUFavorite:
            if let handle = favorite.channelHandle, channel = RUChannelManager.sharedInstance().channelWithHandle(handle) {
                menuCell.setupForChannel(channel)
                menuCell.channelTitleLabel.text = favorite.title
            }
        case let channel as [NSObject : AnyObject]:
            menuCell.setupForChannel(channel)
        default: return
        }
    }
    
    ///Editing
    
    func removeItemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        if indexPath.section == 0 {
            return visible.removeAtIndex(indexPath.row)
        } else {
            return hidden.removeAtIndex(indexPath.row)
        }
    }
    
    func insertItem(item: AnyObject, atIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            visible.insert(item, atIndex: indexPath.row)
        } else {
            hidden.insert(item, atIndex: indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .Delete
        } else {
            return .Insert
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        
        let item = removeItemAtIndexPath(sourceIndexPath)
        insertItem(item, atIndexPath: destinationIndexPath)
        
        tableView.reloadData()
        
        invalidateCachedHeights()
        saveChanges()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.beginUpdates()
        
        switch editingStyle {
        case .Insert:
            let item = removeItemAtIndexPath(indexPath)
            visible.append(item)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            let indexPath = NSIndexPath(forRow: visible.count - 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        case .Delete:
            let item = removeItemAtIndexPath(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            if !(item is RUFavorite) {
                hidden.insert(item, atIndex: 0)
                let indexPath = NSIndexPath(forRow: 0, inSection: 1)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
        case .None: fatalError()
        }
        
        tableView.endUpdates()
        
        invalidateCachedHeights()
        saveChanges()
    }
    
    
    func saveChanges() {
        RUMenuItemManager.sharedManager.menuItems = visible
    }
}