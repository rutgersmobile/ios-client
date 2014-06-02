//
//  EZTableViewRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewRow.h"
#import "ALTableViewRightDetailCell.h"

@interface EZTableViewRow ()
@end

@implementation EZTableViewRow
-(instancetype)initWithIdentifier:(NSString *)identifier{
    self = [super init];
    if (self) {
        self.textFont = [UIFont systemFontOfSize:17];
        self.shouldHighlight = YES;
        _identifier = identifier;
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithIdentifier:@"ALTableViewRightDetailCell"];
    if (self) {
        
    }
    return self;
}

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
        self.text = text;
        self.detailText = detailText;
    }
    return self;
}

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

-(void)setupCell:(UITableViewCell *)cell{
    if (self.detailText) {
        cell.textLabel.numberOfLines = 1;
        cell.detailTextLabel.text = self.detailText;
    } else {
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.text = nil;
    }
    
    cell.textLabel.font = [self textFont];
    cell.textLabel.text = self.text;

    if (self.didSelectRowBlock) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}
@end
