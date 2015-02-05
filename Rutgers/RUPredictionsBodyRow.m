//
//  RUPredictionsExtraRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyRow.h"
#import "RUPredictionsBodyTableViewCell.h"
#import "NSDate+EpochTime.h"

@interface RUPredictionsBodyRow ()
@property (nonatomic) NSArray *predictionTimes;
@property (nonatomic) NSString *minutesString;
@property (nonatomic) NSString *descriptionString;
@property (nonatomic) NSString *timeString;
@end

@implementation RUPredictionsBodyRow
-(instancetype)initWithPredictionTimes:(NSArray *)predictionTimes{
    
    self = [super init];
    if (self) {
        self.predictionTimes = predictionTimes;
    }
    return self;
}

-(void)setPredictionTimes:(NSArray *)predictionTimes{
    _predictionTimes = predictionTimes;
    
    NSMutableString *minutesString = [NSMutableString new];
    NSMutableString *descriptionString = [NSMutableString new];
    NSMutableString *timeString = [NSMutableString new];
    
    [self.predictionTimes enumerateObjectsUsingBlock:^(NSDictionary *prediction, NSUInteger idx, BOOL *stop) {
        NSString *minutes = prediction[@"_minutes"];
        NSString *seconds = prediction[@"_seconds"];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:[seconds integerValue]];
        /*
        NSDate *otherDate = [NSDate dateWithEpochTime:prediction[@"_epochTime"]];
        NSLog(@"%f",[date timeIntervalSinceDate:otherDate]);
         */
        
        if (idx != 0) {
            [minutesString appendString:@"\n"];
            [descriptionString appendString:@"\n"];
            [timeString appendString:@"\n"];
        }
        
        if ([minutes integerValue] == 0) {
            [minutesString appendString:seconds];
            [descriptionString appendString:@"seconds at"];
        } else {
            [minutesString appendString:minutes];
            if ([minutes integerValue] == 1) {
                [descriptionString appendString:@"minute at"];
            } else {
                [descriptionString appendString:@"minutes at"];
            }
        }
        [timeString appendString:[self formatDate:date]];
        
    }];

    self.minutesString = minutesString;
    self.descriptionString = descriptionString;
    self.timeString = timeString;
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
