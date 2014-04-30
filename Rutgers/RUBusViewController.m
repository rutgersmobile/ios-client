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

@interface RUBusViewController () <RUBusDataDelegate>
@property (nonatomic) RUBusData *busData;
@property (nonatomic) NSTimer *refreshTimer;
@property (nonatomic) UISegmentedControl *segmentedControl;
@end

@implementation RUBusViewController

- (id)initWithDelegate:(id <RUBusDelegate>)delegate {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.navigationItem.title = @"Bus";
        self.busData = [RUBusData sharedInstance];
        self.busData.delegate = self;
        // Custom initialization
        self.delegate = delegate;
        if ([self.delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
            // delegate expects menu button notification, so let's create and add a menu button
            UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
            self.navigationItem.leftBarButtonItem = btn;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:NO animated:NO];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    NSArray *segItemsArray = @[@"Routes",@"Stops",@"Search"];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    self.segmentedControl = segmentedControl;
    [segmentedControl addTarget:self action:@selector(segmentedControlButtonChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 260, 30);
    segmentedControl.selectedSegmentIndex = 1;
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = [NSArray arrayWithObjects: flexibleSpace, segmentedControlButtonItem, flexibleSpace, nil];
    
    [self setToolbarItems:barArray];
    
    [self.busData updateActiveStopsAndRoutesWithCompletion:^{
        [self.tableView reloadData];
        [self.busData startFindingNearbyStops];
    }];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2*60 target:self selector:@selector(reloadActiveStopsAndRoutes) userInfo:nil repeats:YES];

    // Do any additional setup after loading the view.
}
-(void)dealloc{
    [self.busData stopFindingNearbyStops];
}
-(void)reloadActiveStopsAndRoutes{
    [self.busData updateActiveStopsAndRoutesWithCompletion:^{
        if (self.view.window) {
            [self.tableView reloadData];
        }
    }];
}
-(void)busData:(RUBusData *)busData didUpdateNearbyStops:(NSDictionary *)nearbyStops{
    if (self.view.window) {
        [self.tableView reloadData];
    }
}
-(void)segmentedControlButtonChanged:(UISegmentedControl *)segmentedControl{
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    if (index == 0) {
        return 2;
    } else if (index == 1) {
        return 3;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    if (index == 0) {
        if (section == 0) {
            return [self.busData.activeRoutes[newBrunswickAgency] count];
        } else if (section == 1) {
            return [self.busData.activeRoutes[newarkAgency] count];
        }
    } else if (index == 1) {
        if (section == 0) {
            return MAX([self.busData.nearbyStops[newBrunswickAgency] count], [self.busData.nearbyStops[newarkAgency] count]);
        } else if (section == 1) {
            return [self.busData.activeStops[newBrunswickAgency] count];
        } else if (section == 2) {
            return [self.busData.activeStops[newarkAgency] count];
        }
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    if (index == 0) {
        if (indexPath.section == 0) {
            RUBusRoute *route = self.busData.activeRoutes[newBrunswickAgency][indexPath.row];
            cell.textLabel.text = route.title;
        } else if (indexPath.section == 1) {
            RUBusRoute *route = self.busData.activeRoutes[newarkAgency][indexPath.row];
            cell.textLabel.text = route.title;
        }
    } else if (index == 1) {
        if (indexPath.section == 0) {
            if ([self.busData.nearbyStops[newBrunswickAgency] count] > [self.busData.nearbyStops[newarkAgency] count]) {
                RUBusStop *stop = [self.busData.nearbyStops[newBrunswickAgency][indexPath.row] firstObject];
                cell.textLabel.text = stop.title;
            } else {
                RUBusStop *stop = [self.busData.nearbyStops[newarkAgency][indexPath.row] firstObject];
                cell.textLabel.text = stop.title;
            }
        } else if (indexPath.section == 1) {
            RUBusStop *stop = [self.busData.activeStops[newBrunswickAgency][indexPath.row] firstObject];
            cell.textLabel.text = stop.title;
        } else if (indexPath.section == 2) {
            RUBusStop *stop = [self.busData.activeStops[newarkAgency][indexPath.row] firstObject];
            cell.textLabel.text = stop.title;
        }
    }
    
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    if (index == 0) {
        if (section == 0) {
            return @"New Brunswick Active Routes";
        } else if (section == 1) {
            return @"Newark Active Routes";
        }
    } else if (index == 1) {
        if (section == 0){
            return @"Nearby Active Stops";
        } else if (section == 1) {
            return @"New Brunswick Active Stops";
        } else if (section == 2) {
            return @"Newark Active Stops";
        }
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    RUPredictionsViewController *predictionsVC = [[RUPredictionsViewController alloc] init];
    predictionsVC.busData = self.busData;
    if (index == 0) {
        if (indexPath.section == 0) {
            predictionsVC.agency = newBrunswickAgency;
            RUBusRoute *route = self.busData.activeRoutes[newBrunswickAgency][indexPath.row];
            predictionsVC.route = route;
            [self.navigationController pushViewController:predictionsVC animated:YES];
        } else if (indexPath.section == 1) {
            predictionsVC.agency = newarkAgency;
            RUBusRoute *route = self.busData.activeRoutes[newarkAgency][indexPath.row];
            predictionsVC.route = route;
            [self.navigationController pushViewController:predictionsVC animated:YES];
        }
    } else if (index == 1) {
        if (indexPath.section == 0) {
            if ([self.busData.nearbyStops[newBrunswickAgency] count] > [self.busData.nearbyStops[newarkAgency] count]) {
                predictionsVC.agency = newBrunswickAgency;
                NSArray *stops = self.busData.nearbyStops[newBrunswickAgency][indexPath.row];
                predictionsVC.stops = stops;
                [self.navigationController pushViewController:predictionsVC animated:YES];
            } else {
                predictionsVC.agency = newarkAgency;
                NSArray *stops = self.busData.nearbyStops[newarkAgency][indexPath.row];
                predictionsVC.stops = stops;
                [self.navigationController pushViewController:predictionsVC animated:YES];
            }
        } else if (indexPath.section == 1) {
            predictionsVC.agency = newBrunswickAgency;
            NSArray *stops = self.busData.activeStops[newBrunswickAgency][indexPath.row];
            predictionsVC.stops = stops;
            [self.navigationController pushViewController:predictionsVC animated:YES];
        } else if (indexPath.section == 2) {
            predictionsVC.agency = newarkAgency;
            NSArray *stops = self.busData.activeStops[newarkAgency][indexPath.row];
            predictionsVC.stops = stops;
            [self.navigationController pushViewController:predictionsVC animated:YES];
        }
    }
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
