//
//  RURecCenterMeetingAreaRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterMeetingAreaRow.h"
@interface RURecCenterMeetingAreaRow ()
@property NSString *date;
@end

@implementation RURecCenterMeetingAreaRow
-(id)initWithArea:(NSString *)area dates:(NSDictionary *)dates{
    self = [super initWithIdentifier:@"RURecCenterHoursHeaderTableViewCell"];
    if (self) {
        
    }
    return self;
}

@end
