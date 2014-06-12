//
//  EZCollectionViewItem.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZCollectionViewAbstractItem : NSObject
-(instancetype)initWithIdentifier:(NSString *)identifier;
-(void)setupCell:(UICollectionViewCell *)cell;
@property (readonly, nonatomic) NSString *identifier;

@property (nonatomic) BOOL shouldHighlight;
@property (copy) void (^didSelectItemBlock)(void);
@end
