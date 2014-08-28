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
        [self.contentView autoRemoveConstraintsAffectingView];
        
        //self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
       // self.opaque = YES;
       // self.contentView.opaque = YES;
        [self initializeSubviews];
        [self initializeConstraints];
        [self updateFonts];
    }
    return self;
}

-(void)initializeSubviews{
    
}

-(void)initializeConstraints{
    
}

-(void)updateFonts{
    
}
@end
