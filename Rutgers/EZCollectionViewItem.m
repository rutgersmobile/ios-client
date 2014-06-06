//
//  EZCollectionViewItem.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewItem.h"
#import "EZCollectionViewCell.h"

@implementation EZCollectionViewItem

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
    self = [self initWithIdentifier:@"EZCollectionViewCell"];
    if (self) {
        
    }
    return self;
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
-(void)setupCell:(EZCollectionViewCell *)cell{
    cell.textLabel.text = self.text;
}
@end
