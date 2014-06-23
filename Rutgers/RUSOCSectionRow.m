//
//  RUSOCSectionRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSectionRow.h"
#import "RUSOCSectionCell.h"
#import "UIColor+Utilities.h"

@interface RUSOCSectionRow ()
@property NSDictionary *section;
@property NSString *indexText;
@property NSString *professorText;
@property NSString *descriptionText;
@property NSString *dayText;
@property NSString *timeText;
@property NSString *locationText;
@end

@implementation RUSOCSectionRow
-(instancetype)initWithSection:(NSDictionary *)section{
    self = [super initWithIdentifier:@"RUSOCSectionCell"];
    if (self) {
        self.section = section;
        self.indexText = [NSString stringWithFormat:@"%@ %@",[self stringForKeypath:@"number"],[self stringForKeypath:@"index"]];
        self.professorText = [self.section[@"instructors"] firstObject][@"name"];
        self.descriptionText = [self stringForKeypath:@"sectionNotes"];
        [self makeOtherTextStrings];
    }
    return self;
}

-(void)setupCell:(RUSOCSectionCell *)cell{
    cell.indexLabel.text = self.indexText;
    cell.professorLabel.text = self.professorText;
    cell.descriptionLabel.text = self.descriptionText;
    cell.dayLabel.text = self.dayText;
    cell.timeLabel.text = self.timeText;
    cell.locationLabel.text = self.locationText;
    if ([self.section[@"openStatus"] boolValue]) {
        cell.backgroundColor = [UIColor colorWithRed:244/255.0 green:201/255.0 blue:181/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:217/255.0 green:242/255.0 blue:213/255.0 alpha:1];
    }
}

-(NSString *)stringForKeypath:(NSString *)keypath{
    return [self dictionary:self.section stringFromKeypath:keypath];
}

-(NSString *)dictionary:(NSDictionary *)dictionary stringFromKeypath:(NSString *)keypath{
    NSString *value = [dictionary valueForKeyPath:keypath];
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

-(void)makeOtherTextStrings{
    NSMutableString *mutableDayString = [[NSMutableString alloc] init];
    NSMutableString *mutableTimeString = [[NSMutableString alloc] init];
    NSMutableString *mutableLocationString = [[NSMutableString alloc] init];

    for (NSDictionary *meetingTime in self.section[@"meetingTimes"]) {
        NSString *meetingDay = [self dictionary:meetingTime stringFromKeypath:@"meetingDay"];
        if (meetingDay) {
            [mutableDayString appendString:meetingDay];
            [mutableDayString appendString:@"\n"];
        }
        
        NSString *startTime = [self dictionary:meetingTime stringFromKeypath:@"startTime"];
        NSString *endTime = [self dictionary:meetingTime stringFromKeypath:@"endTime"];
        
        if (startTime || endTime) {
            [mutableTimeString appendString:[NSString stringWithFormat:@"%@:%@ - %@:%@",[startTime substringToIndex:2],[startTime substringFromIndex:2],[endTime substringToIndex:2],[endTime substringFromIndex:2]]];
            [mutableTimeString appendString:@"\n"];
        }
        
        NSString *campusAbbrev = [self dictionary:meetingTime stringFromKeypath:@"campusAbbrev"];
        NSString *buildingCode = [self dictionary:meetingTime stringFromKeypath:@"buildingCode"];
        NSString *roomNumber = [self dictionary:meetingTime stringFromKeypath:@"roomNumber"];

        if (meetingDay) {
            [mutableLocationString appendString:[NSString stringWithFormat:@"%@ %@ %@",campusAbbrev,buildingCode,roomNumber]];
            [mutableLocationString appendString:@"\n"];
        }
    }

    self.dayText = [mutableDayString copy];
    self.timeText = [mutableTimeString copy];
    self.locationText = [mutableLocationString copy];
}

@end
