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
#import "RUPredictionsExpandingSection.h"
#import "EZDataSource.h"

#define PREDICTION_TIMER_INTERVAL 30.0

@interface RUPredictionsViewController ()
@property MSWeakTimer *timer;
@property (nonatomic) id item;
@end

@implementation RUPredictionsViewController

-(instancetype)initWithItem:(id)item{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.item = item;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        self.tableView.rowHeight = 68.0;
    } else {
        self.tableView.rowHeight = 90.0;
    }
    self.title = [self.item title];
    
    [self setupContentLoadingStateMachine];
 //   self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:PREDICTION_TIMER_INTERVAL target:self.contentLoadingStateMachine selector:@selector(startNetworking) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)loadNetworkData{
    [[RUBusData sharedInstance] getPredictionsForItem:self.item withSuccess:^(NSArray *response) {
        [self.contentLoadingStateMachine networkLoadSuccessful];
        [self parseResponse:response];
    } failure:^{
        [self.contentLoadingStateMachine networkLoadFailedWithNoData];
    }];
}

-(void)parseResponse:(NSArray *)response{
    [self.tableView beginUpdates];
     if (self.dataSource.numberOfSections == 0) {
        for (NSDictionary *predictions in response) {
            [self.dataSource addSection:[[RUPredictionsExpandingSection alloc] initWithPredictions:predictions forItem:self.item]];
        }
    } else {
        [response enumerateObjectsUsingBlock:^(NSDictionary *predictions, NSUInteger idx, BOOL *stop) {
            [((RUPredictionsExpandingSection *)[self.dataSource sectionAtIndex:idx]) updateWithPredictions:predictions];
        }];
        [self.tableView reloadData];
    }
    [self.tableView endUpdates];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return self.tableView.rowHeight;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

@end
