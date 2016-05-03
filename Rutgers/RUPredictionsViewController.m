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
#import "RUBusMultiStop.h"
#import "TableViewController_Private.h"
#import <MSWeakTimer.h>
#import "NSURL+RUAdditions.h"
#import "RUBusDataLoadingManager.h"

#define PREDICTION_TIMER_INTERVAL 30.0

#define DEV 1


@interface RUPredictionsViewController ()
@property (nonatomic) MSWeakTimer *timer;
@property (nonatomic) id item;
@property (nonatomic) id serializedItem;
@end

@implementation RUPredictionsViewController
-(instancetype)initWithItem:(id)item{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.item = item;
        self.title = [self.item title];
        if(DEV) NSLog(@"title");
    }
    return self;
}

-(instancetype)initWithSerializedItem:(id)item title:(NSString *)title{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.item = item;
        self.title = title;
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    //Set the estimated row height to help the tableview
    self.tableView.rowHeight = [self.item isKindOfClass:[RUBusRoute class]] ? 70.0 : 96.0;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    
    //All of the content loading happens in the data source
    self.dataSource = [[RUPredictionsDataSource alloc] initWithItem:self.item];
    
    self.pullsToRefresh = YES;
}

-(NSURL *)sharingURL{
    NSString *type;
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        type = @"route";
    } else if ([self.item isKindOfClass:[RUBusMultiStop class]]) {
        type = @"stop";
    }
    if (!type) return nil;
    return [NSURL rutgersUrlWithPathComponents:@[@"bus", type, [self.item title]]];
}

//This causes an update timer to start upon the Predictions View controller appearing
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:PREDICTION_TIMER_INTERVAL target:self.dataSource selector:@selector(setNeedsLoadContent) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

//And stops the timer
-(void)viewWillDisappear:(BOOL)animated{
    [self.timer invalidate];
    [super viewWillDisappear:animated];
}

-(UITableViewRowAnimation)rowAnimationForOperationDirection:(DataSourceAnimationDirection)direction{
    switch (direction) {
        case DataSourceAnimationDirectionNone:
            //This causes the inserted and removed sections to slide on and off the screen
            return UITableViewRowAnimationAutomatic;
            break;
        default:
            return [super rowAnimationForOperationDirection:direction];
            break;
    }
}

@end
