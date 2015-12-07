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

/**
 *  This is for a more sophisticated analytics system that details all the user interaction events
 *  Here you would recieve the segment that was tapped on, and return details about it to send to the analytics server
 *  @return A dictionary containing details about segment that was selected
 */
-(NSDictionary *)userInteractionForSegmentAtIndex:(NSInteger)segmentIndex;
@end
