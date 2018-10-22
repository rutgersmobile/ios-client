//
//  RUPredictionsHeaderRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsHeaderRow.h"
#import "RUBusRoute.h"
#import "RUBusMultipleStopsForSingleLocation.h"
#import "HexColors.h"
#import "RUPredictionsHeaderTableViewCell.h"

#import "RUBusPrediction.h"
#import "RUBusArrival.h"

@interface RUPredictionsHeaderRow ()
@property id item;
@property RUBusPrediction *predictions;
@end

@implementation RUPredictionsHeaderRow
-(instancetype)initWithPredictions:(RUBusPrediction *)predictions forItem:(id)item{
    self = [super init];
    if (self) {
        self.item = item;
        self.predictions = predictions;
    }
    return self;
}

-(NSString *)title{
    if ([self.item isKindOfClass:[RUBusRoute class]]) {
        
        return self.predictions.stopTitle;
    } else {
        return self.predictions.routeTitle;
    }
}
/*
-(NSString *)directionTitle{
    if ([self.item isKindOfClass:[RUBusRoute class]]) return nil;
    return self.predictions.directionTitle;
}
 */

-(NSString *)arrivalTimeDescription{
    if (!self.predictions.active) return @"No predictions available.";
  
    NSArray *arrivals = self.predictions.arrivals;
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"Arriving in "];
    
    [arrivals enumerateObjectsUsingBlock:^(RUBusArrival *arrival, NSUInteger idx, BOOL *stop) {
        BOOL lastPrediction = (idx == 2 || idx == arrivals.count - 1);
        
        if (idx != 0){
            if (idx == 1 && lastPrediction) [string appendString:@" "];
            else [string appendString:@", "];
        }
        
        if (idx != 0 && lastPrediction) [string appendString:@"and "];
        
        NSInteger minutes = arrival.minutes;
        
        if (minutes == 0) {
            [string appendString:@"<1"];
        } else {
            [string appendFormat:@"%ld",(long)minutes];
        }

        if (lastPrediction){
            if (minutes == 1) {
                [string appendString:@" minute."];
            } else {
                [string appendString:@" minutes."];
            }
        }
        
        if (idx == 2) *stop = YES;
    }];
    
    
    return string;
}

-(BOOL)active{
    return self.predictions.active;
}

-(UIColor *)timeLabelColor{
    NSInteger minutes = [self.predictions.arrivals.firstObject minutes];
    if (minutes < 2) {
        return [UIColor hx_colorWithHexString:@"#CC0000"];
    } else if (minutes < 6) {
        return [UIColor hx_colorWithHexString:@"#FF6600"];
    } else {
        return [UIColor hx_colorWithHexString:@"#000099"];
    }
}

@end
