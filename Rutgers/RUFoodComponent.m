//
//  RUFoodComponent.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodComponent.h"
#import "RUFoodViewController.h"

@implementation RUFoodComponent

-(id)initWithDelegate:(id<RUComponentDelegate>)delegate{
    self = [super init];
    if (self) {
        // Custom initialization
        RUFoodViewController * vc = [[RUFoodViewController alloc] initWithDelegate:delegate];
        
        [self pushViewController:vc animated:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
