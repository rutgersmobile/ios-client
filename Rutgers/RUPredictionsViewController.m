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
#import "RUPredictionsTableViewCell.h"
#import "RUPredictionsExpandingSection.h"
#import "RUPredictionsBodyTableViewCell.h"

#define PREDICTION_TIMER_INTERVAL 30.0

@interface RUPredictionsViewController ()
@property NSTimer *timer;
@property (nonatomic) id item;
@end


@implementation RUPredictionsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getPredictions) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];

    [self.tableView registerClass:[RUPredictionsTableViewCell class] forCellReuseIdentifier:@"RUPredictionsTableViewCell"];
    [self.tableView registerClass:[RUPredictionsBodyTableViewCell class] forCellReuseIdentifier:@"RUPredictionsBodyTableViewCell"];

    [self getPredictions];
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
    [self.tableView beginUpdates];
    if ([self numberOfSections] == 0) {
        for (NSDictionary *predictions in response) {
            [self addSection:[[RUPredictionsExpandingSection alloc] initWithPredictions:predictions forItem:self.item]];
        }
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfSections])] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [response enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((RUPredictionsExpandingSection *)[self sectionAtIndex:idx]) updateWithPredictions:obj];
        }];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfSections])] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
    [self.refreshControl endRefreshing];
}
-(void)startTimer{
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:PREDICTION_TIMER_INTERVAL target:weakSelf selector:@selector(getPredictions) userInfo:nil repeats:YES];
}
- (BOOL) hidesBottomBarWhenPushed {
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    RUPredictionsExpandingSection *section = (RUPredictionsExpandingSection *)[self sectionAtIndex:indexPath.section];
    if (!section.active) return NO;
    return [super tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
