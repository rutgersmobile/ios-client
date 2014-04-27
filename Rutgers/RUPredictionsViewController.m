//
//  RUPredictionsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsViewController.h"
#import "RUBusRoute.h"
#import "RUBusStop.h"
#import <AFNetworking.h>
#import "RUBusData.h"
#import "RUPredictionTableViewCell.h"

@interface RUPredictionsViewController ()
@property (nonatomic) NSArray *response;
@property (nonatomic) NSTimer *updateTimer;
@end


@implementation RUPredictionsViewController


-(void)setStops:(NSArray *)stops{
    _stops = stops;
    self.title = [[stops firstObject] title];
    self.tableView.rowHeight = 78.0;
    [self getPredictions];
}
-(void)setRoute:(RUBusRoute *)route{
    _route = route;
    self.title = route.title;
    self.tableView.rowHeight = 60.0;
    [self getPredictions];
}
-(void)getPredictions{
    if (self.stops) {
        [self.busData getPredictionsForStops:self.stops inAgency:self.agency withCompletion:^(NSArray *response) {
            self.response = response;
        }];
    } else if (self.route) {
        [self.busData getPredictionsForRoute:self.route inAgency:self.agency withCompletion:^(NSArray *response) {
            self.response = response;
        }];
    }
}
-(void)setResponse:(NSArray *)response{
    _response = response;
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"RUPredictionTableViewCell" bundle:nil] forCellReuseIdentifier:@"PredictionCell"];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(getPredictions) userInfo:nil repeats:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)dealloc{
    [self.updateTimer invalidate];
}
- (BOOL) hidesBottomBarWhenPushed {
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.response.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RUPredictionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PredictionCell" forIndexPath:indexPath];
    NSDictionary *itemForCell = self.response[indexPath.row];
    // Configure the cell...
    if (self.stops) {
        cell.titleLabel.text = itemForCell[@"routeTitle"];
        cell.detailLabelOne.text = itemForCell[@"directionTitle"];
        cell.detailLabelTwo.text = itemForCell[@"arrivalTimes"];
    } else if (self.route) {
        cell.titleLabel.text = itemForCell[@"stopTitle"];
        cell.detailLabelOne.text = itemForCell[@"arrivalTimes"];
        cell.detailLabelTwo.text = nil;
    }
 
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
