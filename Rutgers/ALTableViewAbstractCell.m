//
//  EZTableViewAbstractCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/23/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewAbstractCell.h"

@implementation ALTableViewAbstractCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.opaque = YES;
        self.contentView.opaque = YES;
        [self makeSubviews];
    }
    return self;
}
-(void)makeSubviews{
    [NSException raise:@"You need to subclass EZTableViewAbstractCell and override the makeSubviews method" format:nil];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    
    // If constraints have been set, don't do anything.

    if (!self.didSetupConstraints) {
        
        [self initializeConstraints];
        self.didSetupConstraints = YES;
    }
    
    [self makeConstraintChanges];
}
-(void)initializeConstraints{

}
-(void)makeConstraintChanges{
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutSubviews];
    
    [self didLayoutSubviews];
}
-(void)didLayoutSubviews{
    
}
@end
