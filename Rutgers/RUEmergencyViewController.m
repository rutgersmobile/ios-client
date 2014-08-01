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
#import "TileDataSource.h"

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
    NSString *emergencyAlertTitle = @"Emergency Alerts";
    TileCollectionViewItem *alertsItem = [[TileCollectionViewItem alloc] initWithTitle:emergencyAlertTitle object:nil];
 
    NSString *actionPlanTitle = @"Emergency Action Plans";
    TileCollectionViewItem *actionPlanItem = [[TileCollectionViewItem alloc] initWithTitle:actionPlanTitle object:nil];
   
    self.dataSource = [[TileDataSource alloc] initWithItems:@[alertsItem,actionPlanItem]];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TileCollectionViewItem *item = [self.dataSource itemAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        RUOperatingStatusViewController *operatingStatusVc = [[RUOperatingStatusViewController alloc] init];
        operatingStatusVc.title = item.title;
        [self.navigationController pushViewController:operatingStatusVc animated:YES];
    } else if (indexPath.row == 1) {
        [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : item.title, @"view" : @"www", @"url" : @"http://halflife.rutgers.edu/eap/mobile.php"}] animated:YES];
    }
}


@end
