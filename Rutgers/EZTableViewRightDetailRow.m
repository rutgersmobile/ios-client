//
//  EZTableViewRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewRightDetailRow.h"
#import "ALTableViewRightDetailCell.h"

@interface EZTableViewRightDetailRow ()
@end

@implementation EZTableViewRightDetailRow

-(instancetype)initWithText:(NSString *)text{
    self = [self init];
    if (self) {
        self.text = text;
        self.textFont = [UIFont systemFontOfSize:18];
    }
    return self;
}

-(instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText{
    self = [self init];
    if (self) {
        self.textFont = [UIFont systemFontOfSize:17];
        self.text = text;
        self.detailText = detailText;
    }
    return self;
}
-(NSString *)textString{
    return self.text;
}

-(void)setupCell:(ALTableViewRightDetailCell *)cell{
    [super setupCell:cell];
    
    cell.textLabel.font = self.textFont;
    cell.textLabel.text = self.text;
    cell.detailTextLabel.text = self.detailText;
    cell.detailTextLabel.font = self.detailTextFont;
    
    
    if (self.active) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.userInteractionEnabled = YES;
    } else {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }

}
@end
