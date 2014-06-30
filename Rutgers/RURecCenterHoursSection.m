//
//  RURecHoursSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterHoursSection.h"
#import "RURecCenterHoursHeaderRow.h"
#import "RURecCenterMeetingAreaRow.h"

@interface RURecCenterHoursSection ()
@property (nonatomic) NSDictionary *meetingAreas;

@property (nonatomic) NSDateComponents *currentDateComponents;
@property (nonatomic) NSArray *allDateComponents;
@property NSInteger currentDateIndex;

@property (nonatomic) NSMutableArray *rows;

@property (nonatomic) RURecCenterHoursHeaderRow *headerRow;
@end

@implementation RURecCenterHoursSection

-(instancetype)initWithMeetingAreas:(NSDictionary *)meetingAreas{
    self = [super initWithSectionTitle:@"Hours"];
    if (self) {
        self.meetingAreas = meetingAreas;
        
        NSArray *areaLabels = [[meetingAreas allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSMutableSet *dates = [NSMutableSet set];
        
        [meetingAreas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [dates addObjectsFromArray:[obj allKeys]];
        }];

        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        self.currentDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
        
        self.allDateComponents = [self componentsForDateStrings:dates];
        if (!self.allDateComponents.count) self.allDateComponents = @[self.currentDateComponents];
        

        self.currentDateIndex = [self.allDateComponents indexOfObject:self.currentDateComponents inSortedRange:NSMakeRange(0, self.allDateComponents.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [self compareComponents:obj1 withComponents:obj2];
        }];
        
        RURecCenterHoursHeaderRow *header = [[RURecCenterHoursHeaderRow alloc] init];
        header.shouldHighlight = NO;
        header.date = NSStringFromDateComponents(self.currentDateComponents);
        [self addRow:header];
        self.headerRow = header;
        [self updateDate];
        
        for (NSString *meetingArea in areaLabels) {
            NSDictionary *datesForArea = meetingAreas[meetingArea];
            RURecCenterMeetingAreaRow *row = [[RURecCenterMeetingAreaRow alloc] initWithArea:meetingArea times:datesForArea];
            row.shouldHighlight = NO;
            [self addRow:row];
        }
        
        [self updateDate];

    }
    return self;
}

-(void)goLeft{
    if (self.currentDateIndex == 0) return;
    self.currentDateIndex--;
    [self updateDate];
}

-(void)goRight{
    if (self.currentDateIndex == self.allDateComponents.count - 1) return;
    self.currentDateIndex++;
    [self updateDate];
}

-(void)updateDate{
    NSString *date = NSStringFromDateComponents(self.allDateComponents[self.currentDateIndex]);
    [self.rows makeObjectsPerformSelector:@selector(setDate:) withObject:date];
    
    self.headerRow.leftButtonEnabled = !(self.currentDateIndex == 0);
    self.headerRow.rightButtonEnabled = !(self.currentDateIndex == self.allDateComponents.count - 1);

}

NSString *NSStringFromDateComponents(NSDateComponents *dateComponents){
    return [NSString stringWithFormat:@"%ld/%ld/%ld",(long)dateComponents.month,(long)dateComponents.day,(long)dateComponents.year];
}

-(NSArray *)componentsForDateStrings:(NSSet *)dateStrings{
    NSMutableArray *allDateComponents = [NSMutableArray array];
    for (NSString *dateString in dateStrings) {
        NSArray *components = [dateString componentsSeparatedByString:@"/"];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        
        [dateComponents setDay:[components[1] integerValue]];
        [dateComponents setMonth:[components[0] integerValue]];
        [dateComponents setYear:[components[2] integerValue]];
        
        [allDateComponents addObject:dateComponents];
    }
    return [allDateComponents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self compareComponents:obj1 withComponents:obj2];
    }];
}
NSComparisonResult compare(NSInteger int1, NSInteger int2){
    if (int1 < int2) return NSOrderedAscending;
    if (int1 > int2) return NSOrderedDescending;
    return NSOrderedSame;
};
-(NSComparisonResult)compareComponents:(NSDateComponents *)comps1 withComponents:(NSDateComponents *)comps2{

    NSComparisonResult year = compare(comps1.year,comps2.year);
    if (year != NSOrderedSame) return year;
    
    NSComparisonResult month = compare(comps1.month,comps2.month);
    if (month != NSOrderedSame) return month;
    
    NSComparisonResult day = compare(comps1.day,comps2.day);
    if (day != NSOrderedSame) return day;
    
    return NSOrderedSame;
}
@end
