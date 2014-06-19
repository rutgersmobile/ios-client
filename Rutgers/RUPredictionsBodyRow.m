//
//  RUPredictionsExtraRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPredictionsBodyRow.h"

@interface RUPredictionsBodyRow ()
@end

@implementation RUPredictionsBodyRow
-(instancetype)initWithPredictionTimes:(NSArray *)predictionTimes{
    self = [super init];
    if (self) {
        self.predictionTimes = predictionTimes;
    }
    return self;
}

@synthesize predictionTimes = _predictionTimes;

-(void)setPredictionTimes:(NSArray *)predictionTimes{
    @synchronized(_predictionTimes) {
        _predictionTimes = predictionTimes;
        self.attributedString = [self labelString];
    }
}

-(NSArray *)predictionTimes{
    return _predictionTimes;
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
-(NSAttributedString *)labelString{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:16]};
    NSDictionary *boldAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
    
    NSMutableAttributedString *labelString = [[NSMutableAttributedString alloc] init];
    for (NSDictionary *prediction in self.predictionTimes) {
        NSString *minutes = prediction[@"_minutes"];
        NSInteger seconds = [prediction[@"_seconds"] integerValue];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:seconds];
  
        NSString *minutesString = [NSString stringWithFormat:@"%@ minutes at ",minutes];
        NSString *timeString = [NSString stringWithFormat:@"%@ \n",[self formatDate:date]];
        
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:minutesString attributes:attributes]];
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:timeString attributes:boldAttributes]];
    }
    return labelString;
}
@end
