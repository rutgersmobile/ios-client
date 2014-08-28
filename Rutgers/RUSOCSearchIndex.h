//
//  RUSOCSearchIndex.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUSOCSearchIndex : NSObject
-(void)resultsForQuery:(NSString *)query completion:(void(^)(NSArray *subjects, NSArray *courses))handler;
@end
