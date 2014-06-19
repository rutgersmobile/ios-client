//
//  RUSportsPlayer.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUSportsPlayer : NSObject
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *initials;
@property (nonatomic) NSURL *imageUrl;
@property (nonatomic) NSString *jerseyNumber;
@property (nonatomic) NSString *physique;
@property (nonatomic) NSString *position;
@property (nonatomic) NSString *hometown;
@end
