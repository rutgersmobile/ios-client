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

@interface RUPlacesViewController ()

@end

@implementation RUPlacesViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[PlacesDataSource alloc] init];
    self.searchDataSource = [[PlacesSearchDataSource alloc] init];
    self.searchBar.placeholder = @"Search All Places";
    
    self.searchBar.userInteractionEnabled = NO;
    
    __weak UISearchBar *weakSearchBar = self.searchBar;
    [[RUPlacesDataLoadingManager sharedInstance] performOnPlacesLoaded:^(NSError *error){
        weakSearchBar.userInteractionEnabled = YES;
    }];
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

@end
