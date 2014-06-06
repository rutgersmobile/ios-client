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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getPredictions) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];

    [self startTimer];
}
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
        self.tableView.rowHeight = 60.0;
    } else {
        self.tableView.rowHeight = 80.0;
    }
    self.title = [item title];
}
-(void)getPredictions{
    [[RUBusData sharedInstance] getPredictionsForItem:self.item withCompletion:^(NSArray *response) {
        [self parseResponse:response];
    }];
}
-(void)parseResponse:(NSArray *)response{
     if ([self numberOfSections] == 0) {
        for (NSDictionary *predictions in response) {
            [self addSection:[[RUPredictionsExpandingSection alloc] initWithPredictions:predictions forItem:self.item]];
        }
    } else {
        [response enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((RUPredictionsExpandingSection *)[self sectionInTableView:self.tableView atIndex:idx]) updateWithPredictions:obj];
        }];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfSections])] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.refreshControl endRefreshing];
}
-(void)startTimer{
    __weak typeof(self) weakSelf = self;
    [weakSelf getPredictions];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PREDICTION_TIMER_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf startTimer];
    });
}
-(void)dealloc{

}
- (BOOL) hidesBottomBarWhenPushed {
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    RUPredictionsExpandingSection *section = (RUPredictionsExpandingSection *)[self sectionInTableView:self.tableView atIndex:indexPath.section];
    if (!section.active) return NO;
    return [super tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
