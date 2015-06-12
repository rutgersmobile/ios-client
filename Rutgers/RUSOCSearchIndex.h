//
//  RUSOCSearchIndex.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUSOCSearchIndex : NSObject
@property (nonatomic) NSDictionary *ids;
@property (nonatomic) NSDictionary *subjects;
@property (nonatomic) NSDictionary *courses;
@property (nonatomic) NSDictionary *abbreviations;
-(void)performWhenIndexLoaded:(void(^)(NSError *error))handler;
@end
