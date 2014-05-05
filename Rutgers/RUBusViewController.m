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

#define ACTIVE_TIMER_INTERVAL 60.0*3

//NSString *const busSavedSearchTextKey = @"busSavedSearchTextKey";
NSString *const busLastPaneKey = @"busLastPaneKey";


typedef enum : NSUInteger {
    RUBusVCRoutesPane = 0,
    RUBusVCStopsPane = 1
} RUBusVCPane;


@interface RUBusViewController () <UISearchDisplayDelegate, RULocationManagerDelegate>
@property (nonatomic) RUBusData *busData;

@property NSDictionary *activeStops;
@property NSDictionary *activeRoutes;
@property NSDictionary *nearbyStops;

@property RUBusVCPane currentPane;

@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UISearchDisplayController *searchController;

@property NSArray *searchResults;
@property dispatch_group_t searchingGroup;

@end

@implementation RUBusViewController
-(instancetype)initWithDelegate:(id<RUComponentDelegate>)delegate{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.navigationItem.title = @"Bus";
        self.busData = [RUBusData sharedInstance];
        self.searchingGroup = dispatch_group_create();
        self.delegate = delegate;
    }
    return self;
}
-(void)setDelegate:(id<RUComponentDelegate>)delegate{
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
        // delegate expects menu button notification, so let's create and add a menu button
        UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
        self.navigationItem.leftBarButtonItem = btn;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self reloadActiveStopsAndRoutes];

    [self.navigationController setToolbarHidden:NO animated:NO];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.showsCancelButton = YES;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableHeaderView = self.searchBar;

    /// segmented bar setup
    NSArray *segItemsArray = @[@"Routes",@"Stops"];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [segmentedControl addTarget:self action:@selector(segmentedControlButtonChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 260, 30);
    
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, flexibleSpace, nil];
    
    [self setToolbarItems:barArray];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{busLastPaneKey: @(1)}];
    
    RUBusVCPane lastPane = [userDefaults integerForKey:busLastPaneKey];
    
    segmentedControl.selectedSegmentIndex = lastPane;
    [self segmentedControlButtonChanged:segmentedControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearResponders) name:@"JASidePanelWillShowLeftPanel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearResponders) name:@"JASidePanelDidBeginPanning" object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)locationManager:(RULocationManager *)manager didUpdateLocation:(CLLocation *)location{
    [self.busData stopsNearLocation:location completion:^(NSDictionary *nearbyStops) {
        dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
            self.nearbyStops = nearbyStops;
            if (self.currentPane == RUBusVCStopsPane) {
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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


-(void)reloadActiveStopsAndRoutes{
    __weak typeof(self) weakSelf = self;
    [self.busData getActiveStopsAndRoutesWithCompletion:^(NSDictionary *activeStops, NSDictionary *activeRoutes) {
        dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
            [weakSelf.tableView beginUpdates];

            weakSelf.activeRoutes = activeRoutes;
            weakSelf.activeStops = activeStops;
            switch (weakSelf.currentPane) {
                case RUBusVCRoutesPane:
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                case RUBusVCStopsPane:
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                default:
                    break;
            }
            [weakSelf.tableView endUpdates];

            double delayInSeconds = ACTIVE_TIMER_INTERVAL;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf reloadActiveStopsAndRoutes];
            });

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
-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [self.navigationController setToolbarHidden:NO animated:YES];
    dispatch_group_leave(self.searchingGroup);
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self.busData queryStopsAndRoutesWithString:searchString completion:^(NSArray *results) {
        self.searchResults = results;
        [self.searchController.searchResultsTableView reloadData];
    }];
    return NO;
}
-(void)clearResponders{
    [self.searchController.searchBar resignFirstResponder];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self clearResponders];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self clearResponders];
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
                return 0;
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        return 1;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        switch (self.currentPane) {
            case RUBusVCRoutesPane:
                switch (section) {
                    case 0:
                        return [self.activeRoutes[newBrunswickAgency] count];
                        break;
                    case 1:
                        return [self.activeRoutes[newarkAgency] count];
                        break;
                    default:
                        return 0;
                        break;
                }
                break;
            case RUBusVCStopsPane:
                switch (section) {
                    case 0:
                        return MAX([self.nearbyStops[newBrunswickAgency] count], [self.nearbyStops[newarkAgency] count]);
                        break;
                    case 1:
                        return [self.activeStops[newBrunswickAgency] count];
                        break;
                    case 2:
                        return [self.activeStops[newarkAgency] count];
                        break;
                    default:
                        return 0;
                        break;
                }
                break;
            default:
                return 0;
                break;
        }

    } else if (tableView == self.searchController.searchResultsTableView) {
        return self.searchResults.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (tableView == self.tableView) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
        cell.textLabel.textColor = [UIColor blackColor];
        switch (self.currentPane) {
            case RUBusVCRoutesPane:
                switch (indexPath.section) {
                    case 0:
                    {
                        RUBusRoute *route = self.activeRoutes[newBrunswickAgency][indexPath.row];
                        cell.textLabel.text = route.title;
                    }
                        break;
                    case 1:
                    {
                        RUBusRoute *route = self.activeRoutes[newarkAgency][indexPath.row];
                        cell.textLabel.text = route.title;
                    }
                        break;
                    default:
                        return 0;
                        break;
                }
                break;
            case RUBusVCStopsPane:
                switch (indexPath.section) {
                    case 0:
                        if ([self.nearbyStops[newBrunswickAgency] count] > [self.nearbyStops[newarkAgency] count]) {
                            RUBusStop *stop = [self.nearbyStops[newBrunswickAgency][indexPath.row] firstObject];
                            cell.textLabel.text = stop.title;
                        } else {
                            RUBusStop *stop = [self.nearbyStops[newarkAgency][indexPath.row] firstObject];
                            cell.textLabel.text = stop.title;
                        }
                        break;
                    case 1:
                    {
                        RUBusStop *stop = [self.activeStops[newBrunswickAgency][indexPath.row] firstObject];
                        cell.textLabel.text = stop.title;
                    }
                        break;
                    case 2:
                    {
                        RUBusStop *stop = [self.activeStops[newarkAgency][indexPath.row] firstObject];
                        cell.textLabel.text = stop.title;
                    }
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        id itemForCell = self.searchResults[indexPath.row];
        cell.textLabel.text = [itemForCell title];
        if ([itemForCell active]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    return cell;
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
            default:
                return nil;
                break;
        }

    } else if (tableView == self.searchController.searchResultsTableView) {
        return @"Search Results";
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUPredictionsViewController *predictionsVC = [[RUPredictionsViewController alloc] init];
    predictionsVC.busData = self.busData;
    if (tableView == self.tableView) {
        
        switch (self.currentPane) {
            case RUBusVCRoutesPane:
                switch (indexPath.section) {
                    case 0:
                    {
                        RUBusRoute *route = self.activeRoutes[newBrunswickAgency][indexPath.row];
                        predictionsVC.route = route;
                    }
                        break;
                    case 1:
                    {
                        RUBusRoute *route = self.activeRoutes[newarkAgency][indexPath.row];
                        predictionsVC.route = route;
                    }
                        break;
                    default:
                        return;
                }
                break;
            case RUBusVCStopsPane:
                switch (indexPath.section) {
                    case 0:
                        if ([self.nearbyStops[newBrunswickAgency] count] > [self.nearbyStops[newarkAgency] count]) {
                            NSArray *stops = self.nearbyStops[newBrunswickAgency][indexPath.row];
                            predictionsVC.stops = stops;
                        } else {
                            NSArray *stops = self.nearbyStops[newarkAgency][indexPath.row];
                            predictionsVC.stops = stops;
                        }
                        break;
                    case 1:
                    {
                        NSArray *stops = self.activeStops[newBrunswickAgency][indexPath.row];
                        predictionsVC.stops = stops;
                    }
                        break;
                    case 2:
                    {
                        NSArray *stops = self.activeStops[newarkAgency][indexPath.row];
                        predictionsVC.stops = stops;
                    }
                        break;
                    default:
                        return;
                }
                break;
            default:
                return;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        id itemForCell = self.searchResults[indexPath.row];
        if ([itemForCell isKindOfClass:[RUBusRoute class]]){
            predictionsVC.route = itemForCell;
        } else {
            predictionsVC.stops = itemForCell;
        }
    }
    [self.navigationController pushViewController:predictionsVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
