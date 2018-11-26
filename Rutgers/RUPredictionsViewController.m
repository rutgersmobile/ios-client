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
#import "RUPredictionsBodyTableViewCell.h"
#import "RUBusNumberButton.h"
#import "RUBusStop.h"
#import <Foundation/Foundation.h>



#define PREDICTION_TIMER_INTERVAL 30.0

/*
 Handles the predictions for the BUS app.
 */

@interface RUPredictionsViewController ()
@property (nonatomic) MSWeakTimer *timer;
@property (nonatomic) id item;
@property (nonatomic) id serializedItem;
@property (nonatomic) BOOL didExpand;
@property (nonatomic) AlertDataSource *busNumberDataSource;
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
#warning Uncomment lines to make sure functionality is the same
- (void)viewDidLoad
{
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
                                   self.title = dataSource.responseTitle;
                               }
                           });
        }
    }];
 
    /* Maps button to be implemented.  Currently does not do anything */
    
    /*
     // Set up the button for opening the maps
     UIButton *mapsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [mapsView addTarget:self action:@selector(mapsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
     [mapsView setBackgroundImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
     UIBarButtonItem *mapsButton = [[UIBarButtonItem alloc] initWithCustomView:mapsView];
     */
    
    // [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.shareButton  , mapsButton , nil]];
    
//    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.shareButton  , nil]];
    
    //self.pullsToRefresh = YES;
}

/*
 Open the Bus maps View Controller
 */
-(void) mapsButtonPressed
{
    
}

/*
 the self.item is set by the init , and can either represent the route or a stop and based on that
 */
#warning Change return so it works with transloc update
-(NSURL *)sharingURL
{
    NSString *type;
    NSString *identifier;
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        type = @"route";
        identifier = [(RUBusRoute*)self.item tag];
        //Mark: Used to be RUBusMultiStop
    } else if ([self.item isKindOfClass:[RUBusStop class]]) {
        type = @"stop";
        identifier = [self.item title];
    }
    else if([self.item isKindOfClass:[NSArray class]]) // add support for showing the url when the bus has been favourited..
    {
        type = self.item[0];
        identifier = self.item[1];
    }
    if (!type) return nil;
   // return [NSURL rutgersUrlWithPathComponents:@[@"bus", type, identifier]]; // eg rut../bus/route/f
    return nil;
}

//This causes an update timer to start upon the Predictions View controller appearing
#warning Set timer needs to be updated so it doesn't crash
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Sets up a timer that repeatedly calls setNeeds... on the data source .
    // What determine what information the data source will request ????? <q>
  //  self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:PREDICTION_TIMER_INTERVAL target:self.dataSource selector:@selector(setNeedsLoadContent) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    
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

//The IBAction uses the data from sender in order to return the indexPath so the compiler knows which times/what bus to display to the user

- (IBAction)busPinButtonTapped:(id)sender {
    
    //Casts the sender data as the RUBusNumberButton class in order to access the indexPath property
    RUBusNumberButton* busNumberButton = (RUBusNumberButton*)sender;
    
    //Uses the busNumberButton indexPath property in order to access the correct data to display
    DataSource *basicDataSource = [(BasicDataSource *)self.dataSource itemAtIndexPath:busNumberButton.indexPath];
    
    if ([basicDataSource isKindOfClass:[RUPredictionsBodyRow class]]) {
        
        __weak __typeof__(self) weakSelf = self;
        
        RUPredictionsBodyRow* bodyRow = (RUPredictionsBodyRow*)basicDataSource;
        
        NSMutableArray* predictionTimes = [NSMutableArray new];
        
        //Filters through the arrival times and formats the times accrodingly - if minutes == 0 display seconds etc. etc.
        for (RUBusArrival* arrivals in bodyRow.predictionTimes) {
            if (arrivals.minutes < 1) {
                if (arrivals.seconds == 1) {
                    [predictionTimes addObject:[NSString stringWithFormat:@"%li second", arrivals.seconds]];
                } else {
                    [predictionTimes addObject:[NSString stringWithFormat:@"%li seconds", arrivals.seconds]];
                }
            } else {
                if (arrivals.minutes == 1) {
                    [predictionTimes addObject:[NSString stringWithFormat:@"%li minute", arrivals.minutes]];}
                else {
                    [predictionTimes addObject:[NSString stringWithFormat:@"%li minutes", arrivals.minutes]];
                }
            }
            
        }
        
        //Initializes the AlertDataSource (popup) with the predictionTimes array
        self.busNumberDataSource = [[AlertDataSource alloc] initWithInitialText:@"" alertButtonTitles: predictionTimes];
        
        self.busNumberDataSource.alertTitle = @"Track bus arriving in...";
        
        //This closure controls what happens when a user taps on a row in the alertView that pops up
        self.busNumberDataSource.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            NSString* vehicleID = bodyRow.vehicleArray[buttonIndex];
            
            
            RUBusNumberViewController* vc = [[RUBusNumberViewController alloc] initWithItem:((RUBusPredictionsAndMessageDataSource*)weakSelf.dataSource).item busNumber:vehicleID];
            
            [weakSelf.navigationController pushViewController: vc animated:YES];
        };
        
        //Displays Alert
        [self.busNumberDataSource showAlertInView:self.view];
    }
    
}

//Tried to use an extension on UIImage, but it proved to be too cumbersome to implement.  Could be added to an extension at some point in the future.
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


//This method assures that the images/buttons get realloc when the view reloads
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Since the expanding cells are in indexPath.row(1) and we only act on the expanding cells, this assures us that nothing will be displayed in the headerRows
    if (indexPath.row == 1) {
        
        RUBusNumberButton *busPinButton = [RUBusNumberButton buttonWithType:UIButtonTypeCustom];
        [busPinButton setFrame:CGRectMake(10, 5, 55, 55)];
        
         UIImage *image = [[UIImage imageNamed:@"bus_pin"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        
        
        [busPinButton setImage:image forState:UIControlStateNormal];
        busPinButton.tintColor = [UIColor grayColor];
        
        
        
        busPinButton.indexPath = indexPath;
        //[busPinButton setBackgroundImage:[self imageWithColor:[UIColor darkGrayColor]] forState:UIControlEventAllTouchEvents];
        
        [busPinButton setBackgroundImage:[self imageWithColor:[UIColor darkGrayColor]] forState:UIControlStateSelected];
        
        [busPinButton addTarget:self action:@selector(busPinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:busPinButton];
        
        //May not be necessary, but just in case the button gets buried
        [cell bringSubviewToFront:busPinButton];
        
        cell.accessoryView = busPinButton;
        
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
}



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



