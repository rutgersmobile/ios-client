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
                        [me updateSectionsForResponse:predictions];
                    }];
                } else {
                    [loading updateWithNoContent:^(typeof(self) me) {
                        [me updateSectionsForResponse:nil];
                    }];
                }

            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

-(void)updateSectionsForResponse:(NSArray *)response{
    NSMutableArray *sections = [NSMutableArray array];
    
    for (RUBusPrediction *prediction in response) {
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
