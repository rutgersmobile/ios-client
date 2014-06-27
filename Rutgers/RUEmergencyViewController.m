//
//  RUEmergencyViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUEmergencyViewController.h"
#import "EZCollectionViewSection.h"
#import "TileCollectionViewItem.h"
#import "RUOperatingStatusViewController.h"
#import "RUChannelManager.h"

@interface RUEmergencyViewController ()

@end

@implementation RUEmergencyViewController

+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUEmergencyViewController alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        EZCollectionViewSection *section = [[EZCollectionViewSection alloc] init];
        
        NSString *emergencyAlertTitle = @"Emergency Alerts";
        TileCollectionViewItem *alertsItem = [[TileCollectionViewItem alloc] initWithText:emergencyAlertTitle];
        alertsItem.didSelectItemBlock = ^ {
            RUOperatingStatusViewController *operatingStatusVc = [[RUOperatingStatusViewController alloc] init];
            operatingStatusVc.title = emergencyAlertTitle;
            [self.navigationController pushViewController:operatingStatusVc animated:YES];
        };
    
        NSString *actionPlanTitle = @"Emergency Action Plans";
        TileCollectionViewItem *actionPlanItem = [[TileCollectionViewItem alloc] initWithText:actionPlanTitle];
        actionPlanItem.didSelectItemBlock = ^ {
            [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : actionPlanTitle, @"view" : @"www", @"url" : @"http://halflife.rutgers.edu/eap/mobile.php"}] animated:YES];
        };
        
        [section addItems:@[alertsItem,actionPlanItem]];
        
        [self addSection:section];

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
