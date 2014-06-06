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

#define ACTIVE_TIMER_INTERVAL 60.0

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
//@property NSTimer *timer;
@property (nonatomic) UISearchDisplayController *searchController;

@property NSArray *searchResults;
@property dispatch_group_t searchingGroup;
@property CLLocation *lastLocation;

@end

@implementation RUBusViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUBusViewController alloc] init];
}
-(instancetype)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.busData = [RUBusData sharedInstance];
        self.searchingGroup = dispatch_group_create();
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self loadAgency];
    [self startTimer];

    [self.navigationController setToolbarHidden:NO animated:NO];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self setupSearchController];
    [self setupBottomBar];
}
-(void)startTimer{
    __weak typeof(self) weakSelf = self;
    [weakSelf reloadActiveStopsAndRoutes];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ACTIVE_TIMER_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf startTimer];
    });
}
-(void)setupSearchController{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableHeaderView = searchBar;

}
-(void)setupBottomBar{
    /// segmented bar setup
    NSArray *segItemsArray = @[@"Routes",@"Stops",@"All"];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [segmentedControl addTarget:self action:@selector(segmentedControlButtonChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 290, 30);
    
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, flexibleSpace, nil];
    
    [self setToolbarItems:barArray];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{busLastPaneKey: @(1)}];
    
    RUBusVCPane lastPane = [userDefaults integerForKey:busLastPaneKey];
    
    segmentedControl.selectedSegmentIndex = lastPane;
    [self segmentedControlButtonChanged:segmentedControl];
}

-(void)dealloc{
   // [self.timer invalidate];
}
-(void)locationManager:(RULocationManager *)manager didUpdateLocation:(CLLocation *)location{
    self.lastLocation = location;
    [self updateNearbyStopsWithLocation:location];
}
-(void)updateNearbyStopsWithLocation:(CLLocation *)location{
    if (!location) return;
    [self.busData getStopsNearLocation:location completion:^(NSArray *nearbyStops) {
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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[RULocationManager sharedLocationManager] addDelegatesObject:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[RULocationManager sharedLocationManager] removeDelegatesObject:self];
}
-(void)loadAgency{
    [self.busData getAgencyConfigWithCompletion:^(NSDictionary *allStops, NSDictionary *allRoutes) {
       // self.allStops = allStops;
     //   self.allRoutes = allRoutes;
 
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
-(void)reloadActiveStopsAndRoutes{
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - segmented control

-(void)segmentedControlButtonChanged:(UISegmentedControl *)segmentedControl{    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    self.currentPane = segmentedControl.selectedSegmentIndex;
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentPane forKey:busLastPaneKey];
}

#pragma mark - search bar
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    dispatch_group_enter(self.searchingGroup);
    [self.navigationController setToolbarHidden:YES animated:NO];
}
-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    dispatch_group_leave(self.searchingGroup);
    [self.navigationController setToolbarHidden:NO animated:YES];
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
-(id)itemForSection:(NSInteger)section inTableView:(UITableView *)tableView{
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
        if (section == 0) {
            return self.searchResults;
        } else {
            return nil;
        }
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
        return nil;//@"Search Results";
    }
    return nil;
}
-(id)itemForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView{
    return [self itemForSection:indexPath.section inTableView:tableView][indexPath.row];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self itemForSection:section inTableView:tableView] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    id itemForCell = [self itemForIndexPath:indexPath inTableView:tableView];
    
    cell.textLabel.text = [itemForCell title];
    if ([itemForCell active]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:[self itemForIndexPath:indexPath inTableView:tableView]] animated:YES];
}
@end
