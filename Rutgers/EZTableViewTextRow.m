//
//  EZTableViewTextRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewTextRow.h"
#import "ALTableViewTextCell.h"

@implementation EZTableViewTextRow
- (instancetype)init
{
    self = [super initWithIdentifier:NSStringFromClass([ALTableViewTextCell class])];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithAttributedText:(NSAttributedString *)attributedText{
    self = [self init];
    if (self) {
        self.attributedText = attributedText;
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

-(NSString *)text{
    return self.attributedText.string;
}

-(NSString *)textRepresentation{
    return self.text;
}

-(void)setText:(NSString *)text{
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17]};
    self.attributedText = [[NSAttributedString alloc] initWithString:text attributes:textAttributes];
}

-(void)setupCell:(ALTableViewAbstractCell *)cell{
    [super setupCell:cell];
    cell.textLabel.attributedText = self.attributedText;
}
@end
