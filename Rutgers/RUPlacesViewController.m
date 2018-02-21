//
//  RUPlacesTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlacesViewController.h"
#import "PlacesDataSource.h"
#import "PlacesSearchDataSource.h"
#import "RUPlacesDataLoadingManager.h"
#import "RUPlaceDetailViewController.h"
#import "RULocationManager.h"
#import "RUPlace.h"
#import "TableViewController_Private.h"
#import "RUChannelManager.h"

@interface RUPlacesViewController ()

@end

@implementation RUPlacesViewController
+(NSString *)channelHandle{
    return @"places";
}
+(void)load{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[PlacesDataSource alloc] init];
    self.searchDataSource = [[PlacesSearchDataSource alloc] init];
    self.searchBar.placeholder = @"Search All Places";
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[RULocationManager sharedLocationManager] startUpdatingLocation];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[RULocationManager sharedLocationManager] stopUpdatingLocation];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUPlace *place = [[self dataSourceForTableView:tableView] itemAtIndexPath:indexPath];

    [[RUPlacesDataLoadingManager sharedInstance] userWillViewPlace:place];

    [self.navigationController pushViewController:[[RUPlaceDetailViewController alloc] initWithPlace:place] animated:YES];
}

+(NSArray *)viewControllersWithPathComponents:(NSArray *)pathComponents destinationTitle:(NSString *)destinationTitle {
    RUPlaceDetailViewController *viewController = [[RUPlaceDetailViewController alloc] initWithSerializedPlace:pathComponents.firstObject title:destinationTitle];
    return @[viewController];
}

@end
