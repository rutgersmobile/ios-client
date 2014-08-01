//
//  RUFoodDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodDataSource.h"
#import "RUFoodData.h"
#import "ALTableViewTextCell.h"
#import "TupleDataSource.h"
#import "DataTuple.h"

@interface RUFoodDataSource ()
@property (nonatomic) TupleDataSource *nbDiningHalls;
@property (nonatomic) TupleDataSource *camdenDiningHalls;
@property (nonatomic) TupleDataSource *newarkDiningHalls;
@end

@implementation RUFoodDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.nbDiningHalls = [[TupleDataSource alloc] init];
        self.nbDiningHalls.title = @"New Brunswick";
        [self addDataSource:self.nbDiningHalls];
        
        self.camdenDiningHalls = [[TupleDataSource alloc] init];
        self.camdenDiningHalls.title = @"Camden";
        [self addDataSource:self.camdenDiningHalls];

        self.newarkDiningHalls = [[TupleDataSource alloc] init];
        self.newarkDiningHalls.title = @"Newark";
        [self addDataSource:self.newarkDiningHalls];
    }
    return self;
}

-(void)loadContent{
    [RUFoodData getFoodWithSuccess:^(NSArray *response) {
        [self parseResponse:response];
        [self updateStaticDiningHalls];
    } failure:^{
        
    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(void)parseResponse:(NSArray *)response{
    NSMutableArray *parsedDiningHalls = [NSMutableArray array];
    for (NSDictionary *diningHall in response) {
        DataTuple *parsedDiningHall = [[DataTuple alloc] initWithTitle:diningHall[@"location_name"] object:diningHall];
        [parsedDiningHalls addObject:parsedDiningHall];
    }
    self.nbDiningHalls.items = parsedDiningHalls;
}

-(void)updateStaticDiningHalls{
    NSDictionary *newarkData =  @{@"title" : @"Stonsby Commons & Eatery",
                                  @"header" : @"Newark",
                                  @"data" : @"Students enjoy all-you-care-to-eat dining in a contemporary setting. This exciting location offers fresh made menu items, cutting-edge American entrees, ethnically-inspired foods, vegetarian selections and lots more... \n\nThe Commons also features upscale Premium entrees and fresh baked goods from our in house bakery or local vendors.",
                                  @"view" : @"text"
                                  };
    
    NSDictionary *camdenData = @{@"title" : @"Gateway Cafe",
                                 @"header" : @"Camden",
                                 @"data" : @"The Camden Dining Hall, the Gateway Cafe, is located at the Camden Campus Center.\n\nIt offers a variety of eateries in one convenient location.",
                                 @"view" : @"text"
                                 };
    
    self.newarkDiningHalls.items = @[[[DataTuple alloc] initWithTitle:newarkData[@"title"] object:newarkData]];
    self.camdenDiningHalls.items = @[[[DataTuple alloc] initWithTitle:camdenData[@"title"] object:camdenData]];
}

@end
