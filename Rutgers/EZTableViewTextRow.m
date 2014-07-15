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
-(instancetype)initWithString:(NSString *)string{
    self = [self init];
    if (self) {
        self.string = string;
    }
    return self;
}
-(NSString *)string{
    return self.attributedString.string;
}
-(NSString *)textRepresentation{
    return self.string;
}
-(void)setString:(NSString *)string{
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17]};
    self.attributedString = [[NSAttributedString alloc] initWithString:string attributes:textAttributes];
}
-(void)setupCell:(ALTableViewAbstractCell *)cell{
    [super setupCell:cell];
    cell.textLabel.attributedText = self.attributedString;
}
@end
