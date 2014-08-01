//
//  RUDiningHallViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUDiningHallViewController.h"
#import "RUMealViewController.h"
#import "RUDiningHallDataSource.h"
#import "EZTableViewRightDetailRow.h"


@interface RUDiningHallViewController ()
@property (nonatomic) NSDictionary *diningHall;
@end

@implementation RUDiningHallViewController
-(id)initWithDiningHall:(NSDictionary *)diningHall{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.diningHall = diningHall;
        self.title = diningHall[@"location_name"];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[RUDiningHallDataSource alloc] initWithDiningHall:self.diningHall];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
@end
