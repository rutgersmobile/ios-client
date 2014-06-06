//
//  EZTableViewRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZTableViewAbstractRow.h"

@interface EZTableViewRightDetailRow : EZTableViewAbstractRow

-(instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText;
-(instancetype)initWithText:(NSString *)text;

@property (nonatomic) NSString *text;
@property (nonatomic) UIFont *textFont;

@property (nonatomic) NSString *detailText;
@property (nonatomic) UIFont *detailTextFont;

@end
