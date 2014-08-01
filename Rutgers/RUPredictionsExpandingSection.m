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

@interface RUPredictionsExpandingSection ()
@property RUPredictionsHeaderRow *headerRow;
@property RUPredictionsBodyRow *bodyRow;

@end

@implementation RUPredictionsExpandingSection
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item{
 
    self = [super init];
    if (self) {
        self.headerRow = [[RUPredictionsHeaderRow alloc] initWithPredictions:predictions forItem:item];
        self.bodyRow = [[RUPredictionsBodyRow alloc] initWithPredictionTimes:[predictions[@"direction"] firstObject][@"prediction"]];
        self.items = @[self.headerRow, self.bodyRow];
        self.identifier = [NSString stringWithFormat:@"%@%@",predictions[@"_stopTag"],predictions[@"_routeTag"]];
    }
    return self;
}

-(BOOL)expanded{
    return [super expanded] && self.headerRow.active;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewAbstractRow *item = [self itemAtIndexPath:indexPath];
    
    id cell = [tableView dequeueReusableCellWithIdentifier:item.identifier];
    [item setupCell:cell];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}
@end
