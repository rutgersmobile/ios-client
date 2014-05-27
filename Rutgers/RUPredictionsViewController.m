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
#import "NSArray+RUBusStop.h"
#import "RUPredictionTableViewCell.h"

#define PREDICTION_TIMER_INTERVAL 30.0

@interface RUPredictionsViewController ()
@property NSArray *response;
@end


@implementation RUPredictionsViewController
-(void)setItem:(id)item{
    _item = item;
    if ([item isKindOfClass:[RUBusRoute class]]) {
        self.tableView.rowHeight = 60.0;
    } else {
        self.tableView.rowHeight = 80.0;
    }
    self.title = [item title];
}
-(void)getPredictions{
    [[RUBusData sharedInstance] getPredictionsForItem:self.item withCompletion:^(NSArray *response) {
        [self.tableView beginUpdates];
        self.response = response;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"RUPredictionTableViewCell" bundle:nil] forCellReuseIdentifier:@"PredictionCell"];
    [self getPredictions];
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, PREDICTION_TIMER_INTERVAL * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self getPredictions];
    });
    
    dispatch_resume(timer);
}
-(void)dealloc{
    
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
    
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
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
    } else {
        cell.titleLabel.text = itemForCell[@"_routeTitle"];
        if (predictionsForCell) {
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

@end
