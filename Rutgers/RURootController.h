//
//  RURootViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUContainerController.h"


#import "SWRevealViewController.h"

@interface RURootController : NSObject
+(instancetype)sharedInstance;

//-(void)openDrawer;
-(void)openDrawerIfNeeded;
-(void)openURL:(NSURL *)url;

-(void)openDrawer;

@property (nonatomic) UIViewController <RUContainerController> *containerViewController;
@property (nonatomic) id selectedItem;
@property (nonatomic) UIBarButtonItem *menuBarButtonItem;
@end
