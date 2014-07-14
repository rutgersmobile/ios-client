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
#import <MSWeakTimer.h>

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
    
    [self startNetworkLoad];
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:PREDICTION_TIMER_INTERVAL target:self selector:@selector(startNetworkLoad) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)setItem:(id)item{
    _item = item;
    if ([item isKindOfClass:[RUBusRoute class]]) {
        self.tableView.rowHeight = 68.0;
    } else {
        self.tableView.rowHeight = 90.0;
    }
    self.title = [item title];
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

-(void)parseResponse:(NSArray *)response{
    [self.tableView beginUpdates];
     if (self.sections.count == 0) {
        for (NSDictionary *predictions in response) {
            [self addSection:[[RUPredictionsExpandingSection alloc] initWithPredictions:predictions forItem:self.item]];
        }
    } else {
        [response enumerateObjectsUsingBlock:^(NSDictionary *predictions, NSUInteger idx, BOOL *stop) {
            [((RUPredictionsExpandingSection *)[self sectionAtIndex:idx]) updateWithPredictions:predictions];
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
