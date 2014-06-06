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
@property (nonatomic) RUPredictionsHeaderRow *headerRow;
@property (nonatomic) RUPredictionsBodyRow *bodyRow;
@end

@implementation RUPredictionsExpandingSection
-(instancetype)initWithPredictions:(NSDictionary *)predictions forItem:(id)item{
    RUPredictionsHeaderRow *headerRow = [[RUPredictionsHeaderRow alloc] initWithPredictions:predictions forItem:item];
    RUPredictionsBodyRow *bodyRow = [[RUPredictionsBodyRow alloc] initWithPredictionTimes:[predictions[@"direction"] firstObject][@"prediction"]];
    self = [super initWithHeaderRow:headerRow bodyRows:@[bodyRow]];
    if (self) {
        self.headerRow = headerRow;
        self.bodyRow = bodyRow;
    }
    return self;
}

-(void)updateWithPredictions:(NSDictionary *)predictions{
    self.headerRow.predictions = predictions;
    self.bodyRow.predictionTimes = [predictions[@"direction"] firstObject][@"prediction"];
}

-(BOOL)active{
    return self.headerRow.active;
}
-(BOOL)expanded{
    return [super expanded] && [self active];
}
@end
