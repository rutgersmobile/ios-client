//
//  RUContainerController.h
//  Rutgers
//
//  Created by Open Systems Solutions on 7/20/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RUContainerController <NSObject>
/**
 
    MM Drawe and SW Revel use different terminology for the same view controller 
    front = center
    rear = left
 
 
    Also the contaiend view controller is placed within the container view controller
*/

/**
    The class method is used to customize the SW and MD controllers used for the left slide bar. This protocol is added to the controllers using category techniqu
    @praram draweViewController  The view contoller displayed within the slide menu bar
    @param containedViewController The view controller that holds the menu , which is the ru root vc 
 */



+(id<RUContainerController>)containerWithContainedViewController:(UIViewController *)containedViewController drawerViewController:(UIViewController *)drawerViewController;
-(void)setDrawerShouldOpenBlock:(BOOL(^)())block;
@property (nonatomic) UIViewController *containedViewController; // the front view controller that holds the drawer
-(void)closeDrawer;
-(void)openDrawer;
-(void)toogleDrawer;
-(void)setFrontViewControllerInteration:(BOOL) interaction;
@end

