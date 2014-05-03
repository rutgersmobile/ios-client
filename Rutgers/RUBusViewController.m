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

#define ACTIVE_TIMER_INTERVAL 60.0*3

//NSString *const busSavedSearchTextKey = @"busSavedSearchTextKey";
NSString *const busLastPaneKey = @"busLastPaneKey";


typedef enum : NSUInteger {
    RUBusVCRoutesPane = 0,
    RUBusVCStopsPane = 1,
    RUBusVCMapPane = 2,
} RUBusVCPane;


@interface RUBusViewController () <RUBusDataDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
@property (nonatomic) RUBusData *busData;

@property NSDictionary *activeStops;
@property NSDictionary *activeRoutes;

@property RUBusVCPane currentPane;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UISearchDisplayController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property NSArray *searchResults;
@end

@implementation RUBusViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Bus";
        self.busData = [RUBusData sharedInstance];
        self.busData.delegate = self;
        
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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
 //   self.mapView.delegate = self;
    
    [self reloadActiveStopsAndRoutes];

    [self.navigationController setToolbarHidden:NO animated:NO];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    /// segmented bar setup
    NSArray *segItemsArray = @[@"Routes",@"Stops",@"Map"];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    [segmentedControl addTarget:self action:@selector(segmentedControlButtonChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 260, 30);
    
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, flexibleSpace, nil];
    
    [self setToolbarItems:barArray];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.showsCancelButton = YES;

    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    
    self.tableView.tableHeaderView = self.searchBar;
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    
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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.busData startFindingNearbyStops];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.busData stopFindingNearbyStops];
}

-(void)reloadActiveStopsAndRoutes{
    __weak typeof(self) weakSelf = self;
    [self.busData updateActiveStopsAndRoutesWithCompletion:^(NSDictionary *activeStops, NSDictionary *activeRoutes) {
        self.activeRoutes = activeRoutes;
        self.activeStops = activeStops;
        switch (self.currentPane) {
            case RUBusVCRoutesPane:
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case RUBusVCStopsPane:
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            default:
                break;
        }

        double delayInSeconds = ACTIVE_TIMER_INTERVAL;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf reloadActiveStopsAndRoutes];
        });
    }];
}

-(void)busData:(RUBusData *)busData didUpdateNearbyStops:(NSDictionary *)nearbyStops{
    if (self.currentPane == RUBusVCStopsPane) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - segmented control

-(void)segmentedControlButtonChanged:(UISegmentedControl *)segmentedControl{
 
    if (segmentedControl.selectedSegmentIndex == RUBusVCMapPane) {
        self.tableView.hidden = YES;
        self.mapView.hidden = NO;
    } else {
        self.tableView.hidden = NO;
        self.mapView.hidden = YES;
    }
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    self.currentPane = segmentedControl.selectedSegmentIndex;
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentPane forKey:busLastPaneKey];
    
    [self.tableView reloadData];
}

#pragma mark - search bar

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self.busData queryStopsAndRoutesWithString:searchString completion:^(NSArray *results) {
        self.searchResults = results;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    return NO;
}
-(void)clearResponders{
    [self.searchBar resignFirstResponder];
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
                        return MAX([self.busData.nearbyStops[newBrunswickAgency] count], [self.busData.nearbyStops[newarkAgency] count]);
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (tableView == self.tableView) {
        
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
                        if ([self.busData.nearbyStops[newBrunswickAgency] count] > [self.busData.nearbyStops[newarkAgency] count]) {
                            RUBusStop *stop = [self.busData.nearbyStops[newBrunswickAgency][indexPath.row] firstObject];
                            cell.textLabel.text = stop.title;
                        } else {
                            RUBusStop *stop = [self.busData.nearbyStops[newarkAgency][indexPath.row] firstObject];
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
        if ([itemForCell isKindOfClass:[RUBusRoute class]]){
            cell.textLabel.text = [itemForCell title];
        } else {
            cell.textLabel.text = [[itemForCell firstObject] title];
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
                        if ([self.busData.nearbyStops[newBrunswickAgency] count] > [self.busData.nearbyStops[newarkAgency] count]) {
                            NSArray *stops = self.busData.nearbyStops[newBrunswickAgency][indexPath.row];
                            predictionsVC.stops = stops;
                        } else {
                            NSArray *stops = self.busData.nearbyStops[newarkAgency][indexPath.row];
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
