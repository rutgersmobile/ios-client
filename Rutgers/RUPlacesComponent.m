//
//  RUPlacesComponent.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlacesComponent.h"
#import "RUPlacesTableViewController.h"
@interface RUPlacesComponent ()

@end

@implementation RUPlacesComponent

-(id)initWithDelegate:(id<RUPlacesDelegate>)delegate{
    self = [super init];
    if (self) {
        // Custom initialization
        RUPlacesTableViewController * vc = [[RUPlacesTableViewController alloc] initWithDelegate:delegate];
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
