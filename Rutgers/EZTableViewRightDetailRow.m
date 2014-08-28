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

- (instancetype)init
{
    return [self initWithIdentifier:NSStringFromClass([ALTableViewRightDetailCell class])];
}

-(instancetype)initWithText:(NSString *)text{
    self = [self init];
    if (self) {
        self.text = text;
    }
    return self;
}

-(instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText{
    self = [self initWithText:text];
    if (self) {
        self.detailText = detailText;
    }
    return self;
}

-(NSString *)textRepresentation{
    return self.text;
}

-(void)setupCell:(ALTableViewRightDetailCell *)cell{
    [super setupCell:cell];
    
    cell.textLabel.text = self.text;
    cell.detailTextLabel.text = self.detailText;
    
    if (self.active) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.userInteractionEnabled = YES;
    } else {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor grayColor];
    }

}
@end
