//
//  NewBrunswickFoodDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NewBrunswickFoodDataSource.h"
#import "RUFoodData.h"
#import "DataTuple.h"
#import "ALTableViewTextCell.h"

@implementation NewBrunswickFoodDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"New Brunswick";
    }
    return self;
}
-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [RUFoodData getFoodWithSuccess:^(NSArray *response) {
            [loading updateWithContent:^(typeof(self) me) {
                [me parseResponse:response];
            }];
        } failure:^{
            [loading doneWithError:nil];
        }];
    }];
}

-(void)parseResponse:(NSArray *)response{
    NSMutableArray *parsedDiningHalls = [NSMutableArray array];
    for (NSDictionary *diningHall in response) {
        DataTuple *parsedDiningHall = [[DataTuple alloc] initWithTitle:diningHall[@"location_name"] object:diningHall];
        [parsedDiningHalls addObject:parsedDiningHall];
    }
    self.items = parsedDiningHalls;
}

-(void)configureCell:(ALTableViewTextCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [super configureCell:cell forRowAtIndexPath:indexPath];
    DataTuple *diningHall = [self itemAtIndexPath:indexPath];
    BOOL open = [self isDiningHallOpen:diningHall.object];
    cell.textLabel.textColor = open ? [UIColor blackColor] : [UIColor grayColor];
    cell.accessoryType = open ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

-(BOOL)isDiningHallOpen:(NSDictionary *)diningHall{
    NSArray *meals = diningHall[@"meals"];
    for (NSDictionary *meal in meals) {
        if ([meal[@"meal_avail"] boolValue]) return YES;
    }
    return NO;
}
@end
