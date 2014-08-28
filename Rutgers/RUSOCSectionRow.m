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
@property (nonatomic) NSString *indexText;
@property (nonatomic) NSString *professorText;
@property (nonatomic) NSString *descriptionText;
@property (nonatomic) NSString *dayText;
@property (nonatomic) NSString *timeText;
@property (nonatomic) NSString *locationText;
@end

@implementation RUSOCSectionRow
-(instancetype)initWithSection:(NSDictionary *)section{
    self = [super init];
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
    self.professorText = [[self.section[@"instructors"] valueForKey:@"name"] componentsJoinedByString:@"\n"];
    self.descriptionText = self.section[@"sectionNotes"];
    
    NSMutableString *mutableDayString = [[NSMutableString alloc] init];
    NSMutableString *mutableTimeString = [[NSMutableString alloc] init];
    NSMutableString *mutableLocationString = [[NSMutableString alloc] init];
    
    
    NSArray *meetingTimes = [self sortMeetingTimesByDay:self.section[@"meetingTimes"]];
    
    [meetingTimes enumerateObjectsUsingBlock:^(NSDictionary *meetingTime, NSUInteger idx, BOOL *stop) {
      
        if (idx != 0) {
            [mutableDayString appendString:@"\n"];
            [mutableTimeString appendString:@"\n"];
            [mutableLocationString appendString:@"\n"];
        }
        
        NSString *meetingDay = meetingTime[@"meetingDay"];
        if (meetingDay) {
            [mutableDayString appendString:meetingDay];
        }
        
        NSString *startTime = meetingTime[@"startTime"];
        NSString *endTime = meetingTime[@"endTime"];
        
        if (startTime || endTime) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            
            NSInteger startHour = [[numberFormatter numberFromString:[startTime substringToIndex:2]] integerValue];
            NSInteger endHour = [[numberFormatter numberFromString:[endTime substringToIndex:2]] integerValue];

            NSString *pmCode = meetingTime[@"pmCode"];
            if (startHour  > endHour || (startHour < 12 && endHour >= 12)) pmCode = @"P";
            
            if ([pmCode isEqualToString:@"A"]) {
                pmCode = @"AM";
            } else if ([pmCode isEqualToString:@"P"]) {
                pmCode = @"PM";
            }
            
            [mutableTimeString appendFormat:@"%ld:%@-%ld:%@ %@",(long)startHour,[startTime substringFromIndex:2],(long)endHour,[endTime substringFromIndex:2],pmCode];
        }
        
        if (meetingDay) {
            NSString *campusAbbrev = meetingTime[@"campusAbbrev"];
            NSString *buildingCode = meetingTime[@"buildingCode"];
            NSString *roomNumber = meetingTime[@"roomNumber"];
            
            if (campusAbbrev) [mutableLocationString appendFormat:@"%@ ",campusAbbrev];
            if (buildingCode) [mutableLocationString appendFormat:@"%@ ",buildingCode];
            if (roomNumber) [mutableLocationString appendString:roomNumber];
        }

    }];

    if (mutableDayString.length || mutableTimeString.length || mutableLocationString.length) {
        self.dayText = [mutableDayString copy];
        self.timeText = [mutableTimeString copy];
        self.locationText = [mutableLocationString copy];
    } else {
        self.timeText = @"Hours by arr.";
    }

}

-(NSArray *)sortMeetingTimesByDay:(NSArray *)meetingTimes{
    return [meetingTimes sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *meetingTimeOne, NSDictionary *meetingTimeTwo) {
        NSUInteger indexOne = [self indexOfDay:meetingTimeOne[@"meetingDay"]];
        NSUInteger indexTwo = [self indexOfDay:meetingTimeTwo[@"meetingDay"]];
        
        NSComparisonResult result = compare(indexOne, indexTwo);
        if (result != NSOrderedSame) return result;
        
        NSString *pmCodeOne = meetingTimeOne[@"pmCode"];
        NSString *pmCodeTwo = meetingTimeTwo[@"pmCode"];
        
        if ([pmCodeOne isEqualToString:@"A"] && [pmCodeTwo isEqualToString:@"P"]) {
            return NSOrderedAscending;
        } else if ([pmCodeOne isEqualToString:@"P"] && [pmCodeTwo isEqualToString:@"A"]) {
            return NSOrderedDescending;
        }
        //time and am pm code
        
        NSString *startTimeOne = meetingTimeOne[@"startTime"];
        NSString *startTimeTwo = meetingTimeTwo[@"startTime"];
        
        return [startTimeOne compare:startTimeTwo options:NSNumericSearch];
    }];
}

-(NSUInteger)indexOfDay:(NSString *)day{
    return [@[@"U",@"M",@"T",@"W",@"TH",@"F",@"S"] indexOfObject:day];
}

@end
