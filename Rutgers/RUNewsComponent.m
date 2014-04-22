//
//  RUNewsComponent.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUNewsComponent.h"
#import "RUNewsViewController.h"
@interface RUNewsComponent ()

@end

@implementation RUNewsComponent
 
- (id)initWithDelegate:(id <RUNewsDelegate>)delegate {
    self = [super init];
    if (self) {
        // Custom initialization
        RUNewsViewController * vc = [[RUNewsViewController alloc] initWithDelegate:delegate];
        
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
