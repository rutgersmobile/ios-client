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
-(instancetype)initWithQuery:(NSString *)query searchIndex:(RUSOCSearchIndex *)searchIndex;
@property (nonatomic) NSArray *subjects;
@property (nonatomic) NSArray *courses;
@end
