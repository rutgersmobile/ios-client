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
#import "NSDictionary+DiningHall.h"
#import "RUFoodDataLoadingManager.h"

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
        [[RUFoodDataLoadingManager sharedInstance] getDiningHallsWithCompletion:^(NSArray *diningHalls, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }

            if (diningHalls) {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = diningHalls;
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}
-(void)configureCell:(ALTableViewTextCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [super configureCell:cell forRowAtIndexPath:indexPath];
    DataTuple *diningHall = [self itemAtIndexPath:indexPath];
    BOOL open = [diningHall.object isDiningHallOpen];
    cell.textLabel.textColor = open ? [UIColor blackColor] : [UIColor grayColor];
    cell.accessoryType = open ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

@end
