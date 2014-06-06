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

static NSString *const placesSavedSearchTextKey = @"placesSavedSearchTextKey";

@interface RUPlacesViewController () <UISearchDisplayDelegate, RULocationManagerDelegate>
@property (nonatomic) RUPlacesData *placesData;
@property (nonatomic) UISearchDisplayController *searchController;
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
        self.placesData = [RUPlacesData sharedInstance];
        self.searchingGroup = dispatch_group_create();
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearchController];
}

-(void)setupSearchController{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ALTableViewRightDetailCell"];
    
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
        #define MAX_SEARCH_RESULTS 40
        return self.searchResults.count <= MAX_SEARCH_RESULTS ? self.searchResults.count : MAX_SEARCH_RESULTS;
    }
    return 0;
}

-(NSString *)identifierForRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    return @"ALTableViewRightDetailCell";
}
-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *itemForCell;
    
    if (tableView == self.tableView) {
        itemForCell = [self itemForIndexPath:indexPath];
    } else if (tableView == self.searchController.searchResultsTableView) {
        itemForCell = self.searchResults[indexPath.row];
    }
    cell.textLabel.text = itemForCell[@"title"];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *itemForCell;

    if (tableView == self.tableView) {
        itemForCell = [self itemForIndexPath:indexPath];
        if (indexPath.section == 0) {
            [self.placesData addPlaceToRecentPlacesList:itemForCell];
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        itemForCell = self.searchResults[indexPath.row];
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
