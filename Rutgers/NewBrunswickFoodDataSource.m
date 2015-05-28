//
//  NewBrunswickFoodDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NewBrunswickFoodDataSource.h"
#import "DataTuple.h"
#import "ALTableViewTextCell.h"
#import "DataSource_Private.h"

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
        [[RUNetworkManager sessionManager] GET:@"rutgers-dining.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSArray *parsedDiningHalls = [self parseResponse:responseObject];
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = parsedDiningHalls;
                }];
            } else {
                [loading doneWithError:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            [loading doneWithError:error];
        }];
    }];
}

-(NSArray *)parseResponse:(NSArray *)response{
    NSMutableArray *parsedDiningHalls = [NSMutableArray array];
    for (NSDictionary *diningHall in response) {
        DataTuple *parsedDiningHall = [[DataTuple alloc] initWithTitle:diningHall[@"location_name"] object:diningHall];
        [parsedDiningHalls addObject:parsedDiningHall];
    }
    return parsedDiningHalls;
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
