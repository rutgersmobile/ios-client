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
-(NSString *)textRepresentation;
@property (readonly, nonatomic) NSString *identifier;
@property (nonatomic) BOOL shouldHighlight;
@property (nonatomic) BOOL shouldCopy;
@property (copy) dispatch_block_t didSelectRowBlock;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL showsDisclosureIndicator;
@end
