//
//  EZTableViewTextRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewTextRow.h"
#import "ALTableViewAbstractCell.h"

@implementation EZTableViewTextRow
- (instancetype)init
{
    self = [super initWithIdentifier:@"ALTableViewTextCell"];
    if (self) {
        
    }
    return self;
}
-(instancetype)initWithAttributedString:(NSAttributedString *)attributedString{
    self = [self init];
    if (self) {
        self.attributedString = attributedString;
    }
    return self;
}
-(NSString *)stringForTextSearch{
    return self.attributedString.string;
}
-(void)setupCell:(ALTableViewAbstractCell *)cell{
    [super setupCell:cell];
    cell.textLabel.attributedText = self.attributedString;
}
@end
