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
    }
    return self;
}
-(instancetype)initWithIdentifier:(NSString *)identifier{
    self = [super init];
    if (self) {
        self.shouldHighlight = YES;
        self.active = YES;
        self.showsDisclosureIndicator = YES;
        _identifier = identifier;
    }
    return self;
}
-(void)setupCell:(UITableViewCell *)cell{
    if (self.didSelectRowBlock && self.active && self.showsDisclosureIndicator) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}
-(NSString *)textRepresentation{
    return nil;
}
@end
