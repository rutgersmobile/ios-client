//
//  EZTableViewAbstractRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewAbstractRow.h"

@implementation EZTableViewAbstractRow
- (instancetype)init
{
    self = [self initWithIdentifier:@"ALTableViewRightDetailCell"];
    if (self) {
        self.active = YES;
    }
    return self;
}
-(instancetype)initWithIdentifier:(NSString *)identifier{
    self = [super init];
    if (self) {
        self.shouldHighlight = YES;
        _identifier = identifier;
    }
    return self;
}
-(void)setupCell:(UITableViewCell *)cell{
    if (self.didSelectRowBlock && self.active) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}
-(NSString *)textString{
    return nil;
}
@end
