//
//  RUNavigationController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUNavigationController.h"

@implementation RUNavigationController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.preferredStatusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

-(void)setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle{
    _preferredStatusBarStyle = preferredStatusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}
@end
