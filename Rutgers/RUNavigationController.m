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

<<<<<<< HEAD
@synthesize  preferredStatusBarStyle = _preferredStatusBarStyle;
=======
@synthesize preferredStatusBarStyle =  _preferredStatusBarStyle ;
>>>>>>> db5b9ae141176d686ca0e418bd7e492d24df1d40

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
