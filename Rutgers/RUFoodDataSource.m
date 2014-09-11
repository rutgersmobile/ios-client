//
//  RUFoodDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodDataSource.h"
#import "ALTableViewTextCell.h"
#import "TupleDataSource.h"
#import "DataTuple.h"
#import "NewBrunswickFoodDataSource.h"
#import "RUUserInfoManager.h"

@interface RUFoodDataSource ()
@end

@implementation RUFoodDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSDictionary *camdenData = @{@"title" : @"Gateway Cafe",
                                     @"header" : @"Camden",
                                     @"data" : @"The Camden Dining Hall, the Gateway Cafe, is located at the Camden Campus Center.\n\nIt offers a variety of eateries in one convenient location.",
                                     @"view" : @"text"
                                     };
        
        NSDictionary *newarkData =  @{@"title" : @"Stonsby Commons & Eatery",
                                      @"header" : @"Newark",
                                      @"data" : @"Students enjoy all-you-care-to-eat dining in a contemporary setting. This exciting location offers fresh made menu items, cutting-edge American entrees, ethnically-inspired foods, vegetarian selections and lots more... \n\nThe Commons also features upscale Premium entrees and fresh baked goods from our in house bakery or local vendors.",
                                      @"view" : @"text"
                                      };
        
        [[RUUserInfoManager sharedInstance] performInCampusPriorityOrderWithNewBrunswickBlock:^{
            [self addDataSource:[[NewBrunswickFoodDataSource alloc] init]];
        } newarkBlock:^{
            [self addDataSource:[self dataSourceWithDictionary:newarkData]];
        } camdenBlock:^{
            [self addDataSource:[self dataSourceWithDictionary:camdenData]];
        }];
        
    }
    return self;
}

-(DataSource *)dataSourceWithDictionary:(NSDictionary *)dictionary{
    TupleDataSource *dataSource = [[TupleDataSource alloc] init];
    dataSource.title = dictionary[@"header"];
    dataSource.items = @[[[DataTuple alloc] initWithTitle:dictionary[@"title"] object:dictionary]];
    return dataSource;
}

@end
