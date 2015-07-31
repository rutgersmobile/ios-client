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

-(instancetype)init{
    return [self initWithTitle:nil object:nil];
}

+(instancetype)tupleWithTitle:(NSString *)title object:(id)object{
    return [[self alloc] initWithTitle:title object:object];
}

-(NSString *)description{
    return self.title;
}
-(id)objectForKeyedSubscript:(id<NSCopying>)key{
    return [self.object objectForKeyedSubscript:key];
}
@end
