//
//  RURecCenterMeetingAreaRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterMeetingAreaRow.h" 
#import "RURecCenterMeetingAreaTableViewCell.h"
@interface RURecCenterMeetingAreaRow ()
@property (nonatomic) NSString *area;
@property (nonatomic) NSDictionary *times;
@end

@implementation RURecCenterMeetingAreaRow
-(id)initWithArea:(NSString *)area times:(NSDictionary *)times{
    self = [super initWithIdentifier:@"RURecCenterMeetingAreaTableViewCell"];
    if (self) {
        self.area = area;
        self.times = times;
    }
    return self;
}
-(void)setupCell:(RURecCenterMeetingAreaTableViewCell *)cell{
    cell.areaLabel.text = self.area;
    cell.timesLabel.text = [self.times[self.date] stringByReplacingOccurrencesOfString:@", " withString:@",\n"];
}
@end
