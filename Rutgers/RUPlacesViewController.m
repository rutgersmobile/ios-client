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


@interface RUPlacesViewController ()

@end

@implementation RUPlacesViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[PlacesDataSource alloc] init];
    self.searchDataSource = [[PlacesSearchDataSource alloc] init];
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
/*
-(void)updateRecentPlaces:(NSArray *)recentPlaces{
    dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        self.recentPlaces = recentPlaces;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    });
}*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUPlace *place;
    if (tableView == self.tableView) {
        place = [self.dataSource itemAtIndexPath:indexPath];
    } else if (tableView == self.searchTableView) {
        place = [self.searchDataSource itemAtIndexPath:indexPath];
    }
    
    [[RUPlacesDataLoadingManager sharedInstance] userWillViewPlace:place];

    RUPlaceDetailViewController *detailVC = [[RUPlaceDetailViewController alloc] initWithPlace:place];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
