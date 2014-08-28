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
#import "DataSource_Private.h"
#import "NSIndexPath+RowExtensions.h"

@interface RURecCenterHoursSection ()
@property (nonatomic) NSDictionary *meetingAreas;

@property (nonatomic) NSDateComponents *currentDateComponents;
@property (nonatomic) NSArray *allDateComponents;
@property (nonatomic) NSInteger todaysDateIndex;
@property (nonatomic) NSInteger selectedDateIndex;

@property (nonatomic) RURecCenterHoursHeaderRow *headerRow;
@end

@implementation RURecCenterHoursSection

-(instancetype)initWithMeetingAreas:(NSDictionary *)meetingAreas{
    self = [super initWithSectionTitle:@"Hours"];
    if (self) {
        self.meetingAreas = meetingAreas;
        
        NSArray *areaLabels = [[meetingAreas allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        RURecCenterHoursHeaderRow *header = [[RURecCenterHoursHeaderRow alloc] init];
        header.shouldHighlight = NO;
        header.date = NSStringFromDateComponents(self.currentDateComponents);
        [self addItem:header];
        self.headerRow = header;
        
        for (NSString *meetingArea in areaLabels) {
            NSDictionary *datesForArea = meetingAreas[meetingArea];
            RURecCenterMeetingAreaRow *row = [[RURecCenterMeetingAreaRow alloc] initWithArea:meetingArea times:datesForArea];
            row.shouldHighlight = NO;
            [self addItem:row];
        }
        
        NSMutableSet *dates = [NSMutableSet set];
        
        [meetingAreas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [dates addObjectsFromArray:[obj allKeys]];
        }];

        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        self.currentDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
        
        self.allDateComponents = componentsForDateStrings(dates);
        if (!self.allDateComponents.count) self.allDateComponents = @[self.currentDateComponents];
        
        self.todaysDateIndex = [self.allDateComponents indexOfObject:self.currentDateComponents inSortedRange:NSMakeRange(0, self.allDateComponents.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
            return compareComponents(obj1, obj2);
        }];
        
        if (self.todaysDateIndex != NSNotFound) {
            self.selectedDateIndex = self.todaysDateIndex;
        } else {
            self.selectedDateIndex = self.allDateComponents.count-1;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goLeft) name:@"RecCenterHeaderLeft" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goRight) name:@"RecCenterHeaderRight" object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)goLeft{
    if (self.selectedDateIndex == 0) return;
    self.selectedDateIndex--;
    [self updateDateWithDirection:DataSourceOperationDirectionRight];
}

-(void)goRight{
    if (self.selectedDateIndex == self.allDateComponents.count - 1) return;
    self.selectedDateIndex++;
    [self updateDateWithDirection:DataSourceOperationDirectionLeft];
}

-(void)setSelectedDateIndex:(NSInteger)selectedDateIndex{
    _selectedDateIndex = selectedDateIndex;
    NSString *date = NSStringFromDateComponents(self.allDateComponents[self.selectedDateIndex]);
    [self.items makeObjectsPerformSelector:@selector(setDate:) withObject:date];
    
    if (self.selectedDateIndex == self.todaysDateIndex) {
        self.headerRow.date = @"Today";
    } else if (self.selectedDateIndex == self.todaysDateIndex - 1) {
        self.headerRow.date = @"Yesterday";
    } else if (self.selectedDateIndex == self.todaysDateIndex + 1) {
        self.headerRow.date = @"Tomorrow";
    }
    
    self.headerRow.leftButtonEnabled = !(self.selectedDateIndex == 0);
    self.headerRow.rightButtonEnabled = !(self.selectedDateIndex == self.allDateComponents.count - 1);
}

-(void)updateDateWithDirection:(DataSourceOperationDirection)direction{
    [self invalidateCachedHeightsForSection:0];
    [self notifyItemsRefreshedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, [self numberOfItemsInSection:0]) inSection:0] direction:direction];
}

NSString *NSStringFromDateComponents(NSDateComponents *dateComponents){
    return [NSString stringWithFormat:@"%ld/%ld/%ld",(long)dateComponents.month,(long)dateComponents.day,(long)dateComponents.year];
}

NSArray *componentsForDateStrings(NSSet *dateStrings){
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
        return compareComponents(obj1, obj2);
    }];
}

NSComparisonResult compareComponents(NSDateComponents *comps1, NSDateComponents *comps2){

    NSComparisonResult year = compare(comps1.year,comps2.year);
    if (year != NSOrderedSame) return year;
    
    NSComparisonResult month = compare(comps1.month,comps2.month);
    if (month != NSOrderedSame) return month;
    
    NSComparisonResult day = compare(comps1.day,comps2.day);
    if (day != NSOrderedSame) return day;
    
    return NSOrderedSame;
}

@end
