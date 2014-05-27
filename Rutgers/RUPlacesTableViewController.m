//
//  RUPlacesTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlacesTableViewController.h"
#import "RUPlacesData.h"
#import "RUPlaceDetailTableViewController.h"
#import "RULocationManager.h"

NSString *const placesSavedSearchTextKey = @"placesSavedSearchTextKey";

@interface RUPlacesTableViewController () <UISearchDisplayDelegate, RULocationManagerDelegate>
@property (nonatomic) RUPlacesData *placesData;
@property (nonatomic) UISearchDisplayController *searchController;
@property dispatch_group_t searchingGroup;
@property NSArray *nearbyPlaces;
@property NSArray *searchResults;
@property NSArray *recentPlaces;

@end

@implementation RUPlacesTableViewController
+(instancetype)component{
    return [[RUPlacesTableViewController alloc] init];
}
-(id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.placesData = [RUPlacesData sharedInstance];
        self.searchingGroup = dispatch_group_create();
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableHeaderView = searchBar;

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

-(void)dealloc{
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateRecentPlaces:(NSArray *)recentPlaces{
    dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        self.recentPlaces = recentPlaces;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    });
}
-(void)locationManager:(RULocationManager *)manager didUpdateLocation:(CLLocation *)location{
    [self.placesData placesNearLocation:location completion:^(NSArray *nearbyPlaces) {
        dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            self.nearbyPlaces = nearbyPlaces;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        });
    }];
}

#pragma mark - search display controller

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    dispatch_group_enter(self.searchingGroup);
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
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
-(NSArray *)itemForSection:(NSInteger)section{
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
}
-(id)itemForIndexPath:(NSIndexPath *)indexPath{
    return [self itemForSection:indexPath.section][indexPath.row];
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
    if (tableView == self.tableView) {
        return [[self itemForSection:section] count];
    } else if (tableView == self.searchController.searchResultsTableView) {
        return self.searchResults.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSDictionary *itemForCell;

    if (tableView == self.tableView) {
        switch (indexPath.section) {
            case 0:
                itemForCell = self.nearbyPlaces[indexPath.row];
                break;
            case 1:
                itemForCell = self.recentPlaces[indexPath.row];
                break;
            default:
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        itemForCell = self.searchResults[indexPath.row];
    }
    cell.textLabel.text = itemForCell[@"title"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *itemForCell;

    if (tableView == self.tableView) {
        switch (indexPath.section) {
            case 0:
                itemForCell = self.nearbyPlaces[indexPath.row];
                [self.placesData addPlaceToRecentPlacesList:itemForCell];
                break;
            case 1:
                itemForCell = self.recentPlaces[indexPath.row];
                break;
            default:
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        itemForCell = self.searchResults[indexPath.row];
        [self.placesData addPlaceToRecentPlacesList:itemForCell];
    }

    RUPlaceDetailTableViewController *detailVC = [[RUPlaceDetailTableViewController alloc] initWithPlace:itemForCell];
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
        return @"Search Results";
    }
    return nil;
}

@end
