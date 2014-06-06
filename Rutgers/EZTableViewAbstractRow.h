//
//  EZTableViewAbstractRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ALTableViewAbstractCell;

@interface EZTableViewAbstractRow : NSObject
-(instancetype)initWithIdentifier:(NSString *)identifier;

-(void)setupCell:(ALTableViewAbstractCell *)cell;
@property (readonly, nonatomic) NSString *identifier;
@property (nonatomic) BOOL shouldHighlight;
@property (copy) void (^didSelectRowBlock)(void);
@property (nonatomic) BOOL active;
@end
