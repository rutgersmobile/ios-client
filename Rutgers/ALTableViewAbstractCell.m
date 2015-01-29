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
        
        //self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
     
        [self initializeSubviews];
        
        [UIView autoSetPriority:999 forConstraints:^{
            [self initializeConstraints];
        }];
        
        [self updateFonts];
    }
    return self;
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

-(void)initializeSubviews{
    
}

-(void)initializeConstraints{
    
}

-(void)updateFonts{
    
}
@end
