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
        [self makeTextStrings];
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
        cell.backgroundColor = [UIColor colorWithRed:217/255.0 green:242/255.0 blue:213/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:243/255.0 green:181/255.0 blue:181/255.0 alpha:1];
    }
}

-(void)makeTextStrings{
    self.indexText = [NSString stringWithFormat:@"%@ %@",self.section[@"number"],self.section[@"index"]];
    self.professorText = [self.section[@"instructors"] firstObject][@"name"];
    self.descriptionText = self.section[@"sectionNotes"];
    
    NSMutableString *mutableDayString = [[NSMutableString alloc] init];
    NSMutableString *mutableTimeString = [[NSMutableString alloc] init];
    NSMutableString *mutableLocationString = [[NSMutableString alloc] init];

    for (NSDictionary *meetingTime in self.section[@"meetingTimes"]) {
        NSString *meetingDay = meetingTime[@"meetingDay"];
        if (meetingDay) {
            [mutableDayString appendString:meetingDay];
            [mutableDayString appendString:@"\n"];
        }
        
        NSString *startTime = meetingTime[@"startTime"];
        NSString *endTime = meetingTime[@"endTime"];
        
        if (startTime || endTime) {
            [mutableTimeString appendString:[NSString stringWithFormat:@"%@:%@ - %@:%@",[startTime substringToIndex:2],[startTime substringFromIndex:2],[endTime substringToIndex:2],[endTime substringFromIndex:2]]];
            [mutableTimeString appendString:@"\n"];
        }
        
        NSString *campusAbbrev = meetingTime[@"campusAbbrev"];
        NSString *buildingCode = meetingTime[@"buildingCode"];
        NSString *roomNumber = meetingTime[@"roomNumber"];

        if (meetingDay) {
            [mutableLocationString appendString:[NSString stringWithFormat:@"%@ %@ %@",campusAbbrev,buildingCode,roomNumber]];
            [mutableLocationString appendString:@"\n"];
        }
    }

    if (mutableDayString.length || mutableTimeString.length || mutableLocationString.length) {
        self.dayText = [mutableDayString copy];
        self.timeText = [mutableTimeString copy];
        self.locationText = [mutableLocationString copy];
    } else {
        self.timeText = @"Hours by arr.";
    }

}

@end
