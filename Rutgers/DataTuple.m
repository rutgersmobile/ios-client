//
//  DataTuple.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DataTuple.h"

@implementation DataTuple
-(instancetype)initWithTitle:(NSString *)title object:(id)object{
    self = [super init];
    if (self) {
        self.title = title;
        self.object = object;
    }
    return self;
}
+(instancetype)tupleWithTitle:(NSString *)title object:(id)object{
    return [[self alloc] initWithTitle:title object:object];
}
@end
