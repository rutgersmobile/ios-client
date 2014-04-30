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

#define PREDICTION_TIMER_INTERVAL 30.0

@interface RUPredictionsViewController ()
@property NSArray *response;
@property (nonatomic) NSTimer *updateTimer;
@end


@implementation RUPredictionsViewController

-(void)setAgency:(NSString *)agency{
    _agency = [agency copy];
}
-(void)setStops:(NSArray *)stops{
    _stops = stops;
    self.title = [[stops firstObject] title];
    self.tableView.rowHeight = 80.0;
}
-(void)setRoute:(RUBusRoute *)route{
    _route = route;
    self.title = route.title;
    self.tableView.rowHeight = 60.0;
}
-(void)getPredictions{

    __weak typeof(self) weakSelf = self;

    void (^completion)(NSArray *response) = ^(NSArray *response) {
        self.response = response;
        if (self.view.window) {
            [self.tableView reloadData];
            double delayInSeconds = PREDICTION_TIMER_INTERVAL;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf getPredictions];
            });
        }
    };
    
    if (self.stops) {
        [self.busData getPredictionsForStops:self.stops inAgency:self.agency withCompletion:completion];
    } else if (self.route) {
        [self.busData getPredictionsForRoute:self.route inAgency:self.agency withCompletion:completion];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"RUPredictionTableViewCell" bundle:nil] forCellReuseIdentifier:@"PredictionCell"];
    [self getPredictions];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.response.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RUPredictionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PredictionCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    
    NSDictionary *itemForCell = self.response[indexPath.row];
    NSArray *predictionsForCell = [itemForCell[@"direction"] firstObject][@"prediction"];
    // Configure the cell...
    if (self.stops) {
        cell.titleLabel.text = itemForCell[@"_routeTitle"];
        if (itemForCell[@"direction"]) {
            cell.detailLabelOne.text = [itemForCell[@"direction"] firstObject][@"_title"];
            cell.detailLabelTwo.text = [self arrivalTimeDescriptionForPredictions:predictionsForCell];
            cell.titleLabel.textColor = [UIColor blackColor];
            cell.detailLabelOne.textColor = [UIColor blackColor];
            cell.detailLabelTwo.textColor = [UIColor blackColor];
        } else {
            cell.detailLabelOne.text = itemForCell[@"_dirTitleBecauseNoPredictions"];
            cell.detailLabelTwo.text =  @"No predictions available.";
            cell.titleLabel.textColor = [UIColor grayColor];
            cell.detailLabelOne.textColor = [UIColor lightGrayColor];
            cell.detailLabelTwo.textColor = [UIColor lightGrayColor];
        }
    } else if (self.route) {
        cell.titleLabel.text = itemForCell[@"_stopTitle"];
        if (predictionsForCell) {
            cell.detailLabelOne.text = [self arrivalTimeDescriptionForPredictions:predictionsForCell];
            cell.titleLabel.textColor = [UIColor blackColor];
            cell.detailLabelOne.textColor = [UIColor blackColor];
        } else {
            cell.detailLabelOne.text =  @"No predictions available.";
            cell.titleLabel.textColor = [UIColor grayColor];
            cell.detailLabelOne.textColor = [UIColor lightGrayColor];
        }
        cell.detailLabelTwo.text = nil;
    }
 
    return cell;
}

-(NSString *)arrivalTimeDescriptionForPredictions:(NSArray *)predictions{
    NSMutableString *string = [[NSMutableString alloc] init];
    [predictions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *prediction = obj;
        NSString *minutes = prediction[@"_minutes"];
        if ([string isEqualToString:@""]) {
            [string appendString:minutes];
        } else {
            [string appendFormat:@", %@",minutes,nil];
        }
        if (idx == 2) *stop = YES;
    }];
    [string appendString:@" minutes"];
    return string;
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
