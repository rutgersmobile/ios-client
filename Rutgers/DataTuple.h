//
//  DataTuple.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataTuple : NSObject
-(instancetype)initWithTitle:(NSString *)title object:(id)object;
+(instancetype)tupleWithTitle:(NSString *)title object:(id)object;
@property NSString *title;
@property id object;
@end
