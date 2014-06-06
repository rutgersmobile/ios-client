//
//  EZCollectionViewItem.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EZCollectionViewCell;

@interface EZCollectionViewItem : NSObject
-(instancetype)initWithIdentifier:(NSString *)identifier;
-(instancetype)initWithText:(NSString *)text;
-(instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText;

-(void)setupCell:(EZCollectionViewCell *)cell;
@property (nonatomic) BOOL showsEllipses;

@property (readonly, nonatomic) NSString *identifier;
@property (nonatomic) UIFont *textFont;
@property (nonatomic) UIFont *detailTextFont;

@property (nonatomic) NSString *text;
@property (nonatomic) NSString *detailText;
@property (nonatomic) BOOL shouldHighlight;
@property (copy) void (^didSelectRowBlock)(void);
@end
