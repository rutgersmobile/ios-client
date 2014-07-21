//
//  EZTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@class EZDataSource;

@interface EZTableViewController : TableViewController
//-(void)setDataSource:(EZDataSource *)dataSource;
-(EZDataSource *)dataSource;

@property (nonatomic) UISearchDisplayController *searchController;
-(void)enableSearch;

@property (nonatomic) NetworkContentLoadingStateMachine *contentLoadingStateMachine;
-(void)setupContentLoadingStateMachine;
@end
