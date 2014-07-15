//
//  RUBusViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusViewController.h"
#import "RUBusData.h"
#import "RUBusStop.h"
#import "RUBusRoute.h"
#import "RUPredictionsViewController.h"
#import "NSArray+RUBusStop.h"
#import "RULocationManager.h"
#import "ALTableViewRightDetailCell.h"
#import <MSWeakTimer.h>

#define ACTIVE_TIMER_INTERVAL 2*60.0

static NSString *const busLastPaneKey = @"busLastPaneKey";

typedef enum : NSUInteger {
    RUBusVCRoutesPane = 0,
    RUBusVCStopsPane = 1,
    RUBusVCAllPane = 2
} RUBusVCPane;


@interface RUBusViewController () <UISearchDisplayDelegate, RULocationManagerDelegate>
@property (nonatomic) RUBusData *busData;

@property NSDictionary *allStops;
@property NSDictionary *allRoutes;

@property NSDictionary *activeStops;
@property NSDictionary *activeRoutes;
@property NSArray *nearbyStops;

@property RUBusVCPane currentPane;
@property UISegmentedControl *segmentedControl;

@property BOOL searching;

@property NSArray *searchResults;
@property dispatch_group_t searchingGroup;
@property CLLocation *lastLocation;

@property MSWeakTimer *timer;

@end

@implementation RUBusViewController

+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUBusViewController alloc] init];
}

-(instancetype)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.searchingGroup = dispatch_group_create();
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.busData = [RUBusData sharedInstance];

    [self loadAgency];
    [self loadActiveStopsAndRoutes];
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:ACTIVE_TIMER_INTERVAL target:self selector:@selector(loadActiveStopsAndRoutes) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    
    [self enableSearch];
    [self setupToolbar];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.searching) {
        [self.navigationController setToolbarHidden:NO animated:NO];
    }
    [[RULocationManager sharedLocationManager] addDelegatesObject:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[RULocationManager sharedLocationManager] removeDelegatesObject:self];
}

#pragma mark - Bus Data Source Methods
-(void)loadAgency{
    [self.busData getAgencyConfigWithCompletion:^(NSDictionary *allStops, NSDictionary *allRoutes) {
        [self.tableView beginUpdates];
        self.allStops = allStops;
        self.allRoutes = allRoutes;
        switch (self.currentPane) {
            case RUBusVCAllPane:
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
        [self.tableView endUpdates];
    }];
}

-(void)loadActiveStopsAndRoutes{
    [self.busData getActiveStopsAndRoutesWithCompletion:^(NSDictionary *activeStops, NSDictionary *activeRoutes) {
        dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            self.activeRoutes = activeRoutes;
            self.activeStops = activeStops;
            switch (self.currentPane) {
                case RUBusVCRoutesPane:
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                case RUBusVCStopsPane:
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
                    [self updateNearbyStopsWithLocation:self.lastLocation];
                    break;
                case RUBusVCAllPane:
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                default:
                    break;
            }
            [self.tableView endUpdates];
        });
    }];
}

#pragma mark - Location Manager Methods
-(void)locationManager:(RULocationManager *)manager didUpdateLocation:(CLLocation *)location{
    self.lastLocation = location;
    [self updateNearbyStopsWithLocation:location];
}

-(void)updateNearbyStopsWithLocation:(CLLocation *)location{
    [self.busData getActiveStopsNearLocation:location completion:^(NSArray *nearbyStops) {
        dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
            self.nearbyStops = nearbyStops;
            if (self.currentPane == RUBusVCStopsPane) {
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
        });
    }];
}

#pragma mark - Segmented Control

-(void)segmentedControlButtonChanged:(UISegmentedControl *)segmentedControl{    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    self.currentPane = segmentedControl.selectedSegmentIndex;
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentPane forKey:busLastPaneKey];
}

