//
//  RUPredictionsExtraRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyRow.h"
#import "RUPredictionsBodyTableViewCell.h"

@interface RUPredictionsBodyRow ()
@end

@implementation RUPredictionsBodyRow
-(instancetype)initWithPredictionTimes:(NSArray *)predictionTimes{
    self = [super initWithIdentifier:@"RUPredictionsBodyTableViewCell"];
    if (self) {
        self.predictionTimes = predictionTimes;
    }
    return self;
}

-(void)setupCell:(RUPredictionsBodyTableViewCell *)cell{
    NSMutableString *labelString = [[NSMutableString alloc] init];
    for (NSDictionary *prediction in self.predictionTimes) {
        [labelString appendFormat:@"%@ minutes \n",prediction[@"_minutes"]];
    }
    cell.label.text = labelString;
}
@end
