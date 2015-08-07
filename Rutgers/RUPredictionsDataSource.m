//
//  RUPredictionsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsDataSource.h"
#import "RUBusDataLoadingManager.h"
#import "RUPredictionsExpandingSection.h"
#import "RUPredictionsHeaderTableViewCell.h"
#import "RUPredictionsBodyTableViewCell.h"

#import "RUPredictionsHeaderRow.h"
#import "RUPredictionsBodyRow.h"
#import "DataSource_Private.h"

#import "RUBusRoute.h"
#import "RUMultiStop.h"
#import "RUBusStop.h"

@interface RUPredictionsDataSource ()
@property id item;
@end

@implementation RUPredictionsDataSource

-(instancetype)initWithItem:(id)item{
    self = [super init];
    if (self) {
        self.item = item;
        self.noContentTitle = @"No predictions available";
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] getPredictionsForItem:self.item completion:^(NSArray *predictions, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            if (!error) {
                if (predictions.count) {
                    [loading updateWithContent:^(typeof(self) me) {
                        [me parseResponse:predictions];
                    }];
                } else {
                    [loading updateWithNoContent:^(typeof(self) me) {
                        self.sections = nil;
                    }];
                }

            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

-(void)parseResponse:(NSArray *)response{
    NSMutableArray *sections = [NSMutableArray array];
    
    for (NSDictionary *predictions in [self reorderResponse:response]) {
        [sections addObject:[[RUPredictionsExpandingSection alloc] initWithPredictions:predictions forItem:self.item]];
    }
    
    [self restoreExpansionStateFromCurrentSectionsToNewSections:sections];
    
    self.sections = sections;
}

-(NSArray *)reorderResponse:(NSArray *)response{
    
    if ([self.item isKindOfClass:[RUMultiStop class]]) {
        response = [response sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"_routeTitle" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"_routeTitle" ascending:YES]]];
    } else if ([self.item isKindOfClass:[RUBusRoute class]]){
        RUBusRoute *route = self.item;
        response = [response sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSInteger indexOne = [route.stops indexOfObject:obj1[@"_stopTag"]];
            NSInteger indexTwo = [route.stops indexOfObject:obj2[@"_stopTag"]];
            return compare(indexOne, indexTwo);
        }];
    }
    
    return response;
}

-(void)restoreExpansionStateFromCurrentSectionsToNewSections:(NSArray *)newSections{
    if (!self.sections.count) return;
    
    NSMutableSet *expandedSections = [NSMutableSet set];
    for (RUPredictionsExpandingSection *section in self.sections) {
        if (section.expanded) [expandedSections addObject:section.identifier];
    }
    
    for (RUPredictionsExpandingSection *section in newSections) {
        section.expanded = [expandedSections containsObject:section.identifier];
    }
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUPredictionsBodyTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUPredictionsBodyTableViewCell class])];
    [tableView registerClass:[RUPredictionsHeaderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUPredictionsHeaderTableViewCell class])];
}

@end
