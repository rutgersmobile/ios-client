//
//  NSArray+SearchAndSort.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Sort)
-(NSArray *)sortByKeyPath:(NSString *)keyPath;
-(NSArray *)sortByKeyPath:(NSString *)keyPath beginsWith:(NSString *)string;
@end
