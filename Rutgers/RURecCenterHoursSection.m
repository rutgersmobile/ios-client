//
//  RURecHoursSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterHoursSection.h"
#import "RURecCenterHoursHeaderTableViewCell.h"
#import "RURecCenterMeetingAreaTableViewCell.h"
#import "DataSource_Private.h"
#import "NSIndexPath+RowExtensions.h"

@interface RURecCenterHoursSection ()
@property (nonatomic) NSArray *dailySchedules;
@property (nonatomic) NSInteger todaysDateIndex;
@property (nonatomic) NSInteger selectedDateIndex;
@end

@implementation RURecCenterHoursSection
-(instancetype)initWithDailySchedules:(NSArray *)dailySchedules{
    self = [super init];
    if (self) {
        self.title = @"Hours";
        self.dailySchedules = dailySchedules;
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *todaysDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
        
        NSString *todaysDateString = NSStringFromDateComponents(todaysDateComponents);
      
        self.todaysDateIndex = -1;
        _selectedDateIndex = 0;
        [self.dailySchedules enumerateObjectsUsingBlock:^(NSDictionary *dailySchedule, NSUInteger idx, BOOL *stop) {
            NSString *date = dailySchedule[@"date"];
            if ([date isEqualToString:todaysDateString]) {
                self.todaysDateIndex = idx;
                self.selectedDateIndex = idx;
                *stop = YES;
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goLeft) name:@"RecCenterHeaderLeft" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goRight) name:@"RecCenterHeaderRight" object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSDictionary *)selectedDailySchedule{
    return self.dailySchedules[self.selectedDateIndex];
}

-(NSArray *)selectedMeetingAreaHours{
    return [self selectedDailySchedule][@"meeting_area_hours"];
}

-(NSInteger)numberOfItems{
    return [self selectedMeetingAreaHours].count + 1;
}

-(id)itemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return nil;
    } else {
        return [self selectedMeetingAreaHours][indexPath.row - 1];
    }
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RURecCenterHoursHeaderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RURecCenterHoursHeaderTableViewCell class])];
    [tableView registerClass:[RURecCenterMeetingAreaTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RURecCenterMeetingAreaTableViewCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return NSStringFromClass([RURecCenterHoursHeaderTableViewCell class]);
    } else {
        return NSStringFromClass([RURecCenterMeetingAreaTableViewCell class]);
    }
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        RURecCenterHoursHeaderTableViewCell *headerCell = cell;
        
        NSString *title = [self selectedDailySchedule][@"date"];
        
        if (self.todaysDateIndex >= 0) {
            if (self.selectedDateIndex == self.todaysDateIndex) {
                title = @"Today";
            } else if (self.selectedDateIndex == self.todaysDateIndex - 1) {
                title = @"Yesterday";
            } else if (self.selectedDateIndex == self.todaysDateIndex + 1) {
                title = @"Tomorrow";
            }
        }
        
        headerCell.dateLabel.text = title;
        
        headerCell.leftButton.enabled = (self.selectedDateIndex > 0);
        headerCell.rightButton.enabled = (self.selectedDateIndex < self.dailySchedules.count - 1);
        
    } else {
        RURecCenterMeetingAreaTableViewCell *meetingAreaCell = cell;
        NSDictionary *item = [self itemAtIndexPath:indexPath];
        
        meetingAreaCell.areaLabel.text = item[@"area"];
        meetingAreaCell.hoursLabel.text = item[@"hours"];
    }
}

-(void)goLeft{
    self.selectedDateIndex--;
}

-(void)goRight{
    self.selectedDateIndex++;
}

-(void)setSelectedDateIndex:(NSInteger)selectedDateIndex{
    selectedDateIndex = MIN(MAX(selectedDateIndex, 0), self.dailySchedules.count - 1);
    
    DataSourceAnimationDirection direction = DataSourceAnimationDirectionNone;
    if (selectedDateIndex > _selectedDateIndex) {
        direction = DataSourceAnimationDirectionLeft;
    } else {
        direction = DataSourceAnimationDirectionRight;
    }
    
    NSInteger oldNumberOfItems = self.numberOfItems;
    _selectedDateIndex = selectedDateIndex;
    NSInteger newNumberOfItems = self.numberOfItems;
    
    [self invalidateCachedHeightsForSection:0];
    
    [self notifyBatchUpdate:^{
        if (oldNumberOfItems > newNumberOfItems) {
            [self notifyItemsRefreshedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, newNumberOfItems) inSection:0] direction:direction];
            [self notifyItemsRemovedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(newNumberOfItems, oldNumberOfItems - newNumberOfItems) inSection:0] direction:direction];
        } else if (newNumberOfItems > oldNumberOfItems) {
            [self notifyItemsRefreshedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, oldNumberOfItems) inSection:0] direction:direction];
            [self notifyItemsInsertedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(oldNumberOfItems, newNumberOfItems - oldNumberOfItems) inSection:0] direction:direction*-1];
        } else {
            [self notifyItemsRefreshedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, newNumberOfItems) inSection:0] direction:direction];
        }
    }];
}

NSString *NSStringFromDateComponents(NSDateComponents *dateComponents){
    return [NSString stringWithFormat:@"%ld/%ld/%ld",(long)dateComponents.month,(long)dateComponents.day,(long)dateComponents.year];
}

@end
