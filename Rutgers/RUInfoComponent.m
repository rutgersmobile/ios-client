//
//  RUInfoComponent.m
//  info
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 RU. All rights reserved.
//

#import "RUInfoComponent.h"
#import "RUInfoTableViewController.h"

@interface RUInfoComponent ()

@end

@implementation RUInfoComponent
- (id)initWithDelegate:(id <RUComponentDelegate>)delegate {
    self = [super init];
    if (self) {
        // Custom initialization
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil];
        RUInfoTableViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"RUInfoTableViewController"];//[[RUInfoViewController alloc] initWithDelegate:delegate];
        vc.delegate = delegate;
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
