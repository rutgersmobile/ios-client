//
//  ALTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALTableViewAbstractCell;

@interface ALTableViewController : UIViewController <UISearchDisplayDelegate, NetworkContentLoadingStateMachineDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithStyle:(UITableViewStyle)style;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIRefreshControl *refreshControl;



@property (nonatomic) UISearchDisplayController *searchController;
-(void)enableSearch;

@property (nonatomic) NetworkContentLoadingStateMachine * contentLoadingStateMachine;
-(void)setupContentLoadingStateMachine;
@end
