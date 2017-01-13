//
//  RUBusNumberTableViewController.m
//  Rutgers
//
//  Created by cfw37 on 1/12/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

#import "RUBusNumberTableViewController.h"
#import "ALTableViewAbstractCell.h"
#import "RUBusPredictionsAndMessageDataSource.h"
#import "RUBusPredictionsAndMessageDataSource.h"
#import "RUBusArrival.h"

@interface RUBusNumberTableViewController ()



@end

@implementation RUBusNumberTableViewController
/*
- (void)viewDidLoad {
    [super viewDidLoad];

   
    self.dataSource = [[RUBusPredictionsAndMessageDataSource alloc] initWithItem:self.item];
    
    [self.dataSource whenLoaded:^{
        if (self.dataSource != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");
                               RUBusPredictionsAndMessageDataSource* dataSource = (RUBusPredictionsAndMessageDataSource*)self.dataSource;
                               
                               if (dataSource.responseTitle == nil) {
                                   self.title = @"Bus";
                               } else {
                                   self.title = dataSource.responseTitle;
                               }
                           });
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.routeObject.stops.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ALTableViewAbstractCell* testCell = [[ALTableViewAbstractCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"defaultCell"];
    
    RUBusArrival* arrival = self.predictionTimes[indexPath.row];
    
    NSLog(@"%li", arrival.minutes);
    
    
    
   
    
    NSString* stop = self.routeObject.stops[indexPath.row];
    
    testCell.textLabel.text = stop;
 //   testCell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%li", arrival.minutes];
    
    return testCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
*/

@end
