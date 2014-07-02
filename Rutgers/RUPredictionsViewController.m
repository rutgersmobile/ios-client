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

#define PREDICTION_TIMER_INTERVAL 30.0

@interface RUPredictionsViewController ()
//@property NSTimer *timer;
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

-(void)setItem:(id)item{
    _item = item;
    if ([item isKindOfClass:[RUBusRoute class]]) {
        self.tableView.rowHeight = 68.0;
        self.tableView.estimatedRowHeight = 68.0;
    } else {
        self.tableView.rowHeight = 90.0;
        self.tableView.estimatedRowHeight = 90.0;
    }
    self.title = [item title];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self startNetworkLoad];
    [self startTimer];
}

-(void)startNetworkLoad{
    [super startNetworkLoad];
    [[RUBusData sharedInstance] getPredictionsForItem:self.item withSuccess:^(NSArray *response) {
        [self networkLoadSucceeded];
        [self parseResponse:response];
    } failure:^{
        [self networkLoadFailed];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)parseResponse:(NSArray *)response{
    [self.tableView beginUpdates];
     if (self.sections.count == 0) {
        for (NSDictionary *predictions in response) {
            [self addSection:[[RUPredictionsExpandingSection alloc] initWithPredictions:predictions forItem:self.item]];
        }
    } else {
        [response enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((RUPredictionsExpandingSection *)[self sectionInTableView:self.tableView atIndex:idx]) updateWithPredictions:obj];
        }];
        [self.tableView reloadData];
    }
    [self.tableView endUpdates];
}

-(void)startTimer{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PREDICTION_TIMER_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf startNetworkLoad];
        [weakSelf startTimer];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
