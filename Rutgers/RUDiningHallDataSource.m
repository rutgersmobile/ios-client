//
//  RUDiningHallDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUDiningHallDataSource.h"
#import "ComposedDataSource.h"
#import "StringDataSource.h"

@interface RUDiningHallDataSource ()
@property (nonatomic) NSDictionary *diningHall;
@end

@implementation RUDiningHallDataSource
-(instancetype)initWithDiningHall:(NSDictionary *)diningHall{
    self = [super init];
    if (self) {
        self.diningHall = diningHall;
        
        for (NSDictionary *meal in self.diningHall[@"meals"]) {
            if (![meal[@"meal_avail"] boolValue]) continue;
            
            ComposedDataSource *mealDataSource = [[ComposedDataSource alloc] init];
            mealDataSource.title = meal[@"meal_name"];
            
            for (NSDictionary *genre in meal[@"genres"]) {
                StringDataSource *genreDataSource = [[StringDataSource alloc] initWithItems:genre[@"items"]];
                genreDataSource.title = genre[@"genre_name"];
                [mealDataSource addDataSource:genreDataSource];
            }
            
            [self addDataSource:mealDataSource];
        }
    }
    return self;
}
@end






