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
-(void)menu:(RUMenuViewController *)menu didSelectItem:(NSDictionary *)item;
@end

@interface RUMenuViewController : TableViewController
@property id <RUMenuDelegate> delegate; // where is the delegate set ? :: with in the RURootViewController
@end
