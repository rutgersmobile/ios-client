//
//  EZTableViewTextRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewAbstractRow.h"

@interface EZTableViewTextRow : EZTableViewAbstractRow
-(instancetype)initWithAttributedText:(NSAttributedString *)attributedText;
-(instancetype)initWithText:(NSString *)text;

@property (nonatomic) NSAttributedString *attributedText;
@property (nonatomic) NSString *text;
@end
