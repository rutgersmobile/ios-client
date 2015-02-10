//
//  SegmentedTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/7/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "TableViewController.h"

@interface SegmentedTableViewController : TableViewController
@property (nonatomic) UISegmentedControl *segmentedControl;
-(NSDictionary *)userInteractionForSegmentAtIndex:(NSInteger)segmentIndex;
@end
