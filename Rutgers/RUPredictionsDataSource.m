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

#import "RUBusMultipleStopsForSingleLocation.h"
#import "RUBusRoute.h"

#import "TextViewDataSource.h"


/*
    This class obtains the prediction using the rubusdataloading manager
    This class and another class containing the messages will be placed in a composed data source and that will be displayed..

 */
@interface RUPredictionsDataSource ()
@end

@implementation RUPredictionsDataSource


-(instancetype)initWithItem:(id)item
{
    self = [super init];
    if (self)
    {
        self.item = item;
        self.noContentTitle = @"No predictions available";
       
    }
    return self;
}

/*
    Add the objects which were recieved in the data request to the data source
 
 */
-(void)updateSectionsForResponse:(NSArray *)response
{
    NSMutableArray *sections = [NSMutableArray array];
    
    for (RUBusPrediction *prediction in response)
    {
        [sections addObject:[[RUPredictionsExpandingSection alloc] initWithPredictions:prediction forItem:self.item]];
    }

    [self restoreExpansionStateFromCurrentSectionsToNewSections:sections];
    
    self.sections = sections;
}

-(void)restoreExpansionStateFromCurrentSectionsToNewSections:(NSArray *)newSections
{
    if (!self.sections.count) return;
    
    NSMutableSet *expandedSections = [NSMutableSet set];
    for (RUPredictionsExpandingSection *section in self.sections) // store the sections that are already expanded
    {
        if (section.expanded) [expandedSections addObject:section.identifier];
    }
    
    for (RUPredictionsExpandingSection *section in newSections) // change the sections that were previosuly expanded to be expanded.
    {
        section.expanded = [expandedSections containsObject:section.identifier];
    }
    
    /*
        This is done when say a section is removed or added . Or refresed and we want to save which of the sections the user has expanded and expand them again , if they are present  in the new state
     */
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView
{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUPredictionsBodyTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUPredictionsBodyTableViewCell class])];
    [tableView registerClass:[RUPredictionsHeaderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUPredictionsHeaderTableViewCell class])];
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];

    
    
    [super configureCell:cell forRowAtIndexPath:indexPath];
}
    


@end
