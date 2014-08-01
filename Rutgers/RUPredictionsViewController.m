//
//  RUPredictionsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsViewController.h"
#import "RUPredictionsDataSource.h"
#import "RUBusRoute.h"

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
    
    self.title = [self.item title];
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        self.tableView.rowHeight = 68.0;
    } else {
        self.tableView.rowHeight = 90.0;
    }
    
    self.dataSource = [[RUPredictionsDataSource alloc] initWithItem:self.item];
    
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:PREDICTION_TIMER_INTERVAL target:self.dataSource selector:@selector(setNeedsLoadContent) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}


@end
