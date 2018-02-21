//
//  RUNavigationController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

/*
 Descript:
 Might function as the nav controller on which everything is based ?
 */

#import "RUNavigationController.h"

@implementation RUNavigationController
@synthesize preferredStatusBarStyle = _preferredStatusBarStyle;


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.preferredStatusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

-(void)setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle{
    _preferredStatusBarStyle = preferredStatusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}
@end
