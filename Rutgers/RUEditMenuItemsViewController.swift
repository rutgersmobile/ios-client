//
//  RUEditMenuItemsViewController.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

class RUEditMenuItemsViewController: TableViewController , RUChannelProtocol {
    
    static func channelHandle() -> String!
    {
       return "edit";
    }

 // temp solution
    
/*
        Every class is register with the RUChannelManager by calling a register class static method in the load function of each class.
        The load is called in objc on every class by the run time library...
        The load handles the registration process .
 */
    static func registerClass()
    {
            RUChannelManager.sharedInstance().registerClass(RUEditMenuItemsViewController.self)
    }

    //   // register the channel with j
    //   override class func initialize()
    //   
    //       var onceToken : dispatch_once_t = 0;
    //       dispatch_once(&onceToken)
    //       {
    //           RUChannelManager.sharedInstance().registerClass(RUEditMenuItemsViewController.self)
    //       }
    //   }
       
    static func channelWithConfiguration(channelConfiguration: [NSObject : AnyObject]!) -> AnyObject!
    {
        return RUEditMenuItemsViewController(style: .Grouped);
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.editing = true
        title = "Edit Channels"
        
        tableView.allowsSelectionDuringEditing = false ;
        
        let editDataSource = RUEditMenuItemsDataSource()
        dataSource = editDataSource
       
        // Set the background image for the edit channels
        let imageView = UIImageView(image: UIImage(named: "bg"))
        imageView.contentMode = .ScaleToFill
        tableView.backgroundView = imageView
        tableView.separatorColor = UIColor.clearColor()
        
       
        // Add edit button :: No need for the edit button as the view controller opens in the edit mode and the changes are saved ..
      //  self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .Delete
        } else {
            return .Insert
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        let item = dataSource.itemAtIndexPath(indexPath)
        if item is RUFavorite {
            return "Delete"
        } else {
            return "Hide"
        }
    }
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        let item = dataSource.itemAtIndexPath(sourceIndexPath)
        if item is RUFavorite && proposedDestinationIndexPath.section == 1 {
            return NSIndexPath(forRow: dataSource.numberOfItemsInSection(0) - 1, inSection: 0)
        } else {
            return proposedDestinationIndexPath
        }
    }
   
   //    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
   //        return nil;
   //    }
        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
        let item = self.dataSource .itemAtIndexPath(indexPath)
        
        if item is RUFavorite
        {
            print(item.url!!.absoluteString)
        }
        else
        {
            print(item.self)
            print(item.channelURL)
            print(item.channelHandle)
            print()
        }
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool
    {
        return true
    }
 
    
    
    
    
    
    
}
