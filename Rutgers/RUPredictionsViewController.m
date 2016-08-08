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
#import "RUBusMultipleStopsForSingleLocation.h"
#import "TableViewController_Private.h"
#import <MSWeakTimer.h>
#import "NSURL+RUAdditions.h"
#import "RUBusDataLoadingManager.h"
#import "RUDefines.h"

#import "RUBusPredictionsAndMessageDataSource.h"

#define PREDICTION_TIMER_INTERVAL 30.0

/*
    Handles the predictions for the BUS app.
 
 */

@interface RUPredictionsViewController ()
@property (nonatomic) MSWeakTimer *timer;
@property (nonatomic) id item;
@property (nonatomic) id serializedItem;
@end

@implementation RUPredictionsViewController

/*
    Is called from the BUS table view when a user clicks on the row
    The item can either represent a stop or a route
    Determine how this is passed ???? <q>
 
 */
-(instancetype)initWithItem:(id)item
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.item = item; // RUBusRoute or RUBusStop
        self.title = [self.item title];
        if(DEV) NSLog(@"title : %@" , self.title);
    }
    return self;
}

-(instancetype)initWithSerializedItem:(id)item title:(NSString *)title{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.item = item;
        self.title = title;
        if(DEV) NSLog(@"title : %@" , title);
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    /*
        the cell view has different heights for stop vs route 
        as stop -> has an additional line containing the bus route that will come by that stop 
        route does not have this and hence is it smaller in size
     */

    //Set the estimated row height to help the tableview
    self.tableView.rowHeight = [self.item isKindOfClass:[RUBusRoute class]] ? 70.0 : 96.0;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    
    //All of the content loading happens in the data source
    
    
    /*
        RUPrediction... is an interface which depends on the superclass expandingcells...
        Which in turn inherits from composed data source which in turn inherits from the Data Source class
     */

    self.dataSource = [[RUBusPredictionsAndMessageDataSource alloc] initWithItem:self.item];

    [self.dataSource whenLoaded:^{
           if (self.dataSource != nil)
            {
                id item = ((RUBusPredictionsAndMessageDataSource *)self.dataSource).item;
                
                NSLog(@"DATASOURCE ITEM : %@", item);
                NSString * busTitle ;
                
                // base on the location where this object is initialized , the item can be a stop , a route or simply an array
                if ([self.item isKindOfClass:[RUBusMultipleStopsForSingleLocation class]] || [self.item isKindOfClass:[RUBusRoute class]]) // when initialized from the bus view controller
                {
                    busTitle = [self.item title];
                }
                else if ([self.item isKindOfClass:[NSArray class]] && [self.item count] >= 2) // when the object has been initializec from a favourite or a deep url
                {
                    busTitle = [(NSString*)self.item[1] stringByRemovingPercentEncoding];
                }
                
                  dispatch_async(dispatch_get_main_queue(), ^
                    {
                        self.title = busTitle;
                    });
                
            }
    }];
    
    
    self.pullsToRefresh = YES;
}


/*
    the self.item is set by the init , and can either represent the route or a stop and based on that 
 */
-(NSURL *)sharingURL
{
    NSString *type;
    NSString *identifier;
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        type = @"route";
        identifier = [(RUBusRoute*)self.item tag];
    } else if ([self.item isKindOfClass:[RUBusMultipleStopsForSingleLocation class]]) {
        type = @"stop";
        identifier = [self.item title];
    }
    else if( [self.item isKindOfClass:[NSArray class]]) // add support for showing the url when the bus has been favourited..
    {
        type = self.item[0];
        identifier = self.item[1];
    }
    if (!type) return nil;
    return [NSURL rutgersUrlWithPathComponents:@[@"bus", type, identifier]]; // eg rut../bus/route/f
}


//This causes an update timer to start upon the Predictions View controller appearing
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Sets up a timer that repeatedly calls setNeeds... on the data source .
    // What determine what information the data source will request ????? <q>
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

/*
    Make the messges unselectable
 
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) // if message then make it unselectable
    {
        [tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else // pass on the message to the super class
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


@end
