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
@property (nonatomic) NSAttributedString *attributedString;
@end
