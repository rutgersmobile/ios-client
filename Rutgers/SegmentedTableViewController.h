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

/*
     set as a property so that the collision between swipe gesture in the RUBUSViewController for the segmented controls are the pan gesture that opens the drawer can be prevented.

    Used by the RURootController to set up a should require failure relationship between the swipe gestures and the pan , such that the pan gesture is called only if the swipe gesture is either not present or has failed
 */
@property (nonatomic) UISwipeGestureRecognizer *leftSwipe;
@property (nonatomic) UISwipeGestureRecognizer *rightSwipe;

/**
 *  This is for a more sophisticated analytics system that details all the user interaction events
 *  Here you would recieve the segment that was tapped on, and return details about it to send to the analytics server
 *  @return A dictionary containing details about segment that was selected
 */
-(NSDictionary *)userInteractionForSegmentAtIndex:(NSInteger)segmentIndex;

-(void)configureSegmentedControl;

@end
