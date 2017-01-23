//
//  RUPredictionsExpandingRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsExpandingSection.h"
#import "RUPredictionsHeaderRow.h"
#import "RUPredictionsBodyRow.h"
#import "DataSource_Private.h"
#import "RUPredictionsHeaderTableViewCell.h"
#import "RUPredictionsBodyTableViewCell.h"
#import "RUBusMultipleStopsForSingleLocation.h"
#import "RUBusPrediction.h"

@interface RUPredictionsExpandingSection ()
@property RUPredictionsHeaderRow *headerRow;
@property RUPredictionsBodyRow *bodyRow;
@end

@implementation RUPredictionsExpandingSection
-(instancetype)initWithPredictions:(RUBusPrediction *)predictions forItem:(id)item{
 
    self = [super init];
    if (self) {
        self.headerRow = [[RUPredictionsHeaderRow alloc] initWithPredictions:predictions forItem:item];
        self.bodyRow = [[RUPredictionsBodyRow alloc] initWithPredictions:predictions];
        self.items = @[self.headerRow, self.bodyRow];
        self.identifier = [NSString stringWithFormat:@"%@%@",predictions.stopTag, predictions.routeTag];
    }
    return self;
}

-(BOOL)expanded{
    return [super expanded] && self.headerRow.active;
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        
        return NSStringFromClass([RUPredictionsHeaderTableViewCell class]);
    }
    return NSStringFromClass([RUPredictionsBodyTableViewCell class]);
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self itemAtIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        RUPredictionsHeaderRow *row = item;
        RUPredictionsHeaderTableViewCell *headerCell = cell;

    
        
        headerCell.titleLabel.text = [row title];
        headerCell.directionLabel.text = [row.item isKindOfClass:[RUBusMultipleStopsForSingleLocation class]] ? [row directionTitle] : nil;
        headerCell.timeLabel.text = [row arrivalTimeDescription];
        if ([row active])
        {
            headerCell.titleLabel.textColor = [UIColor blackColor];
            headerCell.directionLabel.textColor = [UIColor blackColor];
            headerCell.timeLabel.textColor = [row timeLabelColor];
        }
        else
        {
            headerCell.titleLabel.textColor = [UIColor grayColor];
            headerCell.directionLabel.textColor = [UIColor grayColor];
            headerCell.timeLabel.textColor = [UIColor grayColor];
        }
    }
    else
    {
        RUPredictionsBodyRow *row = item;
        RUPredictionsBodyTableViewCell *bodyCell = cell;

        bodyCell.minutesLabel.text = row.minutesString;
        bodyCell.descriptionLabel.text = row.descriptionString;
        bodyCell.timeLabel.text = row.timeString;
       
    }
    
    [super configureCell:cell forRowAtIndexPath:indexPath];
    
}
@end
