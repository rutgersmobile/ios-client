//
//  EZTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALTableViewController.h"
@class EZTableViewSection;
@class EZTableViewAbstractRow;

@interface EZTableViewController : ALTableViewController

-(void)addSection:(EZTableViewSection *)section;
-(void)insertSection:(EZTableViewSection *)section atIndex:(NSInteger)index;
-(void)replaceSection:(EZTableViewSection *)oldSection withSection:(EZTableViewSection *)newSection;
-(void)replaceSectionAtIndex:(NSInteger)index withSection:(EZTableViewSection *)section;
-(void)reloadSection:(EZTableViewSection *)section;
-(void)reloadSectionAtIndex:(NSInteger)index;
-(void)removeAllSections;

-(NSInteger)indexOfSection:(EZTableViewSection *)section;
-(EZTableViewSection *)sectionAtIndex:(NSInteger)index;

@property (nonatomic) NSMutableArray *sections;

- (EZTableViewSection *)sectionInTableView:(UITableView *)tableView atIndex:(NSInteger)section;
- (EZTableViewAbstractRow *)rowInTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath;

-(void)startNetworkLoad NS_REQUIRES_SUPER;
-(void)networkLoadSucceeded NS_REQUIRES_SUPER;
-(void)networkLoadFailed NS_REQUIRES_SUPER;
@end
