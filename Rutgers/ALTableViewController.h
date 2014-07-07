//
//  ALTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALTableViewAbstractCell;

@interface ALTableViewController : UITableViewController <UISearchDisplayDelegate>
-(ALTableViewAbstractCell *)layoutCellWithIdentifier:(NSString *)identifier;
-(NSString *)identifierForRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic) UISearchDisplayController *searchController;
-(void)enableSearch;
@end
