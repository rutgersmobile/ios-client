//
//  EZTableViewRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ALTableViewRightDetailCell;
@class ALTableViewAbstractCell;

@interface EZTableViewRow : NSObject
-(instancetype)initWithIdentifier:(NSString *)identifier;
-(instancetype)initWithText:(NSString *)text;
-(instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText;

-(void)setupCell:(ALTableViewAbstractCell *)cell;

@property (readonly, nonatomic) NSString *identifier;
@property (nonatomic) UIFont *textFont;
@property (nonatomic) UIFont *detailTextFont;

@property (nonatomic) NSString *text;
@property (nonatomic) NSString *detailText;
@property (nonatomic) BOOL shouldHighlight;
@property (copy) void (^didSelectRowBlock)(void);
@end
