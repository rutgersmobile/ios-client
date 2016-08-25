//
//  NSPredicate+SearchPredicate.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (SearchPredicate)
+(NSPredicate *)predicateForQuery:(NSString *)query keyPath:(NSString *)keyPath;
@end
