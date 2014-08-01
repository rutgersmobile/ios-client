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
@property (nonatomic) NSString *minutesString;
@property (nonatomic) NSString *descriptionString;
@property (nonatomic) NSString *timeString;
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
    cell.minutesLabel.text = self.minutesString;
    cell.descriptionLabel.text = self.descriptionString;
    cell.timeLabel.text = self.timeString;
}

-(void)setPredictionTimes:(NSArray *)predictionTimes{
    _predictionTimes = predictionTimes;
    
    NSMutableString *minutesString = [NSMutableString new];
    NSMutableString *descriptionString = [NSMutableString new];
    NSMutableString *timeString = [NSMutableString new];
    
    for (NSDictionary *prediction in self.predictionTimes) {
        NSString *minutes = prediction[@"_minutes"];
        NSString *seconds = prediction[@"_seconds"];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:[seconds integerValue]];
       
        if ([minutes integerValue] == 0) {
            [minutesString appendFormat:@"%@\n",seconds];
            [descriptionString appendString:@"seconds at\n"];
        } else {
            [minutesString appendFormat:@"%@\n",minutes];
            if ([minutes integerValue] == 1) {
                [descriptionString appendString:@"minute at\n"];
            } else {
                [descriptionString appendString:@"minutes at\n"];

            }
        }
        [timeString appendFormat:@"%@\n",[self formatDate:date]];
    }
    
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
}/*

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
}*/
@end
