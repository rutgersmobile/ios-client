//
//  RUPredictionsExtraRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyRow.h"
#import "NSDate+EpochTime.h"
#import "RUBusPrediction.h"
#import "RUBusArrival.h"

/***
 
 Displays output for expanded cells withing the RUBusPredictionVC
 
 ***/


@implementation RUPredictionsBodyRow
-(instancetype)initWithPredictions:(RUBusPrediction *)predictions{
    self = [super init];
    
    if (self) {
        self.predictionTimes = predictions.arrivals;
        self.stop = predictions.stopTitle;
        self.precdictionsSaved = predictions;
    }
    return self;
}

-(void)setPredictionTimes:(NSArray *)predictionTimes{
    _predictionTimes = predictionTimes;
    
    NSMutableString *minutesString = [NSMutableString new];
    NSMutableString *descriptionString = [NSMutableString new];
    NSMutableString *timeString = [NSMutableString new];
    NSMutableArray *vehicleArray = [NSMutableArray new];

    
    [self.predictionTimes enumerateObjectsUsingBlock:^(RUBusArrival *arrivals, NSUInteger idx, BOOL *stop) {
        NSInteger minutes = arrivals.minutes;
        NSInteger seconds = arrivals.seconds;
        NSString *vehicle = arrivals.vehicle;
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:seconds];
        
        if (idx != 0) {
            [minutesString appendString:@"\n"];
            [descriptionString appendString:@"\n"];
            [timeString appendString:@"\n"];
        }
        
        if (minutes == 0) {
            [minutesString appendFormat:@"%ld",(long)seconds];
            [descriptionString appendString:@"seconds at"];
        } else {
            [minutesString appendFormat:@"%ld",(long)minutes];
            if (minutes == 1) {
                [descriptionString appendString:@"minute at"];
            } else {
                [descriptionString appendString:@"minutes at"];
            }
        }
        [timeString appendString:[self formatDate:date]];
        
        [timeString appendFormat:@" - Bus #%@", vehicle];
        
        //Checks to see if there is a duplicate vehicle number object to be added in the vehicle array
        
        BOOL objectIsSame = NO;
        
        if (vehicleArray.count == 0) {
            [vehicleArray addObject:vehicle];
        } else {
            for (NSString* check in vehicleArray) {
                if (check == vehicle) {
                    objectIsSame = YES;
                } else if (objectIsSame == NO && check == vehicleArray.lastObject) {
                    [vehicleArray addObject:vehicle];
                }
            }
        }
        
    }];

    self.minutesString = minutesString;
    self.descriptionString = descriptionString;
    self.timeString = timeString;
    self.vehicleArray = vehicleArray;
    
    
}

-(NSString *)formatDate:(NSDate *)date{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    return [dateFormatter stringFromDate:date];
}
@end
