//
//  RURootViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RUDrawerViewController;

@protocol RUMenuDelegate <NSObject>
@required
-(void)menu:(RUDrawerViewController *)menu didSelectChannel:(NSDictionary *)channel;
//- (void)menuButtonTapped;
@end

@interface RUMenuController : NSObject
-(UIViewController *)makeMenu;
@end
