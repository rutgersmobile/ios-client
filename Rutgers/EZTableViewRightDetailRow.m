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
/*
-(void)setText:(NSString *)text{
    _text = text;
    if ([_text isEqualToString:@""]) {
        _text = nil;
    }
}

-(void)setDetailText:(NSString *)detailText{
    _detailText = detailText;
    if ([_detailText isEqualToString:@""]) {
        _detailText = nil;
    }
}
*/
-(void)setupCell:(ALTableViewRightDetailCell *)cell{
    [super setupCell:cell];
    if (self.detailText) {
        cell.textLabel.numberOfLines = 1;
        cell.detailTextLabel.text = self.detailText;
        cell.detailTextLabel.font = self.detailTextFont;
    } else {
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.text = nil;
    }
    
    if (self.active) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.userInteractionEnabled = YES;
    } else {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }

    cell.textLabel.font = self.textFont;
    cell.textLabel.text = self.text;
}
@end
