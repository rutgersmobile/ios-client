//
//  RUFoodViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodViewController.h"
#import "RUFoodData.h"
#import "RUDiningHallViewController.h"
#import "RUChannelManager.h"

@interface RUFoodViewController ()
@property (nonatomic) RUFoodData *foodData;
@property (nonatomic) NSArray *nbDiningHalls;
@property (nonatomic) NSArray *staticDiningHalls;
@end

@implementation RUFoodViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUFoodViewController alloc] init];
}
- (instancetype)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.foodData = [RUFoodData sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.staticDiningHalls = self.foodData.staticDiningHalls;
    [self.foodData getFoodWithCompletion:^(NSArray *response) {
        [self.tableView beginUpdates];
        self.nbDiningHalls = response;
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.nbDiningHalls) return 0;
    return [self.staticDiningHalls count]+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.nbDiningHalls.count;
            break;
        default:
            return 1;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *diningHall = self.nbDiningHalls[indexPath.row];
            cell.textLabel.text = diningHall[@"location_name"];
        }
            break;
        default:
            cell.textLabel.text = self.staticDiningHalls[indexPath.section-1][@"title"];
            break;
    }
    
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"New Brunswick";
            break;
        default:
            return self.staticDiningHalls[section-1][@"header"];
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *diningHall = self.nbDiningHalls[indexPath.row];
            RUDiningHallViewController *diningVC = [[RUDiningHallViewController alloc] initWithDiningHall:diningHall];
            [self.navigationController pushViewController:diningVC animated:YES];
        }
            break;
        default:
        {
            NSDictionary *channel = self.staticDiningHalls[indexPath.section-1];
            [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:channel] animated:YES];
        }
            break;
    }
}

@end
