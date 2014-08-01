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

@interface RUPredictionsDataSource ()
@property id item;
@end

@implementation RUPredictionsDataSource

-(id)initWithItem:(id)item{
    self = [super init];
    if (self) {
        self.item = item;
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUBusDataLoadingManager sharedInstance] getPredictionsForItem:self.item withSuccess:^(NSArray *response) {
            [loading updateWithContent:^(typeof(self) me) {
                [me parseResponse:response];
            }];
        } failure:^{
            
        }];
    }];
}

-(void)parseResponse:(NSArray *)response{
    NSMutableArray *sections = [NSMutableArray array];
    
    for (NSDictionary *predictions in response) {
        [sections addObject:[[RUPredictionsExpandingSection alloc] initWithPredictions:predictions forItem:self.item]];
    }
    
    [self restoreExpansionStateFromCurrentSectionsToNewSections:sections];
    
    self.sections = sections;
}

-(void)restoreExpansionStateFromCurrentSectionsToNewSections:(NSArray *)sections{
    NSMutableDictionary *expandedSections = [NSMutableDictionary dictionary];
    for (RUPredictionsExpandingSection *section in self.sections) {
        expandedSections[section.identifier] = @(section.expanded);
    }
    
    for (RUPredictionsExpandingSection *section in sections) {
        section.expanded = [expandedSections[section.identifier] boolValue];
    }
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUPredictionsBodyTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUPredictionsBodyTableViewCell class])];
    [tableView registerClass:[RUPredictionsHeaderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUPredictionsHeaderTableViewCell class])];
}

@end
