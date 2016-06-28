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
#import "RUFoodDataLoadingManager.h"
#import "DataSource_Private.h"
#import "ALTableViewTextCell.h"
#import "NSDictionary+DiningHall.h"
#import "PlaceholderDataSource.h"

@interface RUDiningHallDataSource ()
@property (nonatomic) NSString *serializedDiningHall;
@end

@implementation RUDiningHallDataSource
-(instancetype)initWithDiningHall:(NSDictionary *)diningHall{
    self = [super init];
    if (self) {
        self.diningHall = diningHall;
        [self setupWithDiningHall:diningHall];
    }
    return self;
}

-(instancetype)initWithSerializedDiningHall:(NSString *)serializedDiningHall{
    self = [super init];
    if (self) {
        self.noContentTitle = @"Dining Hall Closed";
        self.noContentMessage = @"Check back another day very sorry";
        self.serializedDiningHall = serializedDiningHall;
    }
    return self;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(void)setupWithDiningHall:(NSDictionary *)diningHall {
    NSMutableArray *dataSources = [NSMutableArray array];
    for (NSDictionary *meal in diningHall[@"meals"]) {
        if (![meal[@"meal_avail"] boolValue]) continue;
        
        ComposedDataSource *mealDataSource = [[ComposedDataSource alloc] init];
        mealDataSource.title = meal[@"meal_name"];
        
        for (NSDictionary *genre in meal[@"genres"]) {
            StringDataSource *genreDataSource = [[StringDataSource alloc] initWithItems:genre[@"items"]];
            genreDataSource.title = genre[@"genre_name"];
            [mealDataSource addDataSource:genreDataSource];
        }
        
        [dataSources addObject:mealDataSource];
        [self addDataSource:mealDataSource];
    }
}

-(void)setupWithNoContent {
    /*
    PlaceholderDataSource *placeholder = [[PlaceholderDataSource alloc] init];
    placeholder.title = @"Dining Hall Closed";
    placeholder.noContentTitle = @"Dining Hall Closed";
    placeholder.noContentMessage = @"Please check back later";
    
    [self addDataSource:placeholder];
     */
}

-(void)loadContent{
    if (!self.serializedDiningHall) {
        [super loadContent];
        return;
    }
    
    [self loadContentWithBlock:^(AAPLLoading *loading) {
       [[RUFoodDataLoadingManager sharedInstance] getSerializedDiningHall:self.serializedDiningHall withCompletion:^(DataTuple *diningHall, NSError *error) {
           if (diningHall) {
               if ([diningHall.object isDiningHallOpen]) {
                   [loading updateWithContent:^(typeof(self) me) {
                       me.diningHall = diningHall.object;
                       [me setupWithDiningHall:diningHall.object];
                   }];
               } else {
                   [loading updateWithNoContent:^(typeof(self) me) {
                       [me setupWithNoContent];
                   }];
               }
           } else {
               [loading doneWithError:error];
           }
       }];
    }];
}
@end






