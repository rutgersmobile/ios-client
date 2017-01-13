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
#import "RUBusRoute.h"
#import "RUBusStop.h"

@interface RUBusNumberTableViewController ()

@property (nonatomic) id item;

@end

@implementation RUBusNumberTableViewController


-(instancetype)initWithItem:(id)item
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
     
        self.item = item; // RUBusRoute or RUBusStop
        self.title = [self.item title];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    if ([self.item isKindOfClass:[RUBusPredictionsAndMessageDataSource class]]) {
        
        RUBusPredictionsAndMessageDataSource* data = (RUBusPredictionsAndMessageDataSource*)self.item;
        
        if ([data.item isKindOfClass:[RUBusRoute class]]) {
            
            RUBusRoute* route = (RUBusRoute*)data.item;
             NSLog(@"%@", route.stops);
        
        } else if ([data.item isKindOfClass:[RUBusStop class]]) {
        
            NSLog(@"%@", data.item);
        }
       
        
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
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    
    ALTableViewRightDetailCell *cell = [[ALTableViewRightDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"default"];
    
    cell.textLabel.text = @"Hey";
    
    cell.detailTextLabel.text = @"How are things?";
    
    // Configure the cell...
    
    return cell;
}


@end
