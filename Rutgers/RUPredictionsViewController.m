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

#define PREDICTION_TIMER_INTERVAL 30.0

@interface RUPredictionsViewController () <UIPopoverControllerDelegate>
@property (nonatomic) MSWeakTimer *timer;
@property (nonatomic) id item;
@property (nonatomic) UIBarButtonItem *shareButton;
@property (nonatomic) UIPopoverController *sharingPopoverController;
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
    
    //Set the title of the view controller to the items title
    self.title = [self.item title];
    
    //Set the estimated row height to help the tableview
    self.tableView.rowHeight = [self.item isKindOfClass:[RUBusRoute class]] ? 70.0 : 96.0;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    
    //All of the content loading happens in the data source
    self.dataSource = [[RUPredictionsDataSource alloc] initWithItem:self.item];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
    self.shareButton = shareButton;
    self.navigationItem.rightBarButtonItem = shareButton;
}

-(NSURL *)url{
    NSString *type;
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        type = @"bus";
    } else if ([self.item isKindOfClass:[RUBusMultiStop class]]) {
        type = @"stop";
    }
    if (!type) return nil;
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"rutgers://%@/%@", type, [self.item title]]];
}

- (void)actionButtonTapped:(id)sender {
    NSURL *url = self.url;
    if (!url) return;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        //If we're on an iPhone, we can just present it modally
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        //UIPopoverController requires we retain our own instance of it.
        //So if we somehow have a prior instance, clean it out
        if (self.sharingPopoverController)
        {
            [self.sharingPopoverController dismissPopoverAnimated:NO];
            self.sharingPopoverController = nil;
        }
        
        //Create the sharing popover controller
        self.sharingPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        self.sharingPopoverController.delegate = self;
        [self.sharingPopoverController presentPopoverFromBarButtonItem:self.shareButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
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

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error{
    if (!self.refreshControl && !error) {
        //After first load, add the refresh control to let the user pull to refresh
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self.dataSource action:@selector(setNeedsLoadContent) forControlEvents:UIControlEventValueChanged];
    }
    //If the refresh control was refreshing, stop it
    [self.refreshControl endRefreshing];
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
