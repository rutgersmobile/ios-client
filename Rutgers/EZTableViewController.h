//
//  EZTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EZTableViewSection;

@interface EZTableViewController : UITableViewController
-(void)addSection:(EZTableViewSection *)section;
-(void)insertSection:(EZTableViewSection *)section atIndex:(NSInteger)index;
-(void)removeAllSections;
@end
