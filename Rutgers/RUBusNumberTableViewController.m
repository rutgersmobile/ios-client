//
//  RUBusNumberTableViewController.m
//  Rutgers
//
//  Created by cfw37 on 1/13/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

#import "RUBusNumberTableViewController.h"
#import "ALTableViewRightDetailCell.h"
#import "RUBusPredictionsAndMessageDataSource.h"
#import "RUBusPrediction.h"
#import "RUBusRoute.h"
#import "RUBusStop.h"
#import "RUPredictionsDataSource.h"

@interface RUBusNumberTableViewController ()


@property (nonatomic) NSArray* stopArray;
@property (nonatomic) RUBusPredictionsAndMessageDataSource* dataSource;

@end

@implementation RUBusNumberTableViewController


-(instancetype)initWithItem:(id)item busNumber:(NSString*)busNumber
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        self.item = item; // RUBusRoute or RUBusStop
        
        self.busNumber = busNumber;
        
        self.title = [self.item title];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[RUBusPredictionsAndMessageDataSource alloc] initWithItem: self.item busNumber: self.busNumber];
    
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
    
    RUPredictionsDataSource* predictionDataSource = (RUPredictionsDataSource*)self.dataSource;
    
    if ([predictionDataSource isKindOfClass:[RUPredictionsDataSource class]]) {
        NSLog(@"CONFIRMED!");
        
    } else {
        NSLog(@"Nope.");
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    
    ALTableViewRightDetailCell *cell = [[ALTableViewRightDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"default"];
    
    cell.textLabel.text = @"Suh dude";
    
    cell.detailTextLabel.text = @"0";
    
    return cell;
}


@end
