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
#import "RUPrediction.h"

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
    NSMutableArray *parsedPredictions = [NSMutableArray array];
    
    for (NSDictionary *predictionDictionary in response) {
        RUPrediction *prediction = [[RUPrediction alloc] initWithDictionary:predictionDictionary];
        [parsedPredictions addObject:prediction];
    }
    
    if ([self.item isKindOfClass:[RUMultiStop class]]) {
        [parsedPredictions sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"active" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"routeTitle" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"directionTitle" ascending:YES]]];
    } else if ([self.item isKindOfClass:[RUBusRoute class]]){
        RUBusRoute *route = self.item;
        [parsedPredictions sortUsingComparator:^NSComparisonResult(RUPrediction *obj1, RUPrediction *obj2) {
            NSInteger indexOne = [route.stops indexOfObject:obj1.stopTag];
            NSInteger indexTwo = [route.stops indexOfObject:obj2.stopTag];
            return compare(indexOne, indexTwo);
        }];
    }
    
    NSMutableArray *sections = [NSMutableArray array];
    
    for (RUPrediction *prediction in parsedPredictions) {
        [sections addObject:[[RUPredictionsExpandingSection alloc] initWithPredictions:prediction forItem:self.item]];
    }

    [self restoreExpansionStateFromCurrentSectionsToNewSections:sections];
    
    self.sections = sections;
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
