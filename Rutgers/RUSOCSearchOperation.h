//
//  RUSOCSearchIndexOperation.h
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUSOCSearchIndex.h"

@interface RUSOCSearchOperation : NSOperation
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithQuery:(NSString *)query searchIndex:(RUSOCSearchIndex *)searchIndex NS_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly) NSArray *subjects;
@property (nonatomic, readonly) NSArray *courses;
@end
