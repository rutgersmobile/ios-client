//
//  RUContainerController.h
//  Rutgers
//
//  Created by Open Systems Solutions on 7/20/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RUContainerController <NSObject>
+(id<RUContainerController>)containerWithContainedViewController:(UIViewController *)containedViewController drawerViewController:(UIViewController *)drawerViewController;
@property (nonatomic) UIViewController *containedViewController;
-(void)closeDrawer;
-(void)openDrawer;
@end

