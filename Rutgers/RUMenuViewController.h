//
//  RUMenuViewController.h
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@class RUMenuViewController;

@protocol RUMenuDelegate <NSObject>
@required
-(void)menu:(RUMenuViewController *)menu didSelectItem:(id)item;

// pass messages about opening and closing the drawer to the root view controller so that it can disable the front view user interaction appropraitely
-(void)menuWillAppear;
-(void)menuWillDisappear;

@end

@interface RUMenuViewController : TableViewController
@property id <RUMenuDelegate> delegate; // where is the delegate set ? :: with in the RURootViewController
@end
