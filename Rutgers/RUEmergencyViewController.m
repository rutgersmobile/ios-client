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
        [self makeSections];
    }
    return self;
}

-(void)makeSections{
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

@end
