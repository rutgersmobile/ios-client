//
//  RURecCenterHoursHeaderRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterHoursHeaderRow.h"
#import "RURecCenterHoursHeaderTableViewCell.h"

@interface RURecCenterHoursHeaderRow ()
@end

@implementation RURecCenterHoursHeaderRow
-(id)init{
    self = [super initWithIdentifier:NSStringFromClass([RURecCenterHoursHeaderTableViewCell class])];
    if (self) {
        
    }
    return self;
}
-(void)setupCell:(RURecCenterHoursHeaderTableViewCell *)cell{
    cell.dateLabel.text = self.date;
    cell.leftButton.enabled = self.leftButtonEnabled;
    cell.rightButton.enabled = self.rightButtonEnabled;
}
@end
