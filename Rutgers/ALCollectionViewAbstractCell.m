//
//  ALCollectionViewAbstractCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALCollectionViewAbstractCell.h"

@implementation ALCollectionViewAbstractCell

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
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
