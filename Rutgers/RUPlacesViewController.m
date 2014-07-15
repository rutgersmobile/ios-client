//
//  RUPlacesTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlacesViewController.h"
#import "RUPlacesData.h"
#import "RUPlaceDetailViewController.h"
#import "RULocationManager.h"
#import "ALTableViewRightDetailCell.h"
#import "RUPlace.h"

static NSString *const placesSavedSearchTextKey = @"placesSavedSearchTextKey";

@interface RUPlacesViewController () <UISearchDisplayDelegate, RULocationManagerDelegate>
@property (nonatomic) RUPlacesData *placesData;
@property dispatch_group_t searchingGroup;
@property NSArray *nearbyPlaces;
@property NSArray *searchResults;
@property NSArray *recentPlaces;
@end

@implementation RUPlacesViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUPlacesViewController alloc] init];
}

-(id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.placesData = [RUPlacesData sharedInstance];
    self.searchingGroup = dispatch_group_create();
    [self enableSearch];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[RULocationManager sharedLocationManager] addDelegatesObject:self];
    [self.placesData getRecentPlacesWithCompletion:^(NSArray *recentPlaces) {
        [self updateRecentPlaces:recentPlaces];
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[RULocationManager sharedLocationManager] removeDelegatesObject:self];
}

-(void)updateRecentPlaces:(NSArray *)recentPlaces{
    dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        self.recentPlaces = recentPlaces;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    });
}

-(void)locationManager:(RULocationManager *)manager didUpdateLocation:(CLLocation *)location{
    [self.placesData placesNearLocation:location completion:^(NSArray *nearbyPlaces) {
        dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            self.nearbyPlaces = nearbyPlaces;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        });
    }];
}

#pragma mark - search display controller

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [super searchDisplayControllerWillBeginSearch:controller];
    dispatch_group_enter(self.searchingGroup);
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [super searchDisplayControllerWillEndSearch:controller];
    dispatch_group_leave(self.searchingGroup);
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self.placesData queryPlacesWithString:searchString completion:^(NSArray *results) {
        self.searchResults = results;
        [self.searchController.searchResultsTableView reloadData];
    }];
    return NO;
}

#pragma mark - Table view data source
-(NSArray *)itemForSection:(NSInteger)section inTableView:(UITableView *)tableView{
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return self.nearbyPlaces;
                break;
            case 1:
                return self.recentPlaces;
                break;
            default:
                return nil;
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        return self.searchResults;
    }
    return nil;
}
-(RUPlace *)itemForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView{
    return [self itemForSection:indexPath.section inTableView:tableView][indexPath.row];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return 2;
    } else if (tableView == self.searchController.searchResultsTableView) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self itemForSection:section inTableView:tableView] count];
}

-(NSString *)identifierForCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    return @"ALTableViewRightDetailCell";
}

-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    RUPlace *itemForCell = [self itemForIndexPath:indexPath inTableView:tableView];
    
    cell.textLabel.text = itemForCell.title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUPlace *itemForCell = [self itemForIndexPath:indexPath inTableView:tableView];

    if (!(tableView == self.tableView && indexPath.section == 1)) {
        [self.placesData addPlaceToRecentPlacesList:itemForCell];
    }
    
    RUPlaceDetailViewController *detailVC = [[RUPlaceDetailViewController alloc] initWithPlace:itemForCell];
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return @"Nearby Places";
                break;
            case 1:
                return @"Recently Viewed";
                break;
            default:
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        return nil;//@"Search Results";
    }
    return nil;
}

@end
