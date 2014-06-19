//
//  EZTableViewTextRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewAbstractRow.h"

@interface EZTableViewTextRow : EZTableViewAbstractRow
-(instancetype)initWithAttributedString:(NSAttributedString *)attributedString;
-(instancetype)initWithString:(NSString *)string;

@property (nonatomic) NSAttributedString *attributedString;
@property (nonatomic) NSString *string;
@end