-(void)setupToolbar{
    /// segmented bar setup
    NSArray *segItemsArray = @[@"Routes",@"Stops",@"All"];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlButtonChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.frame = CGRectMake(0, 0, 290, 30);
    
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, flexibleSpace, nil];
    [self setToolbarItems:barArray];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{busLastPaneKey: @(1)}];
    
    RUBusVCPane lastPane = [userDefaults integerForKey:busLastPaneKey];
    
    self.segmentedControl.selectedSegmentIndex = lastPane;
    [self segmentedControlButtonChanged:self.segmentedControl];
}

#pragma mark - Search Bar
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    dispatch_group_enter(self.searchingGroup);
    [super searchDisplayControllerWillBeginSearch:controller];
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.searching = YES;
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    self.searching = NO;
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super searchDisplayControllerWillEndSearch:controller];
    dispatch_group_leave(self.searchingGroup);
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self.busData queryStopsAndRoutesWithString:searchString completion:^(NSArray *results) {
        self.searchResults = results;
        [self.searchController.searchResultsTableView reloadData];
    }];
    return NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        switch (self.currentPane) {
            case RUBusVCRoutesPane:
                return 2;
                break;
            case RUBusVCStopsPane:
                return 3;
                break;
            default:
                return 4;
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        return 1;
    }
    return 0;
}
-(id)itemsForSection:(NSInteger)section inTableView:(UITableView *)tableView{
    if (tableView == self.tableView) {
        switch (self.currentPane) {
            case RUBusVCRoutesPane:
                switch (section) {
                    case 0:
                        return self.activeRoutes[newBrunswickAgency];
                        break;
                    case 1:
                        return self.activeRoutes[newarkAgency];
                        break;
                    default:
                        return nil;
                        break;
                }
                break;
            case RUBusVCStopsPane:
                switch (section) {
                    case 0:
                        return self.nearbyStops;
                        break;
                    case 1:
                        return self.activeStops[newBrunswickAgency];
                        break;
                    case 2:
                        return self.activeStops[newarkAgency];
                        break;
                    default:
                        return nil;
                        break;
                }
                break;
            case RUBusVCAllPane:
                switch (section) {
                    case 0:
                        return self.allRoutes[newBrunswickAgency];
                        break;
                    case 1:
                        return self.allStops[newBrunswickAgency];
                        break;
                    case 2:
                        return self.allRoutes[newarkAgency];
                        break;
                    case 3:
                        return self.allStops[newarkAgency];
                        break;
                    default:
                        return nil;
                        break;
                }
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
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        
        switch (self.currentPane) {
            case RUBusVCRoutesPane:
                switch (section) {
                    case 0:
                        return @"New Brunswick Active Routes";
                        break;
                    case 1:
                        return @"Newark Active Routes";
                        break;
                    default:
                        return nil;
                        break;
                }
                break;
            case RUBusVCStopsPane:
                switch (section) {
                    case 0:
                        return @"Nearby Active Stops";
                        break;
                    case 1:
                        return @"New Brunswick Active Stops";
                        break;
                    case 2:
                        return @"Newark Active Stops";
                        break;
                    default:
                        return nil;
                        break;
                }
                break;
            case RUBusVCAllPane:
                switch (section) {
                    case 0:
                        return @"All New Brunswick Routes";
                        break;
                    case 1:
                        return @"All New Brunswick Stops";
                        break;
                    case 2:
                        return @"All Newark Routes";
                        break;
                    case 3:
                        return @"All Newark Stops";
                        break;
                    default:
                        return nil;
                        break;
                }
                break;
            default:
                return nil;
                break;
        }
        
    } else if (tableView == self.searchController.searchResultsTableView) {
        return @"All Stops and Routes";
    }
    return nil;
}
-(id)itemForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView{
    return [self itemsForSection:indexPath.section inTableView:tableView][indexPath.row];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self itemsForSection:section inTableView:tableView] count];
}
-(NSString *)identifierForCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    return @"ALTableViewRightDetailCell";
}
-(void)setupCell:(ALTableViewRightDetailCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    id itemForCell = [self itemForIndexPath:indexPath inTableView:tableView];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [itemForCell title];
    if ([itemForCell active]) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:[self itemForIndexPath:indexPath inTableView:tableView]] animated:YES];
}
@end
