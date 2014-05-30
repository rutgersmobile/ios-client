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

@interface EZTableViewController : ALTableViewController
-(void)addSection:(EZTableViewSection *)section;
-(void)insertSection:(EZTableViewSection *)section atIndex:(NSInteger)index;
-(void)removeAllSections;
@end
