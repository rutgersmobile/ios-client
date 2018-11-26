//
//  RUBusNumberViewController.m
//  Rutgers
//
//  Created by cfw37 on 1/18/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

/* So far this class is a near exact copy of RUPredictionsViewConroller in order to see how the data is passed and whether or not it can be filtered such that a user should only see a particular bus number and the stops it will make
 This class will ultimately be heavily modified, or even deleted.
 */

#import "RUBusNumberViewController.h"
#import "RUPredictionsDataSource.h"
#import "RUBusRoute.h"
#import "TableViewController_Private.h"
#import "MSWeakTimer.h"
#import "NSURL+RUAdditions.h"
#import "RUBusDataLoadingManager.h"
#import "RUDefines.h"
#import "RUBusNumberViewController.h"
#import "RUBusPredictionsAndMessageDataSource.h"
#import "AlertDataSource.h"
#import "RUPredictionsBodyRow.h"
#import "RUBusArrival.h"
#import "RUPredictionsDataSource.h"

#define PREDICTION_TIMER_INTERVAL 30.0

@interface RUBusNumberViewController ()

@property (nonatomic) MSWeakTimer *timer;
@property (nonatomic) id item;
@property (nonatomic) id serializedItem;
@property (nonatomic) BOOL didExpand;
@property (nonatomic) AlertDataSource *busNumberDataSource;
@property (nonatomic) NSString* busNumber;
@end

@implementation RUBusNumberViewController

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

-(instancetype)initWithItem:(id)item busNumber:(NSString*)busNumber
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.item = item; // RUBusRoute or RUBusStop
        self.title = [self.item title];
        self.busNumber = busNumber;
        if(DEV) NSLog(@"title : %@" , self.title);
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
    
    
    
    self.dataSource = [[RUBusPredictionsAndMessageDataSource alloc] initWithItem:self.item busNumber:self.busNumber];
    
    
    
    // Set the title of the Bus . This usually happens , when we do not have a title ..
    
    [self.dataSource whenLoaded:^{
        if (self.dataSource != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               RUBusPredictionsAndMessageDataSource* dataSource = (RUBusPredictionsAndMessageDataSource*)self.dataSource;
                               if (dataSource.responseTitle == nil) {
                                   self.title = @"Bus";
                                   
                               } else {
                                   
                                   NSString* formattedTitle = [[NSString alloc] initWithFormat:@"%@ - %@", dataSource.responseTitle, self.busNumber];
                                   self.title = formattedTitle;
                               }
                           });
        }
    }];
    
    
    
    self.pullsToRefresh = YES;
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
            
            //break;
        default:
            return [super rowAnimationForOperationDirection:direction];
            //break;
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


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
